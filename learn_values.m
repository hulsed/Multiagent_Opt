function values=learn_values(values,actions,reward,alpha);
    
    % Iterate through agents value tables
    for ag = 1:numel(values)
        % Get the current merit of the parameter value chosen in previous state
        Q = values{ag}(actions(ag));
             
        values{ag}( actions(ag)) = Q + alpha*(reward - Q);
    end

end