clear all
% this script generates 1000 sinthetic samples for each generative model
% based on the mean and stdev of the group parameters obtained in our
% sample. This is the script that is used to generate data to build the
% confusion matrix and test the recoverability of the parameters. The
% output of this script is called sim_data_MODEL.mat and should be saved in
% a separate folder in the simulation_checks folder
 
% 480 trials (2 blocks => each block 240 trials => each stimulus 12 times
% => set_size * 12)

%addpath 'E:\recoverability\recoverability\rlwm'
%% simulate rlwm

day = 1;
target_path = ['../../comp_modelling_day', num2str(day), '-prg_exclusions/RLWM/RLWM/'];

pl=[];
for ite=1:10
    load ([target_path '240228_EM_-ll_rlwm-ite' num2str(ite)]);
    pl(ite)=sum(PL(1:end)); 
end

% Find the lowest pl
[min_value, min_index] = min(pl);

if (day == 1)
    %load([dtset '240228_EM_-ll_rlwm-ite' num2str(min_index) '.mat']) % day 1
    load('capacity_pilot2.mat');
    %load('C:\Users\stewe\pavlovia\retest-decision-battery\analysis\modelling_battery\pilot_retest\RLWM\K_distribution_pilot2.mat')
else
    %load('240228_EM_-ll_rlwm-ite10_day2.mat') % day 2
    load('real_capacity_retest.mat');
end

n_trials = 480;

% Select a random stimulus row from the real data
% TODO: create a design matrix with randomly generated conditions
% temp = 0;
% Define number of samples based on the K distribution in our data
samples = length(E);

mp = mu;
stdev = nu;
% param = stdev.*randn(length(mp),samples)+mp*ones(1,samples);

if (day == 1)
    iter_num = 20;
else
    iter_num = 26;
end


for s = 1:samples
    for i = 1:iter_num
        parameters = E(:,s);
        k = K(s);
        [setsize_order_vec, block_index_vec, stimuli_vec, key_pairs_vec] = design_matrix();
        [choices, reward] = sim_rlwm (parameters, n_trials, setsize_order_vec, block_index_vec, stimuli_vec, key_pairs_vec,k);
        
        index = i+((s-1)*iter_num);
        data(index,1) = {struct('choices', choices, 'outcomes', reward, 'stimuli', stimuli_vec,'block',block_index_vec,'setsize',setsize_order_vec, 'params', parameters)};
    end
end
% temp = temp + samples;

% Initialize arrays for storing extracted data
A_real = [];
R_real = [];
S_real = [];
B_real = [];
SZ_real = [];
params = [];

% Number of samples 
samples = length(data);

% Loop over each synthetic dataset
for s = 1:samples
    % Extract synthetic data
    synthetic_data = data{s};

    choices = synthetic_data.choices;
    outcomes = synthetic_data.outcomes;
    stim = synthetic_data.stimuli;
    param = synthetic_data.params;
    block = synthetic_data.block;
    setsize = synthetic_data.setsize;
    
    % Append to arrays
    A_real = [A_real; choices];
    R_real = [R_real; outcomes];
    S_real = [S_real; stim];
    B_real = [B_real; block];
    SZ_real = [SZ_real; setsize];
    params = [params; param'];
end

% Save the arrays in a .mat file

if (day == 1)
    save('output/synthdata_from_real_params_RLWM_pilot2.mat', 'A_real', 'R_real', 'S_real','B_real','SZ_real', 'params');
else
    save('output/synthdata_from_real_params_RLWM_pilot2day2.mat', 'A_real', 'R_real', 'S_real','B_real','SZ_real', 'params');
end
%save ('output/recovery_output.mat','data', 'mp', 'stdev' , 'param')


