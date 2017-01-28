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
bestActions = uint8(zeros(numRuns,numAgents)); % The discrete action choices of the agents that give best performance
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
    bestG(1)= -10000;
    G=-10000;
    epochOfMax(r) = 0;
    e=1;
    converged=false;
    bestGc=nan(1,maxEpochs);
    avgGk=nan(1,maxEpochs);
    while converged==false
        penalty.R=penFxnA*exp(penFxnB*e);
        e=e+1;
        
        bestG(e)=bestG(e-1);
        k=0;
        for k=1:numKs
            
            exploration.completion = k/numKs;

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
            avgGk(e)=mean(G_khist);
                        
            oldStates = states;
            if stateful
                states = update_states(states, constraints);
                states_hist(:, r, e) = states;
            end
            Qlearn = stateful; % Use Q-learning for agents if stateful
            
            learned=0;
            [agents, gagents,learned] = update_values(agents, gagents, rewards, alpha, actions, states,...
                oldStates, Qlearn, gamma,'best',penalty,scaleFactor,...
                battery, motor, prop, foil, rod,sys,res, data);
            
            %feasels = update_values(feasels, cUpdate, alpha, actions, states, oldStates, 0,[],'RL');
            agents_hist{r, e} = agents;
            feasels_hist{r,e} = feasels;
            
            if learned
            learndisp=' learned';
            else
                learndisp='.';
            end
            
            disp([num2str(r) ', ' num2str(e) ', ' num2str(k) ', G=' num2str(G, 3) ', maxG=' num2str(bestG(e), 3) ' , avgG=' num2str(avgGk(e), 3) learndisp])
            
            if G > bestG(e) %&& all(constraints <= 0.01)
                bestG(e) = G;
                epochOfMax(r) = e;
                % Update record of actions that got us there
                bestActions(r,:) = actions;
                % As well as the parameters that describe the design
                bestParams{r} = {battery, motor, prop, foil, rod};
                break
            end
            
        end

       if e>stopEpoch+1
            if bestG(e)==bestG(e-stopEpoch)
                converged=true;
            end
       end
       if e>maxEpochs
           converged=true;
       end
       
    end
    bestGc(1:length(bestG))=bestG;
    bestGhist(r,:)=bestGc;
    avgGhist(r,:)=avgGk;
end


if ~exist('Saved Workspaces', 'dir')
    mkdir('Saved Workspaces');
end
%best design

%[rewardnum,mode,pennum,penmode]=label_parameters(exploration, penalty);
uav_plots

if saveWorkspace
    if stateful, strState = 'state'; else strState = 'NOstate'; end
    save(['Saved Workspaces\\' ...
            strState ...
        '_' exploration.mode '_' ...
            char((useD == 1) * 'D' + (useD == 0) * 'G') ... 'D' or 'G', depending on useD
        '_' penalty.Mode '_' datestr(now,'mm-dd-yy_HH.MM.SS') '.mat'])
end
