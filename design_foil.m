function foil = design_foil(actions, foilData)
    % Characterizing propeller.
    foil.Cl0=foilData(actions(5),1);
    foil.Cla=foilData(actions(5),2)*360/(2*pi); %converting to 1/deg to 1/rad
    foil.Clmin=foilData(actions(5),3);
    foil.Clmax=foilData(actions(5),4);
    foil.Cd0=foilData(actions(5),5);
    foil.Cd2=foilData(actions(5),6)*360/(2*pi); %converting to 1/deg to 1/rad
    foil.Clcd0=foilData(actions(5),7);
    foil.Reref=foilData(actions(5),8);
    foil.Reexp=foilData(actions(5),9);
    foil.Num=foilData(actions(5),10);
end