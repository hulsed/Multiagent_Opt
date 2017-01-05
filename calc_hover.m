function [hover] = calc_hover(sys)

thrustReq = sys.mass*9.81/4;

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

hover=call_qprop(velStr, rpmStr, voltStr, dBetaStr, thrustStr, torqueStr, ampsStr, peleStr, mode, sys.motorNum);


if hover.thrust<0.9*thrustReq
hover.failure=1;  
else
hover.failure=0;   
end

end