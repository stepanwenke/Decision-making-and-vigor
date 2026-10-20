clear all
clc

% Settings
day = '1';
model='unconstrained_linear';  % constrained_quadratic, constrained_linear, unconstrained_linear
%%%%%

target_path = ['day' day filesep model filesep];
addpath('..') % add the one dir above to be able to use identicalCorr function

load([target_path 'output_sim/synthdata_physE.mat']) % Simulated parameters
load([target_path 'output_fit/parameters_physicalE.mat']) % Observed / fitted params

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

% Identify extreme points based on simulated beta
extreme_idx = beta_simulated > 15;   % logical index

% Iterate over parameter pairs to plot and correlate
for i = 1:size(param_pairs, 1)
    param_name = param_pairs{i, 1};
    observed = param_pairs{i, 2};
    simulated = param_pairs{i, 3};
    
    % Calculate correlation coefficient
    r = corr(observed, simulated);

    % Calculate your R2-like measure
    R2_like = identicalCorr(simulated, observed);
    
    % Scatter plot
    subplot(1, 3, i);
    scatter(simulated, observed, 'filled');
    %scatter(simulated(~extreme_idx), observed(~extreme_idx), 36, 'b', 'filled');
    hold on;
   

    % Fit and plot line
    lm = fitlm(simulated, observed, 'linear');
    %plot(lm);
    legend('off');

    % Plot the regression line manually
    x_line = linspace(min(simulated), max(simulated), 100);
    y_line = lm.Coefficients.Estimate(1) + lm.Coefficients.Estimate(2) * x_line;
    plot(x_line, y_line, 'r-', 'LineWidth', 2); % Red line for the fit
    
    % Add title and labels
    title([param_name ' (r = ' num2str(r, '%.2f') ', R^2 = ' num2str(R2_like,'%.2f') ')']);
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
    
    % Plot extreme points in red
    %scatter(simulated(extreme_idx), observed(extreme_idx), 50, 'r', 'filled');

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

%% Recalculate correlations and replot without extreme points
figure();

for i = 1:size(param_pairs, 1)
    param_name = param_pairs{i, 1};
    observed = param_pairs{i, 2};
    simulated = param_pairs{i, 3};
    
    % Remove extreme points
    observed_no_extreme = observed(~extreme_idx);
    simulated_no_extreme = simulated(~extreme_idx);
    
    % Recalculate correlation
    r_no_extreme = corr(observed_no_extreme, simulated_no_extreme);
    
    % Recalculate R2-like measure
    R2_no_extreme = identicalCorr(simulated_no_extreme, observed_no_extreme);
    
    % Scatter plot
    subplot(2, 2, i);
    scatter(simulated_no_extreme, observed_no_extreme, 36, 'b', 'filled');
    hold on;
    
    % Fit and plot line
    lm = fitlm(simulated_no_extreme, observed_no_extreme);
    plot(lm);
    legend('off');
    
    % Add title and labels
    title([param_name ' (r = ' num2str(r_no_extreme, '%.2f') ', R^2 = ' num2str(R2_no_extreme,'%.2f') ')']);
    xlabel('Simulated');
    ylabel('Observed');
    
    % Make axes square
    axis_min = min([simulated_no_extreme; observed_no_extreme]);
    axis_max = max([simulated_no_extreme; observed_no_extreme]);
    xlim([axis_min axis_max]);
    ylim([axis_min axis_max]);
    
    % Diagonal line
    plot([axis_min axis_max], [axis_min axis_max], 'k--', 'LineWidth', 1.5);
    
    axis square;
    hold off;
end

saveas(gcf, [target_path 'scatter_plot_no_extremes.png']);

%% Fitted parameters
fitted_params = [beta, k, g];
param_labels = {'beta', 'k', 'g'};

% Create scatter plots for each pair
figure;
pair_idx = nchoosek(1:3, 2); % all pairs of 3 params

for i = 1:size(pair_idx,1)
    subplot(1,3,i);
    x = fitted_params(:, pair_idx(i,1));
    y = fitted_params(:, pair_idx(i,2));
    
    scatter(x, y, 36, 'b', 'filled'); hold on;

    % Fit linear model and plot regression line
    lm = fitlm(x, y);
    plot(lm);  % red regression line
    legend('off');

    xlabel(param_labels{pair_idx(i,1)});
    ylabel(param_labels{pair_idx(i,2)});
    
    % add correlation coefficient
    r = corr(x, y);
    title(['r = ' num2str(r,'%.2f')]);
    
    axis square; % make axes square
end

sgtitle('Scatter plots of fitted parameters');

saveas(gcf, [target_path 'scatter_plot_fitted_params.png']);
