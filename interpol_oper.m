function oper=interpol_oper(perf,thrustReq, index)
%using linear interpolation y=y1+(y2-y1)*(x-x1)/(x2-x1)

%scale factor (x-x1)/(x2-x1)
factor=(thrustReq-perf.thrust(index));

oper.velocity=perf.velocity(index-1)+(perf.velocity(index-1)-perf.velocity(index))*factor;
oper.rpm=perf.rpm(index-1)+(perf.rpm(index-1)-perf.rpm(index))*factor;
oper.dbeta=perf.dbeta(index-1)+(perf.dbeta(index-1)-perf.dbeta(index))*factor;
oper.thrust=thrustReq;
oper.q=perf.q(index-1)+(perf.q(index-1)-perf.q(index))*factor;
oper.pshaft=perf.pshaft(index-1)+(perf.pshaft(index-1)-perf.pshaft(index))*factor;
oper.volts=perf.volts(index-1)+(perf.volts(index-1)-perf.volts(index))*factor;
oper.amps=perf.amps(index-1)+(perf.amps(index-1)-perf.amps(index))*factor;
oper.effmotor=perf.effmotor(index-1)+(perf.effmotor(index-1)-perf.effmotor(index))*factor;
oper.effprop=perf.effprop(index-1)+(perf.effprop(index-1)-perf.effprop(index))*factor;
oper.adv=perf.adv(index-1)+(perf.adv(index-1)-perf.adv(index))*factor;
oper.ct=perf.ct(index-1)+(perf.ct(index-1)-perf.ct(index))*factor;
oper.cp=perf.cp(index-1)+(perf.cp(index-1)-perf.cp(index))*factor;
oper.dv=perf.dv(index-1)+(perf.dv(index-1)-perf.dv(index))*factor;
oper.eff=perf.eff(index-1)+(perf.eff(index-1)-perf.eff(index))*factor;
oper.pelec=perf.pelec(index-1)+(perf.pelec(index-1)-perf.pelec(index))*factor;
oper.pprop=perf.pprop(index-1)+(perf.pprop(index-1)-perf.pprop(index))*factor;
oper.clavg=perf.clavg(index-1)+(perf.clavg(index-1)-perf.clavg(index))*factor;
oper.cdavg=perf.cdavg(index-1)+(perf.cdavg(index-1)-perf.cdavg(index))*factor;
end