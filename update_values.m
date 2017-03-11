% Using the foundMerit received by each agent, update their Q-tables

% INPUTS
% expMerit - cell array of Q-tables, one for each variable
% foundMerit - vector of foundMerit, element i is the reward received by agent i
% x - vector of integers, element i is the action taken by agent i
% alpha - the learning rate, 0 < alpha <= 1

% OUTPUTS
% The expMerit with updated Q-tables
function [expMerit, learned] = update_values(expMerit, foundMerit, alpha, x, learnmode)
    
    learned=0;
    % Iterate through variables
    for ag = 1:numel(expMerit)
        % Get the current merit of the parameter value chosen in previous state
        Q = expMerit{ag}(x(ag));
        
            switch learnmode
                case 'RL'      
            expMerit{ag}( x(ag)) = Q + alpha*(foundMerit(ag) - Q);
                case 'best'
                    if Q>foundMerit(ag)
                       learned=1;
                    end
                    expMerit{ag}(x(ag)) = min(Q,foundMerit(ag));
            end
    end
end