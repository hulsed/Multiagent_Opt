function sys=design_sys(battery,motor,prop,foil,rod)

%Mass of system
resMass=0.3; %TEMP: Defines the mass of the rest of the quadrotor not designed.       
sys.mass = 4*motor.Mass + battery.Mass+4*rod.Mass+4*prop.mass+resMass;
    %Note: thrust required from each motor is one-fourth the total mass.

end