%% Script number 1
% imports the matrices from 03_gonogo_all_participants.R
% Creates A, R, S, Val, which will be fed as input to the computaitonal
% modelling

%% GO/NO-GO
% Load the action matrix
A = readmatrix('gonogo_action_matrix.csv');
% change 0's (no-go) into 2s
A(A == 0) = 2;

% Load the reward matrix (1 is "good" outcome and 0 is "bad")
R = readmatrix('gonogo_reward_matrix.csv'); % Keep as is

% Load the condition matrix and turn it into Val
C = readmatrix('gonogo_condition_matrix.csv');
C(C == 1 | C == 2) = 1; % Replace values 1 and 2 with 1 (win)
C(C == 3 | C == 4) = 2; % Replace values 3 and 4 with 2 (lose)
Val = C;

% Load the stimulus matrix and keep as is (1:24 robots)
S = readmatrix('gonogo_stimulus_matrix.csv');

% save into .mat file
save('data_GNG_retest.mat', 'A', 'R', 'S', 'Val')

