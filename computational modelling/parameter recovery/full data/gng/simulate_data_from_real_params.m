clear all
% this script generates 1000 sinthetic samples for each generative model
% based on the mean and stdev of the group parameters obtained in our
% sample. This is the script that is used to generate data to build the
% confusion matrix and test the recoverability of the parameters. The
% output of this script is called sim_data_MODEL.mat and should be saved in
% a separate folder in the simulation_checks folder

%cd('/home/marc.guitart/Documents/modelling_battery/recoverability');
%mkdir sim_data_GNGzorowitz

% cd('/home/marc.guitart/Documents/HBI_online_correctRLM/HBI_amy_new/HBI_reversal/simulations_HBI');
% 
% load ('/home/marc.guitart/Documents/HBI_online_correctRLM/HBI_amy_new/HBI_reversal/simulations_HBI/targetMat.mat')
% 

% 24 unique robots (12 per block)
% 2 go; 1 no-go
% 1 win; 0 loss
% 0 go-win; 1 nogo-win; 2 go-avoid loss; 3 nogo-avoid loss
% 1 win valence, 2 lose valence
% 1 go-trial; 0 no-go trial
% 240 trials (120 per block)


%% simulate gng
day = 2;

if (day == 1)
    load('240207_EM_-ll_zorowitz-ite10.mat')
else
    load('240207_EM_-ll_zorowitz-ite10_day2.mat')
end

load('design_matrix.mat')

samples = length(E);
% load('C:\Users\stewe\pavlovia\retest-decision-battery\analysis\modelling_battery\pilot2\GNG\gonogo_stimulus_matrix.csv')
% load('C:\Users\stewe\pavlovia\retest-decision-battery\analysis\modelling_battery\pilot2\GNG\gonogo_condition_matrix.csv')
% load design matrix

mp = mu;
stdev = nu;
param = stdev.*randn(length(mp),samples)+mp*ones(1,samples);

n_trials = 240;

% Select a random stimulus row from the real data
% TODO: create a design matrix with randomly generated conditions
% stim_rand_rows = size(gonogo_stimulus_matrix, 1);
% cond_rand_rows = size(gonogo_condition_matrix, 1);

if (day == 1)
    iter_num = 20;
else
    iter_num = 26;
end

for s = 1:samples
    for i = 1:iter_num
        parameters = E(:,s);
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
        
        index = i+((s-1)*iter_num);

        data(index,1) = {struct('choices', choices', 'outcomes', reward', 'stimuli', stimuli_id, 'condition',condition,'valence',valence,'params', parameters)};
    end
end

% Initialize arrays for storing extracted data
A_real = [];
R_real = [];
S_real = [];
C_real = [];
Val_real = [];
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
    A_real = [A_real; choices'];
    R_real = [R_real; outcomes'];
    S_real = [S_real; stim];
    C_real = [C_real; condition];
    Val_real = [Val_real; val];
    params = [params; param'];
end

% Last edit
S_real = S_real + 1; % Make it from 1 to 4
% R(R == -10 | R == 1) = 0;
% R(R == -1 | R == 10) = 1;


% Save the arrays in a .mat file
if (day == 1)
    save('output/synthdata_from_real_params_GNG_pilot2.mat', 'A_real', 'R_real', 'S_real','C_real','Val_real', 'params');
else
    save('output/synthdata_from_real_params_GNG_pilot2_day2.mat', 'A_real', 'R_real', 'S_real','C_real','Val_real', 'params');
end
    %save ('output/recovery_output.mat','data', 'mp', 'stdev' , 'param')


