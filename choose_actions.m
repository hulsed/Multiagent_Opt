% Make agents choose an action

% INPUTS
% agents - the cell array of agents, each cell containing a Q-table
% exploration - struct determinint exploration

% OUTPUTS
% actions - column vector of integers, element i corresponds to action
%   taken by ith agent
function actions = choose_actions(agentTables, exploration)

    numAgents = numel(agentTables);
    % initialize vector of integers corresponding to agent actions
    actions = uint8(zeros(numAgents, 1));
    
    % Iterate through the agents
    for ag = 1:numel(agentTables)
        agent = agentTables{ag};
        % Get number of actions that agent ag can make
        numActions = numel(agent);
            
            %calculating bias for exploration
            nu=exploration.biasMin*log(2.0);
            bias=nu/log(1.00001+exploration.completion);
            
            %softmax normalization
            agent2=1./(1+exp(-(agent-mean(agent))/(std(agent)+0.1)));
            %softmax selection
            for a = 1:numel(agent)
                        p(a)= exp(agent2(a)/(bias));                  
            end
            p=p/sum(p);
            %picks action
            actionToTake = find(isnan(p));
            if isempty(actionToTake)
                % Pick an action according to the probabilities in p
                try
                    actionToTake = randsample(1:numel(agent), 1, true, p);
                catch
                    p % in case it produces a complex number
                    actionToTake = randsample(1:numel(agent), 1, true, p);
                end
            else
                disp('Softmax broke due to infinite exponential!')
                disp('Picking between three best')
                [sorting,ranking]=sort(agent);
                dice=randi(20,1);
                if dice<=16
                    actionToTake=ranking(1);
                elseif 16<dice<=19
                    actionToTake=ranking(2);
                else 
                    actionToTake=ranking(3);
                end
                    
            end
            if exploration.completion==1
                [~,actionToTake]=max(p);
            end
            actions(ag) = actionToTake;   
            clear p
    end
end