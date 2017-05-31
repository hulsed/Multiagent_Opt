% Using the foundMerit received by each agent, update their Q-tables

% INPUTS
% expMerit - cell array of Q-tables, one for each variable
% foundMerit - vector of foundMerit, element i is the reward received by agent i
% x - vector of integers, element i is the action taken by agent i
% alpha - the learning rate, 0 < alpha <= 1

% OUTPUTS
% The expMerit with updated Q-tables
function [expMerit, learned,objimprovement,conimprovement] = update_merit(expMerit, foundMerit_obj, foundMerit_con, alpha, x, learnmode)
    
    learned=zeros(1,numel(expMerit)/2);
    objimprovement=zeros(1,numel(expMerit)/2);
    conimprovement=zeros(1,numel(expMerit)/2);
    
    % Iterate through variables
    for ag = 1:(numel(expMerit)/2)
        % Get the current merit of the parameter value chosen in previous state
        Q_con = expMerit{ag,1}(x(ag));
        Q_obj = expMerit{ag,2}(x(ag));
        
        %estimating the difference reward--what the global learning would
        %have been if the found design had the merit of an average action.
        %Qavg=mean(expMerit{ag});
        %for ag2= 1:numel(expMerit)
            %Q2=expMerit{ag2}(x(ag2));
            %if Q2>foundMerit(ag2)
                %CounterEst(ag2)=Qavg-foundMerit(ag2);
            %else
            %    CounterEst=-Qavg;
            %end
        %end
        %DiffEst(ag)=sum(CounterEst);

        
            switch learnmode
                case 'RL'      
            expMerit{ag}( x(ag)) = Q_obj + alpha*(foundMerit(ag) - Q_obj);
                case 'best'
                    
                    if Q_con>foundMerit_con(ag)
                       learned(ag)=1;
                       
                       conimprovement(ag)=(Q_con-foundMerit_con(ag));
                       
                       if Q_obj<foundMerit_obj
                            objimprovement(ag)=Q_obj-foundMerit_obj(ag);
                       else
                           objimprovement(ag)=0;
                       end
                       
                       expMerit{ag,1}(x(ag)) = foundMerit_con(ag);
                       expMerit{ag,2}(x(ag)) = foundMerit_obj(ag);
                       
                    elseif Q_con==foundMerit_con(ag)
                        if Q_obj<foundMerit_obj(ag)
                            learned(ag)=1;
                            
                            objimprovement(ag)=Q_obj-foundMerit_obj(ag);
                            conimprovement(ag)=0;
                            
                            expMerit{ag,1}(x(ag)) = foundMerit_con(ag);
                            expMerit{ag,2}(x(ag)) = foundMerit_obj(ag);
                            
                        end
                    else
                        learned(ag)=0;
                        
                        objimprovement(ag)=0;
                        conimprovement(ag)=0;
                        
                        expMerit{ag,1}(x(ag)) = expMerit{ag,1}(x(ag));
                        expMerit{ag,2}(x(ag)) = expMerit{ag,2}(x(ag));                        
                    end
                    

            end
    end
end