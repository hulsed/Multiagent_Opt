% Using the rewards received by each agent, update their Q-tables

% INPUTS
% agents - cell array of Q-tables, one for each agent
% rewards - vector of rewards, element i is the reward received by agent i
% actions - vector of integers, element i is the action taken by agent i
% alpha - the learning rate, 0 < alpha <= 1

% OUTPUTS
% The agents with updated Q-tables
function [agents, learned] = update_values(agents, rewards, alpha, actions, learnmode)
    
    learned=0;
    % Iterate through agents
    for ag = 1:numel(agents)
        % Get the current value of the action that agent ag took in previous state
        Q = agents{ag}(actions(ag));
        
            switch learnmode
                case 'RL'      
            agents{ag}( actions(ag)) = Q + alpha*(rewards(ag) - Q);
                case 'best'
                    if Q<rewards(ag)
                       learned=1;
                    end
                    agents{ag}(actions(ag)) = max(Q,rewards(ag));
            end
    end
end