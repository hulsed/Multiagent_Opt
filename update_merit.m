% Using the foundMerit received by each agent, update their Q-tables

% INPUTS
% expMerit - cell array of Q-tables, one for each variable
% foundMerit - vector of foundMerit, element i is the reward received by agent i
% x - vector of integers, element i is the action taken by agent i
% alpha - the learning rate, 0 < alpha <= 1

% OUTPUTS
% The expMerit with updated Q-tables
function [expMerit, learned,expimprovement,DiffEst] = update_merit(expMerit, foundMerit, alpha, x, learnmode)
    
    learned=zeros(1,numel(expMerit));
    expimprovement=zeros(1,numel(expMerit));
    
    % Iterate through variables
    for ag = 1:numel(expMerit)
        % Get the current merit of the parameter value chosen in previous state
        Q = expMerit{ag}(x(ag));
        
        %estimating the difference reward--what the global learning would
        %have been if the found design had the merit of an average action.
        Qavg=mean(expMerit{ag});
        for ag2= 1:numel(expMerit)
            Q2=expMerit{ag2}(x(ag2));
            %if Q2>foundMerit(ag2)
                CounterEst(ag2)=Qavg-foundMerit(ag2);
            %else
            %    CounterEst=-Qavg;
            %end
        end
        DiffEst(ag)=sum(CounterEst);

        
            switch learnmode
                case 'RL'      
            expMerit{ag}( x(ag)) = Q + alpha*(foundMerit(ag) - Q);
                case 'best'
                    if Q>foundMerit(ag)
                       learned(ag)=1;
                       expimprovement(ag)=Q-foundMerit(ag);
                    else
                        learned(ag)=0;
                        expimprovement(ag)=0;
                    end
                    expMerit{ag}(x(ag)) = min(Q,foundMerit(ag));

            end
    end
end