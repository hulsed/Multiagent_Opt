function [perf]=run_qprop(battery, motor, prop, foil)

    % I'm breaking my own convention for this variable
    % Instead of camelCase, I'm using an underscore. I confess my sins.
    % But I hope to atone for them through trial by combat (of a seahorse)
    % Although in my defense, this variable KINDA acts like a function
    % (it's a mapping, after all)
%     persistent qprop_map % persistent keyword means variable is not "forgotten"
%     if isempty(qprop_map) % True if it's the first time running this func
%         % If we already have a saved mapping, use that.
%         if exist('qprop_map.mat', 'file')
%             load('qprop_map.mat', 'qprop_map');
%         else
%             qprop_map = containers.Map; % Otherwise, initialize a map
%         end
%         % IN CASE THIS NEEDS TO BE CLEARED:
%         % >> clear run_qprop
%     end

    % Check if SAVE input is provided and is 1
    % If so, DO NOT RUN QPROP, but just save the mappings
%     if exist('SAVE', 'var') && SAVE == 1
%         save('qprop_map.mat', 'qprop_map');
%         disp('qprop_map saved to qprop_map.mat!')
%         return
%     end

    vel=0.0;
    numPts=8;
    volt_max=round(battery.Volt+3.7);
    volt_incr=volt_max/numPts;

%     vel battery.Volt volt_incr thrust_req
%     motor.R0, motor.I0, motor.kv
%     foil.Cl0, foil.Cla, foil.Clmin, foil.Clmax, foil.Cd0, foil.Cd2, foil.Clcd0, foil.Reref, foil.Reexp,
%     prop.diameter, prop.angleRoot, prop.angleTip, prop.chordRoot,
%     prop.chordTip
    % Combine all inputs needed for qprop (including those from motorfile
    % and propfile)
    %Note: we may not need thrust_req for this... I'm not sure it actually
    %changes the result of qprop
%     qpropVars = [vel volt_max volt_incr ...
%         motor.R0 motor.I0 motor.kv foil.Cl0, foil.Cla, foil.Clmin, ...
%         foil.Clmax foil.Cd0 foil.Cd2 foil.Clcd0 foil.Reref foil.Reexp ...
%         prop.diameter, prop.angleRoot, prop.angleTip, prop.chordRoot, ...
%         prop.chordTip];
%     qpropVars = num2str(qpropVars, '%.4f ');
%     qpropVars = regexprep(qpropVars, ' +', ' '); % remove unnecessary space
    % Check if the input is already in our map
%     if ismember(qpropVars, keys(qprop_map))
%         % If it is, GIMME!
%         disp('Found output!')
%         qpropoutput = qprop_map(qpropVars);
%     else
        % If not, we'll need to consult with QProp
%         disp('Didn''t find output in mapping, running qprop.exe')
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
        max_voltagestr=num2str(volt_max);
        volt_incrstr=num2str(volt_incr);
        %thruststr=num2str(thrust_req);

%         qpropinput=['qprop.exe propfile motorfile ', velstr, ' 0',' 0',',', ...
%             max_voltagestr,',',volt_incrstr, ' 0 0 0 0 0 ["]' ];

        % After implementing faster qprop execution, the format for
        % qpropinput below is different (above is original)
        qpropinput={'qprop.exe' 'propfile' 'motorfile' velstr '0' ['0,' ...
            max_voltagestr ',' volt_incrstr] '0' '0' '0' '0' '0' '["]'};
        %Note about qprop syntax:
        %The input looks like
        %qprop propfile motorfile vel rpm volt dBeta Thrust Torque Amps Pele 
        % 0 means unspecified
        % to iterate over values, replace a single value with min,max,incr
        
%         pause(0.05)
%         diary qpropoutput
%         system(qpropinput);
%         diary OFF

        pb = java.lang.ProcessBuilder({''});
        % The command to execute, complete with arguments
        pb.command(qpropinput);
        myProcess = pb.start();
        
        % Reads what comes out of QProp (Even though code says "Input")
        reader = java.io.BufferedReader(java.io.InputStreamReader(...
            myProcess.getInputStream()));

        % Writes to the command line, basically
        writer = java.io.BufferedWriter(java.io.OutputStreamWriter(...
                myProcess.getOutputStream()));
    
        writer.newLine; % Execute!
        writer.close; % Don't need the writer anymore, has done its job
        
        line = reader.readLine; % Start reading output from QProp
        i = 0;
        while ~isequal(line, []) % Keep reading until next line is empty
            line = char(line);
            if isequal(line, ' ') || isequal(line, '\n') || isequal(line, '') || isequal(line(1), '#')
                % Skip unimportant line, read next line and continue
                line = reader.readLine;
                continue
            end
            % Note we don't need to save any files, just read directly
            i = i + 1;
            line = line(1:length(line)); % remove newline character
            crayon = sscanf(line, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
            qpropoutput(i,:) = crayon';
            line = reader.readLine; % read next line
        end
        
%         scantext = -1;
%         while scantext < 3
%             scantext=fopen('qpropoutput');
%         end
%         qpropoutput=textscan(scantext, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Headerlines', 17);
        % Add the output to the map so we can remember it
%         qprop_map(qpropVars) = qpropoutput;
%         fclose('all');
%         delete('qpropoutput')
%     end
    % Whichever way we got the output of QProp, get our individual outputs
    perf.velocity=qpropoutput(:,1);
    perf.rpm=qpropoutput(:,2);
    perf.dbeta=qpropoutput(:,3);
    perf.thrust=qpropoutput(:,4);
    perf.q=qpropoutput(:,5);
    perf.pshaft=qpropoutput(:,6);
    perf.volts=qpropoutput(:,7);
    perf.amps=qpropoutput(:,8);
    perf.effmotor=qpropoutput(:,9);
    perf.effprop=qpropoutput(:,10);
    perf.adv=qpropoutput(:,11);
    perf.ct=qpropoutput(:,12);
    perf.cp=qpropoutput(:,13);
    perf.dv=qpropoutput(:,14);
    perf.eff=qpropoutput(:,15);
    perf.pelec=qpropoutput(:,16);
    perf.pprop=qpropoutput(:,17);
    perf.clavg=qpropoutput(:,18);
    perf.cdavg=qpropoutput(:,19);
end
