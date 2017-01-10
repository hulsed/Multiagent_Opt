function [climb] = calc_climb(sys,vel)

cd=1.5;     % assumed coefficent of drag (quadrotor is a blunt object)
rho=1.225;   % kg/m^3, density of air
drag=0.5*rho*cd*sys.planArea*vel^2;
thrustReq = (drag + sys.mass*9.81)/4;

%specified inputs to qprop:
%specified inputs to qprop:
    if vel==0
        velStr='0.0';
    else
        velStr=num2str(vel);       %velocity (m/s)
    end
    if thrustReq==0
        thrustStr='0.0';
    else
        thrustStr=num2str(thrustReq);
    end
mode='singlepoint'; % specify singlepoint or multipoint runs

%qprop inputs left open:
rpmStr='0';         %rpm
voltStr='0';        % voltage
dBetaStr='0';       %Dbeta, the pitch-change angle (for adjustable pitch motors)
torqueStr='0';      %Torque (N-m)
ampsStr='0';        %Amps (A)
peleStr='0';        %Electrical Power Used

climb=call_qprop(velStr, rpmStr, voltStr, dBetaStr, thrustStr, torqueStr, ampsStr, peleStr, mode, sys.motorNum);


if climb.thrust<0.9*thrustReq
climb.failure=1;  
else
climb.failure=0;   
end

if isnan(climb.pelec)
    climb.pelec=10e9;
end

end
