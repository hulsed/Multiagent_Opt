function [climbEnergy,climbFailure]=calc_maxclimb(sys, battery,motor)

distance= 300; % climb distance in meters--temp, should be specified elsewhere
%velocity range iterating over (maybe this should be justified somehow?)
veliter=2;  %m/s
maxvel=50; %m/s, max velocity worth considering
vel(1)=0;
volts=0;
i=0;
climbFailure=0;
climb=init_perf();
while volts<battery.Volt
    i=i+1;
    cd=1.5;     % assumed coefficent of drag (quadrotor is a blunt object)
    rho=1.225;   % kg/m^3, density of air
    drag=0.5*rho*cd*sys.planArea*vel(i)^2;
    thrustReq = drag + sys.mass*9.81/4;


    %specified inputs to qprop:
    if vel(i)==0
        velStr='0.0';
    else
        velStr=num2str(vel(i));       %velocity (m/s)
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

    climb(i)=call_qprop(velStr, rpmStr, voltStr, dBetaStr, thrustStr, torqueStr, ampsStr, peleStr, mode, sys.motorNum);
    volts=climb(i).volts;
    vel(i+1)=vel(i)+veliter;
    if vel>=maxvel
        break
    end
    %if climb.thrust<0.9*thrustReq
    %climb.failure=1;  
    %else
    %climb.failure=0;   
    %end
    if isnan(climb(i).pelec)
        climbFailure=1;
        climb(i).pelec=100000;
    end
    if climb(i).pelec>4*motor.Pmax
        break
    end
end
maxclimb=climb(i);

for a=1:i
    time(a)=distance/vel(a);
    energy(a)=time(a)*climb(a).pelec;
end
[climbEnergy,loc]=min(energy);
if loc==1
    climbEnergy=100000;
end
end