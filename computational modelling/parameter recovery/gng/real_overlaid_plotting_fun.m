%function real_overlaid_plotting()

clear all
clc

day = 1;

if (day == 1)
    load("output/synthdata_GNG_pilot2.mat") % Simulated parameters
    load("output/synthdata_from_real_params_GNG_pilot2.mat") % Synth choice data from real parameters
else
    load("output/synthdata_GNG_pilot2day2.mat") % Simulated parameters
    load("output/synthdata_from_real_params_GNG_pilot2_day2.mat") % Synth choice data from real parameters
end
%% Quantify the exposure

% Initialize variables to store results for all samples (synthetic and real)
s_df_exp_go_all = [];
s_df_exp_go_all_real = [];

% Loop over each sample
samples = 1000;
for s = 1:samples
    % Process synthetic data
    s_df_exp_go = process_sample(A(s,:)', S(s,:)', C(s,:)');
    s_df_exp_go_all = [s_df_exp_go_all; s_df_exp_go];

    % Process real data
    s_df_exp_go_real = process_sample(A_real(s,:)', S_real(s,:)', C_real(s,:)');
    s_df_exp_go_all_real = [s_df_exp_go_all_real; s_df_exp_go_real];
end

% Calculate average proportions for synthetic and real data
% prop_go_avg = calculate_avg_proportions(s_df_exp_go_all);
% prop_go_avg_real = calculate_avg_proportions(s_df_exp_go_all_real);
% 
% 
% % Plotting all conditions on one figure with a legend
% plot_proportions(prop_go_avg, prop_go_avg_real);

[prop_go_avg, prop_go_avg_real] = calculate_avg_proportions(s_df_exp_go_all, s_df_exp_go_all_real);
plot_proportions(prop_go_avg, prop_go_avg_real,day);


function s_df_exp_go = process_sample(A, S, C)
    % Make a subset of data
    s_df = [A, S, C];

    % Group by stimulus and count the exposure
    stimuli = s_df(:, 2);
    exposure_count = zeros(size(stimuli));
    unique_stimuli = unique(stimuli);
    for i = 1:length(unique_stimuli)
        current_stimulus = unique_stimuli(i);
        stimulus_indices = find(stimuli == current_stimulus);
        exposure_count(stimulus_indices) = 1:length(stimulus_indices);
    end
    s_df_exp = [s_df, exposure_count];

    % Filter by condition and calculate proportions
    responses = s_df_exp(:, 1);
    stimuli = s_df_exp(:, 2);
    conditions = s_df_exp(:, 3);
    exposures = s_df_exp(:, 4);
    s_df_exp_go = [];
    for cond = 0:1
        current_exposures = exposures(conditions == cond);
        current_responses = responses(conditions == cond);
        unique_exposures = unique(current_exposures);
        for i = 1:length(unique_exposures)
            exposure_level = unique_exposures(i);
            exposure_indices = find(current_exposures == exposure_level);
            go_count = sum(current_responses(exposure_indices) == 1);
            total_count = length(exposure_indices);
            proportion_go = go_count / total_count;
            s_df_exp_go = [s_df_exp_go; proportion_go, exposure_level, cond];
        end
    end
end

% function prop_go_avg = calculate_avg_proportions(s_df_exp_go_all)
%     exposure_levels = 1:12;
%     prop_go_avg = cell(4, 1);
%     for cond = 0:3
%         data_cond = s_df_exp_go_all(s_df_exp_go_all(:, 3) == cond, :);
%         prop_go_cond = zeros(length(exposure_levels), 1);
%         sem_go_cond = zeros(length(exposure_levels), 1); % Initialize SEM array
%         for i = 1:length(exposure_levels)
%             exposure_level = exposure_levels(i);
%             rows = data_cond(data_cond(:, 2) == exposure_level, :);
%             prop_go_avg_cond = mean(rows(:, 1));
%             sem_go_cond(i) = std(rows(:, 1)) / sqrt(size(rows, 1)); % Calculate SEM
%             prop_go_cond(i) = prop_go_avg_cond;
%         end
%         prop_go_avg{cond+1} = [prop_go_cond, exposure_levels', sem_go_cond];
%     end
% end

% function plot_proportions(prop_go_avg, prop_go_avg_real)
%     exposure_levels = 1:12;
%     figure;
%     hold on;
%     colors = {'b', 'g', 'r', 'k'};
%     markers = {'o-', 'x--'};
%     labels = {'GW', 'GW Real', 'NGW', 'NGW Real', 'GAL', 'GAL Real', 'NGAL', 'NGAL Real'};
%     for cond = 0:3
%         prop_go_cond = prop_go_avg{cond+1}(:, 1);
%         exposure_level_cond = prop_go_avg{cond+1}(:, 2);
%         plot(exposure_level_cond, prop_go_cond, markers{1}, 'Color', colors{cond+1}, 'LineWidth', 2);
% 
%         prop_go_cond_real = prop_go_avg_real{cond+1}(:, 1);
%         exposure_level_cond_real = prop_go_avg_real{cond+1}(:, 2);
%         plot(exposure_level_cond_real, prop_go_cond_real, markers{2}, 'Color', colors{cond+1}, 'LineWidth', 2);
%     end
%     hold off;
%     title('Average Proportion of ''Go'' Responses per Exposure Level');
%     xlabel('Exposure Level');
%     ylabel('Proportion of ''Go'' Responses');
%     grid on;
%     xlim([min(exposure_levels), max(exposure_levels)]);
%     ylim([0, 1]);
%     legend(labels);
% end

function [prop_go_avg, prop_go_avg_real] = calculate_avg_proportions(s_df_exp_go_all, s_df_exp_go_all_real)
    exposure_levels = 1:12;
    prop_go_avg = cell(4, 1);
    prop_go_avg_real = cell(4, 1);

    for cond = 0:1
        % For synthetic data
        data_cond = s_df_exp_go_all(s_df_exp_go_all(:, 3) == cond, :);
        prop_go_cond = zeros(length(exposure_levels), 1);
        sem_cond = zeros(length(exposure_levels), 1);
        
        % For real data
        data_cond_real = s_df_exp_go_all_real(s_df_exp_go_all_real(:, 3) == cond, :);
        prop_go_cond_real = zeros(length(exposure_levels), 1);
        sem_cond_real = zeros(length(exposure_levels), 1);
        
        for i = 1:length(exposure_levels)
            exposure_level = exposure_levels(i);
            
            % Synthetic data calculations
            rows = data_cond(data_cond(:, 2) == exposure_level, :);
            prop_go_avg_cond = mean(rows(:, 1));
            sem_cond(i) = std(rows(:, 1)) / sqrt(size(rows, 1));
            prop_go_cond(i) = prop_go_avg_cond;

            % Real data calculations
            rows_real = data_cond_real(data_cond_real(:, 2) == exposure_level, :);
            prop_go_avg_cond_real = mean(rows_real(:, 1));
            sem_cond_real(i) = std(rows_real(:, 1)) / sqrt(50);
            prop_go_cond_real(i) = prop_go_avg_cond_real;
        end
        
        prop_go_avg{cond+1} = [prop_go_cond, exposure_levels', sem_cond];
        prop_go_avg_real{cond+1} = [prop_go_cond_real, exposure_levels', sem_cond_real];
    end
end


function plot_proportions(prop_go_avg, prop_go_avg_real,day)
    exposure_levels = 1:12;
    figure;
    hold on;
    colors = {'b', 'g', 'r', 'k'};
    markers = {'o-', 'x--'};
    labels = {'GW', 'GW Real', 'NGW', 'NGW Real', 'GAL', 'GAL Real', 'NGAL', 'NGAL Real'};

    for cond = 0:1
        % Extract synthetic data
        prop_go_cond = prop_go_avg{cond+1}(:, 1);
        exposure_level_cond = prop_go_avg{cond+1}(:, 2);
        sem_cond = prop_go_avg{cond+1}(:, 3);
        errorbar(exposure_level_cond, prop_go_cond, sem_cond, markers{1}, 'Color', colors{cond+1}, 'LineWidth', 2);

        % Extract real data
        prop_go_cond_real = prop_go_avg_real{cond+1}(:, 1);
        exposure_level_cond_real = prop_go_avg_real{cond+1}(:, 2);
        sem_cond_real = prop_go_avg_real{cond+1}(:, 3);
        errorbar(exposure_level_cond_real, prop_go_cond_real, sem_cond_real, markers{2}, 'Color', colors{cond+1}, 'LineWidth', 2);
    end
    
    hold off;
    title('Average Proportion of ''Go'' Responses per Exposure Level');
    xlabel('Exposure Level');
    ylabel('Proportion of ''Go'' Responses');
    grid on;
    xlim([min(exposure_levels), max(exposure_levels)]);
    ylim([0, 1]);
    legend(labels);
    
    saveas(gcf, ['output/behaviour_overlaid_real_sim_day' num2str(day) '.png']);

end



% Run the main function
%real_overlaid_plotting();

