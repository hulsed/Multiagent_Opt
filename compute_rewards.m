     function [rewards, G]=compute_rewards(actions,funchandle)  
     G=-funchandle(actions);
     rewards = ones(13, 1) * G; % Just return G for all rewards
    
end
