function prop = design_prop(actions, propData)
    % Propeller Calculations
    %prop.airfoil = propData(actions(5), 1); % propeller prop.airfoil
    diameter = propData(actions(6), 2)*0.054; % diameter (inch->m)
    angleRoot = propData(actions(7), 3); % blade angle at root
    angleTip = propData(actions(8), 4); % blade angle at tip
    chordRoot = propData(actions(9), 5)*0.054; % chord at root (inch->m)
    chordTip = propData(actions(10), 6)*0.054; % chord at tip (inch->m)
    %NOTE: Need prop mass!
    
    prop = create_prop(diameter, angleRoot, angleTip, chordRoot, chordTip);
end