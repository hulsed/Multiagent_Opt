function G = calc_G(battery, motor, prop, counterbattery,countermotor,counterprop)
    accGravity=9.81;

    fid = fopen('motorfile', 'w');
    fprintf(fid, '\n%s\n\n %d\n\n %f\n %f\n %f\n', 'derp', 1, motor.R0, motor.I0, motor.kv);
    fclose(fid);
    
    totMass = 4*motor.Mass + battery.Mass;
    thrustReq = totMass*accGravity;
    totalCost = battery.Cost + motor.Cost*4; % + propCost*4
    % For now, we'll assume propeller is constant
    [failure, powerUse] = run_qprop(battery.Volt, thrustReq, battery.Imax, motor.Imax);
    
    flightTime = battery.Energy / powerUse;

    if failure
        G = 0;
    else
        G = flightTime;
    end
end