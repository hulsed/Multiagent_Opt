% An agent might have multiple states. What this function does is it picks
% the value table corresponding to the current state it's in. It also gets
% the corresponding constraint table.
function [agentTables, cTables] = get_tables(agents, feaseles, states)
    numAgents = numel(agents);
    agentTables = cell(numAgents, 1);
    cTables = cell(numAgents, 1);
    for ag = 1:numAgents
        agent = agents{ag};
        agentTables{ag} = agent(states(ag),:);
        cTab = feaseles{ag};
        cTables{ag} = cTab(states(ag), :);
    end
end