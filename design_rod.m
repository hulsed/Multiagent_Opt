function rod = design_rod(actions, rodData, matData)
    % NOTE FOR DANIEL: actions is an array of uint8
    % Just be aware that if a uint8 is multiplied with a double
    % the result is a uint8, so you lose precision
    mat.Type=actions(11);
    mat.Ymod=matData(actions(11),1); %young's modulus in GPa
    mat.Sut=matData(actions(11),2); %ultimate strength in MPa
    mat.Sy=matData(actions(11),3); %yield strength in MPa
    mat.Dens=matData(actions(11),4); %density in kg/m^3
    mat.Cost=matData(actions(11),5)*(100/2.54)^3; %cost in $/m^3
    
    length = rodData(actions(12),1)*2.54/100; %length converted to m
    diameter = rodData(actions(13),2)*2.54/100; %diamenter converted to m
    thickness = rodData(actions(14),3)*2.54/100; %thickness converted to m
    % Create the rod given everything we need
    rod = create_rod(mat, length, diameter, thickness);
end