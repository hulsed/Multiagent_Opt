function sys=design_sys(battery, motor, prop, foil, rod, res, motorNum)


%Mass of system
resMass=0.3; %TEMP: Defines the mass of the rest of the quadrotor not designed.       
sys.mass = 4*motor.Mass + battery.Mass+4*rod.Mass+4*prop.mass+res.mass;
    %Note: thrust required from each motor is one-fourth the total mass.
%Planform Area of system
sys.planArea=4*rod.planArea+4*motor.planArea+res.planArea;

%Nat frequency of motor, prop and rod system.
sys.natFreq=sqrt(rod.Stiffness./(0.5*rod.Mass+motor.Mass+prop.mass))/(2*pi);

% Hijacking sys struct -B :)
sys.motorNum = motorNum;

end