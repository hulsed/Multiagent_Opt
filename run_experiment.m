global stateful

exploration.mode = expModes{myMode};
exploration.completion = 0;

penalty.Mode=penModes{penMode};
penFxnB=log(penalty.quadMin/penalty.quadMax)/(1-numEpochs);
penFxnA=penalty.quadMin/exp(penFxnB);
%penFxnA=penaltyMin/exp(1);
%penFxnB=(log(penaltyMax)-log(penFxnA))/numEpochs; %note: log is natural log, not log base 10.

G_hist= zeros(numRuns, numEpochs);
Objectives_hist.totalCost=zeros(numRuns, numEpochs);
Objectives_hist.flightTime=zeros(numRuns, numEpochs);
Objectives_hist.climbEnergy=zeros(numRuns, numEpochs);


numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);
bestActions = uint8(zeros(numRuns, numAgents)); % The discrete action choices of the agents that give best performance
bestParams = cell(numRuns, 1); % The design parameters resulting from the agents' best actions

%%%%
%Residual parameters of the design
res.mass=0.3;
res.framewidth=0.075; %temp width of frame!
res.planArea=res.framewidth^2;
res.cost=50;
res.power=5;
%%%%


rewards_hist = zeros(numAgents, numRuns, numEpochs);
actions_hist = zeros(numAgents, numRuns, numEpochs);
if stateful, states_hist = zeros(numAgents, numRuns, numEpochs); end
agents_hist = cell(numRuns, numEpochs);
feasels_hist = cell(numRuns, numEpochs);
constraint_hist = zeros(8, numRuns, numEpochs);
hover=init_perf(); %TEMP. may require its own initialization
hover.failure=[];
hover_hist=init_perf(); %TEMP. may require its own initialization
hover_hist.failure=[];
bestHover=init_perf();
bestHover.failure=[];
maxG = -10000*zeros(numRuns, 1);
epochOfMax = zeros(numRuns, 1);
maxflightTime = zeros(numRuns, 1);

for r = 1:numRuns
    % Create the agents and feasels
    [agents, feasels] = create_agents(batteryAgents, motorAgents, propAgents,rodAgents,-1000);
    [gagents, feasels] = create_agents(batteryAgents, motorAgents, propAgents,rodAgents,-10000);
    gagents=gagents';
    % Initial states. If not stateful, this is used anyway, but all states
    % are 1 always
    states = ones(numAgents, 1);
    % The best performance obtained by the team
    maxG(r) = -10000;
    G=-10000;
    epochOfMax(r) = 0;
    for e = 1:numEpochs
        penalty.R=penFxnA*exp(penFxnB*e);
        k=1;
        while G<=maxG(r)
            k=k+1;
            
            %exploration.completion = k/(k+100);
            if k>100
                break
            end


            if stateful
                [agentTables, cTables] = get_tables(agents, feasels, states);
            else
                % If not stateful, don't waste time by calling the function.
                % All the agents and feasels have only one table.
                agentTables = agents;
                cTables = feasels;
            end

            % Have agents choose actions
            actions = choose_actions(agentTables, cTables, exploration, k);
            actions_hist(:, r, e) = actions;

            motorNum = actions(4); % remember motor number so we can get the right motorfile
            battery = design_battery(actions, batteryData);
            motor = design_motor(actions, motorData);
            [prop,foil] = design_prop(actions, propData, foilData);
            rod = design_rod(actions, rodData, matData, prop,res);
            sys=design_sys(battery, motor, prop, foil, rod, res, motorNum);

            % Get rewards for agents and system performance
            [rewards, cUpdate, G, Objectives,constraints,hover] = compute_rewards(useD, penalty, ...
                scaleFactor, battery, motor, prop, foil, rod, sys,res, data);
            G=G*scaleFactor;
            hover_hist(r,e)=hover;
            rewards_hist(:, r, e) = rewards;
            constraint_hist(:,r,e) = constraints;
            G_hist(r,e,k)=G;
            G_khist(k)=G;
            avgGk=mean(G_khist);
                        
            Objectives_hist.flightTime(r,e)=Objectives.flightTime;
            Objectives_hist.totalCost(r,e)=Objectives.totalCost;
            Objectives_hist.climbEnergy(r,e)=Objectives.climbEnergy;
            oldStates = states;
            if stateful
                states = update_states(states, constraints);
                states_hist(:, r, e) = states;
            end
            Qlearn = stateful; % Use Q-learning for agents if stateful

            [, gagents] = update_values(agents, gagents, rewards, alpha, actions, states,...
                oldStates, Qlearn, gamma,'bestdiff',penalty,scaleFactor,...
                battery, motor, prop, foil, rod,sys,res, data);
            
            %feasels = update_values(feasels, cUpdate, alpha, actions, states, oldStates, 0,[],'RL');
            agents_hist{r, e} = agents;
            feasels_hist{r,e} = feasels;
            avgG=median(G_hist(r,:,k));
            stdG=std(G_hist(r,:,k));
            
            disp([num2str(r) ', ' num2str(e) ', ' num2str(k) ', G=' num2str(G, 3) ', maxG=' num2str(maxG(r), 3) ' , avgG=' num2str(avgG, 3)])

            if G > avgG %&& all(constraints <= 0.01)
            
            [rewards, cUpdate, G, Objectives,constraints,hover] = compute_rewards(1, penalty, ...
            scaleFactor, battery, motor, prop, foil, rod, sys,res, data);
           [agents,] = update_values(agents,gagents, rewards, alpha, actions, states,...
                oldStates, Qlearn, alpha,'RL',penalty,scaleFactor,...
                battery, motor, prop, foil, rod,sys,res, data);
        %    maxG(r) = G;
        %    epochOfMax(r) = e;
        %    maxflightTime(r)=Objectives.flightTime;
        %    % Update record of actions that got us there
        %    bestActions(r, :) = actions;
        %    % As well as the parameters that describe the design
        %    bestParams{r} = {battery, motor, prop, foil, rod};
        %    bestHover(r)=hover;
        %elseif G<avgGk;
        %    [rewards, cUpdate, G, Objectives,constraints,hover] = compute_rewards(0, penalty, ...
        %    scaleFactor, battery, motor, prop, foil, rod, sys,res, data);
        %   [agents,] = update_values(agents,gagents, rewards, alpha, actions, states,...
        %       oldStates, Qlearn, gamma,'baddiff',penalty,scaleFactor,...
        %        battery, motor, prop, foil, rod,sys,res, data);
            break
            
            end
             
        end
                % If this is the best performance encountered so far...
        if G > maxG(r) %&& all(constraints <= 0.01)
        %    
            [rewards, cUpdate, G, Objectives,constraints,hover] = compute_rewards(1, penalty, ...
            scaleFactor, battery, motor, prop, foil, rod, sys,res, data);
            [agents,] = update_values(agents,gagents, rewards, alpha, actions, states,...
                oldStates, Qlearn, alpha,'RL',penalty,scaleFactor,...
                battery, motor, prop, foil, rod,sys,res, data);
            maxG(r) = G;
        %    epochOfMax(r) = e;
        %    maxflightTime(r)=Objectives.flightTime;
        %    % Update record of actions that got us there
        %    bestActions(r, :) = actions;
        %    % As well as the parameters that describe the design
        %    bestParams{r} = {battery, motor, prop, foil, rod};
        %    bestHover(r)=hover;
        %elseif G<avgGk;
        %    [rewards, cUpdate, G, Objectives,constraints,hover] = compute_rewards(0, penalty, ...
        %    scaleFactor, battery, motor, prop, foil, rod, sys,res, data);
        %   [agents,] = update_values(agents,gagents, rewards, alpha, actions, states,...
        %       oldStates, Qlearn, gamma,'baddiff',penalty,scaleFactor,...
        %        battery, motor, prop, foil, rod,sys,res, data);
        end
       %[gagents, feasels] = create_agents(batteryAgents, motorAgents, propAgents,rodAgents,Qinit);
        
    end
end
% for a=1:numEpochs
%     avgflightTime(a) = mean([Objectives_hist(:,a).flightTime]);
% end

flightTime_hist = Objectives_hist.flightTime;

avgG=mean(G_hist);

if ~exist('Saved Workspaces', 'dir')
    mkdir('Saved Workspaces');
end
%best designs
best=structure_best(G_hist,Objectives_hist, constraint_hist,numRuns, epochOfMax);
disp('the best designs in the run have values:')
struct2table(best)
%converged_designs
converged=structure_best(G_hist,Objectives_hist, constraint_hist,numRuns, numEpochs*ones(numRuns,1));
% save workspace
disp('at final iteration, the converged designs have values:')
struct2table(converged)
disp(['Percentage of converged designs that are feasible: ' num2str( ...
    numel(find(max(constraint_hist(:, :, numEpochs)) <= 0.05))/numRuns*100,...
    '%d') '%'])
[rewardnum,mode,pennum,penmode]=label_parameters(exploration, penalty);
uav_plots
if saveWorkspace
    if stateful, strState = 'state'; else strState = 'NOstate'; end
    save(['Saved Workspaces\\' ...
            strState ...
        '_' exploration.mode '_' num2str(rewardnum, '%.2f_') ...
            char((useD == 1) * 'D' + (useD == 0) * 'G') ... 'D' or 'G', depending on useD
        '_' penalty.Mode '_' num2str(pennum, '%.2f_') datestr(now,'mm-dd-yy_HH.MM.SS') '.mat'])
end


% run_qprop(0, 0, 0, 0, 1); % Save our qprop_map to a file
