function uav_plots(maxflightTime, flightTime_hist, maxG, G_hist, useD, AS, epochOfMax, Qinit)
    % I'm sorry this is really messy.

    maxflightTime = maxflightTime/60;
    flightTime_hist = flightTime_hist/60;
    maxG = maxG/60;
    G_hist = G_hist/60;
    
    if useD
        reward = 'D';
    else
        reward = 'G';
    end
    
    switch AS.mode
        case 'const'
            mode = 'Constant Epsilon';
        case 'decay'
            mode = 'Decaying Epsilon';
        case 'softmax'
            mode = 'Softmax';
        case 'softmaxDecay'
            mode = 'Softmax with Decaying Temp';
    end
            
    
%% Max Flight Time/Max G
    figure;
    plot(maxflightTime, 'r');
    hold on
    plot(maxG, 'k-.', 'LineWidth', 2);
    legend('Max Flight Time (minutes)', 'Max G');
    Title = ['Performance using ' mode ' (' num2str(AS.param1, '%.1f') '), ' reward ', ' num2str(Qinit, '%.1f')];
    title(Title)
    xlabel('Run')
    
    
%% Avg Flight Time/Avg G + Max G Achieved (1 per run)
    figure;
    plot(mean(G_hist), 'LineWidth', 1.25);
%     Title = ['Average G using ' mode ' (' num2str(AS.param1, '%.1f') '), ' reward];
%     title(Title)

    hold on
    plot(epochOfMax, maxG, 'o')

    
%     Ymax = max(avgflightTime);
%     axis([0, numel(avgflightTime), 0, Ymax])
    avgflightTime = mean(flightTime_hist);
    error = std(flightTime_hist,1,1);% / sqrt(size(flightTime_hist,1));
    L = size(flightTime_hist, 2);
    errorbar(1:10:L, avgflightTime(1:10:L), error(1:10:L), 'r', 'LineWidth', 1);
    Title = [mode ' (' num2str(AS.param1, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    title(Title)
    xlabel('Epoch')
    legend('Max G Achieved', 'Average G', 'Average Flight Time (minutes)', 'Location', 'southeast')
    Ymax = max(maxG) * 1.01;
    axis([1, numel(avgflightTime), 0, Ymax])
    %%
    figure; % Plot just average flight time
    errorbar(1:10:L, avgflightTime(1:10:L), error(1:10:L), 'r', 'LineWidth', 1);
    axis([1, numel(avgflightTime), 0, Ymax])
    Title = ['Time in the Air - ' mode ' (' num2str(AS.param1, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    title(Title)
    xlabel('Epoch')
    ylabel('Average Flight Time (minutes)')
end