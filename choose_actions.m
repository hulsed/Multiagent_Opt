% Make agents choose an action

% INPUTS
% agents - the cell array of agents, each cell containing a Q-table
% exploration - struct with two properties, mode and two params
%   modes are "const", "decay", and "softmax"
%   param1 is epsilon value, starting epsilon value, or temperature,
%       repsectively
%   param2 gives percent completion for mode "decay"

% OUTPUTS
% actions - column vector of integers, element i corresponds to action
%   taken by ith agent
function actions = choose_actions(agentTables, cTables, exploration, penalty)

    if strcmp(exploration.mode, 'const') % if constant epsilon
        epsilon = exploration.epsConst;
    elseif strcmp(exploration.mode, 'decay')
        % Calculate epsilon. Note that the constant in the
        % exponential is arbitrary and can be adjusted to taste
        b=log(exploration.decayepsMin/exploration.decayepsMax);
        epsilon = exploration.decayepsMax * exp(b * exploration.completion);
    end

    numAgents = numel(agentTables);
    % initialize vector of integers corresponding to agent actions
    actions = uint8(zeros(numAgents, 1));
    
    % Iterate through the agents
    for ag = 1:numel(agentTables)
        agent = agentTables{ag};
        cTab = cTables{ag};
        % Get number of actions that agent ag can make
        numActions = numel(agent);
        if strcmp(exploration.mode, 'const') || strcmp(exploration.mode, 'decay') % if NOT softmax
            % Will the agent choose a random action?
            if rand < epsilon
                % Yes, pick random action for the agent
                actions(ag) = randi([1, numActions]);
            else
                % No, find the agent's current best action
                % (Second output of max() is the index of the max element)
                [~, bestAction] = max(agent);
                actions(ag) = bestAction;
            end
        else % if softmax
            p = zeros(1, numel(agent));
            if strcmp(exploration.mode, 'softmaxDecay')
                b=log(exploration.tempMin/exploration.tempMax);
                T = exploration.tempMax * exp(b * exploration.completion); % Temperature
                Tc=exploration.tempMax * exp(b * exploration.completion);
            elseif strcmp(exploration.mode, 'softmaxAdaptiveExp')
                b=log(exploration.biasMin/exploration.biasMax);
                bias=exploration.biasMax*exp(b*exploration.completion);
                
            elseif strcmp(exploration.mode, 'softmaxAdaptiveLin')
                bias=exploration.biasMax-exploration.completion*(exploration.biasMax-exploration.biasMin);
            elseif strcmp(exploration.mode, 'softmaxSigmoid')
                %bias=exploration.biasMax-exploration.completion*(exploration.biasMax-exploration.biasMin);
                nu=exploration.biasMin*log(2.0);
                bias=nu/log(1.00001+exploration.completion);
            else
                T = exploration.tempConst; % Temperature
                Tc=exploration.tempConst;
            end
            % iterate through possible actions for agent   
            
            %agent=(agent-mean(agent))/(std(agent)+0.01);
            if strcmp(exploration.mode, 'softmaxFeatScale')
                %feature scaling
                agent=(agent-min(agent))/(max(agent)-min(agent)+0.001);
                %agent=(agent-mean(agent))/(std(agent)+0.01);
            end

            r = rand;
            for a = 1:numel(agent)
               if cTab(a)<0.01
                   cTab(a)=0;
               end 
            end
            
            agent2=agent;
  
%             for a = 1:numel(agent)
%                if cTab(a)<0.01
%                    feasagent(a)=agent(a);
%                    infeasagent(a)=nan;
%                else
%                    feasagent(a)=nan;
%                    infeasagent(a)=agent(a);
%                end 
%             end
%             if  not(all(isnan(feasagent)))
%             bestfeasval=max(feasagent);
%             worstfeasval=min(feasagent);
%             bestinfeasval=max(infeasagent);
%             if bestinfeasval>bestfeasval
%                 infeasagent=infeasagent-(bestinfeasval-bestfeasval)-1;   
%             end
%             for a = 1:numel(agent)
%                if isnan(feasagent(a))
%                    agent1(a)=infeasagent(a);
%                else
%                    agent1(a)=feasagent(a);
%                end
%             end
%             else
%                 agent1=agent-1000*cTab.^2
%             end
            
            
            if strcmp(exploration.mode, 'softmaxSigmoid')
                        %for a=1:numel(agent)
                        % agent1(a)=agent(a)-penalty.R*cTab(a)^2 ;
                        %end
                        agent1=agent;
                        agent2=1./(1+exp(-(agent1-mean(agent1))/(std(agent1)+0.1)));
                        T=bias;
                        %cTab2=1./(1+exp(-(cTab-mean(cTab))/(std(cTab)+0.1)));
                        for a=1:numel(cTab)
                            c(a)= exp(-cTab(a)/T);
                        end
                        c=c./sum(c);
                        value=agent2.*c;
                        for a=1:numel(agent)
                            p(a)= exp(numel(value)*value(a)/T);
                        end
            end
            
                if strcmp(exploration.mode, 'softmaxAdaptiveLin') || strcmp(exploration.mode, 'softmaxAdaptiveExp')
                        T=(mean(abs(agent))+0.1)*bias;
                    for a = 1:numel(agent)
                    
                        %Tc=(mean(abs(cTab))+0.1)*feasBias;
                        %b2=log(exploration.feasTempMin/exploration.feasTempMax);
                        %Tc=exploration.feasTempMax * exp(b2 * exploration.completion);
                        %Tc=exploration.feasTemp;
                        
                        gscale=(mean(abs(agent))+0.01)/(max(abs(agent))+0.01);

                        cscale=(mean(abs(cTab))+0.01)/(max(abs(cTab))+0.01);
                        %gscale=(mean(abs(agent))+0.01)/((abs(agent(a)))+0.01);
                        %cscale=(mean(abs(cTab))+0.01)/((abs(cTab(a)))+0.01);
                        sf=exploration.feasfactor*gscale/cscale;
                        c(a)= exp(-cTab(a)*sf/(bias));
                        g(a)= exp(agent(a)/(T));
                    end

                
                    c=c/sum(c);
                    %Note: this seems to work better when using the global reward.
                    %for a=1:numel(agent)
                    %    if c(a)<0.001
                    %        c(a)=0;
                    %    end
                    %end
                    p=g.*c; 
            
                    end
            
            p=p/sum(p);
            
            actionToTake = find(isnan(p));
            if isempty(actionToTake)
                % Pick an action according to the probabilities in p
                try
                    actionToTake = randsample(1:numel(agent), 1, true, p);
                catch
                    p, g, c, cTab % Sometimes get complex numbers >:[
                    actionToTake = randsample(1:numel(agent), 1, true, p);
                end
            else
                disp('Softmax broke due to infinite exponential!')
                disp('Picking between three best')
                [sorting,ranking]=sort(agent);
                dice=randi(20,1);
                if dice<=16
                    actionToTake=ranking(1);
                elseif 16<dice<=19
                    actionToTake=ranking(2);
                else 
                    actionToTake=ranking(3);
                end
                    
            end
            if exploration.completion==1
                [~,actionToTake]=max(p);
            end
            actions(ag) = actionToTake;   
            clear g c p cTab agent1 agent2
        end
    end
end