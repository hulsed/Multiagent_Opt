function battery = create_battery(cell, sConfigs, pConfigs)
    battery.cell = cell;
    battery.sConfigs = sConfigs; % number of serial configurations
    battery.pConfigs = pConfigs; % number of parallel configurations

    % Make battery struct. Properties are accessible with .
    numCells = battery.sConfigs * battery.pConfigs;
    battery.Cost = battery.cell.Cost * numCells;
    battery.Mass = battery.cell.Mass * numCells;
    battery.Volt = 3.7 * battery.sConfigs; % 3.7V is nominal voltage 
    battery.Cap = battery.cell.Cap * battery.pConfigs; % total capacity is cell cap times parallel configs
    battery.C = battery.cell.C;
    battery.Imax = battery.C.*battery.Cap;
    battery.Energy = battery.Volt * battery.Cap * 3600; % Amps * voltage
end