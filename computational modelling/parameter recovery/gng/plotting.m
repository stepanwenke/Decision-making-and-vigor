clear all
clc

day = 1;
addpath('..');

if (day == 1)
    load("output/synthdata_GNG_pilot2.mat") % Simulated parameters
    load("pilot2/parameters_GNG_pilot2_synthetic.mat") % Observed / fitted params
else
    load("output/synthdata_GNG_pilot2day2.mat") % Simulated parameters
    load("pilot2day2/parameters_GNG_pilot2_synthetic_day2.mat") % Observed / fitted params
end 

% Convert observed params to the param space
beta_pos_simulated 	  = exp(params(:,1));            % sensitivity to reward 
alpha_pos_simulated	  = 1./(1+exp(-params(:,2)));     % learning rate
eps_pos_simulated         = exp(params(:,3));              % 'pavlovian' parameter. Weigth of Vcue into Qgo
lapse_simulated           = 1./(1+exp(-params(:,4)));          % lapse rate

% Transform parameters
% betas = exp(E(1:2,:)); % beta params (row 1:reward, row 2:punishment)
% alphas = 1./(1+exp(-E(3:4,:))); % alpha params (row 1:reward, row 2:punishment)
% eps = exp(E(5:6,:)); % epsilon params (approach/avoid bias; row 1:reward, row 2:punishment)
% lapse = 1./(1+exp(-E(7,:))); % lapse rate

% Transpose the vars into cols
eps = eps';
lapse = lapse';
beta = beta';
alpha = alpha';

% Extract the observed vars the same way as the simulated params
eps_pos = eps(:,1);
beta_pos = beta(:,1);
alpha_pos = alpha(:,1);

%% Quantify the exposure

% Initialize a variable to store results for all samples
s_df_exp_go_all = [];

% Loop over each sample
for s = 1:1000
    % 1. Make a subset of data
    s_df = [A(s,:)', S(s,:)', C(s,:)'];

    % 1a. Group by stimulus and count the exposure
    % Extract the stimulus column (assuming it's the second column)
    stimuli = s_df(:, 2);

    % Initialize the exposure count column
    exposure_count = zeros(size(stimuli));

    % Loop through each unique stimulus and assign exposure counts
    unique_stimuli = unique(stimuli);
    for i = 1:length(unique_stimuli)
        current_stimulus = unique_stimuli(i);
        % Find indices of the current stimulus
        stimulus_indices = find(stimuli == current_stimulus);
        % Assign exposure counts to the current stimulus
        exposure_count(stimulus_indices) = 1:length(stimulus_indices);
    end

    % Append the exposure count column to the original data
    s_df_exp = [s_df, exposure_count];

    % 2. Filter by condition
    % Extract relevant columns
    responses = s_df_exp(:, 1);
    stimuli = s_df_exp(:, 2);
    conditions = s_df_exp(:, 3);
    exposures = s_df_exp(:, 4);

    % Initialize an empty cell array to store filtered data and proportions
    filtered_data = cell(4, 1);
    prop_go = zeros(size(conditions));

    s_df_exp_go = [];

    % Loop through each condition (0 to 3)
    for cond = 0:1
        % Filter data by the current condition
        filtered_data{cond+1} = s_df_exp(conditions == cond, :);

        % Extract exposures and responses for the current condition
        current_exposures = exposures(conditions == cond);
        current_responses = responses(conditions == cond);

        % Initialize a temporary array to store this condition's output
        this_s_exp_go_output = [];

        % Calculate proportion of 'go' responses (1) for each exposure level
        unique_exposures = unique(current_exposures);
        for i = 1:length(unique_exposures)
            exposure_level = unique_exposures(i);
            exposure_indices = find(current_exposures == exposure_level);
            go_count = sum(current_responses(exposure_indices) == 1);
            total_count = length(exposure_indices);
            proportion_go = go_count / total_count;

            % Store the calculated proportion and metadata
            this_s_exp_go_output(i,:) = [proportion_go, exposure_level, cond, s];
        end

        % Accumulate the results for all conditions and samples
        s_df_exp_go = [s_df_exp_go; this_s_exp_go_output];
    end

    % Store results for the current sample
    s_df_exp_go_all = [s_df_exp_go_all; s_df_exp_go];
end

% Initialize variables to store results for each condition
prop_go_avg = cell(2, 1);  % Cell array to store average proportions
exposure_levels = 1:12;     % Assuming exposure levels range from 1 to 12

% Loop through each condition (0 to 3)
for cond = 0:1
    % Filter data for the current condition from all samples
    data_cond = s_df_exp_go_all(s_df_exp_go_all(:, 3) == cond, :);
    
    % Initialize arrays to store average prop_go and exposure_level
    prop_go_cond = zeros(length(exposure_levels), 1);
    exposure_level_cond = exposure_levels';
    
    % Loop through each exposure level
    for i = 1:length(exposure_levels)
        exposure_level = exposure_levels(i);
        
        % Find rows corresponding to current exposure level
        rows = data_cond(data_cond(:, 2) == exposure_level, :);
        
        % Calculate average prop_go for the current exposure level and condition
        prop_go_avg_cond = mean(rows(:, 1));  % Mean of prop_go
        
        % Store in the arrays
        prop_go_cond(i) = prop_go_avg_cond;
    end
    
    % Store results in the cell array
    prop_go_avg{cond+1} = [prop_go_cond, exposure_level_cond];
end

% Plotting all conditions on one figure with a legend
figure;
hold on;
for cond = 0:1
    prop_go_cond = prop_go_avg{cond+1}(:, 1);
    exposure_level_cond = prop_go_avg{cond+1}(:, 2);
    
    plot(exposure_level_cond, prop_go_cond, 'o-', 'LineWidth', 2);
end
hold off;

title('Average Proportion of ''Go'' Responses per Exposure Level');
xlabel('Exposure Level');
ylabel('Proportion of ''Go'' Responses');
grid on;
xlim([min(exposure_levels), max(exposure_levels)]);
ylim([0, 1]); 
legend('GW', 'NGW', 'GAL', 'NGAL');

% Save the plots
if (day == 1)
    saveas(gcf, 'pilot2/behavioural_plot.png');
else
    saveas(gcf, 'pilot2day2/behavioural_plot.png');
end 


%% Create figure for scatter plots
figure;

% List of parameter names and their pairs
param_pairs = {'Beta Positive', beta_pos, beta_pos_simulated;
               'Alpha Positive', alpha_pos, alpha_pos_simulated;
               'Eps Positive', eps_pos, eps_pos_simulated;
               'Lapse', lapse, lapse_simulated};

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
    subplot(2, 2, i);
    scatter(simulated,observed,'filled');
    hold on;
    
    % Fit and plot line
    lm = fitlm(simulated,observed);
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
    
    % Make sure the plot is square
    axis square;

    hold off;
end

% Save the plots
if (day == 1)
    saveas(gcf, 'pilot2/scatter_plots.png');
else
    saveas(gcf, 'pilot2day2/scatter_plots.png');
end 


%% Fitted parameters
fitted_params = [beta_pos, alpha_pos, eps_pos, lapse];
param_labels = {'beta', 'alpha', 'eps','lapse'};

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

if (day == 1)
    saveas(gcf, ['pilot2/scatter_plot_fitted_params.png']);
else
    saveas(gcf, ['pilot2day2/scatter_plot_fitted_params.png']);
end
