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
function actions = choose_actions(agents, cTable, exploration)

    %TEST
    for truck = 1:numel(cTable)
        if max(cTable{truck}) > 0
            disp ''
        end
    end

    if strcmp(exploration.mode, 'const') % if constant epsilon
        epsilon = exploration.epsConst;
    elseif strcmp(exploration.mode, 'decay')
        % Calculate epsilon. Note that the constant in the
        % exponential is arbitrary and can be adjusted to taste
        b=log(exploration.decayepsMin/exploration.decayepsMax)
        epsilon = exploration.decayepsMax * exp(b * exploration.completion);
    end

    numAgents = numel(agents);
    % initialize vector of integers corresponding to agent actions
    actions = uint8(zeros(numAgents, 1));
    
    % Iterate through the agents
    for ag = 1:numel(agents)
        agent = agents{ag};
        cTab = cTable{ag};
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
            
            % 10% chance choose infeasible action (if there are any), or if
            % all actions infeasible choose among them
            r = rand;
%             if (r < 0.1 && ~all(cTab == 0)) || all(cTab > 0)
%                 for a = 1:numel(agent)
%                     if cTab(a) > 0
%                         % p(a) greater for least infeasible designs
%                         p(a) = 1/(cTab(a));
%                     end
%                 end
%             else
%                 % iterate through possible actions for agent
%                 for a = 1:numel(agent)
%                     if strcmp(exploration.mode, 'softmaxAdaptiveLin') || strcmp(exploration.mode, 'softmaxAdaptiveExp')
%                         T=max(abs(agent))*bias;
%                     end
%                     if cTab(a) == 0 % If it's a feasible action, p(a) > 0
%                         p(a) = exp(agent(a)/T);
%                     end % Otherwise, p(a) == 0
%                 end
%             end
            %b3=log(exploration.fcMin/exploration.fcMax);
            %feasCutoff=exploration.fcMax*exp(b3*exploration.completion);
            %feasCutoff=exploration.fcMax-exploration.completion*(exploration.fcMax-exploration.fcMin);
            
            %for a=1:numel(agent)
                %b2=log(exploration.feasTempMin/exploration.feasTempMax);
                %Tc=exploration.feasTempMax * exp(b2 * exploration.completion);
            %    Tc=exploration.feasTemp;

            %        c(a)= exp(-cTab(a)/Tc);
%                 end                 
            %end
            %c=c/sum(c);
            %agent1=agent;
            %agent=agent.*c;
            
            for a = 1:numel(agent)
                    if strcmp(exploration.mode, 'softmaxAdaptiveLin') || strcmp(exploration.mode, 'softmaxAdaptiveExp')
                        T=(mean(abs(agent))+0.1)*bias;
                        %Tc=(mean(abs(cTab))+0.1)*feasBias;
                        %b2=log(exploration.feasTempMin/exploration.feasTempMax);
                        %Tc=exploration.feasTempMax * exp(b2 * exploration.completion);
                        %Tc=exploration.feasTemp;
                    end

                        c(a)= exp(-cTab(a)/1);
                    
                    %if cTab(a)>=feasCutoff && not(isempty(find(cTab==0)))
                    %    c(a)=0;
                    %end
                        g(a)= exp(agent(a)/(T));  
                        %p(a) = g(a)*c(a);   
                 %if cTab(a)>=feasCutoff && not(isempty(find(cTab==0)))
                 %    p(a)=0;
                 %end
                 %if (isempty(find(cTab==0))) && exploration.completion>=0.5
                 %   p(a)=c(a)+p(a)/numel(agent); 
                 %end
                         
            end
            
            
            g = g / sum(g);
            c=c/sum(c);
            for a=1:numel(agent)
                if c(a)<=0.001
                    c(a)=0;
                end
            end
            
            
            p=g.*c;
            p=p/sum(p);
            
            actionToTake = find(isnan(p));
            if isempty(actionToTake)
                % Pick an action according to the probabilities in p
                actionToTake = randsample(1:numel(agent), 1, true, p);                
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
            clear g c p
        end
    end
end