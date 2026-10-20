addpath("../../../data/session1/comp_modelling/rlwm")


% imports the matrices from rlwm_import_data.R
% Creates A, R, S, B, SetSize which will be fed as input to the computaitonal
% modelling

%% RLWM
% Load the data
A       = readmatrix('rlwm_action_matrix.csv');
R       = readmatrix('rlwm_reward_matrix.csv'); % Keep as is
S       = readmatrix('rlwm_stimulus_matrix.csv');
B       = readmatrix('rlwm_block_index_matrix.csv');
SetSize = readmatrix('rlwm_setsize_matrix.csv');

% save into .mat file
save('data_RLWM.mat', 'A', 'B', 'R', 'S', 'SetSize')

