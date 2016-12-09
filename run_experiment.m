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

penFxnB=log(penaltyMin/penaltyMax)/(1-numEpochs);
penFxnA=penaltyMin/exp(penFxnB);
%penFxnA=penaltyMin/exp(1);
%penFxnB=(log(penaltyMax)-log(penFxnA))/numEpochs; %note: log is natural log, not log base 10.

G_hist= zeros(numRuns, numEpochs);
flightTime_hist= zeros(numRuns, numEpochs);

numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);
bestActions = uint8(zeros(numRuns, numAgents)); % The discrete action choices of the agents that give best performance
bestParams = cell(numRuns, 1); % The design parameters resulting from the agents' best actions

rewards_hist = zeros(numAgents, numRuns, numEpochs);
actions_hist = zeros(numAgents, numRuns, numEpochs);
agents_hist = cell(numRuns, numEpochs);
constraint_hist = zeros(7, numRuns, numEpochs);
perf_hist(numRuns,numEpochs)=init_perf();
hover=init_perf(); %TEMP. may require its own initialization
hover.index=[];
hover_hist=init_perf(); %TEMP. may require its own initialization
hover_hist.index=[];
bestHover=init_perf();
bestHover.index=[];
maxG = zeros(numRuns, 1);
epochOfMax = zeros(numRuns, 1);

for r = 1:numRuns
    % Create the agents
    agents = create_agents(batteryAgents, motorAgents, propAgents,rodAgents,Qinit);

    % The best performance obtained by the team
    maxG(r) = 0;
    epochOfMax(r) = 0;
    for e = 1:numEpochs
        penalty=penFxnA*exp(penFxnB*e);
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
        [rewards, G, flightTime,constraints, perf,hover] = compute_rewards(useD, penalty, ...
            battery, motor, prop, foil, rod, data);
        perf_hist(r,e)=perf;
        hover_hist(r,e)=hover;
        rewards_hist(:, r, e) = rewards;
        constraint_hist(:,r,e) = constraints;
        G_hist(r,e)=G;
        flightTime_hist(r,e)=flightTime;
        
        agents = update_values(agents, rewards, actions, alpha);
        agents_hist{r, e} = agents;
        
        % If this is the best performance encountered so far...
        if G > maxG(r)
            maxG(r) = G;
            epochOfMax(r) = e;
            maxflightTime(r)=flightTime;
            % Update record of actions that got us there
            bestActions(r, :) = actions;
            % As well as the parameters that describe the design
            bestParams{r} = {battery, motor, prop, foil, rod};
            bestPerf(r)=perf;
            bestHover(r)=hover;
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

uav_plots(maxflightTime, flightTime_hist,constraint_hist,numEpochs,penaltyMin,penaltyMax, maxG, G_hist, useD, AS, epochOfMax, Qinit);

run_qprop(0, 0, 0, 0, 1); % Save our qprop_map to a file