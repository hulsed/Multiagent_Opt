function [fail,elec_power_used]=run_qprop(max_voltage, thrust_req, batteryImax, motorImax)
vel=0.0;
%max_voltage=20
%thrust_req=1.0

volt_incr=1;
%rpm=0
%Rpm2=3600
%dRpm=600
fail=0;

%converting parameters to strings.
velstr=num2str(vel);
if velstr=='0'
    velstr='0.0';
end
disp('num2str')
max_voltagestr=num2str(max_voltage);
volt_incrstr=num2str(volt_incr);
thruststr=num2str(thrust_req);
disp('qpropinput')
qpropinput=['qprop.exe propfile motorfile ', velstr, ' 0',' 0',',',max_voltagestr,',',volt_incrstr, ' 0 ' thruststr, ' 0 0 0 ["]' ];
disp('got qpropinput')
%Note about qprop syntax:
%The input looks like
%qprop propfile motorfile vel rpm volt dBeta Thrust Torque Amps Pele 
% 0 means unspecified
% to iterate over values, replace a single value with min,max,incr
pause(0.05)
diary qpropoutput
system(qpropinput);
diary OFF
%disp('1') 
scantext = -1;
while scantext < 3
    scantext=fopen('qpropoutput');
end
%disp('2')
disp('textscan')
textscanoutput=textscan(scantext, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Headerlines', 18);
%disp('3')
fclose('all');
%disp('4')
%disp('5')

velocity_qout=textscanoutput{1};
rpm_qout=textscanoutput{2};
Dbeta_qout=textscanoutput{3};
thrust_qout=textscanoutput{4};
q_qout=textscanoutput{5};
pshaft_qout=textscanoutput{6};
volts_qout=textscanoutput{7};
amps_qout=textscanoutput{8};
effmotor_qout=textscanoutput{9};
effprop_qout=textscanoutput{10};
adv_qout=textscanoutput{11};
ct_qout=textscanoutput{12};
cp_qout=textscanoutput{13};
dv_qout=textscanoutput{14};
eff_qout=textscanoutput{15};
pelec_qout=textscanoutput{16};
pprop_qout=textscanoutput{17};
clavg_qout=textscanoutput{18};
cdavg_qout=textscanoutput{19};

stoptime=length(velocity_qout);
failindex=0;
for i=1:stoptime
    if thrust_qout(i)>=thrust_req
        hoverindex=i;
        break
    end
    failindex=i;
end
if failindex==stoptime || batteryImax <= amps_qout(hoverindex) || motorImax <= amps_qout(hoverindex)
    fail=1;
end
    
if ~fail 
    elec_power_used=pelec_qout(hoverindex);
else
    elec_power_used=Inf;
end
delete('qpropoutput')
