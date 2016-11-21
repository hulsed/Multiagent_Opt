% Create the agents, each represented by a Q-table
%
% INPUTS
% each input is a row vector; size of vector specifies how many agents that
%   component has
% each element in the vectors corresponds to how many actions the agent has
% Example: if we get the arguments [5, 2], [24], [4, 19, 8], that means
%   there are 2 agents for the battery, 1 for the motor, and 3 for the prop
%   the battery's first agent has 5 actions, while its second agent has 2
%
% OUTPUTS
% agents - a cell array containing the Q-tables of the agents
function agents = create_agents(battery, motor, prop,rod,Qinit)
    % Join all component vectors into one vector
    allComponents = [battery, motor, prop, rod];
    numAgents = size(allComponents, 2);
    % Our multiagent system, of sorts. This will hold all the Q-tables.
    agents = cell(numAgents, 1);
    
    % Create the agents one by one. ag is the "agent number"
    for ag = 1:numel(allComponents)
        % Get number of actions for agent ag
        numActions = allComponents(ag);
        % Initialize Q-table (table of values)
        agent = Qinit*ones(1, numActions);
        % add agent to our list of1 agents
        agents{ag, 1} = agent;
    end
    
    % (return agents)
end