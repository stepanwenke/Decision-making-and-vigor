%% Generate stimuli for each participant %%

% Import
% Specify the file paths
robots_s00_path = 'robots_runsheet_s00_16.csv';
stimuli_s00_path = 'stimuli_runsheet_s00_16.csv';
robots_s03_path = 'robots_runsheet_s03_16.csv';
stimuli_s03_path = 'stimuli_runsheet_s03_16.csv';

% Read the robots data from the CSV files
robots_s00 = readmatrix(robots_s00_path);
robots_s03 = readmatrix(robots_s03_path);

% Merge block and block 2
combined_robots = [robots_s00; robots_s03];

% Read the stimuli data from the CSV files
stimuli_s00 = readmatrix(stimuli_s00_path);
stimuli_s03 = readmatrix(stimuli_s03_path);
stimuli_s03 = stimuli_s03+12; % add 12 to distinguish stimuli in the block 2

% Merge block 1 and block 2
combined_stimuli = [stimuli_s00; stimuli_s03];

% Initialize the matrices to store the selected values
robot_matrix = zeros(size(combined_robots));
stimuli_matrix = zeros(size(combined_stimuli));

% Initialize cell arrays to store the results
robot_matrices = cell(1000, 1);
stimuli_matrices = cell(1000, 1);

% Loop to generate the samples
for n = 1:1000
    % Loop through the rows of the robots and stimuli matrices (block 1 and 2)
    for i = 1:size(robot_matrix, 1)
        % Generate a random permutation of the indices 1 to 4
        random_indices = randperm(4);
        
        % Loop through the 4 nested iterations
        for j = 1:4
            % Get the random index
            k = random_indices(j);
            
            % Select the robot and stimulus values based on the random index
            robot_matrix(i, j) = combined_robots(i, k);
            stimuli_matrix(i, j) = combined_stimuli(i, k);
        end
    end

    % Store the results for this iteration
    robot_matrices{n} = robot_matrix;
    stimuli_matrices{n} = stimuli_matrix;
end

% Save the results to a .mat file
save('design_matrix.mat', 'robot_matrices', 'stimuli_matrices');

% % Display the results (optional)
% disp('Robot Matrix:');
% disp(robot_matrix);
% disp('Stimuli Matrix:');
% disp(stimuli_matrix);



