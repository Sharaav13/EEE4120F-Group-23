load('results.mat');

image_names = {'SVGA','HD','Full HD','2K Cinema','2K QHD','4K UHD','5K','8K'};
num_wokers = 7;
max_workers = 8;
num_images = 7;

time_parallel_matrix = zeros(num_wokers, num_images);
speedup_matrix = zeros(num_wokers, num_images);
efficiency_matrix = zeros(num_wokers, num_images);
for i = 1:num_images
    time_parallel_matrix(:,i) = time_parallel_results{i};
    speedup_matrix(:,i) = speedup_results{i};
    efficiency_matrix(:,i) = efficiency_results{i};
end

figure
bar(time_parallel_matrix,'grouped')
xticks(1:num_wokers)
xticklabels(2:max_workers)
xlabel('Number of Workers')
ylabel('Execution Time (s)')
title('Parallel Execution Time vs Number of Workers')
legend(image_names,'Location','northeastoutside')
grid on

figure
bar(speedup_matrix,'grouped')
xticks(1:num_wokers)
xticklabels(2:max_workers)
xlabel('Number of Workers')
ylabel('Speed Up/Slow Down')
title('Speed Up/Slow Down vs Number of Workers')
legend(image_names,'Location','northeastoutside')
grid on

figure
bar(efficiency_matrix,'grouped')
xticks(1:num_wokers)
xticklabels(2:max_workers)
xlabel('Number of Workers')
ylabel('Efficiency (%)')
title('Efficiency vs Number of Workers')
legend(image_names,'Location','northeastoutside')
grid on