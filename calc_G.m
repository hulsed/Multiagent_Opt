function [G,flightTime,constraints] = calc_G(penalty, battery, motor, prop, foil, rod)
    
    [failure, powerUse,perf,hoverindex] = run_qprop(battery, motor, prop, foil, rod);   
    
    % Calculation of Constraints (only possible with performance data)
    if ~failure
    [constraints,conRewards]=calc_constraints(penalty, battery,motor,prop,foil,rod,perf,hoverindex);
    else
        conRewards=zeros(1,4);
        constraints=zeros(1,4);
    end
       
    % Calculation of Objectives
    totalCost = battery.Cost + motor.Cost*4+4*rod.Cost;
    flightTime = battery.Energy / powerUse;

    if failure
        G = 0;
    else
        G = flightTime+sum(conRewards);
    end
end