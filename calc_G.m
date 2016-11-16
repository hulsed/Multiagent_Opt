function G = calc_G(battery, motor, prop,foil,rod, counterbattery,countermotor,counterprop)
    accGravity=9.81;
    %creating motor input file
    fid = -1;
    while fid < 3
        fid = fopen([pwd '/motorfile'], 'w');
    end
    disp('writing to motorfile')
    fprintf(fid, '\n%s\n\n %d\n\n %f\n %f\n %f\n', 'derp', 1, motor.R0, motor.I0, motor.kv);
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
    % To Daniel: We can leave the propfile open and it will append
    % automatically
    %fclose(fid2);
    %fid3=fopen('propfile', 'a');
    format3='%f %f %f\n';
    printdata=[radiusvect',chordvect', anglevect'];
    fprintf(fid2, format3, printdata(:,:)');
    fclose(fid2);
    
    totMass = 4*motor.Mass + battery.Mass+4*rod.Mass;
    thrustReq = totMass*accGravity;
    totalCost = battery.Cost + motor.Cost*4+4*rod.Mass; % + propCost*4
    % For now, we'll assume propeller is constant
    [failure, powerUse] = run_qprop(battery.Volt, thrustReq, battery.Imax, motor.Imax);
    
    flightTime = battery.Energy / powerUse;

    if failure
        G = 0;
    else
        G = flightTime;
    end
end