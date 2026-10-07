clear; 

% Steps for model validation:
% ---------------------------
% 1. Fit the models to my data (done):
% - quadratic
% - linear constrained
% - linear unconstrained
% 
% 2. Use each of the model mu and nu and generate synthetic data for modelling (1000 samples)
% - a) load mu, nu (
% 

models = {'constrained_quadratic', 'unconstrained_linear', 'constrained_linear'};
n_models = length(models);
samples = 1000;
day = 1;
fit_path = ['../comp_modelling_day' num2str(day) '-prg_exclusions/Effort/physical/'];
%data = [fit_path 'data_physical_effort_retest.mat'];
confusion = zeros(n_models, n_models);  % Rows = generating model, Cols = winning model
files_generated = true;
addpath(['day' num2str(day)]);

for i = 1:n_models
    sim_model = models{i};
    
    % load mu and nu of the fit of the current model
    sim_model_path = [fit_path sim_model filesep];
    
    if files_generated == false
        generate_synthetic_data_fun(sim_model_path, sim_model, samples,day)
    end
    
    % 3. Fit each of the three models on those synthetic samples
    % - 3x3 matrix
    % 
    bic_for_fitted_models = zeros(samples, length(models));
    for y = 1:n_models
        fit_model = models{y};
        
        % load the corresponding fitting function
        fit_model_path = [fit_path fit_model filesep];
        
        % 4. Get BIC for each of the synthetic samples (observed) in each of the fitted samples (3x3 values)
        %
        current_bic = model_fitting_fun(sim_model, fit_model_path, fit_model, files_generated, day);            
        
        bic_for_fitted_models(:,y) = current_bic;
    
    end
    
    % 5. Record the winning model for each of the synthetic sample for each of the fitted samples
    [~, best_fit_indices] = min(bic_for_fitted_models, [], 2);

    for z = 1:n_models
        confusion(i, z) = sum(best_fit_indices == z);
    end
    
end

% 6. Plot the confusion matrix
confusion_normalized = confusion ./ samples;


figure;
imagesc(confusion_normalized);
xticks(1:n_models); yticks(1:n_models);
models_clean = strrep(models, '_', ' ');  % Replace '_' with space
xticklabels(models_clean);
yticklabels(models_clean);
xlabel('Fitted model'); ylabel('Simulated (true) model');
title('Model recovery confusion matrix (BIC)');
colorbar;

% Overlay values
for i = 1:n_models
    for j = 1:n_models
        val = confusion_normalized(i,j);
        text(j, i, sprintf('%.2f', val), ...
            'HorizontalAlignment', 'center', ...
            'Color', 'k', ...             % text color
            'FontWeight', 'bold');        % make it stand out
    end
end

saveas(gcf, ['day' num2str(day) filesep 'confusion_matrix.jpg']);

% Correlate the parameters of the winning model
load(['day' num2str(day) filesep 'constrained_quadratic/fitted_with_synthetic_constrained_quadratic/parameters_physicalE_retest']);

% Ensure column vectors
beta = beta(:);
k    = k(:);
g    = g(:);

figure;

% beta vs k
subplot(1,3,1);
scatter(beta, k, 'filled'); hold on;
pfit = polyfit(beta, k, 1); % Linear fit
xvals = linspace(min(beta), max(beta), 100);
yfit = polyval(pfit, xvals);
plot(xvals, yfit, 'r', 'LineWidth', 2); % Thick red line
xlabel('\beta'); ylabel('k');
axis square;
[r, p] = corr(beta, k);
title(sprintf('r = %.2f, p = %.3f', r, p));

% beta vs g
subplot(1,3,2);
scatter(beta, g, 'filled'); hold on;
pfit = polyfit(beta, g, 1);
xvals = linspace(min(beta), max(beta), 100);
yfit = polyval(pfit, xvals);
plot(xvals, yfit, 'r', 'LineWidth', 2);
xlabel('\beta'); ylabel('g');
axis square;
[r, p] = corr(beta, g);
title(sprintf('r = %.2f, p = %.3f', r, p));

% beta vs g
subplot(1,3,3);
scatter(k, g, 'filled'); hold on;
pfit = polyfit(k, g, 1);
xvals = linspace(min(k), max(k), 100);
yfit = polyval(pfit, xvals);
plot(xvals, yfit, 'r', 'LineWidth', 2);
xlabel('k'); ylabel('g');
axis square;
[r, p] = corr(k, g);
title(sprintf('r = %.2f, p = %.3f', r, p));

sgtitle('Parameter correlations');

