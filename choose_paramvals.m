% Make agents choose an action

% INPUTS
% expMerit - the cell array of the expected merit of each choice for a variable, each cell containing a Q-table
% completion - the completion of the learning cycle
% TMin, the minimum temperature for 

% OUTPUTS
% x - column vector of integers, element i corresponds to the chosen value
% for the variable i.
function x = choose_paramvals(expMerit, temps, w1s, w2s,conscale)
    
    % initialize vector of integers corresponding to the choices for each
    % parameter
    numChoices = numel(expMerit)/2;
    x = uint8(zeros(numChoices, 1));
    
    % Iterate through the variables
    for ag = 1:numChoices
        
            % merit function for that specific variable
            % NOTE: the sign is inverted so that the best value is chosen
            % (since the best has the lowest objective value)
            
            w1=w1s(ag);
            w2=w2s(ag);
            
            merit = -w1*conscale*expMerit{ag,1}-w2*expMerit{ag,2};

            T=temps(ag);
            
            %softmax normalization
            merit2=1./(1+exp(-(merit-mean(merit))/(std(merit)+0.1)));
            
            %softmax selection (Note: a lower value in the merit function 
            %corresponds to a lower value of the objective function, makeing
            %)
            p= exp(merit2./(T));                  
            p=p/sum(p);
            
            %chooses value for the variable if softmax breaks
            ChosenValue = find(isnan(p));
            
            if isempty(ChosenValue)
                % Pick an action according to the probabilities in p
                try
                    ChosenValue = randsample(1:numel(merit), 1, true, p);
                catch
                    p % in case it produces a complex number
                    ChosenValue = randsample(1:numel(merit), 1, true, p);
                end
            elseif T==0
                [val,Chosen]=max(merit2);
                
                vals=merit2==val;
                die=vals.*rand(1,numel(vals));
                [num,ChosenValue]=max(die);
                
            else
                [val,Chosen]=max(merit2);
                
                vals=merit2==val;
                die=vals.*rand(1,numel(vals));
                [num,ChosenValue]=max(die);
                    
            end

            x(ag) = ChosenValue;   
            clear p
    end
end