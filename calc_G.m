function G = calc_G(battery, motor, prop, foil)
    
    [failure, powerUse] = run_qprop(battery, motor, prop, foil);
    
    flightTime = battery.Energy / powerUse;

    if failure
        G = 0;
    else
        G = flightTime;
    end
end