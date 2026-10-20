% RLWM 2nd iteration is the best one on day 1

% Assuming you have:
% - alpha, bias, decay, lapse, rho as 1x162 double vectors
% - K as a 1x162 double vector with values from 1 to 5

% Define parameter names for analysis
paramNames = {'alpha', 'bias', 'decay', 'lapse', 'rho'};
params = {alpha, bias, decay, lapse, rho}; % Store parameters in a cell array

% Loop over each parameter
for i = 1:5
    currentParam = params{i}; % Extract the current parameter
    groups = K; % Group assignments (1 to 5)

    % Perform one-way ANOVA
    [p, tbl, stats] = anova1(currentParam, groups, 'off');

    % Display ANOVA results
    fprintf('ANOVA results for %s:\n', paramNames{i});
    fprintf('p-value: %.4f\n', p);
    disp(tbl);

    % Generate boxplot and store the figure handle
    boxplotFig = figure('Name', paramNames{i}, 'NumberTitle', 'off');
    boxplot(currentParam, groups);
    title(sprintf('Boxplot of %s by Group (K)', paramNames{i}));
    xlabel('Group (K)');
    ylabel(paramNames{i});
    grid on;

    % Check if ANOVA is significant (p < 0.05)
    if p < 0.05
        fprintf('\nANOVA for %s is significant. Running post-hoc t-tests...\n', paramNames{i});

        % Create a new figure for post-hoc comparisons
        postHocFig = figure('Name', ['Post-hoc Comparisons for ' paramNames{i}], 'NumberTitle', 'off');

        % Perform post-hoc t-tests using multcompare
        [c, m, h, gnames] = multcompare(stats, 'Alpha', 0.05, 'Display', 'on');

        % Set the title of the post-hoc figure explicitly
        set(gcf, 'Name', ['Post-hoc Comparisons for ' paramNames{i}], 'NumberTitle', 'off');

        % Display the results of the post-hoc comparisons in the command window
        fprintf('\nPost-hoc t-test results for %s:\n', paramNames{i});
        disp(c);
    else
        fprintf('\nANOVA for %s is NOT significant. Skipping post-hoc tests.\n', paramNames{i});
    end
    fprintf('--------------------------------------------------\n');
end
