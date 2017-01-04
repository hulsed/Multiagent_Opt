function [prop,foil] = design_prop(actions, propData,foilData)
    % Propeller Calculations
    %prop.airfoil = propData(actions(5), 1); % propeller prop.airfoil
    diameter = propData(actions(6), 2)*0.0254; % diameter (inch->m)
    angleRoot = propData(actions(7), 3); % blade angle at root
    angleTip = propData(actions(8), 4); % blade angle at tip
    chordRoot = propData(actions(9), 5)*0.0254; % chord at root (inch->m)
    chordTip = propData(actions(10), 6)*0.0254; % chord at tip (inch->m)
    
    %Foil Calculations
    chordAvg=mean([chordRoot, chordTip]);
    foil = design_foil(actions, foilData);
    
    foilnum=['NACA00' num2str(foil.Num)];
    avgThickness=0.01*foil.Num*chordAvg;
    xsArea=0.5*avgThickness*chordAvg; %assuming may be approximated as a triangle
    vol=xsArea*diameter;
    %Note: assuming propeller is polycarb (1190 kg/m^3)
    mass=vol*1190;
    
    prop = create_prop(diameter, angleRoot, angleTip, chordRoot, chordTip,mass);
end