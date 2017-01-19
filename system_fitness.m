function [G,constraints] = system_fitness(actions)
        
        %Residual parameters of the design
        res.mass=0.3;
        res.framewidth=0.075; %temp width of frame!
        res.planArea=res.framewidth^2;
        res.cost=50;
        res.power=5;
        %design of system and subsystems
        motorNum = actions(4); % remember motor number so we can get the right motorfile
        battery = design_battery(actions, batteryData);
        motor = design_motor(actions, motorData);
        [prop,foil] = design_prop(actions, propData, foilData);
        rod = design_rod(actions, rodData, matData, prop,res);
        sys=design_sys(battery, motor, prop, foil, rod, res, motorNum);
        %performance calculation
        [rewards, cUpdate, G, Objectives,constraints,hover] = compute_rewards(useD, penalty, ...
            scaleFactor, battery, motor, prop, foil, rod, sys,res, data);
end