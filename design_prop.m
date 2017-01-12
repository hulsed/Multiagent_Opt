function [prop,foil] = design_prop(actions, propData,foilData)
    % Propeller Calculations
    %prop.airfoil = propData(actions(5), 1); % propeller prop.airfoil
    diameter = propData(actions(6), 2)*0.0254; % diameter (inch->m)
    angleRoot = propData(actions(7), 3); % blade angle at root
    angleTip = propData(actions(8), 4); % blade angle at tip
    chordRoot = propData(actions(9), 5)*0.0254; % chord at root (inch->m)
    chordTip = propData(actions(10), 6)*0.0254; % chord at tip (inch->m)
    
    %Foil Calculations
 
    foil = design_foil(actions, foilData);
    
    prop = create_prop(diameter, angleRoot, angleTip, chordRoot, chordTip, foil);
end