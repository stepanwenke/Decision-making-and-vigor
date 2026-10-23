day = 1;

model_name = 'k_rho_alpha_ll_wmh';
load(['capacity/capacity_retest_' model_name '.mat']);
      
% Calculate counts and percentages
[counts, edges] = histcounts(K, 1:6);
percentages = counts / sum(counts);

% Display results
for i = 1:length(percentages)
    fprintf('K %d: %.2f%%\n', i, percentages(i));
end

% Find indices for each value from 1 to 5
indices_1 = find(K == 1);
indices_2 = find(K == 2);
indices_3 = find(K == 3);
indices_4 = find(K == 4);
indices_5 = find(K == 5);

% Load parameters of the best iteration
best_iter_path = [model_name '/240228_EM_-' model_name '-ite'];
pl=[];
for ite=1:10
    load ([best_iter_path num2str(ite)]);
    pl(ite)=sum(PL(1:end));
end

% Find the lowest pl
[min_value, min_index] = min(pl);

load('data_RLWM_retest.mat');
load([best_iter_path num2str(min_index) '.mat']) % Get V for calculation of nu

% Create subsets of E based on the indices of K
E1 = E(:, indices_1);  % Subset for K == 1
E2 = E(:, indices_2);  % Subset for K == 2
E3 = E(:, indices_3);  % Subset for K == 3
E4 = E(:, indices_4);  % Subset for K == 4
E5 = E(:, indices_5);  % Subset for K == 5

% Calculate mu and nu for each subset
% Define the indices and their corresponding subsets
indices = {indices_1, indices_2, indices_3, indices_4, indices_5};
subsets = {E1, E2, E3, E4, E5};

% Initialize cells to store mu and nu for each subset
mu = cell(1, 5);
nu = cell(1, 5);

% Calculate number of samples per K
total_samples = 1000;

% Loop over each subset
for i = 1:5
    Nsj = size(subsets{i},2); 
    %samples = round(percentages(i+1) * total_samples);
    current_subset = subsets{i};
    current_indices = indices{i};  % Indices corresponding to participants
    
    % Calculate mu
    mu{i} = mean(current_subset, 2);
    
    % Calculate nu assuming you want to index columns of V
    nu{i} = sqrt(sum(current_subset.^2, 2)/Nsj + trimmean(V(:, current_indices), 10, 2) - mu{i}.^2);
    %sqrt(sum(E.^2,2)/Nsj + trimmean(V,10,2) - mu .^2);
end

% Define the filename for the .mat file
if day == 1
    filename = ['capacity/K_distribution_pilot2_' model_name '.mat'];
else
    filename = ['capacity/K_distribution_retest_' model_name '.mat'];
end

% Save mu, nu, and percentages to the file
save(filename, 'mu', 'nu', 'percentages');