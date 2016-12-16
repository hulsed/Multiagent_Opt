% Make agents choose an action

% INPUTS
% agents - the cell array of agents, each cell containing a Q-table
% exploration - struct with two properties, mode and two params
%   modes are "const", "decay", and "softmax"
%   param1 is epsilon value, starting epsilon value, or temperature,
%       repsectively
%   param2 gives percent completion for mode "decay"

% OUTPUTS
% actions - column vector of integers, element i corresponds to action
%   taken by ith agent
function actions = choose_actions(agents, exploration)

    if strcmp(exploration.mode, 'const') % if constant epsilon
        epsilon = exploration.epsConst;
    elseif strcmp(exploration.mode, 'decay')
        % Calculate epsilon. Note that the constant in the
        % exponential is arbitrary and can be adjusted to taste
        b=log(exploration.decayepsMin/exploration.decayepsMax)
        epsilon = exploration.decayepsMax * exp(b * exploration.completion);
    end

    numAgents = numel(agents);
    % initialize vector of integers corresponding to agent actions
    actions = uint8(zeros(numAgents, 1));
    
    % Iterate through the agents
    for ag = 1:numel(agents)
        agent = agents{ag};
        % Get number of actions that agent ag can make
        numActions = numel(agent);
        if strcmp(exploration.mode, 'const') || strcmp(exploration.mode, 'decay') % if NOT softmax
            % Will the agent choose a random action?
            if rand < epsilon
                % Yes, pick random action for the agent
                actions(ag) = randi([1, numActions]);
            else
                % No, find the agent's current best action
                % (Second output of max() is the index of the max element)
                [~, bestAction] = max(agent);
                actions(ag) = bestAction;
            end
        else % if softmax
            p = zeros(1, numel(agent));
            if strcmp(exploration.mode, 'softmaxDecay')
                b=log(exploration.tempMin/exploration.tempMax);
                T = exploration.tempMax * exp(b * exploration.completion); % Temperature
            elseif strcmp(exploration.mode, 'softmaxAdaptiveExp')
                b=log(exploration.biasMin/exploration.biasMax);
                bias=exploration.biasMax*exp(b*exploration.completion);
            elseif strcmp(exploration.mode, 'softmaxAdaptiveLin')
                bias=exploration.biasMax-exploration.completion*(exploration.biasMax-exploration.biasMin);
            else
                T = exploration.tempConst; % Temperature
            end
            % iterate through possible actions for agent
            
            
            
            %agent=(agent-mean(agent))/(std(agent)+0.01);
            if strcmp(exploration.mode, 'softmaxFeatScale')
                %feature scaling
                agent=(agent-min(agent))/(max(agent)-min(agent)+0.001);
                %agent=(agent-mean(agent))/(std(agent)+0.01);
            end
            
            for a = 1:numel(agent)
                if strcmp(exploration.mode, 'softmaxAdaptiveLin') || strcmp(exploration.mode, 'softmaxAdaptiveExp')
                    T=mean(abs(agent))*bias;
                end
                                
                p(a) = exp(agent(a)/T);
            end
            s = sum(p);
            for a = 1:numel(agent)
                p(a) = p(a) / s;
            end
            actionToTake = find(isnan(p));
            if isempty(actionToTake)
                % Pick an action according to the probabilities in p
                actionToTake = randsample(1:numel(agent), 1, true, p);
            else
                disp('Softmax broke due to infinite exponential!')
                disp('Picking between three best')
                [sorting,ranking]=sort(agent,'descend');
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
                [~,actionToTake]=max(agent);
            end
            actions(ag) = actionToTake;   
        end
    end
end