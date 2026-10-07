clear

real=true;
real_suffix='';
day='2';
iters='3';
model='unconstrained_linear';

target_path = ['day' day filesep iters 'iter' filesep model];

if real==false
    load([target_path '/output_sim/synthdata_physE_pilot2.mat']) % Simulated parameters     
else
    load([target_path '/output_sim/synthdata_from_real_params_physE_pilot2.mat']) % Simulated parameters from real params
    R=R_real;
    ELevel=ELevel_real;
    A=A_real;
    
    real_suffix='_real';
end

% Define reward and effort levels
rewardLevels = [2, 4, 6, 8, 10];
effortLevels = [1, 2, 3, 4, 5]; % Assuming effort levels are integers and fall between 1 to 5
A(A == 2) = 0; % Change it for now, so the code works

% Initialize the heat map data matrix
heatMapData = zeros(length(effortLevels), length(rewardLevels));

% Calculate the proportion of accepted efforts for each combination
for i = 1:length(effortLevels)
    for j = 1:length(rewardLevels)
        % Find the trials with the current effort and reward levels
        trials = (ELevel == effortLevels(i)) & (R == rewardLevels(j));
        % Calculate the proportion of accepted efforts
        acceptedEfforts = sum(A(trials)) / sum(trials(:));
        % Store the result in the heat map data
        heatMapData(i, j) = acceptedEfforts;
    end
end

% Plot the heat map
figure;
imagesc(rewardLevels, effortLevels, heatMapData);
colorbar;
xlabel('Reward Levels');
ylabel('Effort Levels');
title('Proportion of Accepted Efforts');
set(gca, 'YDir', 'normal'); % Ensure the y-axis starts from the bottom

A(A == 0) = 2; % Change it back to how it was

% Save the figure
saveas(gcf, [target_path '/output_sim/effort_heatmap' real_suffix '.png']); % or use exportgraphics for better quality
