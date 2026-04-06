%% OpenMP results
tinit_omp = { % N=4    % N=5    % N=6     % N=7   % N=8     % N=9     % N=10
            [0.000089 0.000097 0.000096 0.000103 0.000095 0.000110 0.000112];  % 1 proc
            [0.000091 0.000130 0.000166 0.000091 0.000137 0.000102 0.000121]; % 2 procs
            [0.000111 0.000089 0.000088 0.000106 0.000140 0.000091 0.000177]; % 4 procs
            [0.000089 0.000105 0.000092 0.000092 0.000096 0.000102 0.000097]; % 8 procs
            };

tcomp_omp = { % N=4    % N=5    % N=6     % N=7   % N=8     % N=9     % N=10
            [0.000004 0.000005 0.000008 0.000018 0.000065 0.000211 0.001202];  % 1 proc
            [0.000086 0.000145 0.000185 0.000118 0.000138 0.000237 0.001031]; % 2 procs
            [0.000179 0.000158 0.000159 0.000209 0.000199 0.000217 0.000703]; % 4 procs
            [0.000384 0.000389 0.000415 0.000335 0.000536 0.000423 0.000751]; % 8 procs
            };

ttot_omp = cell(4,1);
for o1 = 1:4
    ttot_omp{o1} = tinit_omp{o1} + tcomp_omp{o1}; 
end

comp_speedup_omp = cell(3,1);
tot_speedup_omp = cell(3,1);
for o2 = 2:4
    comp_speedup_omp{o2-1} = tcomp_omp{1}./tcomp_omp{o2}; 
    tot_speedup_omp{o2-1} = ttot_omp{1}./ttot_omp{o2};
end

%% MPI results
tinit_mpi = { % N=4    % N=5    % N=6     % N=7   % N=8     % N=9     % N=10
            [0.228240 0.227507 0.230982 0.227797 0.226957 0.226962 0.227022];  % 1 proc
            [0.231350 0.229594 0.231790 0.229950 0.230433 0.230442 0.230992]; % 2 procs
            [0.236171 0.237075 0.237290 0.237042 0.239944 0.239362 0.238020]; % 4 procs
            [0.258419 0.260889 0.255616 0.255019 0.262587 0.256729 0.257870]; % 8 procs
            };

tcomp_mpi = { % N=4    % N=5    % N=6     % N=7   % N=8     % N=9     % N=10
            [0.0000004 0.000001 0.000002 0.000009 0.000024 0.000126 0.000567];  % 1 proc
            [0.000001 0.000003 0.000004 0.000009 0.000028 0.000109 0.000606]; % 2 procs
            [0.000005 0.000008 0.000010 0.000014 0.000033 0.000123 0.000628]; % 4 procs
            [0.000017 0.000021 0.000015 0.000047 0.000099 0.000135 0.000730]; % 8 procs
            };

ttot_mpi = cell(4,1);
for m1 = 1:4
    ttot_mpi{m1} = tinit_mpi{m1} + tcomp_mpi{m1}; 
end

comp_speedup_mpi = cell(3,1);
tot_speedup_mpi = cell(3,1);
for m2 = 2:4
    comp_speedup_mpi{m2-1} = tcomp_mpi{1}./tcomp_mpi{m2}; 
    tot_speedup_mpi{m2-1} = ttot_mpi{1}./ttot_mpi{m2};
end

%% OpenMP vs MPI results

comp_speedup = cell(4,1);
for v1 = 1:4
    comp_speedup{v1} = tcomp_omp{v1}./tcomp_mpi{v1}; 
end

tot_speedup = cell(4,1);
for v2 = 1:4
    tot_speedup{v2} = ttot_omp{v2}./ttot_mpi{v2}; 
end

%% Problem results
best_cost = [105 115 124 145 155 171 207]; % kWh

best_route = {
            [1 4 2 3], % N=4
            [1 4 5 2 3], % N=5
            [1 4 6 5 2 3], % N=6
            [1 4 6 5 3 2 7], % N=7
            [1 4 6 5 8 3 2 7], % N=8
            [1 4 9 6 5 8 3 2 7], % N=9
            [1 10 4 9 6 5 8 3 2 7] % N=10
            };

%% Data plots

procs1 = [1 2 4 8];
procs2 = [2 4 8];

f_omp = 0.95;
f_mpi = 0.825;
amdahl2_omp = 1./((1-f_omp)+f_omp./procs2);
amdahl2_mpi = 1./((1-f_mpi)+f_mpi./procs2);

% OpenMP computational speedup vs Number of processors (compared to Amdahls'law)
f11 = figure;
for i = 1:7
    temp_comp_speedup_omp = [comp_speedup_omp{1}(i) comp_speedup_omp{2}(i) comp_speedup_omp{3}(i)];
    plot(procs2, temp_comp_speedup_omp,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
plot(procs2, amdahl2_omp,'LineWidth',1 ,'LineStyle','--', 'Marker','o');
hold off;
grid on;
title("OpenMP computational speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10","Amdahl's Law");
saveas(gcf, "comp_speedup_omp_amdahl.png");

% OpenMP total speedup vs Number of processors (compared to Amdahls'law)
f22 = figure;
for i = 1:7
    temp_tot_speedup_omp = [tot_speedup_omp{1}(i) tot_speedup_omp{2}(i) tot_speedup_omp{3}(i)];
    plot(procs2, temp_tot_speedup_omp,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
plot(procs2, amdahl2_omp,'LineWidth',1 ,'LineStyle','--', 'Marker','o');
hold off;
grid on;
title("OpenMP total speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10","Amdahl's Law");
saveas(gcf, "tot_speedup_omp_amdahl.png");

% MPI computational speedup vs Number of processors (compared to Amdahls'law)
f33 = figure;
for i = 1:7
    temp_comp_speedup_mpi = [comp_speedup_mpi{1}(i) comp_speedup_mpi{2}(i) comp_speedup_mpi{3}(i)];
    plot(procs2, temp_comp_speedup_mpi,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
plot(procs2, amdahl2_mpi,'LineWidth',1 ,'LineStyle','--', 'Marker','o');
hold off;
grid on;
title("MPI computational speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10","Amdahl's Law");
saveas(gcf, "comp_speedup_mpi_amdahl.png");

% MPI total speedup vs Number of processors (compared to Amdahls'law)
f55 = figure;
for i = 1:7
    temp_tot_speedup_mpi = [tot_speedup_mpi{1}(i) tot_speedup_mpi{2}(i) tot_speedup_mpi{3}(i)];
    plot(procs2, temp_tot_speedup_mpi,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
plot(procs2, amdahl2_mpi,'LineWidth',1 ,'LineStyle','--', 'Marker','o');
hold off;
grid on;
title("MPI total speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10","Amdahl's Law");
saveas(gcf, "tot_speedup_mpi_amdahl.png");

% OpenMP computational speedup vs Number of processors
f1 = figure;
for i = 1:7
    temp_comp_speedup_omp = [comp_speedup_omp{1}(i) comp_speedup_omp{2}(i) comp_speedup_omp{3}(i)];
    plot(procs2, temp_comp_speedup_omp,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("OpenMP computational speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "comp_speedup_omp.png");

% OpenMP total speedup vs Number of processors
f2 = figure;
for i = 1:7
    temp_tot_speedup_omp = [tot_speedup_omp{1}(i) tot_speedup_omp{2}(i) tot_speedup_omp{3}(i)];
    plot(procs2, temp_tot_speedup_omp,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("OpenMP total speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "tot_speedup_omp.png");

% MPI computational speedup vs Number of processors
f3 = figure;
for i = 1:7
    temp_comp_speedup_mpi = [comp_speedup_mpi{1}(i) comp_speedup_mpi{2}(i) comp_speedup_mpi{3}(i)];
    plot(procs2, temp_comp_speedup_mpi,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("MPI computational speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "comp_speedup_mpi.png");

% MPI total speedup vs Number of processors
f5 = figure;
for i = 1:7
    temp_tot_speedup_mpi = [tot_speedup_mpi{1}(i) tot_speedup_mpi{2}(i) tot_speedup_mpi{3}(i)];
    plot(procs2, temp_tot_speedup_mpi,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("MPI total speedup vs Number of processors");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "tot_speedup_mpi.png");

% Computational speedup of OpenMP vs MPI
f6 = figure;
for i = 1:7
    temp_comp_speedup = [comp_speedup{1}(i) comp_speedup{2}(i) comp_speedup{3}(i) comp_speedup{4}(i)];
    plot(procs1, temp_comp_speedup,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("Computational speedup of OpenMP vs MPI");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "comp_speedup.png");

% Total speedup of OpenMP vs MPI
f4 = figure;
for i = 1:7
    temp_tot_speedup = [tot_speedup{1}(i) tot_speedup{2}(i) tot_speedup{3}(i) tot_speedup{4}(i)];
    plot(procs1, temp_tot_speedup,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("Total speedup of OpenMP vs MPI");
xlabel("Number of processors");
ylabel("Speedup");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "tot_speedup.png");

% OpenMP initialisation time vs Number of processors
f7 = figure;
for i = 1:7
    temp_tinit_omp = [tinit_omp{1}(i) tinit_omp{2}(i) tinit_omp{3}(i) tinit_omp{4}(i)];
    plot(procs1, temp_tinit_omp,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("OpenMP initialisation time vs Number of processors");
xlabel("Number of processors");
ylabel("Initialisation time (s)");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "tinit_omp.png");

% MPI initialisation time vs Number of processors
f8 = figure;
for i = 1:7
    temp_tinit_mpi = [tinit_mpi{1}(i) tinit_mpi{2}(i) tinit_mpi{3}(i) tinit_mpi{4}(i)];
    plot(procs1, temp_tinit_mpi,'LineWidth',1 ,'LineStyle','-', 'Marker','o');
    hold on;
end
hold off;
grid on;
title("MPI initialisation time vs Number of processors");
xlabel("Number of processors");
ylabel("Initialisation time (s)");
legend("N=4","N=5","N=6","N=7","N=8","N=9","N=10");
saveas(gcf, "tinit_mpi.png");