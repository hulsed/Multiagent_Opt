function actions=choose_actions(values,T)

    % initialize vector of integers corresponding to the choices for each
    % parameter
    numAgents = numel(values);
    actions = uint8(zeros(numAgents, 1));
% Iterate through the variables
    for ag = 1:numel(values)
        
            % merit function for that specific variable
            % NOTE: the sign is inverted so that the best value is chosen
            % (since the best has the lowest objective value)
            value = values{ag};
            epsilon=0.05;
            
            dice=rand;
            if dice>epsilon
                [val,ChosenAction]=max(value);
            else
                ChosenAction=randi(numel(value));
            end
            
            %softmax selection (Note: a lower value in the merit function 
            %corresponds to a lower value of the objective function, makeing
            %)
%             p= exp(value);                  
%             p=p/sum(p);
%             
%             %chooses value for the variable if softmax breaks
%             ChosenAction = find(isnan(p));
%             
%             if isempty(ChosenAction)
%                 % Pick an action according to the probabilities in p
%                 try
%                     ChosenAction = randsample(1:numel(value), 1, true, p);
%                 catch
%                     p % in case it produces a complex number
%                     ChosenAction = randsample(1:numel(value), 1, true, p);
%                 end
%             else
%                 disp('Softmax broke due to infinite exponential!')
%                 disp('Picking between three best')
%                 [sorting,ranking]=sort(value);
%                 dice=randi(20,1);
%                 if dice<=16
%                     ChosenAction=ranking(1);
%                 elseif 16<dice<=19
%                     ChosenAction=ranking(2);
%                 else 
%                     ChosenAction=ranking(3);
%                 end
%                     
             %end
            
            actions(ag) = ChosenAction;   
            clear p
    end

end