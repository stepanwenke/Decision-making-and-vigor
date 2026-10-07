function [setsize_order_vec, block_index_vec, stimuli_vec, key_pairs_vec] = design_matrix() 
    % clear
    % clc

    % Main script
    
    % Randomize the set size
    % Define the possible set size orders
    setsize_orders = {'setsize_order1', 'setsize_order2', 'setsize_order3', 'setsize_order4', 'setsize_order5'};
    
    % Randomly select one set size order
    condition_assignment = setsize_orders{randi(length(setsize_orders))};
    
    % Initialize setsize_order variable
    setsize_order = [];
    
    % Assign the setsize_order based on the condition_assignment
    switch condition_assignment
        case 'setsize_order1'
            setsize_order = [2, 6, 3, 5, 4, 6, 4, 2, 3, 5];
        case 'setsize_order2'
            setsize_order = [3, 2, 4, 6, 5, 5, 2, 4, 6, 3];
        case 'setsize_order3'
            setsize_order = [4, 3, 5, 2, 6, 4, 6, 2, 5, 3];
        case 'setsize_order4'
            setsize_order = [5, 3, 2, 4, 6, 3, 6, 5, 2, 4];
        case 'setsize_order5'
            setsize_order = [2, 5, 3, 4, 6, 6, 3, 5, 4, 2];
    end
    
    % Display the chosen setsize_order for verification
    % disp(['Condition Assignment: ', condition_assignment]);
    % disp('Set Size Order:');
    % disp(setsize_order);
    % 
    
    
    % Function to generate key pairs for all set sizes, restarting if any exceed letter count
    function [all_key_pairs, total_letter_counts] = generateAllKeyPairs(setsize_order)
        % Generate the initial distribution of response keys with the specified counts
        possible_keys = generateShuffledKeys();
        sizes = unique(setsize_order);
    
        % Function to check if any letter count exceeds 14 or 13 if 14 is already assigned
        assigned_once = false;
    
        function exceedsLimit = checkLetterCounts(total_letter_counts)
            limit = 14;
            if assigned_once
                limit = 13;
            end
            
            exceedsLimit = total_letter_counts.q > limit || total_letter_counts.w > limit || total_letter_counts.e > limit;
            
    %         if total_letter_counts.q == 14 || total_letter_counts.w == 14 || total_letter_counts.e == 14
    %             assigned_once = true;
    %         end
        end
    
        % Loop until all set sizes meet the criteria
        while true
            total_letter_counts = struct('q', 0, 'w', 0, 'e', 0);
            all_key_pairs = cell(length(sizes), 2);
            
            % Generate key pairs for each set size
            for idx = 1:length(sizes)
                sz = sizes(idx);
                key_pairs = generateKeyPairs(possible_keys, sz, 2);
                all_key_pairs{idx, 1} = sz;
                all_key_pairs{idx, 2} = key_pairs;
                
                % Update total_letter_counts
                for pair = key_pairs
                    counts = countLetters(pair{1});
                    total_letter_counts.q = total_letter_counts.q + counts(1);
                    total_letter_counts.w = total_letter_counts.w + counts(2);
                    total_letter_counts.e = total_letter_counts.e + counts(3);
                end
                
                % If any letter count exceeds 14 or 13 (if 14 once assigned), restart the loop
                if checkLetterCounts(total_letter_counts)
                    % disp('Restarting due to letter count exceeding limit');
                    break;
                end
            end
            
            % If all set sizes meet the criteria, break the loop
            if ~checkLetterCounts(total_letter_counts)
                if total_letter_counts.q == 12 || total_letter_counts.w == 12 || total_letter_counts.e == 12
                    continue;
                else
                    break;
                end
            end
        end
    
        % Print results
        % disp('Generated Key Pairs:');
        for idx = 1:size(all_key_pairs, 1)
            sz = all_key_pairs{idx, 1};
            key_pairs = all_key_pairs{idx, 2};
            % disp(['Set Size ', num2str(sz), ':']);
            % disp(key_pairs);
        end

        % Print total counts of each letter
        % disp('Total Counts of Each Letter:');
        % disp(['q: ', num2str(total_letter_counts.q)]);
        % disp(['w: ', num2str(total_letter_counts.w)]);
        % disp(['e: ', num2str(total_letter_counts.e)]);
    end
    
    [all_key_pairs, total_letter_counts] = generateAllKeyPairs(setsize_order);
    
    % Function definitions
    function shuffled = shuffle(array)
        % Shuffle the array
        shuffled = array(randperm(length(array)));
    end
    
    function count = countLetters(keys)
        % Count the occurrences of each response button
        count = [sum(keys == 'q'), sum(keys == 'w'), sum(keys == 'e')];
    end
    
    function possible_keys = generateShuffledKeys()
        % Generate a shuffled array of response keys with a specified initial distribution
        response_buttons = {'q', 'w', 'e'};
        response_keys_shuffled = shuffle(response_buttons);
        
        % Initialize the possible_keys with the desired counts [14, 13, 13]
        possible_keys = [repmat(response_keys_shuffled{1}, 1, 14), ...
                         repmat(response_keys_shuffled{2}, 1, 13), ...
                         repmat(response_keys_shuffled{3}, 1, 13)];
        
        % Shuffle the possible_keys
        possible_keys = shuffle(possible_keys);
    end
    
    function key_pairs = generateKeyPairs(possible_keys, set_size, num_pairs)
        % Generate key pairs for a given set size
        key_pairs = {};
        while length(key_pairs) < num_pairs
            tempKeys = possible_keys(randperm(length(possible_keys), set_size));
            number_letters = countLetters(tempKeys);
            
            % Check if the key pair meets the requirements
            if (set_size == 2 && length(unique(tempKeys)) == 2) || ...
               (set_size >= 3 && set_size <= 4 && all(number_letters <= 2)) || ...
               (set_size >= 5 && set_size <= 6 && all(number_letters <= 3))
                % If it meets the requirements, add to key_pairs
                key_pairs{end+1} = tempKeys;
            end
        end
    end

    [setsize_order_vec, stimuli_vec, block_index_vec] = generateMatrices(all_key_pairs,setsize_order);
    
    % How to access the correct key presses:
    % all_key_pairs{set_size,2}{block_number}(stimulus_id)
    function [setsize_order_vec, stimuli_vec,block_index_vec] = generateMatrices(all_key_pairs, setsize_order)
        setsize_order_vec = [];
        block_index_vec = [];
        stimuli_vec = [];
        key_pairs_vec = [];
        block_num = 1;
        
        for i = 1:length(setsize_order)
            if i > length(setsize_order) / 2
                block_num = 2;
            end

            n = setsize_order(i);
            block_length = 12 * n;
            setsize_order_vec = [setsize_order_vec; repmat(n, block_length, 1)];

            block_index = zeros(block_length, 1); % Initialize block with zeros
            block_index(1) = 1; % Set the first element of the block to 1
            block_index_vec = [block_index_vec; block_index]; % Concatenate block to the full vector

            block_stimuli = randi(n, block_length, 1);
            stimuli_vec = [stimuli_vec; block_stimuli];
            
            % Determine correct responses
            key_pairs = all_key_pairs{n-1, 2}{block_num};
            key_pairs_for_block = key_pairs(block_stimuli);

            % disp(['Length of block_stimuli: ', num2str(length(block_stimuli))]);
            % disp(['Length of key_pairs_for_block: ', num2str(length(key_pairs_for_block))]);
            
            key_pairs_for_block_numerical = strrep(key_pairs_for_block, 'q', '1');
            key_pairs_for_block_numerical = strrep(key_pairs_for_block_numerical, 'w', '2');
            key_pairs_for_block_numerical = strrep(key_pairs_for_block_numerical, 'e', '3');

            % Convert the string to a numerical array
            %key_pairs_for_block_numerical = str2double(cellstr(key_pairs_vec'))';

            key_pairs_vec = [key_pairs_vec key_pairs_for_block_numerical];
        end
        setsize_order_vec = setsize_order_vec';
        block_index_vec = block_index_vec';
        stimuli_vec = stimuli_vec';
        key_pairs_vec = key_pairs_vec - '0';
    end
end