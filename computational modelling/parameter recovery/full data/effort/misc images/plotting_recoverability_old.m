clear all
clc

day = 2;

if (day == 1)
    load("output/synthdata_physE_pilot2.mat") % Simulated parameters
    load("pilot2/parameters_physicalE_pilot2_01.mat") % Observed / fitted params
else
    load("output/synthdata_physE_pilot2day2.mat") % Simulated parameters
    load("pilot2/parameters_physicalE_pilot2_01_day2.mat") % Observed / fitted params
end 

% Convert observed params to the param space
beta_simulated 	  = exp(params(:,1));
k_simulated 	  = 1./(1+exp(-params(:,2)));

% Transform parameters
% betas = exp(E(1:2,:)); % beta params (row 1:reward, row 2:punishment)
% alphas = 1./(1+exp(-E(3:4,:))); % alpha params (row 1:reward, row 2:punishment)
% eps = exp(E(5:6,:)); % epsilon params (approach/avoid bias; row 1:reward, row 2:punishment)
% lapse = 1./(1+exp(-E(7,:))); % lapse rate

% Transpose the vars into cols
beta = beta';
k = k';
% 
% % Extract the observed vars the same way as the simulated params
% eps_pos = eps(:,1);
% eps_neg = eps(:,2);
% beta_pos = betas(:,1);
% beta_neg = betas(:,2);
% alpha_pos = alphas(:,1);
% alpha_neg = alphas(:,2);


%% Create figure for scatter plots
figure;

% List of parameter names and their pairs
param_pairs = {'beta', beta, beta_simulated;
               'k', k, k_simulated};

% Iterate over parameter pairs to plot and correlate
for i = 1:size(param_pairs, 1)
    param_name = param_pairs{i, 1};
    observed = param_pairs{i, 2};
    simulated = param_pairs{i, 3};
    
    % Calculate correlation coefficient
    r = corr(observed, simulated);
    
    % Scatter plot
    subplot(4, 2, i);
    scatter(simulated,observed,'filled');
    hold on;
    
    % Fit and plot line
    lm = fitlm(simulated,observed);
    plot(lm);
    
    % Add title and labels
    title([param_name ' (r = ' num2str(r, '%.2f') ')']);
    xlabel('Simulated');
    ylabel('Observed');
    
    hold off;
end



