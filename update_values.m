% Using the rewards received by each agent, update their Q-tables

% INPUTS
% agents - cell array of Q-tables, one for each agent
% rewards - vector of rewards, element i is the reward received by agent i
% actions - vector of integers, element i is the action taken by agent i
% alpha - the learning rate, 0 < alpha <= 1

% OUTPUTS
% The agents with updated Q-tables
function agents = update_values(agents, rewards, alpha, actions, states, oldStates, Qlearn, gamma,learnmode)
    % Iterate through agents
    for ag = 1:numel(agents)
        % Get the current value of the action that agent ag took in previous state
        Q = agents{ag}(oldStates(ag), actions(ag));
        
        if Qlearn
%             if ag == 1
%                 disp(['Action took was ' num2str(actions(ag)) ' and reward was ' num2str(rewards(ag))])
%                 disp(['Q-table looked like: ' num2str(agents{ag}(oldStates(ag), :), '%.2f ')])
%             end
            
            % Find max Q-value of current state (optimal action of next state)
            Q_opt = max(agents{ag}(states(ag), :));
            % Update the value of the action
            agents{ag}(oldStates(ag), actions(ag)) = Q + alpha*(rewards(ag) + gamma*Q_opt - Q);
            
%             if ag == 1
%                 disp(['Optimal Q-value of next state is ' num2str(Q_opt, '%.2f')])
%                 disp(['Q-table now looks like: ' num2str(agents{ag}(oldStates(ag), :), '%.2f ')])
%             end
        else
            switch learnmode
                case 'RL'
                  
            agents{ag}(oldStates(ag), actions(ag)) = Q + alpha*(rewards(ag) - Q);
                case 'best'
            agents{ag}(oldStates(ag), actions(ag)) = max(Q,rewards(ag));        
        end
    end
end