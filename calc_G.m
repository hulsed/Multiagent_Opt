function [G,flightTime,constraints, perf, hover] = calc_G(penalty,scaleFactor, battery, motor, prop, foil, rod)
    
    [perf] = run_qprop(battery, motor, prop, foil);   
    [hover,failure]=find_oper(battery, motor, prop, foil, rod,perf);
    
    % Calculation of Constraints (only possible with performance data) 
    if ~failure
        [constraints,conRewards]=calc_constraints(penalty, battery,motor,prop,foil,rod,hover);
    else
        conRewards=zeros(1,7); %7 is the number of constraints used.
        constraints=zeros(1,7);
    end
       
    % Calculation of Objectives
    totalCost = battery.Cost + motor.Cost*4+4*rod.Cost;
    flightTime = battery.Energy /(4*hover.pelec); %note: power use is for EACH motor.

    if failure
        G = 0;
    else
        G = max(-100,(flightTime+sum(conRewards))/scaleFactor); 
        %Note: Truncating possible negative performance to just below zero.
        %This should help with overly high rewards.
end