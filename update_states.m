% For now, states depend on the constraints that are violated or not
% There is a state for each component (except prop)
function states = update_states(states, constraints)
    if constraints(1) <= 0
        % State meanings
        % 1 - design failed
        % 2 - all component constraints violated
        % 3 - first component constraint violated
        % 4 - second component constraint violated
        % 5 - neither constraint violated
        bState = 2*(constraints(3)<=0) + (constraints(4)<=0) + 2;
        mState = 2*(constraints(5)<=0) + (constraints(6)<=0) + 2;
        rState = 2*(constraints(7)<=0) + (constraints(8)<=0) + 2;
    else
        bState = 1;
        mState = 1;
        rState = 1;
    end
    states(1:3) = bState;
    states(4) = mState;
    states(11:13) = rState;
end