function actions=choose_actions(values, epsilon)

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
            
            dice=rand;
            if dice>epsilon
                [val,ChosenAction]=max(value);
            else
                ChosenAction=randi(numel(value));
            end
            
            
            actions(ag) = ChosenAction;   
            clear p
    end

end