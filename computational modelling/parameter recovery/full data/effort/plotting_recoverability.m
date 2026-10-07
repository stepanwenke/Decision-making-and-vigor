clear all
clc

day = '1';
iters= '3';
model='constrained_quadratic';

target_path = ['day' day filesep iters 'iter' filesep model filesep];

load([target_path 'output_sim/synthdata_physE_pilot2.mat']) % Simulated parameters
load([target_path 'output_fit/parameters_physicalE_retest.mat']) % Observed / fitted params

% Convert observed params to the param space
beta_simulated = params(:,1);
if model == "constrained_linear" || model == "constrained_quadratic"
    beta_simulated = exp(params(:,1));
end


k_simulated = params(:,2);

if model == "constrained_quadratic"
    k_simulated = 1./(1+exp(-params(:,2)));
end

g_simulated = 1./(1+exp(-params(:,3)));

% Transform parameters
% Transpose the vars into cols
beta = beta';
k = k';
g = g';


%% Inspect Data Integrity and Summary Statistics
% disp('Summary statistics for Day');
% summary_stats(beta_simulated, 'beta_simulated');
% summary_stats(k_simulated, 'k_simulated');
% summary_stats(beta, 'beta');
% summary_stats(k, 'k');
% summary_stats(g_simulated, 'g_simulated');


%% Visualize Data Distribution
figure;
subplot(3, 2, 1);
histogram(beta_simulated);
title('Beta Simulated');

subplot(3, 2, 2);
histogram(beta);
title('Beta Observed');

subplot(3, 2, 3);
histogram(k_simulated);
title('k Simulated');

subplot(3, 2, 4);
histogram(k);
title('k Observed');

subplot(3, 2, 5);
histogram(g_simulated);
title('g (Lapse) Simulated');

subplot(3, 2, 6);
histogram(g);
title('g (Lapse) Observed');

saveas(gcf, [target_path 'histogram.png']);


%% Create figure for scatter plots
figure();

% List of parameter names and their pairs
param_pairs = {'beta', beta, beta_simulated;
               'k', k, k_simulated;
               'g', g, g_simulated};

% Iterate over parameter pairs to plot and correlate
for i = 1:size(param_pairs, 1)
    param_name = param_pairs{i, 1};
    observed = param_pairs{i, 2};
    simulated = param_pairs{i, 3};
    
    % Calculate correlation coefficient
    r = corr(observed, simulated);
    
    % Scatter plot
    subplot(2, 2, i);
    scatter(simulated, observed, 'filled');
    hold on;
    
    % Fit and plot line
    lm = fitlm(simulated, observed);
    plot(lm);
    legend('off');
    
    % Add title and labels
    title([param_name ' (r = ' num2str(r, '%.2f') ')']);
    xlabel('Simulated');
    ylabel('Observed');
    
    % Get the axis limits
    xlim_values = xlim;
    ylim_values = ylim;
    
    % Determine the maximum range to make the plot square
    axis_max = max([xlim_values ylim_values]);
    axis_min = min([xlim_values ylim_values]);
    
    % Set the same limits for both axes
    xlim([axis_min axis_max]);
    ylim([axis_min axis_max]);
    
    % Plot the perfect diagonal line (y = x)
    % Get the current axis limits
    axis_min = min([xlim ylim]);
    axis_max = max([xlim ylim]);
    
    % Plot the diagonal line
    plot([axis_min axis_max], [axis_min axis_max], 'k--', 'LineWidth', 1.5);
    
    % Make sure the plot is square
    axis square;
    
    
    hold off;
end
saveas(gcf, [target_path 'scatter_plot.png']);
% function summary_stats(data, name)
%     disp(['Statistics for ', name, ':']);
%     disp(['Mean: ', num2str(mean(data))]);
%     disp(['Std: ', num2str(std(data))]);
%     disp(['Min: ', num2str(min(data))]);
%     disp(['Max: ', num2str(max(data))]);
%     disp('-----------------------------');
% end

