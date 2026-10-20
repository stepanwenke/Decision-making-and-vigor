%% simulate effort

clear all;

% Settings
day='1';
model='unconstrained_linear';
%%%%%%

target_path=['day' day filesep model filesep];
addpath(target_path);
output_dir=[target_path 'output_sim' filesep];
fit_file_template=['240208_EM_-' model '-ite'];


target_path = ['../../comp_modelling_session', day, '/Effort/physical' filesep model filesep];

pl=[];
for ite=1:10
    load ([target_path fit_file_template num2str(ite)]);
    pl(ite)=sum(PL(1:end));
end

% Find the lowest pl
[min_value, min_index] = min(pl);

% Construct the filename based on the index
filename = [target_path fit_file_template num2str(min_index)];

% Load the file
load(filename);


samples = length(E);
iter_num = 1;

for s = 1:samples
    for i = 1:iter_num
    parameters = E(:,s);

    trial_matrix = shuffle_array(1,3); % 1: Full matrix; 3 iterations (75 trials)
    trial_num = length(trial_matrix);
    stake_vector = trial_matrix(:,2)';
    effort_vector = trial_matrix(:,1)';

    [choices] = sim_physicalE (parameters, effort_vector,stake_vector,trial_num);
    
    index = i+((s-1)*iter_num);
    
    disp(index)

    data(index,1) = {struct('choices', choices', 'outcomes', stake_vector,'ELevel',effort_vector,'params', parameters)};
    end
end

% Initialize arrays for storing extracted data
A_real = [];
R_real = [];
ELevel_real = [];
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
    A_real = [A_real; choices'];
    R_real = [R_real; outcomes];
    ELevel_real = [ELevel_real; effort];
    params = [params; param'];
end

% Last edit (cannot be 0, otherwise cannot be indexed)
A_real(A_real == 0) = 2;

% Save the arrays in a .mat file
save([output_dir 'synthdata_from_real_params_physE.mat'], 'A_real', 'R_real', 'ELevel_real', 'params');