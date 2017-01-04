function hover = calc_hover(battery, motor, prop, foil, rod)

%calculating requirements specified to qprop
resMass=0.3; %TEMP: Defines the mass of the rest of the quadrotor not designed.       
totMass = 4*motor.Mass + battery.Mass+4*rod.Mass+resMass;
%Note: thrust required from each motor is one-fourth the total mass.
thrustReq = totMass*9.81/4;

%specified inputs to qprop:
velStr='0.0';       %velocity (m/s)
thrustStr=num2str(thrustReq);
mode='singlepoint'; % specify singlepoint or multipoint runs

%qprop inputs left open:
rpmStr='0';         %rpm
voltStr='0';        % voltage
dBetaStr='0';       %Dbeta, the pitch-change angle (for adjustable pitch motors)
torqueStr='0';      %Torque (N-m)
ampsStr='0';        %Amps (A)
peleStr='0';        %Electrical Power Used

hover=call_qprop(velStr, rpmStr, voltStr, dBetaStr, thrustStr, torqueStr, ampsStr, peleStr, mode);

end