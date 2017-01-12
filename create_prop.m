% Creates a prop object with given parameters
function prop = create_prop(diameter, angleRoot, angleTip, chordRoot, chordTip,foil)
    prop.diameter = diameter; % meters
    prop.angleRoot = angleRoot; % blade angle at root
    prop.angleTip = angleTip; % blade angle at tip
    prop.chordRoot = chordRoot; % chord at root (inch->m)
    prop.chordTip = chordTip; % chord at tip (inch->m)
    
    chordAvg=mean([chordRoot, chordTip]);
    foilnum=['NACA00' num2str(foil.Num)];
    avgThickness=0.01*foil.Num*chordAvg;
    xsArea=0.5*avgThickness*chordAvg; %assuming may be approximated as a triangle
    vol=xsArea*diameter;
    %Note: assuming propeller is polycarb (1190 kg/m^3)
    mass=vol*1190;
    %Note: assuming propeller is polycarb (0.29 $/in^3)
    costdens=0.29*(100/2.54)^3;
    cost=costdens*vol;
    
    prop.mass=mass;
    prop.cost=cost;
end