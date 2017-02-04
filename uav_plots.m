global stateful

% _S suffix means SCALED
%maxflightTime_S = maxflightTime/60;
%flightTime_hist_S = flightTime_hist/60;
%maxG_S = maxG/60;
%G_hist_S = G_hist/60;

if useD, reward = 'D'; else reward = 'G'; end
if stateful, st = 'Stateful'; else st = 'Stateless'; end

%% Max Flight Time/Max G
if showMaxFlightTime_vs_MaxG
    figure;
    plot(maxflightTime_S, 'r');
    
    hold on
    plot(maxG_S, 'k-.', 'LineWidth', 2);
    legend('Max Flight Time (minutes)', 'Max G');
    Title = ['Performance using ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', ' st];
    title(Title)
    xlabel('Run')
end

%% Avg Flight Time/Avg G + Max G Achieved (1 per run)
if showAvgFlightTime_AvgG_MaxGAchieved
    figure;
    plot(mean(G_hist_S), 'LineWidth', 1.25);

    hold on
    plot(epochOfMax, maxG_S, 'o')

    L = size(flightTime_hist_S, 2);
    x = [1 10:10:L];

    avgflightTime = mean(flightTime_hist_S, 1);
    error = std(flightTime_hist_S,1,1);
    neg=avgflightTime-min(flightTime_hist_S(:,:));
    pos=max(flightTime_hist_S(:,:))-avgflightTime;
    
    errorbar(x, avgflightTime(x), neg(x),pos(x), 'r', 'LineWidth', 1);

    Ymax = max(max(flightTime_hist_S(:,end)) * 1.5, 5);
    axis([1, numel(avgflightTime), 0, Ymax])
    Title = [mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', ' st];
%     Title = [mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    title(Title)
    xlabel('Epoch')
    legend('Average G', 'Max G Achieved', 'Average Flight Time (minutes)', 'Location', 'northwest')
end

%% Plot just average flight time
if showJustAvgFlightTime
    L = size(flightTime_hist_S, 2);
    x = [1 10:10:L];

    if ~exist('avgflightTime', 'var')
        avgflightTime = mean(flightTime_hist_S, 1);
        error = std(flightTime_hist_S,1,1);
    end
    
    figure;
    errorbar(x, avgflightTime(x), error(x), 'r', 'LineWidth', 1);

    Ymax = max(max(avgflightTime) * 1.05, 5);
    axis([1, numel(avgflightTime), 0, Ymax])
    %Title = ['Time in the Air - ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    Title = ['Time in the Air - ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', ' st];
    title(Title)
    xlabel('Epoch')
    ylabel('Average Flight Time (minutes)')
end
%% Plot cost
if showCost
    L = size(flightTime_hist_S, 2);
    x = [1 10:10:L];
        
        
        avgcost = mean(Objectives_hist.totalCost);
        neg=avgcost-min(Objectives_hist.totalCost);
        pos=max(Objectives_hist.totalCost)-avgcost;
    
    figure;
    plot(avgcost);
    hold on
    errorbar(x, avgcost(x), neg(x), pos(x), 'r', 'LineWidth', 1);

    Ymax = max(max(avgcost) * 1.05, 5);
    axis([1, numel(avgcost), 0, Ymax])
    %Title = ['Time in the Air - ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    Title = ['Quadrotor Cost - ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', ' st];
    title(Title)
    xlabel('Epoch')
    ylabel('Average Cost (Dollars)')
end

%% Plot Energy Used
if showEnergy
    L = size(flightTime_hist_S, 2);
    x = [1 10:10:L];
        
        
        avgenergy = mean(Objectives_hist.climbEnergy);
        neg=avgenergy-min(Objectives_hist.climbEnergy);
        pos=max(Objectives_hist.climbEnergy)-avgenergy;
    
    figure;
    plot(avgenergy);
    hold on
    errorbar(x, avgenergy(x), neg(x), pos(x), 'r', 'LineWidth', 1);

    Ymax = min(min(avgenergy) * 10);
    axis([1, numel(avgenergy), 0, Ymax])
    %Title = ['Time in the Air - ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    Title = ['Quadrotor Climb Energy - ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', ' st];
    title(Title)
    xlabel('Epoch')
    ylabel('Average Energy (Joules)')
end

%% Constraint Violation
if showConstraintViolation
    figure; %Plot constraint violation at final epoch       
    medconst=median(bestConstraints(:,:))
    bar(medconst)
    
    hold on
    neg=medconst-min(bestConstraints(:,:));
    pos=max(bestConstraints(:,:))-medconst;
    errorbar([1:8],medconst,neg,pos, '.')

    Title=['Constraint Values of converged designs'];
    title(Title)
    xlabel('Constraint Number')
    ylabel('Value')
end
if altplots
    figure;

    
    %avgbest=mean(bestGhist);
    medbest=nanmedian(bestGhist);
    neg=medbest-min(bestGhist);
    pos=max(bestGhist)-medbest;
    
    for r=1:numRuns
        for h=1:length(medbest)
            if ~isnan(bestGhist(r,h))
                endptx(r)=h;
                endpty(r)=bestGhist(r,h);
            end
            if ~isnan(medbest(h))
                graphend=h;
             end
        end
    end
    endpt=[endptx;endpty];
    for r=1:numRuns
            numdup{r}=sum(endptx(r)==endptx);
    end
    % Plot line without errorbars. Contains all points.
    plot(1:graphend, medbest(1:graphend), 'k')
    hold on
    L = size(medbest, 2);
    x = [1 10:10:L];
    % Plot errorbar about every 10 points
    % NOTE: Must go into plot editor thing to remove line without removing
    % error bars
    errorbar(x, medbest(x),neg(x),pos(x), 'k')
    %errorbar([1:graphend], medbest(1:graphend),neg(1:graphend),pos(1:graphend))
    Title=['Agent Optimization Over ' num2str(numRuns) ' runs'];
    title(Title)
    xlabel('Learning Cycles')
    ylabel('Performance G')
    xlim([0,graphend])
    ylim([0.25*min(min(bestGhist)),1.1*max(max(bestGhist))])
    plot(endptx, endpty, 'o', 'color','r')
    grid on
    grid minor
    %for r=1:numRuns
    %    text(endptx(r), endpty(r),num2str(numdup{r}))
    %end
figure;
boxplot(endpty, 'orientation', 'horizontal')
% axis([900,2300, 0.9, 1.1])
title('Best values found by each run')

grid on
grid minor
% hold on
% plot([2204.4],[1], '*', 'color', 'k', 'MarkerSize', 9)
    
end

hold off % I think this might be good to put
