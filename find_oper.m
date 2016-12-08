function [hover,fail] = find_oper(battery, motor, prop, foil, rod, perf)


resMass=0.3; %TEMP: Defines the mass of the rest of the quadrotor not designed.       
totMass = 4*motor.Mass + battery.Mass+4*rod.Mass+resMass;
%Note: thrust required from each motor is one-fourth the total mass.
thrustReq = totMass*9.81/4; 

%calculate hover characteristic
fail=0;
stoptime=length(perf.velocity);
failindex=0;
%Finds the first place in the vector when thrust is enough to meet the requirement 
for i=1:stoptime
    if perf.thrust(i)>=thrustReq
        hoverindex=i;
        break
    end
    failindex=i;
    hoverindex=0;
end
%if it reaches the end of the vector without finding enough thrust, it
%reports a failure
if failindex==stoptime 
    fail=1;
end

if ~fail 
    if hoverindex==1
        hover=assign_perf(perf,hoverindex);
    elseif hoverindex>1
        hover=interpol_oper(perf,thrustReq, hoverindex);
    else
        hover=init_perf;
    end
    
    hover.index=hoverindex;
    %hover.pelec=perf.pelec(hoverindex);     

else
    hover=init_perf;
    hover.index=hoverindex;
    hover.pelec=Inf;
end
  
    
end