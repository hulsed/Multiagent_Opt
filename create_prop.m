% Creates a prop object with given parameters
function prop = create_prop(diameter, angleRoot, angleTip, chordRoot, chordTip,mass,cost)
    prop.diameter = diameter; % meters
    prop.angleRoot = angleRoot; % blade angle at root
    prop.angleTip = angleTip; % blade angle at tip
    prop.chordRoot = chordRoot; % chord at root (inch->m)
    prop.chordTip = chordTip; % chord at tip (inch->m)
    prop.mass=mass;
    prop.cost=cost;
end