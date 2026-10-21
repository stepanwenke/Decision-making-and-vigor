clear all
clc

%% Settings
day = '1'; % Specify session 1 or 2
model = 'll_rlwm'; % Specify model ll_rlwm or ll_wmh

addpath('..');
load(['output_sim/synthdata_RLWM_' model '_session' day '.mat']) % Simulated parameters
load(['output_fit/day' day filesep model '/parameters_RLWM.mat']) % Observed / fitted params

% Convert observed params to the param space
transformed_params = 1./(1+exp(-params));
alpha_sim = transformed_params(:,1);
lapse_sim = transformed_params(:,2);
bias_sim  = transformed_params(:,3);
decay_sim = transformed_params(:,4);
rho_sim   = transformed_params(:,5);

% Transform parameters
% Transpose the vars into cols
alpha = params(:,1);
lapse = params(:,2);
bias = params(:,3);
decay = params(:,4);
rho = params(:,5);


%% Inspect Data Integrity and Summary Statistics
disp('Summary statistics for Day');
summary_stats(alpha_sim, 'alpha_sim');
summary_stats(lapse_sim, 'lapse_sim');
summary_stats(bias_sim, 'bias_sim');
summary_stats(decay_sim, 'decay_sim');
summary_stats(rho_sim, 'rho_sim');
summary_stats(alpha, 'alpha');
summary_stats(lapse, 'lapse');
summary_stats(bias, 'bias');
summary_stats(decay, 'decay');
summary_stats(rho, 'rho');

%% Visualize Data Distribution
figure;
subplot(3, 2, 1);
histogram(alpha_sim);
title('Alpha Simulated');

subplot(3, 2, 2);
histogram(alpha);
title('Alpha Observed');

subplot(3, 2, 3);
histogram(lapse_sim);
title('Lapse Simulated');

subplot(3, 2, 4);
histogram(lapse);
title('Lapse Observed');

subplot(3, 2, 5);
histogram(bias_sim);
title('Bias Simulated');

subplot(3, 2, 6);
histogram(bias);
title('Bias Observed');

% Create a new figure for decay and rho
figure;
subplot(2, 2, 1);
histogram(decay_sim);
title('Decay Simulated');

subplot(2, 2, 2);
histogram(decay);
title('Decay Observed');

subplot(2, 2, 3);
histogram(rho_sim);
title('Rho Simulated');

subplot(2, 2, 4);
histogram(rho);
title('Rho Observed');


%% Create figure for scatter plots
figure;

% List of parameter names and their pairs
param_pairs = {'alpha', alpha, alpha_sim;
               'lapse', lapse, lapse_sim;
               'bias', bias, bias_sim;
               'decay', decay, decay_sim;
               'rho', rho, rho_sim};

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
    subplot(2, 3, i);
    scatter(simulated, observed, 'filled');
    hold on;
    
    % Fit the linear model without plotting it
    lm = fitlm(simulated, observed, 'linear');
    
    % Plot the regression line manually
    x_line = linspace(min(simulated), max(simulated), 100);
    y_line = lm.Coefficients.Estimate(1) + lm.Coefficients.Estimate(2) * x_line;
    plot(x_line, y_line, 'r-', 'LineWidth', 2); % Red line for the fit
    
    % Plot the perfect diagonal line (y = x)
    % Get the current axis limits
    axis_min = min([xlim ylim]);
    axis_max = max([xlim ylim]);
    
    % Plot the diagonal line
    plot([axis_min axis_max], [axis_min axis_max], 'k--', 'LineWidth', 1.5);
    
    % Add title and labels
    title([param_name ' (r = ' num2str(r, '%.2f') ', R^2 = ' num2str(R2_like,'%.2f') ')']);
    xlabel('Simulated');
    ylabel('Observed');
    
    % Set the same limits for both axes
    xlim([axis_min axis_max]);
    ylim([axis_min axis_max]);
    
    % Make sure the plot is square
    axis square;
    
    hold off;
end

saveas(gcf, ['output_fit/day' day filesep model '/scatter_plots.png']);

%% Fitted parameters
fitted_params = [alpha, lapse, bias, decay, rho];
param_labels = {'alpha', 'lapse', 'bias','decay','rho'};

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

saveas(gcf, ['output_fit/day' day filesep model '/scatter_plot_fitted_params.png']);

%% Function to display summary statistics
function summary_stats(data, name)
    disp(['Statistics for ', name, ':']);
    disp(['Mean: ', num2str(mean(data))]);
    disp(['Std: ', num2str(std(data))]);
    disp(['Min: ', num2str(min(data))]);
    disp(['Max: ', num2str(max(data))]);
    disp('-----------------------------');
end