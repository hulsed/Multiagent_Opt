function sys=design_sys(battery, motor, prop, foil, rod, res, motorNum)


%Mass of system       
sys.mass = 4*motor.Mass + battery.Mass+4*rod.Mass+4*prop.mass+res.mass;
    %Note: thrust required from each motor is one-fourth the total mass.
%Planform Area of system
sys.planArea=4*rod.planArea+4*motor.planArea+res.planArea;

%Nat frequency of motor, prop and rod system.
sys.natFreq=sqrt(rod.Stiffness./(0.5*rod.Mass+motor.Mass+prop.mass))/(2*pi);

%Motor Used
sys.motorNum = motorNum;

%Cost
sys.cost=4*rod.Cost+4*motor.Cost+battery.Cost+4*prop.cost+res.cost;
%power used not including funcitonality
sys.power=res.power;

end