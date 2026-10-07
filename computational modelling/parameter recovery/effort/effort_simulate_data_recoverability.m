%% simulate effort

clear all;

day=1;
iters=3;
model='constrained_quadratic_beta';

load_path = sprintf('day%d/%diter/%s/', day, iters, model);
load([load_path 'parameters_physicalE_retest.mat']);
addpath(load_path);

samples = 1000;
mp = mu;
stdev = nu;
param = stdev.*randn(length(mp),samples)+mp*ones(1,samples);


for s = 1:samples
    parameters = param(:,s);

    trial_matrix = shuffle_array(1,iters); % 1 = full matrix, num of iters
    stake_vector = trial_matrix(:,2)';
    effort_vector = trial_matrix(:,1)';
    n_trials = length(trial_matrix);
    [choices] = sim_physicalE (parameters, effort_vector,stake_vector,n_trials);
    
    data(s,1) = {struct('choices', choices', 'outcomes', stake_vector,'ELevel',effort_vector,'params', parameters)};
end

% Initialize arrays for storing extracted data
A = [];
R = [];
ELevel = [];
params = [];

% Number of samples (participants)
samples = length(data);

% Loop over each synthetic dataset
for s = 1:samples
    % Extract synthetic data
    synthetic_data = data{s};
    choices = synthetic_data.choices;
    outcomes = synthetic_data.outcomes;
    effort = synthetic_data.ELevel;
    param = synthetic_data.params;
    
    % Append to arrays
    A = [A; choices'];
    R = [R; outcomes];
    ELevel = [ELevel; effort];
    params = [params; param'];
end

% Last edit (cannot be 0, otherwise cannot be indexed)
A(A == 0) = 2;

% Save the arrays in a .mat file
save([load_path '/output_sim/synthdata_physE_pilot2.mat'], 'A', 'R', 'ELevel', 'params');