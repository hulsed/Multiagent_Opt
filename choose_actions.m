% Make agents choose an action

% INPUTS
% agents - the cell array of agents, each cell containing a Q-table
% AS - struct with two properties, mode and two params
%   modes are "const", "decay", and "softmax"
%   param1 is epsilon value, starting epsilon value, or temperature,
%       repsectively
%   param2 gives percent completion for mode "decay"

% OUTPUTS
% actions - column vector of integers, element i corresponds to action
%   taken by ith agent
function actions = choose_actions(agents, AS)

    if strcmp(AS.mode, 'const') % if constant epsilon
        epsilon = AS.param1;
    elseif strcmp(AS.mode, 'decay')
        % Calculate epsilon. Note that the constant in the
        % exponential is arbitrary and can be adjusted to taste
        epsilon = AS.param1 * exp(-10 * AS.param2);
    end

    numAgents = numel(agents);
    % initialize vector of integers corresponding to agent actions
    actions = uint8(zeros(numAgents, 1));
    
    % Iterate through the agents
    for ag = 1:numel(agents)
        agent = agents{ag};
        % Get number of actions that agent ag can make
        numActions = numel(agent);
        if strcmp(AS.mode, 'softmax') == 0 % if NOT softmax
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
            T = AS.param1; % Temperature
            s = 0; % Sum of p's
            
            % iterate through possible actions for agent
            for a = 1:numel(agent)
                p(a) = exp(agent(a)/T);
            end
            s = sum(p);
            for a = 1:numel(agent)
                p(a) = p(a) / s;
            end
            % Pick an action according to the probabilities in p
            actionToTake = randsample(1:numel(agent), 1, true, p);
            actions(ag) = actionToTake;   
        end
    end
end