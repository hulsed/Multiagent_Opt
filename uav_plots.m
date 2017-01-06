global stateful

% _S suffix means SCALED
maxflightTime_S = maxflightTime/60;
flightTime_hist_S = flightTime_hist/60;
maxG_S = maxG/60;
G_hist_S = G_hist/60;

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
    errorbar(x, avgflightTime(x), error(x), 'r', 'LineWidth', 1);

    Ymax = max(max(maxG_S) * 1.01, 5);
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

%% Constraint Violation
if showConstraintViolation
    figure; %Plot constraint violation at final epoch       
    bar(median(constraint_hist(:,:,numEpochs)'))
    
    hold on
    neg=median(constraint_hist(:,:,numEpochs)')-min(constraint_hist(:,:,numEpochs)');
    pos=max(constraint_hist(:,:,numEpochs)')-median(constraint_hist(:,:,numEpochs)');
    errorbar([1:8],median(constraint_hist(:,:,numEpochs)'),neg,pos, '.')

    Title=['Final Constraint Values, ' penmode ' parameters: ' num2str(pennum) ', ' st];
    title(Title)
    xlabel('Constraint Number')
    ylabel('Value')
end

hold off % I think this might be good to put
