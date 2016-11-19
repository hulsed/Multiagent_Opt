 function [rewards, G, flightTime, constraints] = compute_rewards(useD, ...
     penalty, battery, motor, prop, foil, rod)
    % I included the material in the inputs because I didn't know how to
    % compute the counterfactual rod otherwise... -B
    
    % Global System Performance
    [G, flightTime, constraints] = calc_G(penalty, battery, motor, prop, foil, rod);
    
    %ostensibly this is also where we calculate constraint penalties.
    
    if ~useD % if NOT using difference reward
        rewards = ones(14, 1) * G; % Just return G for all rewards
    else
        rewards = zeros(14, 1);
        
        % Create "average" components (moved this from main)
        [avgCell, avgMotor, avgProp, avgFoil, avgRod] = counter_calc(batteryData, ...
            motorData, propData, foilData, rodData, matData);s
        
        for ag = 1:14
            switch ag
                case 1 % want to replace cell with avgCell
                    counterBattery = create_battery(avgCell, battery.sConfigs, battery.pConfigs);
                    rewards(ag, 1) = G - calc_G(penalty, counterBattery, motor, prop, foil, rod);
                case 2 % replace sConfigs with 2
                    counterBattery = create_battery(battery.cell, 2, battery.pConfigs);
                    rewards(ag, 1) = G - calc_G(penalty, counterBattery, motor, prop, foil, rod);
                case 3 % replace pConfigs with 1
                    counterBattery = create_battery(battery.cell, battery.sConfigs, 1);
                    rewards(ag, 1) = G - calc_G(penalty, counterBattery, motor, prop, foil, rod);
                case 4 % replace motor with its average counterpart
                    rewards(ag, 1) = G - calc_G(penalty, battery, avgMotor, prop, foil, rod);
                case 5 % replace foil with its average counterpart
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, avgFoil, rod);
                case 6
                    counterProp = create_prop(avgProp.diameter, prop.angleRoot, ...
                        prop.angleTip, prop.chordRoot, prop.chordTip);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 7
                    counterProp = create_prop(prop.diameter, avgProp.angleRoot, ...
                        prop.angleTip, prop.chordRoot, prop.chordTip);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 8
                    counterProp = create_prop(prop.diameter, avgProp.angleRoot, ...
                        avgProp.angleTip, prop.chordRoot, prop.chordTip);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 9
                    counterProp = create_prop(prop.diameter, prop.angleRoot, ...
                        prop.angleTip, avgProp.chordRoot, prop.chordTip);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 10
                    counterProp = create_prop(prop.diameter, prop.angleRoot, ...
                        prop.angleTip, prop.chordRoot, avgProp.chordTip);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 11 % material
                    % Counterfact rod's material replaced with avg material
                    counterRod = create_rod(avgRod.mat, rod.Length, rod.Dia, rod.Thick);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
                case 12 % Rod length
                    % Counterfact rod's length is replaced with avg rod length
                    counterRod = create_rod(rod.mat, avgRod.Length, rod.Dia, rod.Thick);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
                case 13
                    % Counterfact rod's dia replaced with avg rod's dia
                    counterRod = create_rod(rod.mat, rod.Length, avgRod.Dia, rod.Thick);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
                case 14
                    % thickness replaced by avg rod's thickness
                    counterRod = create_rod(rod.mat, rod.Length, rod.Dia, avgRod.Thick);
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
            end
        end   
    end
end
