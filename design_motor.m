function motor = design_motor(actions, motorData)
    % temp is our motor choice
    temp =  motorData(actions(4), :);
    % For R0, convert to Ohms
    motor.kv = temp(1); 
    motor.R0 = temp(2)/1000; 
    motor.I0 = temp(3);
    motor.Imax = temp(4); 
    motor.Pmax = temp(5); 
    motor.Mass = temp(6) / 1000; 
    motor.Cost = temp(7); 
    motor.Diam = temp(8) / 1000;
    motor.planArea=(pi/4) * motor.Diam^2;
end