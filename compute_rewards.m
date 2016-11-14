function [rewards, G] = compute_rewards(cell, battery, motor, prop, foil, avgCell, avgMotor, avgProp, avgFoil)
    % Battery calculations
    numCells = battery.sConfigs * battery.pConfigs;
    % Make battery struct. Properties are accessible with .
    battery.Cost = cell.Cost * numCells;
    battery.Mass = cell.Mass * numCells;
    battery.Volt = 3.7 * battery.sConfigs; % 3.7V is nominal voltage 
    battery.Cap = cell.Cap * battery.pConfigs; % total capacity is cell cap times parallel configs
    battery.C = cell.C;
    battery.Imax = battery.C.*battery.Cap;
    battery.Energy = battery.Volt * battery.Cap * 3600; % Amps * voltage
    
    % Global System Performance
    G = calc_G(battery, motor, prop, foil);
    rewards = zeros(10, 1);
    
    counterProp.diameter = prop.diameter; % diameter (inch->m)
    counterProp.angleRoot = prop.angleRoot; % blade angle at root
    counterProp.angleTip = prop.angleTip; % blade angle at tip
    counterProp.chordRoot = prop.chordRoot; % chord at root (inch->m)
    counterProp.chordTip = prop.chordTip; % chord at tip (inch->m)
    
    for ag = 1:10
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
                
                rewards(ag, 1) = G - calc_G(counterBattery, motor, prop, foil);
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
                
                rewards(ag, 1) = G - calc_G(counterBattery, motor, prop, foil);
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
                
                rewards(ag, 1) = G - calc_G(counterBattery, motor, prop, foil);
            case 4
                rewards(ag, 1) = G - calc_G(battery, avgMotor, prop, foil);
            case 5 % foil
                rewards(ag, 1) = G - calc_G(battery, motor, prop, avgFoil);
            case 6
                counterProp.diameter = avgProp.diameter; % diameter (inch->m)
                rewards(ag, 1) = G - calc_G(battery, motor, counterProp, foil);
            case 7
                counterProp.angleRoot = avgProp.angleRoot; % blade angle at root
                rewards(ag, 1) = G - calc_G(battery, motor, counterProp, foil);
            case 8
                counterProp.angleTip = avgProp.angleTip; % blade angle at tip
                rewards(ag, 1) = G - calc_G(battery, motor, counterProp, foil);
            case 9
                counterProp.chordRoot = avgProp.chordRoot; % chord at root (inch->m)
                rewards(ag, 1) = G - calc_G(battery, motor, counterProp, foil);
            case 10
                counterProp.chordTip = avgProp.chordTip; % chord at tip (inch->m)
                rewards(ag, 1) = G - calc_G(battery, motor, counterProp, foil);
        end
    end    
end