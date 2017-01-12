function best=structure_best(G_hist,Objectives_hist, constraint_hist,numRuns, epochOfBest)

for a=1:numRuns
best.G(a,1)=G_hist(a,epochOfBest(a))';
best.flighttimes_mins(a,1)=Objectives_hist.flightTime(a,epochOfBest(a))'/60;
best.climbenergy(a,1)=Objectives_hist.climbEnergy(a,epochOfBest(a))';
best.cost(a,1)=Objectives_hist.totalCost(a,epochOfBest(a))';

best.g1(a,1)=constraint_hist(1,a,epochOfBest(a));
best.g2(a,1)=constraint_hist(2,a,epochOfBest(a));
best.g3(a,1)=constraint_hist(3,a,epochOfBest(a));
best.g4(a,1)=constraint_hist(4,a,epochOfBest(a));
best.g5(a,1)=constraint_hist(5,a,epochOfBest(a));
best.g6(a,1)=constraint_hist(6,a,epochOfBest(a));
best.g7(a,1)=constraint_hist(7,a,epochOfBest(a));
best.g8(a,1)=constraint_hist(8,a,epochOfBest(a));
end

end