% =========================================================================
% Practical 2: Mandelbrot-Set Serial vs Parallel Analysis
% =========================================================================
%
% GROUP NUMBER: 27
%
% MEMBERS:
%   - Member 1 Max Mendelow, MNDMAX003
%   - Member 2 Sharaav Dhebideen, DHBSHA001

%% ========================================================================
%  PART 1: Mandelbrot Set Image Plotting and Saving
%  ========================================================================
%
% TODO: Implement Mandelbrot set plotting and saving function
function mandelbrot_plot(iter_matrix, max_iter, res_name, workers) %Add necessary input arguments
      
    % Show the image
    figure;
    set(gcf,'Color','w');
    imagesc(iter_matrix, [0 max_iter]);
    colormap(parula);
    colorbar;
    axis image;
    axis off;
    
    % Determine if Serial or parallel implementation was used
    if (workers == 0)
        figname = res_name + " Mandelbrot Image (Serial)";
        save_name = "mandlbrt_" + res_name + "_" + "srl" + ".png";
    else 
        figname = res_name + " Mandelbrot Image (Parallel, " + num2str(workers) + " workers)";
        save_name = "mandlbrt_" + res_name + "_" + "prl_" + num2str(workers) + ".png";
    end
    title(figname,'FontSize',14);

    % Save image
    saveas(gcf, save_name); 
end

%% ========================================================================
%  PART 2: Serial Mandelbrot Set Computation
%  ========================================================================`
%
%TODO: Implement serial Mandelbrot set computation function
function iter_matrix = mandelbrot_serial(max_iter, img_size) %Add necessary input arguments
    
    % Extract the image dimensions
    n_x = img_size(2);
    n_y = img_size(1);
    empty_matrix = zeros(n_x,n_y);
   
    % Using the defined standard region of the Mandelbrot set
    x_vals = linspace(-2,0.5,n_x);
    y_vals = linspace(-1.2,1.2,n_y);

    % Perform Mandelbrot Algorithm
    for x = 1:n_x
        %x_0 = 2.5*((x-1)/(n_x-1)) - 2;
        x_0 = x_vals(x);
        for y = 1:n_y
            %y_0 = 2.4*((y-1)/(n_y-1)) - 1.2;
            y_0 = y_vals(y);
            
            % Initialise variables for performing iterations
            x_i = 0; 
            y_i = 0;
            iter = 0;

            % Evaluation of Mandelbrot condition
            while ((iter < max_iter) && ((x_i^2 + y_i^2) <= 4))
                temp = x_i^2 - y_i^2;
                y_i = 2*x_i*y_i + y_0;
                x_i = temp + x_0;
                iter = iter + 1;
            end
          
            empty_matrix(x,y) = iter;  
        end
    end

    iter_matrix = empty_matrix;
end

%% ========================================================================
%  PART 3: Parallel Mandelbrot Set Computation
%  ========================================================================
%
%TODO: Implement parallel Mandelbrot set computation function
function iter_matrix = mandelbrot_parallel(max_iter, img_size) %Add necessary input arguments 
    
    % Extract the image dimensions
    n_x = img_size(2);
    n_y = img_size(1);
    empty_matrix = zeros(n_x,n_y);

    % Using the defined standard region of the Mandelbrot set
    x_vals = linspace(-2,0.5,n_x);
    y_vals = linspace(-1.2,1.2,n_y);

    % Perform Mandelbrot Algorithm
    parfor x = 1:n_x % Parallelized outer loop
        %x_0 = 2.5*((x-1)/(n_x-1)) - 2;
        x_0 = x_vals(x);
        for y = 1:n_y
            %y_0 = 2.4*((y-1)/(n_y-1)) - 1.2;
            y_0 = y_vals(y);

            % Initialise variables for performing iterations
            x_i = 0; 
            y_i = 0;
            iter = 0;

            % Evaluation of Mandelbrot condition
            while ((iter < max_iter) && ((x_i^2 + y_i^2) <= 4))
                temp = x_i^2 - y_i^2;
                y_i = 2*x_i*y_i + y_0;
                x_i = temp + x_0;
                iter = iter + 1;
            end
          
            empty_matrix(x,y) = iter;  
        end
    end

    iter_matrix = empty_matrix;
end

%% ========================================================================
%  PART 4: Testing and Analysis
%  ========================================================================
% Compare the performance of serial Mandelbrot set computation
% with parallel Mandelbrot set computation.

function run_analysisf()
    %Array conatining all the image sizes to be tested
    image_sizes = [
        [800,600],   %SVGA
        [1280,720],  %HD
        [1920,1080], %Full HD
        [2048,1080], %2K Cinema
        [2560,1440], %2K QHD
        [3840,2160], %4K UHD
        [5120,2880], %5K
        [7680,4320]  %8K UHD
    ];
    
    max_iterations = 1000; 
    
    %TODO: For each image size, perform the following:
    %   a. Measure execution time of mandelbrot_serial
    %   b. Measure execution time of mandelbrot_parallel
    %   c. Store results (image size, time_serial, time_parallel, speedup) 
    %   d. Plot and save the Mandelbrot set images generated by both methods
    
    image_names = {"SVGA","HD","Full HD","2K Cinema","2K QHD","4K UHD","5K","8K UHD"};
    
    repetitions = 4; % Number of times to repeat a specific benchmark test
    
    max_workers = feature('numcores');
    
    % Cell arrays for storing results
    results = cell(5,8);
    
    for i = 1:8 % Test for all 8 image sizes
        
        % Determine serial execution time
        sum_time_serial = 0;
        for r = 1:repetitions    
            start_time_serial = tic; % start timer
            iteration_matrix_serial = mandelbrot_serial(max_iterations, image_sizes(i,:));
            sum_time_serial = sum_time_serial + toc(start_time_serial); % end timer
        end
        time_serial = sum_time_serial/repetitions;

        % Plot and save Mandelbrot images
        mandelbrot_plot(iteration_matrix_serial, max_iterations, image_names{i}, 0);  % Plot and save Mandelbrot images

        % Temporary arrays for storing Parallel results
        time_parallel = zeros(max_workers-1,1);
        speedup = zeros(max_workers-1,1);
        efficiency = zeros(max_workers-1,1);
        
        for n = 2:max_workers

            % Parallelisation setting up
            p = gcp('nocreate');
            if ~isempty(p)
                delete(p);
            end
            parpool(n);
            
            % Determining Parallel Mandelbrot function's execution time
            sum_time_parallel = 0;
            for r = 1:repetitions
                start_time_parallel = tic; % start timer
                iteration_matrix_parallel = mandelbrot_parallel(max_iterations, image_sizes(i,:));
                sum_time_parallel = sum_time_parallel + toc(start_time_parallel); % end timer
            end
            
            % Calculate execution time, speed up and efficiency for
            % parallel implementation
            time_parallel(n-1) = sum_time_parallel/repetitions;
            speedup(n-1) = time_serial/time_parallel(n-1);
            efficiency(n-1) = (speedup(n-1)/n)*100;
            
            % Plot and save mandelbrot image
            if (n == max_workers)
                mandelbrot_plot(iteration_matrix_parallel, max_iterations, image_names{i}, n);
            end
        end

        delete(gcp('nocreate')); % Close the pool
        
        % Saving results
        results{1, i} = image_names{i};
        results{2, i} = time_serial;
        results{3, i} = time_parallel;
        results{4, i} = speedup;
        results{5, i} = efficiency;
    end

    % Display results
    disp("Results");
    disp(results);
    
    % Unpack results
    time_serial = cell2mat(results{2, :});
    time_parallel = results{3, :}; 
    speedup = results{4, :};
    efficiency = results{5, :};
    
    % Average all Parallel computation results
    av_time_parallel = zeros(8,1);
    av_speedup = zeros(8,1);
    av_efficiency = zeros(8,1);
    for i = 1:8
        av_time_parallel(i) = mean(time_parallel{i});
        av_speedup(i) = mean(speedup{i});
        av_efficiency(i) = mean(efficiency{i});
    end

    % Plot double bar graph for execution times (average parallel case)
    Y1 = [time_serial av_time_parallel];
    figure;
    b1 = bar(Y1);               
    b1(1).FaceColor = [0.2 0.6 0.8];
    b1(2).FaceColor = [0.9 0.4 0.3];
    legend({'Serial','Parallel'}, 'Location','best');
    xticks(1:size(Y1,1));
    xticklabels(image_names);
    xlabel('Image Resolutions');
    ylabel('Execution Time (s)');
    title('Double Bar Graph showing the Execution Times of the Serial and Parallel Mandelbrot implementation for each Image Resolution');
    grid on;

    % Plot bar graph for speedup
    figure;
    bar(av_speedup);               
    xticks(1:8);
    xticklabels(image_names);
    xlabel('Image Resolutions');
    ylabel('Speed Up/Slow down');
    title('Bar Graph of Speed Up/Slow Down for each Image Resolution');
    grid on;

    % Plot bar graph for efficiency
    figure;
    bar(av_efficiency);               
    xticks(1:8);
    xticklabels(image_names);
    xlabel('Image Resolutions');
    ylabel('Efficiency (%)');
    title('Bar Graph of Efficiency for each Image Resolution');
    grid on;
    
    % Plot Influence of Parallel workers on execution time
    figure;
    plot(2:max_workers, time_parallel{3}) % Full HD is the most common image size
    xlabel('Number of workers/cores');
    ylabel('Execution Time (s)');
    title('Execution Time versus Parallel worker/cores for a Full HD Mandelbrot image');
    grid on;

    % Plot Influence of Parallel workers on speedup
    figure;
    plot(2:max_workers, speedup{3}) % Full HD is the most common image size
    hold on
    plot(2:max_workers, 2:max_workers,'--');
    hold off
    legend("Measured Speedup","Ideal Speedup");
    xlabel('Number of workers/cores');
    ylabel('Speed Up/Slow down');
    title('Speed Up/Slow down versus Parallel worker/cores for a Full HD Mandelbrot image');
    grid on;

    % Plot Influence of Parallel workers on efficiency
    figure;
    plot(2:max_workers, efficiency{3}) % Full HD is the most common image size
    xlabel('Number of workers/cores');
    ylabel('Efficiency (%)');
    title('Efficiency versus Parallel worker/cores for a Full HD Mandelbrot image');
    grid on;

end

run_analysisf();