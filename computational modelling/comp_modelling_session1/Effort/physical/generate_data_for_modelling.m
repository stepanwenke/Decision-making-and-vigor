addpath("../../../../data/session1/comp_modelling/effort")

% Read the CSV files
R = csvread('physical_reward_matrix.csv');
A = csvread('physical_chosen_effort_matrix.csv');
Elevel = csvread('physical_effort_matrix.csv');

% Change 0s to 2s
A(A == 0) = 2;

% Save variables to .mat file
save('data_physical_effort.mat', 'A', 'R', 'Elevel');
