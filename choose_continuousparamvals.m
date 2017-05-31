% Make agents choose an action

% INPUTS
% meritfxn - the cell array of the expected merit for each value of the
% variable
% temps - chosen temperature to choose the variable value with

% OUTPUTS
% x - column vector of floating-point numbers, element i corresponds to the chosen value
% for the variable i.
function x_cont = choose_continuousparamvals(meritfxn, temps, w1s, w2s,conscale)
    
    % initialize vector of integers corresponding to the choices for each
    % parameter
    numChoices = numel(meritfxn);
    x_cont =(zeros(numChoices, 1));
    
    % Iterate through the variables
    for ag = 1:numel(meritfxn)
        
            % merit function for that specific variable
            % NOTE: the sign is inverted so that the best value is chosen
            % (since the best has the lowest objective value)
            
            w1=w1s(ag);
            w2=w2s(ag);
            
            merit = -w1*conscale*meritfxn{ag}(2,:)-w2*meritfxn{ag}(3,:);

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
            else
                disp('Softmax broke due to infinite exponential!')
                disp('Picking between three best')
                [sorting,ranking]=sort(merit);
                dice=randi(20,1);
                if dice<=16
                    ChosenValue=ranking(1);
                elseif 16<dice<=19
                    ChosenValue=ranking(2);
                else 
                    ChosenValue=ranking(3);
                end
                    
            end

            x_cont(ag) = meritfxn{ag}(1,ChosenValue);   
            clear p
    end
end