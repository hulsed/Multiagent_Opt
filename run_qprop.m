function [fail,elec_power_used]=run_qprop(battery, motor, prop, foil)

    % I'm breaking my own convention for this variable
    % Instead of camelCase, I'm using an underscore. I confess my sins.
    % But I hope to atone for them through trial by combat (of a seahorse)
    % Although in my defense, this variable KINDA acts like a function
    % (it's a mapping, after all)
    persistent qprop_map % persistent keyword means variable is not "forgotten"
    if isempty(qprop_map)
        qprop_map = containers.Map; % Initialize as a map
        % IN CASE THIS NEEDS TO BE CLEARED:
        % >> clear run_qprop
    end

    
        
    
    totMass = 4*motor.Mass + battery.Mass;
    thrust_req = totMass*9.81; % Let's just always assume accel of gravity is 9.81

    vel=0.0;

    volt_incr=1;

%     vel battery.Volt volt_incr thrust_req
%     motor.R0, motor.I0, motor.kv
%     foil.Cl0, foil.Cla, foil.Clmin, foil.Clmax, foil.Cd0, foil.Cd2, foil.Clcd0, foil.Reref, foil.Reexp,
    % Combine all inputs needed for qprop (including those from motorfile
    % and propfile)
    qpropVars = [vel battery.Volt volt_incr thrust_req ...
        motor.R0 motor.I0 motor.kv foil.Cl0, foil.Cla, foil.Clmin, ...
        foil.Clmax foil.Cd0 foil.Cd2 foil.Clcd0 foil.Reref foil.Reexp];
    qpropVars = num2str(qpropVars, '%.4f ');
    % Check if the input is already in our map
    if ismember(qpropVars, keys(qprop_map))
        % If it is, GIMME!
        disp('Found output!')
        qpropoutput = qprop_map(qpropVars);
    else
        % If not, we'll need to consult with QProp
        disp('Didn''t find output')
        %creating motor input file
        fid = -1;
        while fid < 3
            fid = fopen([pwd '/motorfile'], 'w');
        end
        format = '\n%s\n\n %d\n\n %f\n %f\n %f\n';
        fprintf(fid, format, 'derp', 1, motor.R0, motor.I0, motor.kv);
        fclose(fid);
        %creating propeller input file
        %generating propeller geometry
        sects=20;
        radius=prop.diameter/2;
        root=0.02;
        radiusvect=linspace(root,radius,sects);
        anglevect=prop.angleRoot+radiusvect*(prop.angleTip-prop.angleRoot)/radius;
        chordvect=prop.chordRoot+radiusvect*(prop.chordTip-prop.chordRoot)/radius;
        %appending airfoil data
        fid2 = -1;
        while fid2 < 3
            fid2 = fopen([pwd '/propfile'], 'w');
        end
        format2='%s\n%s\n\n%d\n\n%f %f\n%f %f\n\n%f %f %f\n%f %f\n\n%f %f %f\n%f %f %f\n\n\n';
        fprintf(fid2, format2,'1,', '',2,foil.Cl0, foil.Cla, foil.Clmin, foil.Clmax, foil.Cd0, foil.Cd2, foil.Clcd0, foil.Reref, foil.Reexp, 1, 1,1,0,0,0);
        %appending prop geometry

        format3='%f %f %f\n';
        printdata=[radiusvect',chordvect', anglevect'];
        fprintf(fid2, format3, printdata(:,:)');
        fclose(fid2);      

        %converting parameters to strings.
        velstr=num2str(vel);
        if velstr=='0'
            velstr='0.0';
        end
        max_voltagestr=num2str(battery.Volt);
        volt_incrstr=num2str(volt_incr);
        thruststr=num2str(thrust_req);

        qpropinput=['qprop.exe propfile motorfile ', velstr, ' 0',' 0',',', ...
            max_voltagestr,',',volt_incrstr, ' 0 ' thruststr, ' 0 0 0 ["]' ];

        %Note about qprop syntax:
        %The input looks like
        %qprop propfile motorfile vel rpm volt dBeta Thrust Torque Amps Pele 
        % 0 means unspecified
        % to iterate over values, replace a single value with min,max,incr
        pause(0.05)
        diary qpropoutput
        system(qpropinput);
        diary OFF
        scantext = -1;
        while scantext < 3
            scantext=fopen('qpropoutput');
        end
        qpropoutput=textscan(scantext, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Headerlines', 17);
        % Add the output to the map so we can remember it
        qprop_map(qpropVars) = qpropoutput;
        fclose('all');
        delete('qpropoutput')
    end
    % Whichever way we got the output of QProp, get our individual outputs
    velocity_qout=qpropoutput{1};
    rpm_qout=qpropoutput{2};
    Dbeta_qout=qpropoutput{3};
    thrust_qout=qpropoutput{4};
    q_qout=qpropoutput{5};
    pshaft_qout=qpropoutput{6};
    volts_qout=qpropoutput{7};
    amps_qout=qpropoutput{8};
    effmotor_qout=qpropoutput{9};
    effprop_qout=qpropoutput{10};
    adv_qout=qpropoutput{11};
    ct_qout=qpropoutput{12};
    cp_qout=qpropoutput{13};
    dv_qout=qpropoutput{14};
    eff_qout=qpropoutput{15};
    pelec_qout=qpropoutput{16};
    pprop_qout=qpropoutput{17};
    clavg_qout=qpropoutput{18};
    cdavg_qout=qpropoutput{19};

    fail=0;
    
    stoptime=length(velocity_qout);
    failindex=0;
    for i=1:stoptime
        if thrust_qout(i)>=thrust_req
            hoverindex=i;
            break
        end
        failindex=i;
    end
    if failindex==stoptime || battery.Imax <= amps_qout(hoverindex) || motor.Imax <= amps_qout(hoverindex)
        fail=1;
    end

    if ~fail 
        elec_power_used=pelec_qout(hoverindex);
    else
        elec_power_used=Inf;
    end

end