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
function [agentTables, feasels] = create_agents(battery, motor, prop,rod,Qinit)
global stateful
    % Join all component vectors into one vector
    allComponents = [battery, motor, prop, rod];
    numAgents = size(allComponents, 2);
    % Our multiagent system, of sorts. This will hold all the Q-tables.
    agentTables = cell(numAgents, 1);
    % Feasels are the constraint tables for the agents
    feasels = cell(numAgents, 1);
    
    % Create the agents one by one. ag is the "agent number"
    for ag = 1:numel(allComponents)
        % Get number of actions for agent ag
        numActions = allComponents(ag);
        
        if stateful && ismember(ag, [1 2 3 4 11 12 13 14]) % each of non-prop agents has 4 possible states
            % Initialize Q-table (table of values)
            agent = Qinit*ones(5, numActions);
            feasel = zeros(5, numActions);
        else
            % Initialize Q-table (table of values)
            agent = Qinit*ones(1, numActions);
            feasel = zeros(1, numActions);
        end
        % add agent to our list of1 agents
        agentTables{ag, 1} = agent;
        feasels{ag, 1} = feasel;
    end
    
    % (return agents)
end