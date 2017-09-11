function [xpts,ypts]=init_pts(UB,LB,maxzones, Qinit);

for ag=1:numel(UB)
    xpts{ag}=linspace(LB(ag),UB(ag),maxzones(ag)+1);
    ypts{ag}=Qinit*ones(1,maxzones(ag)+1);
end

end