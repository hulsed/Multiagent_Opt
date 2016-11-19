function battery = design_battery(actions, batteryData)
    % cell that was chosen, contains data
    temp = batteryData(actions(1), :);
    cell.Cost = temp(1); cell.Cap = temp(2) / 1000; 
    cell.C = temp(3); cell.Mass = temp(4) / 1000;

    battery = create_battery(cell, double(actions(2)), double(actions(3)));
end