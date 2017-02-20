 %function [rewards, cUpdate, G,Objectives, constraints,hover] = compute_rewards(useD, ...
 %    penalty,scaleFactor, battery, motor, prop, foil, rod,sys,res, data)
    
    %[G, Objectives, constraints,hover] = calc_G(penalty, ...
    %    scaleFactor, battery, motor, prop, foil, rod, sys);
    
    %ostensibly this is also where we calculate constraint penalties.
     function [rewards, G]=compute_rewards(actions)
     
     G=-objcfun(actions);
    
    rewards = ones(13, 1) * G; % Just return G for all rewards
    
end
