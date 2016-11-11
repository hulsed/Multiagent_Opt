function rewards = compute_rewards(battery, motor, prop,foil, counterbattery, countermotor, counterprop)
    G = calc_G(battery, motor, prop,foil, counterbattery, countermotor, ...
        counterprop);
    rewards = ones(10, ... 10 is TEMP!!!!!!!!!!
        1) * G;
end