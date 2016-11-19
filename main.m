tic % Begin measuring time of execution

clear variables

numEpochs = 50; % NOTE: Changed generations to epochs because political correctness
numRuns = 10; %25; %Note: D runs slow, so fewer runs is a better idea.
useD = 0; % 1 - use difference reward, 0 - use global reward

penalty=100;  %temp. This penalty should ideally be increased over time to enforce feasiblity

% Values for components below are arbitrary. Change as necessary.
% See create_agents.m for details

% BATTERY
batteryAgents = [6, 6, 4];
% MOTOR
motorAgents = [24];
% PROPELLER
propAgents = [7, 12, 10, 10, 15, 15];
% ROD
rodAgents=[4, 16,11,8];

epsilon = 0.1; % Value for epsilon-greedy action selection
alpha = 0.1; % Learning rate

[batteryData, motorData, propData, foilData, rodData, matData] = load_data('batterytable.csv', ...
    'motortable.csv', 'propranges.csv', 'airfoiltable.csv','rodtable.csv','materialtable.csv');

G_hist= zeros(numRuns, numEpochs);
flightTime_hist= zeros(numRuns, numEpochs);

numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);
bestActions = uint8(zeros(numRuns, numAgents)); % The discrete action choices of the agents that give best performance
bestParams = cell(numRuns, 1); % The design parameters resulting from the agents' best actions

rewards_hist = zeros(numAgents, numRuns, numEpochs);
actions_hist = zeros(numAgents, numRuns, numEpochs);
%constraint_hist = zeros(numAgents, numRuns, numEpochs);

maxG = zeros(numRuns, 1);
for r = 1:numRuns
    % Create the agents
    agents = create_agents(batteryAgents, motorAgents, propAgents,rodAgents);

    % The best performance obtained by the team
    maxG(r) = 0;
    for e = 1:numEpochs
        % Have agents choose actions
        actions = choose_actions(agents, epsilon);
        actions_hist(:, r, e) = actions;

        battery = design_battery(actions, batteryData);
        motor = design_motor(actions, motorData);
        prop = design_prop(actions, propData);
        foil = design_foil(actions, foilData);
        rod = design_rod(actions, rodData, matData);

        % Get rewards for agents and system performance
        [rewards, G, flightTime,constraints] = compute_rewards(useD, penalty, ...
            battery, motor, prop, foil, rod);
        rewards_hist(:, r, e) = rewards;
        constraint_hist(:,r,e) = constraints;
        G_hist(r,e)=G;
        flightTime_hist(r,e)=flightTime;
        
        agents = update_values(agents, rewards, actions, alpha);
        
        % If this is the best performance encountered so far...
        if G > maxG(r)
            maxG(r) = G;
            % Update record of actions that got us there
            bestActions(r, :) = actions;
            % As well as the parameters that describe the design
            bestParams{r} = {battery, motor, prop, foil,rod};            
        end
        disp([num2str(r) ', ' num2str(e)])
    end
end

avgflightTime = mean(flightTime_hist);
avgG=mean(G_hist);

toc % Spit out execution time

% comment