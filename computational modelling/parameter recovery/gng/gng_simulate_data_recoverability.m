clear all
% this script generates 1000 sinthetic samples for each generative model
% based on the mean and stdev of the group parameters obtained in our
% sample. This is the script that is used to generate data to build the
% confusion matrix and test the recoverability of the parameters. The
% output of this script is called sim_data_MODEL.mat and should be saved in
% a separate folder in the simulation_checks folder


% 24 unique robots (12 per block)
% 2 go; 1 no-go
% 1 win; 0 loss
% 0 go-win; 1 nogo-win
% 1 win valence
% 1 go-trial; 0 no-go trial
% 240 trials (120 per block)

samples = 1000;

%% simulate gng
day = '1'; % Specify session 1 or 2

load(['../../comp_modelling_session' day '/GNG/output/parameters_gng.mat']) % load parameters
load('design_matrix.mat')

% load design matrix

mp = mu;
stdev = nu;
param = stdev.*randn(length(mp),samples)+mp*ones(1,samples);

n_trials = 160; % 2 blocks, 80 trials each

% Select a random stimulus row from the real data
% TODO: create a design matrix with randomly generated conditions
% stim_rand_rows = size(gonogo_stimulus_matrix, 1);
% cond_rand_rows = size(gonogo_condition_matrix, 1);


for s = 1:samples
    parameters = param(:,s);
    valence = zeros(1, n_trials); % valence
    go_trials = zeros(1, n_trials); 

    stimuli_vector = stimuli_matrices{s}; % load
    stimuli_vector = reshape(stimuli_vector', 1,[]); % reshape

    condition_vector = robot_matrices{s}; % load
    condition_vector = reshape(condition_vector', 1, []); % reshape

    stimuli_id = stimuli_vector; % stimuli vector
    condition = condition_vector; % condition vector (go-to win 0, no-go to win 1, go-to avoid loss 2, no-go to avoid loss 3)
    
    % Assign 1 where the trials are "go", leave 0 for "no-go"
    go_trials(condition == 0 | condition == 2) = 1;

    % Assign 1 to val where condition is 0 or 1 (win)
    valence(condition == 0 | condition == 1) = 1;
    
    % Assign 2 to val where condition is 2 or 3 (avoid loss)
    valence(condition == 2 | condition == 3) = 2;
    
    [choices, reward] = sim_zorowitz (parameters, stimuli_id, go_trials, valence);
    
    data(s,1) = {struct('choices', choices', 'outcomes', reward', 'stimuli', stimuli_id, 'condition',condition,'valence',valence,'params', parameters)};
end

% Initialize arrays for storing extracted data
A = [];
R = [];
S = [];
C = [];
Val = [];
params = [];

% Number of samples (participants)
samples = length(data);

% Loop over each synthetic dataset
for s = 1:samples
    % Extract synthetic data
    synthetic_data = data{s};
    choices = synthetic_data.choices;
    outcomes = synthetic_data.outcomes;
    condition = synthetic_data.condition;
    stim = synthetic_data.stimuli;
    param = synthetic_data.params;
    val = synthetic_data.valence;
    
    % Append to arrays
    A = [A; choices'];
    R = [R; outcomes'];
    S = [S; stim];
    C = [C; condition];
    Val = [Val; val];
    params = [params; param'];
end

% Last edit
S = S + 1; % Make it from 1 to 4
% R(R == -10 | R == 1) = 0;
% R(R == -1 | R == 10) = 1;


% Save the arrays in a .mat file
save(['day' day '/output_sim/synthdata_GNG.mat'], 'A', 'R', 'S','C','Val', 'params');