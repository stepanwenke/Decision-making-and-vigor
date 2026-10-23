% This script extracts the estimated parameters from all models and
% generates a .csv file with all parameters for each session, ready for
% analysis in R.

%% Settings
day = '1'; % Choose session 1 or 2
comp_modelling_folder = ['comp_modelling_session' day filesep];

% Define tasks
tasks = { ...
    struct('file', fullfile(comp_modelling_folder, 'Effort', 'physical', ...
                            'constrained_quadratic', 'parameters_physicalE.mat'), ...
           'prefix', 'phys', 'rawNames', {{}}), ...
    struct('file', fullfile(comp_modelling_folder, 'GNG', 'output', ...
                            'parameters_gng.mat'), ...
           'prefix', 'gng_', 'rawNames', {{}}), ...
    struct('file', fullfile(comp_modelling_folder, 'RLWM', 'll_rlwm', ...
                            'parameters_RLWM.mat'), ...
           'prefix', 'rlwm_', 'rawNames', {{}})};

%% Load each task into a per-task table (rows = subjects)
taskTables = {};

for t = 1:numel(tasks)
    f = tasks{t};

    if isempty(f.file)
        error('Task %d has an empty file path. Check the tasks definition.', t);
    end

    fprintf('Loading task %d: %s\n', t, f.file);
    if ~exist(f.file, 'file')
        error('File not found: %s', f.file);
    end
    S = load(f.file);
    fn = fieldnames(S);

    if isempty(fn)
        warning('File %s is empty. Skipping.', f.file);
        continue;
    end

    % --- STRATEGY: Find the struct variable ---
    params = S.(fn{1});
    isStructFile = false;
    
    if isstruct(params)
        isStructFile = true;
    else
        for k = 2:numel(fn)
            if isstruct(S.(fn{k}))
                params = S.(fn{k});
                isStructFile = true;
                fprintf('  Found struct in variable: %s\n', fn{k});
                break;
            end
        end
    end

    if isStructFile
        % ---- Case A: Struct File (e.g., RLWM) ----
        pf = fieldnames(params);
        if isempty(pf)
            error('Struct in %s has no fields.', f.file);
        end
        
        nSubj = numel(params.(pf{1}));
        T = table();
        for p = 1:numel(pf)
            v = params.(pf{p});
            if numel(v) ~= nSubj
                warning('%s%s has %d values, expected %d.', ...
                        f.prefix, pf{p}, numel(v), nSubj);
            end
            T.([f.prefix pf{p}]) = v(:);   % force column vector
        end
        fprintf('  Struct loaded: %d subjects, %d parameters.\n', nSubj, numel(pf));

    else
        % ---- Case B: Multiple Raw Variables (e.g., Effort, GNG) ----
        T = table();
        nSubj = -1;
        
        for k = 1:numel(fn)
            varName = fn{k};
            varData = S.(varName);
            
            if isstruct(varData) || isempty(varData) || ~isnumeric(varData)
                continue;
            end
            
            if isvector(varData) || (ismatrix(varData) && (size(varData,1)==1 || size(varData,2)==1))
                varData = varData(:);
            elseif ismatrix(varData) && size(varData,2)>1
                [r, c] = size(varData);
                if r == 1
                    varData = varData(:);
                else
                    for col = 1:c
                        paramName = sprintf('%s_%s_col%d', f.prefix, varName, col);
                        colData = varData(:, col);
                        if nSubj == -1, nSubj = length(colData); end
                        if length(colData) ~= nSubj
                             warning('Var %s col %d has %d rows, expected %d.', varName, col, length(colData), nSubj);
                        end
                        T.(paramName) = colData;
                    end
                    continue;
                end
            end
            
            if nSubj == -1
                nSubj = length(varData);
            elseif length(varData) ~= nSubj
                warning('Variable %s has %d rows, expected %d. Skipping.', varName, length(varData), nSubj);
                continue;
            end
            
            T.([f.prefix '_' varName]) = varData;
        end
        
        if isempty(T)
            error('No numeric data found in %s', f.file);
        end
        
        fprintf('  Raw variables loaded: %d subjects, %d parameters.\n', nSubj, width(T));
    end

    taskTables{end+1} = T;
end

%% Load and preprocess foraging_params.csv
foragingFile = fullfile(['../data/session' day '/output/foraging_params.csv']);
if exist(foragingFile, 'file')
    fprintf('Loading foraging data: %s\n', foragingFile);
    foragingT = readtable(foragingFile);

    if width(foragingT) < 2
        error('foraging_params.csv must have at least 2 columns.');
    end

    % --- Clean subjID: strip "output/" prefix ---
    oldName1 = foragingT.Properties.VariableNames{1};
    rawIDs = string(foragingT.(oldName1));   % cell of char -> string array
    rawIDs = erase(rawIDs, "output/");       % remove prefix wherever present

    foragingT.subjID = rawIDs;

    % extractBetween returns "" (missing) where the delimiter isn't found
    stripped = erase(rawIDs, "output/");
    % Where stripping failed (no "output/" present), keep the original
    foragingT.subjID = stripped;

    % --- Rename second column ---
    oldName2 = foragingT.Properties.VariableNames{2};
    foragingT.foraging_exit_threshold = foragingT.(oldName2);

    % Keep only the two columns we want
    foragingT = foragingT(:, {'subjID', 'foraging_exit_threshold'});

    if height(foragingT) ~= height(taskTables{1})
        warning('Foraging data has %d rows, expected %d. Alignment may be off.', ...
                height(foragingT), height(taskTables{1}));
    end

    taskTables = [ {foragingT}, taskTables ];
else
    warning('foraging_params.csv not found. Skipping foraging data.');
end
%% Horizontally join all task tables
output = taskTables{1};
for i = 2:numel(taskTables)
    if height(taskTables{i}) ~= height(output)
        warning('Task %d has %d rows, first task has %d. Subjects may misalign.', ...
                i, height(taskTables{i}), height(output));
    end
    output = [output, taskTables{i}];
end

%% Export
filename = ['../data/comp_modelling/session' day 'comp_params_anonymized.csv'];
writetable(output, filename);
fprintf('Saved %s (%d rows x %d columns)\n', filename, height(output), width(output));