%% simulate effort

clear all;

%load('design_matrix.mat')
% load('C:\Users\stewe\pavlovia\retest-decision-battery\analysis\modelling_battery\pilot2\GNG\gonogo_stimulus_matrix.csv')
% load('C:\Users\steweq\pavlovia\retest-decision-battery\analysis\modelling_battery\pilot2\GNG\gonogo_condition_matrix.csv')
% load design matrix
day='2';
iters='3';
model='constrained_quadratic';
target_path=['day' day filesep iters 'iter' filesep model filesep];
addpath(target_path);
output_dir=[target_path 'output_sim' filesep];
fit_file_template='';

if model == "unconstrained_linear"
    fit_file_template = '240208_EM_-linear_ll_physicalE_new_lapse-ite';
elseif model == "constrained_linear"
    fit_file_template = '240208_EM_-linear_ll_physicalE_new_lapse_beta-ite';
elseif model == "constrained_quadratic"
    fit_file_template = '240208_EM_-quadratic_lapse_ll_physicalE-ite';
end

target_path = ['../../../comp_modelling_day', day, '-no exclusions/Effort/physical' filesep model filesep];

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
iter_num = 1000/samples;

for s = 1:samples
    for i = 1:iter_num
    parameters = E(:,s);

    trial_matrix = shuffle_array(1,str2double(iters));
    trial_num = length(trial_matrix);
    stake_vector = trial_matrix(:,2)';
    effort_vector = trial_matrix(:,1)';

    [choices] = sim_physicalE (parameters, effort_vector,stake_vector,trial_num);
    
    index = i+((s-1)*iter_num);

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
save([output_dir 'synthdata_from_real_params_physE_pilot2.mat'], 'A_real', 'R_real', 'ELevel_real', 'params');