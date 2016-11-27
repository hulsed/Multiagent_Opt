tic % Begin measuring time of execution

clear variables

numEpochs = 1000; % NOTE: Changed generations to epochs because political correctness
numRuns = 10; %25; %Note: D runs slow, so fewer runs is a better idea.
useD = 0; % 1 - use difference reward, 0 - use global reward
Qinit= 100;

modes = {'const', 'decay', 'softmax'};
params = [0.1, 0.5, 250];

% USE THIS TO SELECT WHICH SELECTION POLICY YOU WANT
% Adjust params as necessary, see below for description of each
myMode = 3;

% AS stands for action selector. It's a struct that describes how agents
% will select actions
% The mode tells the program which type of policy to use for exploration
% "const" means eps-greedy with constant epsilon
% "decay" means eps-greedy with exponentially decaying epsilon
% "softmax" means softmax (duh), so pick actions with certain probability
AS.mode = modes{myMode};

% param1 is the first parameter which affects exploration
% For mode "const", this gives the constant value of epsilon
% For mode "decay", this gives the starting value of epsilon that decays
% For mode "softmax", this gives the temperature for choosing actions 
% (good temp is 250)
AS.param1 = params(myMode);

% param2 is the second parameter which affects exploration
% For mode "const", does nothing
% For mode "decay", represents percent completion of design (ex: e/numEpochs)
% For mode "softmax", [to be determined]
AS.param2 = 0;

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


alpha = 0.1; % Learning rate

[batteryData, motorData, propData, foilData, rodData, matData] = load_data('batterytable.csv', ...
    'motortable.csv', 'propranges.csv', 'airfoiltable.csv','rodtable.csv','materialtable.csv');

data.batteryData = batteryData; data.motorData = motorData;
data.propData = propData; data.foilData = foilData; data.rodData = rodData;
data.matData = matData;

G_hist= zeros(numRuns, numEpochs);
flightTime_hist= zeros(numRuns, numEpochs);

numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);
bestActions = uint8(zeros(numRuns, numAgents)); % The discrete action choices of the agents that give best performance
bestParams = cell(numRuns, 1); % The design parameters resulting from the agents' best actions

rewards_hist = zeros(numAgents, numRuns, numEpochs);
actions_hist = zeros(numAgents, numRuns, numEpochs);
%constraint_hist = zeros(numAgents, numRuns, numEpochs);

maxG = zeros(numRuns, 1);
epochOfMax = zeros(numRuns, 1);
for r = 1:numRuns
    % Create the agents
    agents = create_agents(batteryAgents, motorAgents, propAgents,rodAgents,Qinit);

    % The best performance obtained by the team
    maxG(r) = 0;
    epochOfMax(r) = 0;
    for e = 1:numEpochs
        if e == numEpochs
            disp('aeaas');
        end
        
        AS.param2 = e/numEpochs;
        
        % Have agents choose actions
        actions = choose_actions(agents, AS);
        actions_hist(:, r, e) = actions;

        battery = design_battery(actions, batteryData);
        motor = design_motor(actions, motorData);
        prop = design_prop(actions, propData);
        foil = design_foil(actions, foilData);
        rod = design_rod(actions, rodData, matData);

        % Get rewards for agents and system performance
        [rewards, G, flightTime,constraints] = compute_rewards(useD, penalty, ...
            battery, motor, prop, foil, rod, data);
        rewards_hist(:, r, e) = rewards;
        constraint_hist(:,r,e) = constraints;
        G_hist(r,e)=G;
        flightTime_hist(r,e)=flightTime;
        
        agents = update_values(agents, rewards, actions, alpha);
        
        % If this is the best performance encountered so far...
        if G > maxG(r)
            maxG(r) = G;
            epochOfMax(r) = e;
            maxflightTime(r)=flightTime;
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

if ~exist('Saved Workspaces', 'dir')
    mkdir('Saved Workspaces');
end
% save workspace
save(['Saved Workspaces\\' AS.mode '_' num2str(AS.param1, '%.2f') '_' 'useD=' num2str(useD, '%d') '_' datestr(now,'mm-dd-yy_HH.MM.SS') '.mat'])

uav_plots(maxflightTime, flightTime_hist, maxG, G_hist, useD, AS, epochOfMax, Qinit);

run_qprop(0, 0, 0, 0, 0, 1); % Save our qprop_map to a file

toc % Spit out execution time

% comment
