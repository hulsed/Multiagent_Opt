function rewards = compute_rewards(battery, motor, prop,foil,rod, counterbattery, countermotor, counterprop)
    G = calc_G(battery, motor, prop,foil,rod, counterbattery, countermotor, ...
        counterprop);
    rewards = ones(14, ... 10 is TEMP!!!!!!!!!!
        1) * G;
    
    %ostensibly this is also where we calculate constraint penalties.
end