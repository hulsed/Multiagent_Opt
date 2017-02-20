global stateful

exploration.mode = expModes{myMode};
exploration.completion = 0;

G_hist= zeros(numRuns, numEpochs);
Objectives_hist.totalCost=zeros(numRuns, numEpochs);
Objectives_hist.flightTime=zeros(numRuns, numEpochs);
Objectives_hist.climbEnergy=zeros(numRuns, numEpochs);


numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);
bestActions = uint8(zeros(numRuns,numAgents)); % The discrete action choices of the agents that give best performance
bestParams = cell(numRuns, 1); % The design parameters resulting from the agents' best actions


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

            % Get rewards for agents and system performance
            [rewards, G] = compute_rewards(actions);
            G=G*scaleFactor;
            rewards_hist(:, r, e) = rewards;
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
            [agents,gagents, learned] = update_values(agents,gagents, rewards, alpha, actions, 'best');
            
            %feasels = update_values(feasels, cUpdate, alpha, actions, states, oldStates, 0,[],'RL');
            agents_hist{r, e} = agents;
            
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
    clear bestG
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
