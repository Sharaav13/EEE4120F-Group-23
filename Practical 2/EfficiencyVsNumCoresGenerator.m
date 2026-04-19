    load("results.mat")
efficiencyMatrix=cell2mat(efficiency_results);
    
    workers = [2,3,4,5,6,7,8];
    %efficiencyData = table2array(speedupTable(:,1:end));
    
    % Resolution labels
    numMegaPixels= {'0.48 MP','0.92 MP','2.07 MP','2.21 MP','3.69 MP','8.29 MP','14.75 MP','33.18 MP'};
    
    % Amdahls Law - assume f (parallel fraction) close to 1
    
    
    % Plot
    figure;
    hold on;
    
    % Plot each resolution
    for i = 1:8
        plot(workers, efficiencyMatrix(:,i), '-o', 'DisplayName', numMegaPixels{i}, 'LineWidth', 1.5);
    end
    
    
    % Formatting
    xlabel('Number of Workers');
    ylabel('Efficiency');
    title('Efficiency vs Number of Workers for Parallel Mandelbrot Computation');
    ylim([0 100]);
    legend('Location', 'southwest');
    grid on;
    hold off;