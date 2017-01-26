 function [rewards, cUpdate, G,Objectives, constraints,hover] = compute_rewards(useD, ...
     penalty,scaleFactor, battery, motor, prop, foil, rod,sys,res, data)
    % I included the material in the inputs because I didn't know how to
    % compute the counterfactual rod otherwise... -B
    
    % Global System Performance
    [G, Objectives, constraints,hover] = calc_G(penalty, ...
        scaleFactor, battery, motor, prop, foil, rod, sys);
    
    %ostensibly this is also where we calculate constraint penalties.
    
    if ~useD % if NOT using difference reward
        rewards = ones(13, 1) * G; % Just return G for all rewards
        
    else

        rewards = zeros(13, 1);
        for ag = 1:13
            rewards(ag, 1)=switch_diff(ag,G, penalty,scaleFactor, battery, motor, prop, foil, rod,sys,res, data);
        end   
    end
    
    cUpdate = zeros(14, 1);
    for ag = 1:14
        switch ag
            case 1 % battery cell
                cUpdate(ag) = max(0, constraints(1)) + max(0, constraints(3)) + max(0, constraints(4));
            case 2 % serial configs
                cUpdate(ag) = max(0, constraints(1)) + max(0, constraints(2)) + max(0, constraints(3)) + max(0, constraints(4));
            case 3 % parallel configs
                cUpdate(ag) = max(0, constraints(1)) + max(0, constraints(2)) + max(0,constraints(3)) + max(0, constraints(4));
            case 4 % motor
                cUpdate(ag) = max(0, constraints(1)) + max(0, constraints(2)) + max(0,constraints(5)) + max(0, constraints(6))+max(0, constraints(7));
            case 5 % foil
                true;
            case 6 %diameter
                cUpdate(ag) = max(0,constraints(8))+max(0,constraints(7));
            case 7 % root alpha
                cUpdate(ag) = max(0, constraints(1))+ max(0, constraints(2)) + max(0, constraints(7));
            case 8 % tip alpha
                true;
            case 9 % root chord
                cUpdate(ag) = max(0, constraints(1))+ max(0, constraints(2)) + max(0, constraints(7));
            case 10 % tip chord
                true;
            case 11 % material
                cUpdate(ag) =  max(0, constraints(7)) + max(0, constraints(8));
            %case 12 % length
            %    cUpdate(ag) =   max(0, constraints(8)) + max(0, constraints(8));
            case 12 % diameter
                cUpdate(ag) = max(0, constraints(7)) + max(0, constraints(8));
            case 13 % thickness
                cUpdate(ag) =  max(0, constraints(7)) + max(0, constraints(8));
        end
    end
end
