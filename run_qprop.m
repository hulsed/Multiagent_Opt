function [perf]=run_qprop(battery, motor, prop, foil, SAVE)

    vel=0.0;
    numPts=8;
    voltMax=round(battery.Volt+3.7);
    voltIncr=voltMax/numPts;

        %write files
        write_propfile(prop,foil);
        write_motorfile(motor);
        
        

        %converting parameters to strings.
        velstr=num2str(vel);
        if velstr=='0'
            velstr='0.0';
        end
        maxvoltagestr=num2str(voltMax);
        voltincrstr=num2str(voltIncr);
        
        
        velStr='0.0';       %velocity (m/s)    
        rpmStr='0';         %rpm
        voltStr=['0,', maxvoltagestr,',', voltincrstr];        % voltage
        dBetaStr='0';       %Dbeta, the pitch-change angle (for adjustable pitch motors)
        thrustStr='0';   %Thrust (N)
        torqueStr='0';      %Torque (N-m)
        ampsStr='0';        %Amps (A)
        peleStr='0';        %Electrical Power Used
        mode='multipoint'; % specify singlepoint or multipoint runs
        
        
                
        perf=call_qprop(velStr, rpmStr, voltStr, dBetaStr, thrustStr, torqueStr, ampsStr, peleStr, mode);
end
