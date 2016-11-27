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
    end
            
    
    
    figure;
    plot(maxflightTime, 'r');
    hold on
    plot(maxG, 'k-.', 'LineWidth', 2);
    legend('Max Flight Time (minutes)', 'Max G');
    Title = ['Performance using ' mode ' (' num2str(AS.param1, '%.1f') '), ' reward ', ' num2str(Qinit, '%.1f')];
    title(Title)
    xlabel('Run')
    
    figure;
    avgflightTime = mean(flightTime_hist);
%     plot(avgflightTime, 'r');
%     hold on
    temp = flightTime_hist(:, 1:10:size(flightTime_hist,2));
    avgTemp = mean(temp);
    error = std(temp,0,1) / sqrt(numel(avgTemp));
    errorbar(1:10:size(flightTime_hist,2), avgTemp, error, 'r');
    Title = [mode ' (' num2str(AS.param1, '%.1f') '), ' reward ', ' num2str(Qinit, '%.1f')];
    title(Title)
    
%     Ymax = max(avgflightTime);
%     axis([0, numel(avgflightTime), 0, Ymax])
    
    
    hold on
    plot(mean(G_hist));
%     Title = ['Average G using ' mode ' (' num2str(AS.param1, '%.1f') '), ' reward];
%     title(Title)
    xlabel('Epoch')

    plot(epochOfMax, maxG, 'o')
    legend('Average Flight Time (minutes)', 'Average G', 'Max G Achieved', 'Location', 'southeast')
    Ymax = max(maxG) * 1.01;
    axis([0, numel(avgflightTime), 0, Ymax])
end