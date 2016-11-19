 function [rewards, G, flightTime, constraints] = compute_rewards(useD, ...
     penalty, cell, battery, motor, prop, foil, rod, mat, avgCell, avgMotor, ...
     avgProp, avgFoil, avgRod, avgMat)
    % I included the material in the inputs because I didn't know how to
    % compute the counterfactual rod otherwise... -B
    
    % Global System Performance
    [G, flightTime, constraints] = calc_G(penalty, battery, motor, prop, foil, rod);
    
    %ostensibly this is also where we calculate constraint penalties.
    
    if ~useD % if NOT using difference reward
        rewards = ones(14, 1) * G; % Just return G for all rewards
    else
        rewards = zeros(14, 1);
        
        counterProp.diameter = prop.diameter; % diameter (inch->m)
        counterProp.angleRoot = prop.angleRoot; % blade angle at root
        counterProp.angleTip = prop.angleTip; % blade angle at tip
        counterProp.chordRoot = prop.chordRoot; % chord at root (inch->m)
        counterProp.chordTip = prop.chordTip; % chord at tip (inch->m)

        counterRod.mat = mat.Type;
        counterRod.Ymod = mat.Ymod;
        counterRod.Sut = mat.Sut;
        counterRod.Length = rod.Length;
        counterRod.Dia = rod.Dia;
        counterRod.Thick = rod.Thick;
        counterRod.Area = rod.Area;
        counterRod.Amoment=pi*(rod.Dia^2-(rod.Dia-rod.Thick)^2)/64; %area moment of inertia
        counterRod.Stiffness=(rod.Length^3/(3*rod.Amoment*1e9*mat.Ymod))^-1;
        counterRod.Vol = rod.Vol;
        counterRod.Mass = rod.Vol*mat.Dens;
        counterRod.Cost = mat.Cost*rod.Vol;
        
        for ag = 1:14
            switch ag
                case 1 % want to replace cell with avgCell
                    counterBattery.sConfigs = battery.sConfigs;
                    counterBattery.pConfigs = battery.pConfigs;
                    numCells = counterBattery.sConfigs * counterBattery.pConfigs;
                    counterBattery.Cost = avgCell.Cost * numCells;
                    counterBattery.Mass = avgCell.Mass * numCells;
                    counterBattery.Volt = 3.7 * counterBattery.sConfigs; % 3.7V is nominal voltage 
                    counterBattery.Cap = avgCell.Cap * counterBattery.pConfigs; % total capacity is cell cap times parallel configs
                    counterBattery.C = avgCell.C;
                    counterBattery.Imax = counterBattery.C.*counterBattery.Cap; % convert to amps
                    counterBattery.Energy = counterBattery.Volt * counterBattery.Cap * 3600; % Amps * voltage

                    rewards(ag, 1) = G - calc_G(penalty, counterBattery, motor, prop, foil, rod);
                case 2 % replace sConfigs with 2
                    counterBattery.sConfigs = 2;
                    counterBattery.pConfigs = battery.pConfigs;
                    numCells = counterBattery.sConfigs * counterBattery.pConfigs;
                    counterBattery.Cost = cell.Cost * numCells;
                    counterBattery.Mass = cell.Mass * numCells;
                    counterBattery.Volt = 3.7 * counterBattery.sConfigs; % 3.7V is nominal voltage 
                    counterBattery.Cap = cell.Cap * counterBattery.pConfigs; % total capacity is cell cap times parallel configs
                    counterBattery.C = cell.C;
                    counterBattery.Imax = counterBattery.C.*counterBattery.Cap;
                    counterBattery.Energy = counterBattery.Volt * counterBattery.Cap * 3600; % Amps * voltage

                    rewards(ag, 1) = G - calc_G(penalty, counterBattery, motor, prop, foil, rod);
                case 3 % replace pConfigs with 1
                    counterBattery.sConfigs = battery.sConfigs;
                    counterBattery.pConfigs = 1;
                    numCells = counterBattery.sConfigs * counterBattery.pConfigs;
                    counterBattery.Cost = cell.Cost * numCells;
                    counterBattery.Mass = cell.Mass * numCells;
                    counterBattery.Volt = 3.7 * counterBattery.sConfigs; % 3.7V is nominal voltage 
                    counterBattery.Cap = cell.Cap * counterBattery.pConfigs; % total capacity is cell cap times parallel configs
                    counterBattery.C = cell.C;
                    counterBattery.Imax = counterBattery.C.*counterBattery.Cap; % convert to amps
                    counterBattery.Energy = counterBattery.Volt * counterBattery.Cap * 3600; % Amps * voltage

                    rewards(ag, 1) = G - calc_G(penalty, counterBattery, motor, prop, foil, rod);
                case 4
                    rewards(ag, 1) = G - calc_G(penalty, battery, avgMotor, prop, foil, rod);
                case 5 % foil
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, avgFoil, rod);
                case 6
                    counterProp.diameter = avgProp.diameter; % diameter (inch->m)
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 7
                    counterProp.angleRoot = avgProp.angleRoot; % blade angle at root
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 8
                    counterProp.angleTip = avgProp.angleTip; % blade angle at tip
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 9
                    counterProp.chordRoot = avgProp.chordRoot; % chord at root (inch->m)
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 10
                    counterProp.chordTip = avgProp.chordTip; % chord at tip (inch->m)
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, counterProp, foil, rod);
                case 11 % material
                    % Counterfact rod's material replaced with avg material
                    counterRod.Ymod = avgMat.Ymod;
                    counterRod.Sut = avgMat.Sut;
                    counterRod.Stiffness=(counterRod.Length^3/(3*counterRod.Amoment*1e9*avgMat.Ymod))^1;
                    counterRod.Mass = counterRod.Vol*avgMat.Dens;
                    counterRod.Cost = avgMat.Cost*counterRod.Vol;
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
                case 12 % Rod length
                    % Counterfact rod's length is replaced with avg rod length
                    counterRod.Length = avgRod.Length;
                    counterRod.Stiffness=(counterRod.Length^3/(3*counterRod.Amoment*1e9*mat.Ymod))^-1;
                    counterRod.Vol = counterRod.Length*counterRod.Area;
                    counterRod.Mass = counterRod.Vol*mat.Dens;
                    counterRod.Cost = mat.Cost*counterRod.Vol;
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
                case 13
                    % Counterfact rod's dia replaced with avg rod's dia
                    counterRod.Dia = avgRod.Dia;
                    counterRod.Area = .5*pi*(counterRod.Dia^2-(counterRod.Dia-counterRod.Thick)^2);
                    counterRod.Amoment=pi*(counterRod.Dia^2-(counterRod.Dia-counterRod.Thick)^2)/64; %area moment of inertia
                    counterRod.Stiffness=(counterRod.Length^3/(3*counterRod.Amoment*1e9*mat.Ymod))-1;
                    counterRod.Vol = counterRod.Length*counterRod.Area;
                    counterRod.Mass = counterRod.Vol*mat.Dens; % in kg
                    counterRod.Cost = mat.Cost*counterRod.Vol;
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
                case 14
                    % thickness replaced by avg rod's thickness
                    counterRod.Thick = avgRod.Thick;
                    counterRod.Area = .5*pi*(counterRod.Dia^2-(counterRod.Dia-counterRod.Thick)^2);
                    counterRod.Amoment=pi*(counterRod.Dia^2-(counterRod.Dia-counterRod.Thick)^2)/64; %area moment of inertia
                    counterRod.Stiffness=(counterRod.Length^3/(3*counterRod.Amoment*1e9*mat.Ymod))^-1;
                    counterRod.Vol = counterRod.Length*counterRod.Area;
                    counterRod.Mass = counterRod.Vol*mat.Dens; % in kg
                    counterRod.Cost = mat.Cost*counterRod.Vol;
                    rewards(ag, 1) = G - calc_G(penalty, battery, motor, prop, foil, counterRod);
            end
        end   
    end
end