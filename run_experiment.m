% exploration stands for action selector. It's a struct that describes how agents
% will select actions
% The mode tells the program which type of policy to use for scaleFactor
% "const" means eps-greedy with constant epsilon
% "decay" means eps-greedy with exponentially decaying epsilon
% "softmax" means softmax (duh), so pick actions with certain probability
exploration.mode = expModes{myMode};

% param1 is the first parameter which affects scaleFactor
% For mode "const", this gives the constant value of epsilon
% For mode "decay", this gives the starting value of epsilon that decays
% For mode "softmax", this gives the temperature for choosing actions 
% (good temp is 250)
%exploration.param1 = params(myMode);

% param2 is the second parameter which affects scaleFactor
% For mode "const", does nothing
% For mode "decay", represents percent completion of design (ex: e/numEpochs)
% For mode "softmax", [to be determined]
exploration.completion = 0;

penalty.Mode=penModes{penMode};
penFxnB=log(penalty.quadMin/penalty.quadMax)/(1-numEpochs);
penFxnA=penalty.quadMin/exp(penFxnB);
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
constraint_hist = zeros(8, numRuns, numEpochs);
hover=init_perf(); %TEMP. may require its own initialization
hover_hist=init_perf(); %TEMP. may require its own initialization
bestHover=init_perf();
maxG = zeros(numRuns, 1);
epochOfMax = zeros(numRuns, 1);
maxflightTime = zeros(numRuns, 1);

for r = 1:numRuns
    % Create the agents
    [agents, cTable] = create_agents(batteryAgents, motorAgents, propAgents,rodAgents,Qinit);

    % The best performance obtained by the team
    maxG(r) = 0;
    epochOfMax(r) = 0;
    for e = 1:numEpochs
        penalty.R=penFxnA*exp(penFxnB*e);
        exploration.completion = e/numEpochs;
        
        % Have agents choose actions
        actions = choose_actions(agents, cTable, exploration);
        actions_hist(:, r, e) = actions;

        battery = design_battery(actions, batteryData);
        motor = design_motor(actions, motorData);
        prop = design_prop(actions, propData);
        foil = design_foil(actions, foilData);
        rod = design_rod(actions, rodData, matData, prop);

        % Get rewards for agents and system performance
        [rewards, cUpdate, G, flightTime,constraints,hover] = compute_rewards(useD, penalty, ...
            scaleFactor, battery, motor, prop, foil, rod, data);
        G=G*scaleFactor;
        hover_hist(r,e)=hover;
        rewards_hist(:, r, e) = rewards;
        constraint_hist(:,r,e) = constraints;
        G_hist(r,e)=G;
        flightTime_hist(r,e)=flightTime;
        
        agents = update_values(agents, rewards, actions, alpha);
        cTable = update_values(cTable, cUpdate, actions, 0.99);
        agents_hist{r, e} = agents;
        
        % If this is the best performance encountered so far...
        if G > maxG(r) && all(constraints <= 0)
            maxG(r) = G;
            epochOfMax(r) = e;
            maxflightTime(r)=flightTime;
            % Update record of actions that got us there
            bestActions(r, :) = actions;
            % As well as the parameters that describe the design
            bestParams{r} = {battery, motor, prop, foil, rod};
            bestHover(r)=hover;
        end
        
        disp([num2str(r) ', ' num2str(e)])
        disp([num2str(r) ', ' num2str(e)])
    end
end

avgflightTime = mean(flightTime_hist);
avgG=mean(G_hist);

if ~exist('Saved Workspaces', 'dir')
    mkdir('Saved Workspaces');
end
% save workspace
[rewardnum,mode,pennum,penmode]=label_parameters(exploration, penalty);
uav_plots % No longer a function so we don't need a massive list of params
save(['Saved Workspaces\\' exploration.mode '_' num2str(rewardnum, '%.2f') '_' 'useD=' num2str(useD, '%d') '_' penalty.Mode '_' num2str(pennum) '_' datestr(now,'mm-dd-yy_HH.MM.SS') '.mat'])

%converged_designs
converged.flighttimes_mins=flightTime_hist(:,numEpochs)/60;
converged.g1=constraint_hist(1,:,numEpochs)';
converged.g2=constraint_hist(2,:,numEpochs)';
converged.g3=constraint_hist(3,:,numEpochs)';
converged.g4=constraint_hist(4,:,numEpochs)';
converged.g5=constraint_hist(5,:,numEpochs)';
converged.g6=constraint_hist(6,:,numEpochs)';
converged.g7=constraint_hist(7,:,numEpochs)';
converged.g8=constraint_hist(8,:,numEpochs)';
disp('at final iteration, the converged designs have values:')
struct2table(converged)
disp(['Percentage of converged designs that are feasible: ' num2str( ...
    numel(find(max(constraint_hist(:, :, numEpochs)) <= 0))/numRuns*100,...
    '%d') '%'])
% run_qprop(0, 0, 0, 0, 1); % Save our qprop_map to a file
