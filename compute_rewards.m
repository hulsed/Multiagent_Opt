     function [rewards, G]=compute_rewards(actions)  
     G=-objcfun(actions);
     rewards = ones(13, 1) * G; % Just return G for all rewards
    
end
