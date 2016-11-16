function G = calc_G(battery, motor, prop, foil, rod)
    
    [failure, powerUse] = run_qprop(battery, motor, prop, foil, rod);   
    
    % Not using this yet, but here it is
    totalCost = battery.Cost + motor.Cost*4+4*rod.Cost;

    flightTime = battery.Energy / powerUse;

    if failure
        G = 0;
    else
        G = flightTime;
    end
end