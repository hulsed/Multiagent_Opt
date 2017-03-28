function meritfxn=init_meritfxn(UB,LB,tol, Qinit);

for ag=1:numel(UB)
    xvals=LB(ag):tol(ag):UB(ag);
    yvals=Qinit*ones(1,numel(xvals));
    meritfxn{ag}=[xvals;yvals];
end

end