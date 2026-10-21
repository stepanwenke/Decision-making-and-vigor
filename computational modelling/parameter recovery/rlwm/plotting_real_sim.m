clear;

%% Settings
day = '1'; % Choose a session 1 or 2
model = 'll_rlwm'; % Choose a model ll_rlwm or ll_wmh
%%%%

load(['output_sim/synthdata_from_real_params_RLWM_' model '_session' day '.mat'])
load(['output_sim/synthdata_RLWM_' model '_session' day '.mat'])

if day == '1'
    n_participants_real = 162;
else
    n_participants_real = 71;
end

S_sim = S; SZ_sim = SZ; R_sim = R;
% Number of participants in the simulated and real data
n_participants_sim = size(S_sim, 1);

% Initialize number of iterations and unique set sizes
max_iterations = 12;  % since each stimulus is repeated 12 times
unique_set_sizes = unique(SZ_sim(:));

% Function to calculate average proportions and SEM across all participants
[average_proportions_sim, sem_sim] = calculate_average_proportions(S_sim, SZ_sim, R_sim, max_iterations, unique_set_sizes, n_participants_sim);
[average_proportions_real, sem_real] = calculate_average_proportions(S_real, SZ_real, R_real, max_iterations, unique_set_sizes, n_participants_real);

% Plotting
% Generate labels for the legend
legend_labels = cell(1, 2 * length(unique_set_sizes));
for idx = 1:length(unique_set_sizes)
    legend_labels{idx} = sprintf('Set Size %d (Sim)', unique_set_sizes(idx));
    legend_labels{idx + length(unique_set_sizes)} = sprintf('Set Size %d (Real)', unique_set_sizes(idx));
end

figure;
hold on;
colors = lines(length(unique_set_sizes)); % generate distinct colors for each set size

% Plot each set size's curve for simulated data with error bars
for idx = 1:length(unique_set_sizes)
    errorbar(1:max_iterations, average_proportions_sim(:, idx), sem_sim(:, idx), 'o-', 'Color', colors(idx, :), 'LineWidth', 2); % Solid lines for simulated data
end

% Plot each set size's curve for real parameters data with error bars
for idx = 1:length(unique_set_sizes)
    errorbar(1:max_iterations, average_proportions_real(:, idx), sem_real(:, idx), 's--', 'Color', colors(idx, :), 'LineWidth', 2); % Dashed lines for real data
end

% Adding labels and legend
xlabel('Stimulus Iteration');
ylabel('Proportion Correct');
title('Average Proportion Correct by Stimulus Iteration and Set Size');
legend(legend_labels);
grid on;
hold off;

saveas(gcf, ['output_sim/behaviour_real_sim_' model '_session' day '.png']);


% Function to calculate proportions
function proportions = calculate_proportions(stimuli, set_size, reward, max_iterations, unique_set_sizes)
    % Initialize storage for proportions
    proportions = zeros(max_iterations, length(unique_set_sizes));

    % Initialize a matrix to track stimulus iteration within each set size
    stimulus_iterations = zeros(size(stimuli));

    % Loop through each set size to calculate stimulus iterations
    for idx = 1:length(unique_set_sizes)
        ss = unique_set_sizes(idx);
        
        % Get indices of trials with this set size
        ss_trials = find(set_size == ss);
        
        % Track the count of each stimulus within this set size
        stim_count = zeros(1, max(stimuli)); % Assuming stimuli are numbered 1, 2, 3, ...
        
        % Loop through the trials for this set size
        for i = 1:length(ss_trials)
            trial = ss_trials(i);
            stim = stimuli(trial);
            stim_count(stim) = stim_count(stim) + 1; % Increment count for this stimulus
            
            % Store the current iteration number
            stimulus_iterations(trial) = stim_count(stim);
        end
    end

    % Now calculate the proportion correct for each set size and iteration
    for idx = 1:length(unique_set_sizes)
        ss = unique_set_sizes(idx);
        
        % Initialize counts for stimulus iterations
        correct_counts = zeros(1, max_iterations);
        total_counts = zeros(1, max_iterations);
        
        % Loop through each stimulus iteration
        for stim_iter = 1:max_iterations
            % Find trials corresponding to this set size and stimulus iteration
            iter_trials = (set_size == ss) & (stimulus_iterations == stim_iter);
            
            % Calculate correct and total counts for this iteration
            correct_counts(stim_iter) = sum(reward(iter_trials));
            total_counts(stim_iter) = sum(iter_trials);
        end
        
        % Calculate the proportion correct for each iteration
        proportions(:, idx) = correct_counts ./ total_counts;
    end
end

% Function to calculate average proportions and SEM across all participants
function [average_proportions, sem] = calculate_average_proportions(S, SZ, R, max_iterations, unique_set_sizes, n_participants)
    all_proportions_part1 = zeros(max_iterations, length(unique_set_sizes), n_participants);
    all_proportions_part2 = zeros(max_iterations, length(unique_set_sizes), n_participants);
    
    % Loop over each participant
    for p = 1:n_participants
        stimuli = S(p, :);
        set_size = SZ(p, :);
        reward = R(p, :);
        
        % Split the data into two parts
        n_trials_per_part = 240;
        stimuli_part1 = stimuli(1:n_trials_per_part);
        stimuli_part2 = stimuli(n_trials_per_part+1:end);
        
        set_size_part1 = set_size(1:n_trials_per_part);
        set_size_part2 = set_size(n_trials_per_part+1:end);
        
        reward_part1 = reward(1:n_trials_per_part);
        reward_part2 = reward(n_trials_per_part+1:end);
        
        % Calculate proportions for both parts for this participant
        proportions_part1 = calculate_proportions(stimuli_part1, set_size_part1, reward_part1, max_iterations, unique_set_sizes);
        proportions_part2 = calculate_proportions(stimuli_part2, set_size_part2, reward_part2, max_iterations, unique_set_sizes);
        
        % Store the proportions for this participant
        all_proportions_part1(:, :, p) = proportions_part1;
        all_proportions_part2(:, :, p) = proportions_part2;
    end

    % Average the proportions across all participants and both parts
    average_proportions_part1 = mean(all_proportions_part1, 3);
    average_proportions_part2 = mean(all_proportions_part2, 3);
    average_proportions = (average_proportions_part1 + average_proportions_part2) / 2;
    
    % Calculate SEM across participants
    sem_part1 = std(all_proportions_part1, 0, 3) / sqrt(n_participants);
    sem_part2 = std(all_proportions_part2, 0, 3) / sqrt(n_participants);
    sem = (sem_part1 + sem_part2) / 2;
end
