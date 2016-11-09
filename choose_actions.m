% Make agents choose an action

% INPUTS
% agents - the cell array of agents, each cell containing a Q-table
% epsilon - probability that an agent will choose a random action

% OUTPUTS
% actions - column vector of integers, element i corresponds to action
%   taken by ith agent
function actions = choose_actions(agents, epsilon)
    numAgents = numel(agents);
    % initialize vector of integers corresponding to agent actions
    actions = uint8(zeros(numAgents, 1));
    
    % Iterate through the agents
    for ag = 1:numel(agents)
        agent = agents{ag};
        % Get number of actions that agent ag can make
        numActions = numel(agent);
        % Will the agent choose a random action?
        if rand < epsilon
            % Yes, pick random action for the agent
            actions(ag) = randi([1, numActions]);
        else
            % No, find the agent's current best action
            % (Second output of max() is the index of the max element)
            [derp, bestAction] = max(agent);
            actions(ag) = bestAction;
        end
    end
end