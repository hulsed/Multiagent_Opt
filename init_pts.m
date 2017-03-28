function [xpts,ypts]=init_pts(UB,LB,maxzones, Qinit);

for ag=1:numel(UB)
    xpts{ag}=linspace(LB(ag),UB(ag),maxzones(ag));
    ypts{ag}=Qinit*ones(1,maxzones(ag));
end

end