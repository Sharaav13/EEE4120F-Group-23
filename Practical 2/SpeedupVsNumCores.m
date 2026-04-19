workers = [2,3,4,5,6,7,8];
speedupData = table2array(speedupTable(:,1:end));

% Resolution labels
resLabels = {'SVGA', 'HD', 'FullHD', '2K', 'QHD', '4K UHD', '5K', '8K UHD'};

% Amdahls Law - assume f (parallel fraction) close to 1
f = 0.95; % adjust this value based on your estimation
amdahl = zeros(length(workers), 1);
for i = 1:length(workers)
    P = workers(i);
    amdahl(i) = 1 / ((1 - f) + (f / P));
end

% Plot
figure;
hold on;

% Plot each resolution
for i = 1:8
    plot(workers, speedupData(:,i), '-o', 'DisplayName', resLabels{i}, 'LineWidth', 1.5);
end

% Plot Amdahls Law
plot(workers, amdahl, 'k--', 'DisplayName', sprintf("Amdahl's Law (f=%.2f)", f), ...
    'LineWidth', 2);

% Formatting
xlabel('Number of Workers');
ylabel('Speedup');
title('Speedup vs Number of Workers for Parallel Mandelbrot Computation');
legend('Location', 'northwest');
grid on;
hold off;