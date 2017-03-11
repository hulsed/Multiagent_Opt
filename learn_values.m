function values=learn_values(values,actions,rewards,alpha);
    
    % Iterate through agents value tables
    for ag = 1:numel(values)
        % Get the current merit of the parameter value chosen in previous state
        Q = values{ag}(actions(ag));
             
        values{ag}( actions(ag)) = Q + alpha*(rewards(ag) - Q);
    end

end