clear

% Settings
real=true;
day='1';
model='unconstrained_linear';
%%%%%%%%%%%%%

real_suffix='';
target_path = ['day' day filesep model];
data_path = ['../../comp_modelling_session' day '/Effort/physical/data_physical_effort.mat'];

if real==false
    load([target_path '/output_sim/synthdata_physE.mat']) % Simulated parameters     
else
    load([target_path '/output_sim/synthdata_from_real_params_physE.mat']) % Simulated parameters from real params
    load(data_path); % real data
    
    ELevel = Elevel;
    real_suffix='_real';
end

% Define reward and effort levels
rewardLevels = [2, 4, 6, 8, 10];
effortLevels = [1, 2, 3, 4, 5]; % Assuming effort levels are integers and fall between 1 to 5


A(A == 2) = 0; % Change it for now, so the code works

if real == true
    A_real(A_real == 2) = 0; % Change it for now, so the code works
end

if real == true
    % Initialize the heat map data matrix
    heatMapData_real = zeros(length(effortLevels), length(rewardLevels));

    % Calculate the proportion of accepted efforts for each combination
    for i = 1:length(effortLevels)
        for j = 1:length(rewardLevels)
            % Find the trials with the current effort and reward levels
            trials = (ELevel_real == effortLevels(i)) & (R_real == rewardLevels(j));
            % Calculate the proportion of accepted efforts
            acceptedEfforts = sum(A_real(trials)) / sum(trials(:));
            % Store the result in the heat map data
            heatMapData_real(i, j) = acceptedEfforts;
        end
    end
end

% Calculate the same for the real data
% Calculate real data mean and standard error
heatMapData_data = zeros(length(effortLevels), length(rewardLevels));
heatMapSE_data = zeros(length(effortLevels), length(rewardLevels)); % Standard error

for i = 1:length(effortLevels)
    for j = 1:length(rewardLevels)
        % Find trials for effort/reward combo
        trials_data = (ELevel == effortLevels(i)) & (R == rewardLevels(j));
        
        % Calculate the proportion of accepted efforts
%         acceptedEfforts_data = sum(A(trials_data)) / sum(trials_data(:));
%         
%         % Proportion and standard error
%         heatMapData_data(i, j) = acceptedEfforts_data;
%         heatMapSE_data(i, j) = std(acceptedEfforts_data) / sqrt(sum(acceptedEfforts_data));

        responses = A(trials_data);  % All binary responses (0 or 1)
        n_trials = length(responses);

        if n_trials > 1
            prop = mean(responses); % Proportion of accepted efforts
            se = std(responses) / sqrt(n_trials); % Standard error of the mean
        elseif n_trials == 1
            prop = responses;
            se = NaN; % Cannot compute standard error with only 1 trial
        else
            prop = NaN;
            se = NaN;
        end

        heatMapData_data(i, j) = prop;
        heatMapSE_data(i, j) = se;

    end
end


if real == true
    % Plot simulated data
    figure;
    hold on;
    colors = lines(length(effortLevels)); % Distinct colors

    for i = 1:length(effortLevels)
        plot(rewardLevels, heatMapData_real(i, :), '-o', ...
            'DisplayName', ['Sim Effort ' num2str(effortLevels(i))], ...
            'Color', colors(i, :), 'LineWidth', 2, 'MarkerSize', 6);
    end
    

    % Overlay real data with error bars
    for i = 1:length(effortLevels)
        lightColor = colors(i,:) + (1 - colors(i,:)) * 0.1;

        errorbar(rewardLevels, heatMapData_data(i,:), heatMapSE_data(i,:), ...
            '--o', 'Color', lightColor, ...
            'LineWidth', 1.5, 'MarkerSize', 6, ...
            'DisplayName', ['Real Effort ' num2str(effortLevels(i))]);
    end

    xlabel('Reward Level');
    ylabel('Proportion of Accepted Efforts');
    title('Simulated vs Real: Accepted Efforts by Reward and Effort');
    legend('Location', 'bestoutside');
    grid on;
    ylim([0 1]);

    % Save figure
    saveas(gcf, [target_path '/output_sim/effort_lines_overlaid.png']);

end

if real == false
    % Heatmap of simulated "data" (proportion of accepted efforts)
    figure;

    imagesc(rewardLevels, effortLevels, heatMapData_data); % Keep default colormap
    set(gca, 'YDir', 'normal');  % Make Y-axis from low to high

    colormap(parula);            % Use default colors (or replace with your desired colormap)
    colorbar;                    % Show color scale

    xlabel('Reward Level');
    ylabel('Effort Level');
    title('Simulated Proportion of Accepted Efforts');

    % Show exact values on the heatmap tiles
    for i = 1:length(effortLevels)
        for j = 1:length(rewardLevels)
            value = heatMapData_data(i,j);
            if ~isnan(value)
                text(rewardLevels(j), effortLevels(i), sprintf('%.2f', value), ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', ...
                    'Color', 'white', 'FontWeight', 'bold');
            end
        end
    end
end
