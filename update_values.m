% Using the rewards received by each agent, update their Q-tables

% INPUTS
% agents - cell array of Q-tables, one for each agent
% rewards - vector of rewards, element i is the reward received by agent i
% actions - vector of integers, element i is the action taken by agent i
% alpha - the learning rate, 0 < alpha <= 1

% OUTPUTS
% The agents with updated Q-tables
function [agents,gagents, learned] = update_values(agents,gagents, rewards, alpha, actions,...
    states, oldStates, Qlearn, gamma,learnmode,penalty,scaleFactor, battery,...
    motor, prop, foil, rod,sys,res, data)
    
    learned=0;
    % Iterate through agents
    for ag = 1:numel(agents)
        % Get the current value of the action that agent ag took in previous state
        Q = agents{ag}(oldStates(ag), actions(ag));
        gQ= gagents{ag}(oldStates(ag), actions(ag));
        
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
            gagents{ag}(oldStates(ag), actions(ag)) = Q + alpha*(rewards(ag) - Q);
                case 'best'
                    if Q<rewards(ag)
                       learned=1; 
                    end
                    agents{ag}(oldStates(ag), actions(ag)) = max(Q,rewards(ag));
                    gagents{ag}(oldStates(ag), actions(ag)) = max(Q,rewards(ag));

                    
                case 'bestdiff'
                    if rewards(ag)>=gQ
                       gagents{ag}(oldStates(ag), actions(ag)) = max(gQ,rewards(ag));
                       
                       dreward=switch_diff(ag,rewards(ag), penalty,scaleFactor, battery, motor, prop, foil, rod,sys,res, data);
                       %dQ(ag)=dreward;
                       agents{ag}(oldStates(ag), actions(ag)) = Q + alpha*(dreward - Q);
                       
                    else
                       %agents{ag}(oldStates(ag), actions(ag)) = max(Q,rewards(ag));  
                       gagents{ag}(oldStates(ag), actions(ag)) = max(gQ,rewards(ag));
                    end
                case 'baddiff'
                    if rewards(ag)<=gQ
                       %gagents{ag}(oldStates(ag), actions(ag)) = max(gQ,rewards(ag));
                       
                       dreward=switch_diff(ag,rewards(ag), penalty,scaleFactor, battery, motor, prop, foil, rod,sys,res, data);
                       if dreward<Q
                       agents{ag}(oldStates(ag), actions(ag)) = Q + alpha*(dreward - Q);
                       else
                       agents{ag}(oldStates(ag), actions(ag)) = Q; 
                       end
                    else
                       %agents{ag}(oldStates(ag), actions(ag)) = max(Q,rewards(ag));  
                       %gagents{ag}(oldStates(ag), actions(ag)) = max(gQ,rewards(ag));
                    end   
            end
        clear dQ dreward
    end
end