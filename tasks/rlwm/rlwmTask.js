function rlwmTask(day) {
    var styleElement;
    let timeline = [];
    const RESPONSE_BUTTONS = ['q', 'w', 'e']; // Available response buttons
    const CATCH_BUTTONS = ['ArrowUp', 'ArrowDown', 'g', '3', 'h', 't', 'k', '7', 'a', '5'];
    const CB = jsPsych.randomization.sampleWithoutReplacement(CATCH_BUTTONS, 1);


    // Experiment parameters
    const FIXATION_DURATION = 500;
    const REPETITIONS_PER_STIMULUS = 12;
    const STIMULUS_TRIAL_DURATION = 2000;
    const FEEDBACK_DURATION = 1000;
    const INITIAL_IMAGE_TRIAL_DURATION = 10000;
    const CATCH_TRIAL_DURATION = 10000;
    const CATCH_TRIAL_FEEDBACK_DURATION = 1000;
    const NUMBER_OF_BLOCKS = 2;
    const NUMBER_OF_TRIALS = 2 * (2 + 3 + 4 + 5 + 6) * REPETITIONS_PER_STIMULUS;
    //const NUMBER_OF_TRIALS = 2 * (3 + 4 + 6) * REPETITIONS_PER_STIMULUS;
    const MAX_CONSECUTIVE_MISSED_TRIALS = 10; //threshold for how many trials the participant can miss in a row
    const MAX_MISSED_TRIALS = NUMBER_OF_TRIALS * .10; //threshold for maximum allowed null responses (reaching the threshold leads to exclusion): 10% of trials
    const INSTRUCTIONS_TRIAL_REPETITIONS = 4;
    const BREAK_DURATION = 60000;

    //Global variables
    let TRIALS = []; //global variables collected in each trial - for running locally only
    let nrMissedTrials = 0; //number of null responses
    var nrMissedAttenChecks = 0; //number of missed check trials
    //let incorrectCount = 0; //to track number of incorrect responses (nr of loops in the instructions)
    let instructions_correct = [];//to track the performance during instructions
    let resp = 0; //to track whether or not participant responds anything during the participant ID trial
    let comprehend_loop_count = 0; //counting how many times the participant had to redo the comprehension check (quiz)
    let consecutive_missed_trials = 0; //counting the number of consecutive missed trials

    let atten_check_trial_idx = [0, 2, 4, 6];

    // pick one of 5 set size orders at random at the start of the experiment
    let condition_assignment =
        jsPsych.randomization.sampleWithoutReplacement(['setsize_order1', 'setsize_order2', 'setsize_order3', 'setsize_order4', 'setsize_order5'], 1)[0];

    // record the condition assignment in the jsPsych data (added to every trial)
    jsPsych.data.addProperties({
        setsize_order: condition_assignment
    });

    //setsize = setsize_order;
    //console.log('day in RLWM: ', day);

    //Set size order. Since there are 2 x 5 set sizes, each half of the order contains each set size (to have both halves of the distribution contain same nr of stimuli).
    // I just created 10 permutations of [2,3,4,5,6] in Matlab (and disregarded order starting with 6, because it's difficult to start with set size 6). I then combined them 2 and 2.
    //"Pseudorandomized" 
    let setsize_order = [];//initialize
    if (jsPsych.data.dataProperties.setsize_order == 'setsize_order1') {
        setsize_order = [2, 6, 3, 5, 4, 6, 4, 2, 3, 5];
    } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order2') {
        setsize_order = [3, 2, 4, 6, 5, 5, 2, 4, 6, 3]; //opposite order
    } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order3') {
        setsize_order = [4, 3, 5, 2, 6, 4, 6, 2, 5, 3];
    } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order4') {
        setsize_order = [5, 3, 2, 4, 6, 3, 6, 5, 2, 4];
    } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order5') {
        setsize_order = [2, 5, 3, 4, 6, 6, 3, 5, 4, 2];
    }

    /*     if (jsPsych.data.dataProperties.setsize_order == 'setsize_order1') {
            setsize_order = [6, 3, 4, 6, 4, 3];
        } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order2') {
            setsize_order = [3, 4, 6, 4, 6, 3]; //opposite order
        } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order3') {
            setsize_order = [4, 3, 6, 4, 6, 3];
        } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order4') {
            setsize_order = [3, 4, 6, 3, 6, 4];
        } else if (jsPsych.data.dataProperties.setsize_order == 'setsize_order5') {
            setsize_order = [3, 4, 6, 6, 3, 4];
        }
     */
    //console.log('SETSIZE_ORDER: ', setsize_order);

    setsize = setsize_order;
    var N_SETSIZES = setsize_order.length;

    //Trial feedback html
    const correct_html = '<p style="color: #015001; font-size: 3.5vw;">Correct!</p>';
    const tooslow_html = '<p style="color: #a10000; font-size: 3.5vw;">Too slow!</p>';
    const incorrect_html = '<p style="color: #a10000; font-size: 3.5vw;">Incorrect!</p>';

    // Set up styles
    function setStyles() {
        setTimeout(() => {
            styleElement = document.createElement('style');
            styleElement.innerHTML = rlwm_styles;
            document.head.appendChild(styleElement);
        }, 1);
    }

    function removeStyles() {
        //console.log("removing styles");
        styleElement?.parentNode?.removeChild(styleElement);
    }

    function setupFullscreenListeners() {
        const events = ['fullscreenchange', 'mozfullscreenchange', 'webkitfullscreenchange', 'msfullscreenchange'];
        events.forEach(event => document.addEventListener(event, fullscreenChangeHandler));
        document.addEventListener('keydown', event => {
            if (!CURRENTLY_IN_FULLSCREEN && (event.key === 'f' || event.key === 'F')) {
                enterFullscreen();
            }
        });
    }

    setupFullscreenListeners();


    ///////////////////////////
    // Check for the number of Qs, Ws, and Es in an array of letters
    function countLetters(letterArray) {
        const counts = { Q: 0, W: 0, E: 0 };

        letterArray.forEach(letter => {
            if (letter === RESPONSE_BUTTONS[0]) counts.Q++;
            else if (letter === RESPONSE_BUTTONS[1]) counts.W++;
            else if (letter === RESPONSE_BUTTONS[2]) counts.E++;
        });

        return [counts.Q, counts.W, counts.E];
    }

    // Function to generate valid key pairs for a set size and max allowed count of each letter
    function generateKeyPairs(possibleKeys, setSize, maxCount) {
        let tempKeys;
        let valid = false;
        let i = 0;
        while (!valid) {
            tempKeys = jsPsych.randomization.sampleWithoutReplacement(possibleKeys, setSize);
            let letterCounts = countLetters(tempKeys);
            //console.log('tempKeys', tempKeys, 'letterCounts', letterCounts);
            valid = letterCounts.every(count => count <= maxCount);
            i++;

            if (i > 5) {
                //console.log('Failed to generate valid key pairs, returning null');
                return null;
            }
        }
        return tempKeys;
    }



    // Function to update possible keys by removing used keys
    function updatePossibleKeys(possibleKeys, usedKeys) {
        let remainingLetterCounts = countLetters(possibleKeys);
        let usedLetterCounts = countLetters(usedKeys);

        return Array(remainingLetterCounts[0] - usedLetterCounts[0]).fill('q')
            .concat(Array(remainingLetterCounts[1] - usedLetterCounts[1]).fill('w'))
            .concat(Array(remainingLetterCounts[2] - usedLetterCounts[2]).fill('e'));
    }

    // Function to check if an empty state (infinity case) is reached
    function checkForEmptyState(possibleKeys) {
        let remainingCounts = countLetters(possibleKeys);
        return remainingCounts.filter(count => count === 0).length > 1;
    }

    // Main logic for generating key pairs
    function generateAllKeyPairs() {
        let responseKeysShuffled = jsPsych.randomization.repeat(RESPONSE_BUTTONS, 1);
        let possibleKeys = Array(14).fill(responseKeysShuffled[0])
            .concat(Array(13).fill(responseKeysShuffled[1]))
            .concat(Array(13).fill(responseKeysShuffled[2]));
        possibleKeys = jsPsych.randomization.repeat(possibleKeys, 1); // Shuffle

        let keyPairs = { 6: [], 5: [], 4: [], 3: [], 2: [] };

        [6, 5, 4, 3, 2].forEach(setSize => {
            let maxCount = setSize > 4 ? 3 : setSize === 2 ? 1 : 2;

            for (let i = 0; i < NUMBER_OF_BLOCKS; i++) {
                //console.log('Generating key pairs for set size', setSize, 'block', i, 'maxCount', maxCount, 'possibleKeys', possibleKeys);
                let tempKeys = generateKeyPairs(possibleKeys, setSize, maxCount);

                if (tempKeys === null) {
                    //console.log('Failed to generate key pairs for set size', setSize, 'block', i, '. returning null');
                    return null;
                } else {
                    keyPairs[setSize].push(tempKeys);
                    possibleKeys = jsPsych.randomization.repeat(updatePossibleKeys(possibleKeys, tempKeys), 1);
                }
            }
        });

        return keyPairs;
    }

    // Assign pseudorandomized key-stimulus mappings to stimuli
    function assignKeyPairsToTrials(setsizeOrder, keyPairs) {
        let keyMappings = [];

        setsizeOrder.forEach((trialSize, i) => {
            let block = i < (N_SETSIZES / 2) ? 0 : 1; // Block 1 or 2
            keyMappings.push(keyPairs[trialSize][block]);
        });

        return keyMappings;
    }

    // Example usage

    // Generate key pairs until it does not return null  
    /*     keyPairs = [];
        while (true) {
            let keyPairs = generateAllKeyPairs();
            if (keyPairs !== null) {
                let assignedKeyPairs = assignKeyPairsToTrials(setsize_order, keyPairs);
                console.log('keyPairs', keyPairs, 'assignedKeyPairs', assignedKeyPairs);
                break;
            }
        } */
    //let keyPairs = generateAllKeyPairs();


    // Example usage
    let keyPairs = null;

    // Generate key pairs until it does not return null  
    while (keyPairs === null) {
        //console.log('Generating key pairs...');
        keyPairs = generateAllKeyPairs();

        // check if any of the dimensions of keyPairs is less than 2
        const isAnyDimensionLessThanTwo = Object.values(keyPairs).some(pairArray => pairArray.length < 2);

        if (isAnyDimensionLessThanTwo) {
            //console.log('One or more dimensions of keyPairs is less than 2. Resetting keyPairs to null.');
            keyPairs = null; // Reset to null if any dimension is less than 2
        } else {
            //console.log('Generated key pairs length:', keyPairs[6].length, keyPairs[5].length, keyPairs[4].length, keyPairs[3].length, keyPairs[2].length);
        }
        //console.log('Generated key pairs length:', keyPairs[6].length, keyPairs[5].length, keyPairs[4].length, keyPairs[3].length, keyPairs[2].length);
    }

    // Once we have valid key pairs, we can assign them to trials
    let assignedKeyPairs = assignKeyPairsToTrials(setsize_order, keyPairs);
    //console.log('keyPairs', keyPairs, 'assignedKeyPairs', assignedKeyPairs);


    //create separate array of the images. For displaying the "initial trial"
    let imgs = [ //initialize
        { img: [] }, { img: [] }, { img: [] }, { img: [] }, { img: [] },
        { img: [] }, { img: [] }, { img: [] }, { img: [] }, { img: [] }
    ];

    //to have enough data for the comparisons in the instructions trial
    let empty_trial = {
        type: jsPsychHtmlKeyboardResponse,
        stimulus: '',
        choices: ["NO_KEYS"],
        trial_duration: 1, //
        data: {
            task: 'empty_trial'
        }
    };
    timeline.push(empty_trial);
    timeline.push(empty_trial);
    timeline.push(empty_trial);
    timeline.push(empty_trial);
    timeline.push(empty_trial);
    timeline.push(empty_trial);
    timeline.push(empty_trial);
    timeline.push(empty_trial);

    //fixation cross
    let first_fixation = {
        type: jsPsychHtmlKeyboardResponse,
        stimulus: '<div class="rlwm-fixation">+</div>',
        choices: "NO_KEYS",
        trial_duration: FIXATION_DURATION,
        data: {
            task: 'fixation'
        }
    };

    let second_fixation = first_fixation;

    //instructions before first practice trials
    const instructions_01 = {
        type: jsPsychInstructions,
        pages: [
            `<div class="rlwm-textDiv" style="width: 100%"><p>Welcome to the <b>Picture-Memory Task!</b></p></div>`,
            `<div class="rlwm-textDiv" style="width: 55%"><p>In this task, you will see various images. Your task is simply to learn which button is correct to press for each image.</p></div>`,
            `<div class="rlwm-textDiv" style="width: 85%"><p>You will have three possible response options: <b>Q</b>, <b>W</b>, or <b>E</b>. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 100%"><p>You will have a maximum of <b>2 seconds</b> to respond when you see an image. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 80%"><p>If you do not respond within two seconds, it will count as an incorrect response. </p></div>`,
            `<div class="rlwm-textDiv"><p>The images belong to different categories &mdash; furniture, buildings, fruits, etc. &mdash; and you will see images from one category at a time. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 55%"><p>When there is a new category, you will first see all images of that category presented simultaneously for 10 seconds, so you know which images you will be learning about. </p></div>`,
            `<div class="rlwm-textDiv"><p>The images will then be presented one by one repeatedly, allowing you to learn which response button (<b>Q</b>, <b>W</b>, or <b>E</b>) is correct for each image. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 100%"><p>The correct button for each image will <b><u>not</u></b> change!</p></div>`,
            `<div class="rlwm-textDiv" style="width: 100%"><p>Now, let's try the task out with the furniture category! </p></div>`
        ],
        data: {
            task: `experiment_instructions`,
        },
        show_clickable_nav: true
    }

    //initial trial with the complete stimulus set for current block
    let instructions_initial_trial = {
        type: jsPsychHtmlKeyboardResponse,
        stimulus: function () {

            return `<div class="rlwm-row">
                    <img class="rlwm-img1 rlwm-img-border" src="${instructImg2}" >
                    <img class="rlwm-img1 rlwm-img-border" src="${instructImg3}" >
                    <img class="rlwm-img1 rlwm-img-no-border" src="${backgroundImage}" >
                    </div>
                    <div class="rlwm-row">
                    <img class="rlwm-img1 rlwm-img-no-border" src="${backgroundImage}" >
                    <img class="rlwm-img1 rlwm-img-no-border" src="${backgroundImage}" >
                    <img class="rlwm-img1 rlwm-img-no-border" src="${backgroundImage}" >
                    </div>`
        },
        choices: ["NO_KEYS"],
        trial_duration: INITIAL_IMAGE_TRIAL_DURATION, //* 10000,
        data: {
            task: 'initial_image_instructions'
        }
    }

    var instructions_images = [
        { img: instructImg2, correct_response: 'w', stimulus_type: 'instructions', block: '0', stim_id: 'I1' },
        { img: instructImg3, correct_response: 'e', stimulus_type: 'instructions', block: '0', stim_id: 'I2' }
    ];

    //define feedback function
    function feedbackFunction() {
        var tmp1 = jsPsych.data.get().last(1).values()[0].correct;
        var tmp2 = jsPsych.data.get().last(1).values()[0].response

        if (tmp1 == true) {
            consecutive_missed_trials = 0;
            //console.log('consecutive_missed_trials is: ', consecutive_missed_trials);
            return correct_html
        } else if (tmp2 == null) { // add +1 points for wins?
            consecutive_missed_trials++;
            //console.log('consecutive_missed_trials is: ', consecutive_missed_trials);
            return tooslow_html
        } else {
            consecutive_missed_trials = 0;
            //console.log('consecutive_missed_trials is: ', consecutive_missed_trials);
            return incorrect_html
        }
    };

    //Load stimuli (images)
    if (day == 1) {
        stimuli_block1 = test_stimuli.slice(0, 6);
        stimuli_block2 = test_stimuli.slice(6, 12);
        stimuli_block3 = test_stimuli.slice(12, 18);
        stimuli_block4 = test_stimuli.slice(18, 24);
        stimuli_block5 = test_stimuli.slice(24, 30);
        stimuli_block6 = test_stimuli.slice(30, 36);
        stimuli_block7 = test_stimuli.slice(36, 42);
        stimuli_block8 = test_stimuli.slice(42, 48);
        stimuli_block9 = test_stimuli.slice(48, 54);
        stimuli_block10 = test_stimuli.slice(54, 60);

    } else if (day == 2) {
        stimuli_block1 = test_stimuli_day2.slice(0, 6);
        stimuli_block2 = test_stimuli_day2.slice(6, 12);
        stimuli_block3 = test_stimuli_day2.slice(12, 18);
        stimuli_block4 = test_stimuli_day2.slice(18, 24);
        stimuli_block5 = test_stimuli_day2.slice(24, 30);
        stimuli_block6 = test_stimuli_day2.slice(30, 36);
        stimuli_block7 = test_stimuli_day2.slice(36, 42);
        stimuli_block8 = test_stimuli_day2.slice(42, 48);
        stimuli_block9 = test_stimuli_day2.slice(48, 54);
        stimuli_block10 = test_stimuli_day2.slice(54, 60);
    }

    // Put the stimuli blocks in an array
    let stimulusArray = [
        stimuli_block1, stimuli_block2, stimuli_block3, stimuli_block4, stimuli_block5,
        stimuli_block6, stimuli_block7, stimuli_block8, stimuli_block9, stimuli_block10
    ];

    // Create random indices to sample from the stimulus array
    let shuffleIdx = jsPsych.randomization.repeat([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 1);

    // Initialize an array to store chosen stimuli
    let all_stimuli = [];

    //Assign the correct keys to the chosen stimuli
    function assignKeys(stimChosen, x, current_index) { //x is the current set size
        for (let j = 0; j < stimChosen.length; j++) {// stimChosen.length = length of the current set size
            //const keyPairs = key_pairs[x];
            let second_block_index = N_SETSIZES / NUMBER_OF_BLOCKS - 1;
            let block_num = 0;

            if (current_index > second_block_index) { // 5 > 4 
                //x = x - second_block_index;
                block_num = 1;
            }

            //console.log("stimChosen[j]", stimChosen[j], "keypairs j", x,block_num);
            //console.log("x", x, "block_num", block_num, "j", j);
            //console.log("stimChosen[j]", stimChosen[j], 'keyPairs[x][block_num]: ', keyPairs[x][block_num][j]);
            stimChosen[j].correct_response = keyPairs[x][block_num][j];
        }
        return stimChosen;
    }

    // Loop through the setsize order and assign keys to the chosen stimuli
    for (let i = 0; i < setsize_order.length; i++) {
        let chosenStimuli = jsPsych.randomization.sampleWithoutReplacement(stimulusArray[shuffleIdx[i]], setsize_order[i]);
        chosenStimuli = assignKeys(chosenStimuli, setsize_order[i], i);
        all_stimuli.push({ stimuli: chosenStimuli });
    }


    //extract only the img properties from all_stimuli
    for (let i = 0; i < all_stimuli.length; i++) {
        for (let j = 0; j < all_stimuli[i].stimuli.length; j++) {
            imgs[i].img.push(all_stimuli[i].stimuli[j].img);

        }
    }

    //for set sizes with less than 6 stimuli, add a silver image to the (6 - nr stim) images. For "initial trial"
    for (let i = 0; i < imgs.length; i++) {
        const l = imgs[i].img.length;
        for (let j = 0; j < 6 - l; j++) {
            imgs[i].img.push(backgroundImage)

        }
    }

    //console.log('all_stimuli: ', all_stimuli);

    //define instruction trials
    let instructions_trial = {
        timeline: [
            { //test stimulus (with response)
                type: jsPsychHtmlKeyboardResponse,
                stimulus: function () {
                    var html = `
                        <img class="rlwm-img-border" src="${jsPsych.timelineVariable('img')}">`
                    return html;
                },
                choices: RESPONSE_BUTTONS,
                trial_duration: STIMULUS_TRIAL_DURATION,
                data: {
                    task: 'instructions_trial',
                    correct_response: jsPsych.timelineVariable('correct_response'),
                    stimulus_type: jsPsych.timelineVariable('stimulus_type'),
                    setsize: '2',
                    block: jsPsych.timelineVariable('block'),
                    stim_id: jsPsych.timelineVariable('stim_id'),
                },
                on_finish: function (data) {
                    data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response);
                    let trial_data = jsPsych.data.get().last(1).values()[0];
                    let trial_data2 = jsPsych.data.get().last(10).values(); //will not work if there aren't enough trials in data structure before this

                    if ((trial_data2[9].correct && trial_data2[6].correct && trial_data2[3].correct && trial_data2[0].correct) == true) {
                        instructions_correct = 1;
                    } else {
                        instructions_correct = 0;
                    }
                    //console.log('instructions_correct: ', instructions_correct);
                    data.instructions_correct = instructions_correct;
                }
            },
            { //feedback
                type: jsPsychHtmlKeyboardResponse,
                stimulus: feedbackFunction,
                trial_duration: FEEDBACK_DURATION,
                data: {
                    task: 'experiment_feedback'
                },
                choices: ["NO_KEYS"]
            },
            { //dynamic fixation cross - to keep stimulus presentation and feedback fixed but have feedback immediately after pressing
                type: jsPsychHtmlKeyboardResponse,
                stimulus: '<div class="rlwm-fixation">+</div>',
                choices: "NO_KEYS",
                trial_duration: function () {
                    let trial_data = jsPsych.data.get().last(3).values()[1];
                    //console.log('TRIAL DATA: ', trial_data)
                    //console.log('RT: ', trial_data.rt);
                    if (trial_data.rt == null) {
                        fixation_duration = FIXATION_DURATION; //here fixation will be 0.5 s
                    } else {
                        fixation_duration = STIMULUS_TRIAL_DURATION - trial_data.rt + FIXATION_DURATION; //faster response leads to longer fixation, keeping trial length equal
                    }
                    //console.log('fixation time in ms: ', fixation_duration);
                    return fixation_duration;
                },
                data: {
                    task: 'dynamic_fixation'
                }
            }
        ],
        timeline_variables: instructions_images, //loops over the different stimulus categories 
        randomize_order: true,
        repetitions: INSTRUCTIONS_TRIAL_REPETITIONS
    };

    const instructions_if_trial = {
        type: jsPsychInstructions,
        pages: [
            `<div class="rlwm-textDiv" style="width: 100%"><p>It looks like you could use some extra practice. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 70%"><p>Your task is to learn which button is correct to press for each image. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 55%"><p>You will start by seeing all images presented simultaneously for 10 seconds. Then, you will see one image at a time. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 65%"><p>You will have a maximum of <b>2 seconds</b> to respond when you see an image. Press either <b>Q</b>, <b>W</b>, or <b>E</b>. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 100%"><p>Let's try the task again! </p></div>`
        ],
        data: {
            task: `experiment_instructions`,
        },
        show_clickable_nav: true
    }

    //if node that's run if they fail practice trials
    var instructions_if_node = {
        timeline: [instructions_if_trial, first_fixation, instructions_initial_trial, first_fixation, instructions_trial],
        conditional_function: function (data) {
            let trial_data = jsPsych.data.get().last(3).values()[0];
            //console.log('trial_data in instructions_if_node: ', trial_data);
            if (trial_data.instructions_correct == 0) { //if they did not get the last 4 images correct
                return true; // return the if trial
            } else {
                return false;
            }

        }
    };

    //instructions after practice trials
    instr_html = `<div class="rlwm-textDiv" style="width: 66%"><p>As you probably noticed, you will receive feedback after each image. The 3 possible types of feedback are: </p></div>
    <div style="display: flex;">
        <div style="width: 100%;">${correct_html}</div>
        <div style="width: 100%;">${incorrect_html}</div>
        <div style="width: 100%;">${tooslow_html}</div>
    </div>
    `;

    const instructions_02 = {
        type: jsPsychInstructions,
        pages: [
            `<div class="rlwm-textDiv"><p>This test run was slightly shorter than the real task, so you will have more chances to learn the correct response for each image. However, there can be up to 6 images that you will need to remember, making it harder to remember the correct response. </p></div>`,
            instr_html,
            `<div class="rlwm-textDiv" style="width: 65%"><p>There is <b>only one</b> correct response for each image. The correct response will never change, and the feedback you receive is always truthful. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 58%"><p>One response may be correct for multiple images, or it may not be correct for any image. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 70%"><p>You will learn about a total of ${N_SETSIZES} image categories. The number of images in each category will vary between 2 and 6. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 64%"><p>The duration of the game is fixed, meaning that pressing a key faster will not make the game end sooner. Still, please respond to every image as quickly and accurately as possible. At the end of the task, the total number of correct responses you've<br>made will be converted into a <b>performance bonus. </p></div>`

        ],
        data: {
            task: `experiment_instructions`,
        },
        show_clickable_nav: true
    }

    //all instructions combined
    var INSTRUCTIONS_RLWM = {
        timeline: [
            instructions_01, first_fixation, instructions_initial_trial, first_fixation, instructions_trial, instructions_if_node, instructions_02
        ]
    }

    /*     // Initial Practice Trial (instructions_initial_trial)
        function createInitialTrial(trialFeedback) {
            return {
                timeline: [
                    {
                        type: jsPsychHtmlKeyboardResponse,
                        stimulus: function () {
                            let imgSrc = jsPsych.timelineVariable('img');
                            return `<img class="rlwm-img-border" src="${imgSrc}">`;
                        },
                        choices: RESPONSE_BUTTONS,
                        trial_duration: STIMULUS_TRIAL_DURATION,
                        data: {
                            task: 'instructions_initial_trial',
                            correct_response: jsPsych.timelineVariable('correct_response'),
                            stimulus_type: jsPsych.timelineVariable('stimulus_type'),
                            setsize: jsPsych.timelineVariable('setsize'),
                            block: jsPsych.timelineVariable('block'),
                            stim_id: jsPsych.timelineVariable('stim_id')
                        },
                        on_finish: function (data) {
                            data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response);
                        }
                    },
                    { // Feedback display
                        type: jsPsychHtmlKeyboardResponse,
                        stimulus: function () {
                            const lastTrialData = jsPsych.data.get().last(1).values()[0];
                            if (lastTrialData.correct) {
                                return trialFeedback.correct;
                            } else if (lastTrialData.response === null) {
                                return trialFeedback.tooSlow;
                            } else {
                                return trialFeedback.incorrect;
                            }
                        },
                        trial_duration: FEEDBACK_DURATION,
                        choices: "NO_KEYS",
                        data: { task: 'feedback' }
                    },
                    { // Dynamic fixation cross for consistent trial timing
                        type: jsPsychHtmlKeyboardResponse,
                        stimulus: '<div class="rlwm-fixation">+</div>',
                        choices: "NO_KEYS",
                        trial_duration: FIXATION_DURATION,
                        data: { task: 'fixation' }
                    }
                ],
                timeline_variables: timeline_variables.slice(0, 5), // Only use a few stimuli for the initial trial
                randomize_order: true
            };
        } */

    // Create the comprehension check
    function createComprehensionCheck() {
        return {
            type: jsPsychSurveyMultiChoice,
            preamble: '<h1>Comprehension Check</h1><p>Please answer the following questions to proceed:</p>',
            button_label: 'Submit',
            questions: [
                {
                    prompt: "<i>True</i> or <i>False</i>: The possible response buttons are <b>Q</b>, <b>W</b>, and <b>E</b>.", //T
                    name: 'response_keys',
                    options: ['True', 'False'],
                    required: true
                },
                {
                    prompt: "<i>True</i> or <i>False</i>: The correct response for a specific image will sometimes change.", //F
                    name: 'response_change',
                    options: ['True', 'False'],
                    required: true
                },
                {
                    prompt: "<i>True</i> or <i>False</i>: Some images within a category may have the same correct response key (for example two images can have the key 'Q').", //F
                    name: 'shared_responses',
                    options: ['True', 'False'],
                    required: true
                },
                /*                 {
                                    prompt: "<i>True</i> or <i>False</i>: A specific response button may not be correct for any of the images within a category.", //T
                                    name: 'response_time_limit',
                                    options: ['True', 'False'],
                                    required: true
                                }, */
                {
                    prompt: "<i>True</i> or <i>False</i>: The more correct responses you make, the higher performance bonus you earn.", //T
                    name: 'performance_bonus',
                    options: ['True', 'False'],
                    required: true
                }
            ],
            on_finish: function (data) {
                const responses = data.response;
                const correctAnswers = {
                    response_keys: 'True',
                    response_change: 'False',
                    shared_responses: 'True',
                    //response_time_limit: 'True',
                    performance_bonus: 'True'
                };
                let allCorrect = Object.keys(correctAnswers).every(question => responses[question] === correctAnswers[question]);
                data.comprehension_correct = allCorrect;
                //console.log('all correct:', allCorrect);
            }
        };
    }

    /*     function checkComprehension() {
            const lastResponse = jsPsych.data.get().last(1).values()[0];
            console.log('Comprehension check response:', lastResponse, 'comprehension correct:', lastResponse.comprehension_correct);
            return !lastResponse.comprehension_correct;
        } */

    const comprehensionCheck = createComprehensionCheck();

    //recap if they fail comprehension check
    var instructions_recap = {
        type: jsPsychInstructions,
        pages: [
            `<div class="rlwm-textDiv" style="width: 55%"><p>You did not answer all of the questions correctly. Please review the following instructions carefully. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 55%"><p>Your task is to learn which button to press for each image. You have three possible response options: <b>Q</b>, <b>W</b>, or <b>E</b>.</p></div>`,
            `<div class="rlwm-textDiv" style="width: 70%"><p>For any image, the correct response will <b><u>not</u></b> change during the game. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 70%"><p>You will learn about a total of 10 image categories. The number of images in each category will vary between 2 and 6.</p></div>`,
            `<div class="rlwm-textDiv" style="width: 55%"><p>For example, if there are 6 images within a category, <b>Q</b> could be the correct response for five or none of those images.</p></div>`,
            `<div class="rlwm-textDiv" style="width: 65%"><p>In other words, some or all images within a category can have the same correct response.</p></div>`,
            `<div class="rlwm-textDiv" style="width: 65%"><p>Likewise, a response may not be correct for any image within a category.</p></div>`
        ],
        data: {
            task: `experiment_instructions_recap`,
        },
        show_clickable_nav: true
    };

    //after they pass comprehension check
    const instructions_03 = {
        type: jsPsychInstructions,
        pages: [
            `<div class="rlwm-textDiv" style="width: 60%"><p>Well done! From now on you can't go back to the instructions. The game will take about <b>20</b> minutes to complete. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 65%"><p>If you leave during the task, you will miss too many images, and the entire experiment will end. Furthermore, we will check if you are paying attention at specific times during the experiment by having you press a specific button. If you miss too many images or fail too many attention checks, we will not compensate you for participating. </p></div>`,
            `<div class="rlwm-textDiv" style="width: 60%"><p>You cannot stop the task after pressing 'Next'. Press 'Next' to show the first attention check, followed by the rest of the task. </p></div>`
        ],
        data: {
            task: `experiment_instructions`,
        },
        show_clickable_nav: true,
        on_finish: function (data) {
            jsPsych.data.addProperties({ comprehend_loop_count: comprehend_loop_count });//add to data structure
            consecutive_missed_trials = 0; //reset before experiment begins
        }
    }

    // Return to instructions recap and comprehension check if incorrect
    var comprehend_if_node = {
        timeline: [instructions_recap, createComprehensionCheck()],
        conditional_function: function () {
            const lastResponse = jsPsych.data.get().last(1).values()[0];
            if (!lastResponse.comprehension_correct) {
                return true; // Repeat the comprehension loop if they failed
            }
            return false; // Exit loop if they passed
        }
    };

    // Loop recap and comprehension check if incorrect
    var comprehend_loop_node = {
        timeline: [comprehend_if_node],
        loop_function: function () {
            const lastResponse = jsPsych.data.get().last(1).values()[0];
            if (!lastResponse.comprehension_correct) {
                return true; // Repeat the comprehension loop if they failed
            }
            return false; // Exit loop if they passed
        }
    };



    // Preload images
    const preload = {
        type: jsPsychPreload,
        images: test_stimuli.map(stim => stim.img),
        data: {
            task: 'preload_rlwm',
            parsing: 'start_rlwm'
        },
        continue_after_error: true,
        show_progress_bar: true,
        on_finish: function () {
            setStyles();
        }
    };

    // Timeline pushing
    timeline.push(preload);
    timeline.push(INSTRUCTIONS_RLWM);
    timeline.push(comprehensionCheck);
    timeline.push(comprehend_loop_node);
    timeline.push(instructions_03);




    // Trial structure incorporated with attention checks, experimental trials, and breaks
    for (let i = 0; i < all_stimuli.length; i++) {

        // Check if current index is an attention check trial
        if ([atten_check_trial_idx[0], atten_check_trial_idx[1], atten_check_trial_idx[2], atten_check_trial_idx[3]].includes(i)) {
            // Attention check trial
            let catch_trial = {
                timeline: [
                    {
                        type: jsPsychHtmlKeyboardResponse,
                        stimulus:
                            `<div>This is an attention check, please respond by pressing the <b>${CB}</b> button within 10 seconds</div>` +
                            '<div style="background-color: #ccc; margin-top: 1em;">' +
                            '<div style="width: 0%; height: 20px; background-color: #333; animation-name: progress-bar; animation-duration: 10s; animation-timing-function: linear;">' +
                            '</div>' +
                            '<style> @keyframes progress-bar { 0% { width:0%;} 100% { width:100%} } </style>',
                        choices: [`${CB}`],
                        trial_duration: CATCH_TRIAL_DURATION,
                        data: {
                            task: `catch_trial`,
                            correct_response: `${CB}`
                        },
                        on_finish: function (data) {
                            data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response);

                            if (data.correct !== true) {
                                nrMissedAttenChecks++;
                            }
                        }
                    },
                    { // Feedback for catch trial
                        type: jsPsychHtmlKeyboardResponse,
                        stimulus: function () {
                            var tmp1 = jsPsych.data.get().last(1).values()[0].correct;
                            return tmp1 == true ? correct_html : '<p style="color: #a10000; font-size: 3.5vw;">You failed the attention check!</p>';
                        },
                        trial_duration: CATCH_TRIAL_FEEDBACK_DURATION,
                        data: {
                            task: 'catch_feedback'
                        },
                        choices: ["NO_KEYS"]
                    },
                    { // Redirect if too many checks have been failed
                        type: jsPsychHtmlKeyboardResponse,
                        stimulus: function () {
                            if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
                                return `<div>
                                <p>You have failed to respond in time for ${MAX_MISSED_ATTEN_CHECKS} attention checks. As you have not been paying attention, we will not be able to use your data.</p>
                                <p><b><u>The experiment will now be terminated.</u></b></p>
                                <p>When you press the space bar, you will be redirected back to Prolific.</p>
                            </div>`;
                            } else {
                                return '<div class="rlwm-fixation">+</div>';
                            }
                        },
                        trial_duration: function () {
                            return nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS ? 300000 : 1;
                        },
                        data: {
                            task: 'post_catch_feedback_screen'
                        },
                        on_finish: function () {
                            if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
                                return window.location = FAURL;
                            }
                        },
                        choices: " "
                    }
                ]
            };
            timeline.push(catch_trial);
        } //else {
        // Add break after certain trials
        //console.log('i', i);
        if (i == 4) {

            let break_trial = {
                type: jsPsychHtmlKeyboardResponse,
                stimulus: `<div class="rlwm-textDiv" style="width: 55%"><p>You may now take a break. After <b>1 minute</b>, the task will automatically continue. Press the space bar if you wish to end the break and continue the task.</p></div>`,
                choices: " ",
                trial_duration: BREAK_DURATION,
                data: {
                    task: 'break_trial'
                }
            };
            timeline.push(break_trial);
        }

        // First fixation before the initial trial
        timeline.push(first_fixation);

        // Initial trial with the complete stimulus set for the current block
        let initial_trial = {
            type: jsPsychHtmlKeyboardResponse,
            stimulus: function () {
                return `<div class="rlwm-row">
                        <img class="rlwm-img1" src="${imgs[i].img[0]}" >
                        <img class="rlwm-img1" src="${imgs[i].img[1]}" >
                        <img class="rlwm-img1" src="${imgs[i].img[2]}" >
                        </div>
                        <div class="rlwm-row">
                        <img class="rlwm-img1" src="${imgs[i].img[3]}" >
                        <img class="rlwm-img1" src="${imgs[i].img[4]}" >
                        <img class="rlwm-img1" src="${imgs[i].img[5]}" >
                        </div>`
            },
            choices: ["NO_KEYS"],
            trial_duration: INITIAL_IMAGE_TRIAL_DURATION,
            data: { task: 'initial_image' }
        };
        timeline.push(initial_trial);

        // Second fixation
        timeline.push(second_fixation);
        let experimental_trial = {
            timeline: [
                { //test stimulus (with response)
                    type: jsPsychHtmlKeyboardResponse,
                    stimulus: function () {
                        var html = `
                    <img class="rlwm-img-border" src="${jsPsych.timelineVariable('img')}">`
                        return html;
                    },
                    choices: RESPONSE_BUTTONS,
                    trial_duration: STIMULUS_TRIAL_DURATION,
                    data: {
                        task: 'stimulus_presentation',
                        correct_response: jsPsych.timelineVariable('correct_response'),
                        stimulus_type: jsPsych.timelineVariable('stimulus_type'),
                        setsize: setsize[i],
                        block: jsPsych.timelineVariable('block'),
                        stim_id: jsPsych.timelineVariable('stim_id')
                    },
                    on_finish: function (data) {
                        data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response);
                        let trial_data = jsPsych.data.get().last(1).values()[0];
                        let res = trial_data.response;

                        let trial_rt = trial_data.rt;
                        //console.log('rt: ', trial_rt);
                        //console.log('choice: ', res);
                        if (data.correct == true) {
                            //console.log('correct choice!')
                        } else {
                            //console.log('incorrect choice!')
                        }
                        let trial_index = jsPsych.data.get().filter({ task: 'stimulus_presentation' }).count();

                        if (data.rt == null) {
                            nrMissedTrials++;
                        }
                        //console.log(' Number of missed trials: ', nrMissedTrials);

                        this_trial = {
                            rt: data.rt,
                            correct_key: data.correct_response,
                            chosen_key: data.response,
                            correct: data.correct,
                            trial_index: trial_index,
                            setsize: data.setsize,
                            block: data.block,
                            stimulus_category: data.stimulus_type,
                            time_elapsed: data.time_elapsed,
                            nrMissedTrials: nrMissedTrials
                        };//save block trial index (1,2,3,4,.. within block 1 then 1,2,3,... block 2, etc.)?
                        TRIALS.push(this_trial);
                        //console.log('TRIALS: ', TRIALS);
                        //console.log(data.subjID)

                    }
                },
                { //feedback
                    type: jsPsychHtmlKeyboardResponse,
                    stimulus: feedbackFunction,
                    trial_duration: FEEDBACK_DURATION,
                    data: {
                        task: 'experiment_feedback'
                    },
                    choices: ["NO_KEYS"]
                },
                { //Redirect if too many checks have been failed
                    type: jsPsychHtmlKeyboardResponse,
                    stimulus: function () {
                        if (nrMissedTrials >= MAX_MISSED_TRIALS) {
                            return `<div>
                        <p> You have failed to respond in time to ${MAX_MISSED_TRIALS} or more images. As such we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
                            If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
                            <p> When you press the space bar, you will be redirected back to Prolific.</p>
                    </div>`
                        } else if (consecutive_missed_trials > MAX_CONSECUTIVE_MISSED_TRIALS) {
                            return `<div>
                        <p> You have failed to respond in time to more than ${MAX_CONSECUTIVE_MISSED_TRIALS} images in a row. As such we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
                            If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
                            <p> When you press the space bar, you will be redirected back to Prolific.</p>
                    </div>`
                        } else {
                            return '<div class="rlwm-fixation">+</div>'
                        }
                    },
                    trial_duration: function () {
                        if (nrMissedTrials >= MAX_MISSED_TRIALS | consecutive_missed_trials > MAX_CONSECUTIVE_MISSED_TRIALS) {
                            return 300000
                        } else {
                            return 1
                        }
                    },
                    data: {
                        task: 'missed_trial_screen'
                    },
                    on_finish: function () {
                        if (nrMissedTrials >= MAX_MISSED_TRIALS | consecutive_missed_trials > MAX_CONSECUTIVE_MISSED_TRIALS) {
                            return window.location = MTURL;
                        }
                    },
                    choices: " "
                },
                { //dynamic fixation cross - to keep stimulus presentation and feedback fixed but have feedback immediately after pressing
                    type: jsPsychHtmlKeyboardResponse,
                    stimulus: '<div class="rlwm-fixation">+</div>',
                    choices: "NO_KEYS",
                    trial_duration: function () {
                        let trial_data = jsPsych.data.get().last(3).values()[0];
                        //console.log('TRIAL DATA: ', trial_data)
                        //console.log('RT: ', trial_data.rt);
                        if (trial_data.rt == null) {
                            fixation_duration = FIXATION_DURATION; //here fixation will be 0.5 s
                        } else {
                            fixation_duration = STIMULUS_TRIAL_DURATION - trial_data.rt + FIXATION_DURATION; //faster response leads to longer fixation, keeping trial length equal
                        }
                        //console.log('fixation time in ms: ', fixation_duration);
                        return fixation_duration;
                    },
                    data: {
                        task: 'dynamic_fixation'
                    }
                }
            ],
            timeline_variables: all_stimuli[i].stimuli, //loops over the different stimulus categories 
            randomize_order: true,
            repetitions: REPETITIONS_PER_STIMULUS //12 presentations per stimulus (2017) - although should be same trials per set size?
        };

        timeline.push(experimental_trial);
        //}
    }

    // Define payment.
    const completion_bonus = 0.00;
    var performance_bonus = bonus_per_task;
    // Define feedback screen - to see bonus earned
    var FEEDBACK = {
        stimulus: '',
        type: jsPsychHtmlKeyboardResponse,
        on_start: function (trial, data) {

            // Compute overall accuracy.
            var accuracy = jsPsych.data.get().filter({ task: 'stimulus_presentation' }).select('correct');
            var accuracy = accuracy.mean();
            //console.log('proportion correct: ', accuracy);

            // Compute payment.
            var bonus = completion_bonus + Math.ceil(performance_bonus * accuracy * 100) / 100;
            var total = completion_bonus + performance_bonus;

            //add to global
            bonus_rlwm += bonus;

            //Update global variables to be passed on to next task
            taskNumber++
            performanceBonus += bonus;

            // Report accuracy to subject.
            trial.stimulus = `<h2>Great job!</h2>You earned a performance bonus of ${bonus}&pound out of ${total}&pound in this game.
                <br>You have earned a total performance bonus of ${performanceBonus}&pound.
                <br><br>Press the <b>space bar</b> to continue.`

            /* trial.stimulus = `You earned a bonus of ${bonus}&pound out of ${total}&pound.<br><br>Press the space bar to continue.` */

            //save bonus to data
            jsPsych.data.addProperties({
                bonus_rlwm: bonus_rlwm
            });
            //console.log('bonus reinforce: ', jsPsych.data.dataProperties.reinforce);

        },
        on_finish: function (trial) {

            // Compute overall accuracy.
            var accuracy = jsPsych.data.get().filter([{ block: 1 }, { block: 2 }]).select('accuracy');
            var accuracy = accuracy.mean();
            trial.accuracy = accuracy;

            // Compute payment.
            var bonus = completion_bonus + Math.ceil(performance_bonus * accuracy * 100) / 100;
            var total = completion_bonus + performance_bonus;
            trial.bonus = bonus;

        },
        choices: " "
    }
    timeline.push(FEEDBACK);

    // Debriefing questionnaire
    var DEBRIEF_01 = {
        type: jsPsychSurveyMultiChoice,
        preamble: '<h1>Debriefing</h1><p>Please answer the questions below.</p><p><font color="#c87606">Your answers do not affect your payment or bonus.</font></p>',
        button_label: 'Submit',
        questions: [
            {
                prompt: "How difficult was the task?",
                name: 'difficultyRate',
                options: ['Very easy', 'Somewhat easy', 'Neither easy nor hard', 'Somewhat hard', 'Very hard'],
                required: true
            },
            {
                prompt: "How fun was the task?",
                name: 'funRate',
                options: ['Very fun', 'Somewhat fun', 'Neither fun nor boring', 'Somewhat boring', 'Very boring'],
                required: true
            },
            {
                prompt: "How clear were the instructions?",
                name: 'clarityRate',
                options: ['Very clear', 'Somewhat clear', 'Neither clear nor confusing', 'Somewhat confusing', 'Very confusing'],
                required: true
            }
        ],
        on_finish: function () {
            removeStyles();
        },
        data: {
            parsing: 'end_rlwm',
            task: 'debrief_rlwm'
        }
    }
    timeline.push(DEBRIEF_01);

    removeStyles();
    return timeline;
}
