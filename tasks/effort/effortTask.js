function effortTask(day) {

    // Set the body properties
    // Get the body element
    //console.log('start of the effortask.js');

    var styleElement;

    function setStyles() {
        setTimeout(() => {
            // Create a new <style> element
            styleElement = document.createElement('style');

            // Set the content of the <style> element to your styles
            let styles = effort_styles;
            styleElement.innerHTML = styles;

            // Append the <style> element to the document's <head>
            document.head.appendChild(styleElement);
        }, 1);
    }

    function removeStyles() {

        const body = document.querySelector('body');

        body.style.removeProperty('background-color');
        body.style.removeProperty('background-repeat');
        body.style.removeProperty('background-size');
        body.style.removeProperty('overflow');
        body.style.removeProperty('font-family');
        body.style.removeProperty('background-image');

        styleElement.parentNode.removeChild(styleElement);
    }

    // atentional checks
    var nrMissedAttenChecks = 0;
    //var MAX_MISSED_ATTEN_CHECKS = 2;

    // general global vars here
    var TOTAL_CREDITS = 0; // total credits earned at the end of the experiment
    var MENTAL_CREDITS = 0; // credits earned during the mental effort type of task
    var PHYSICAL_CREDITS = 0; // // credits earned during the physical effort type of task
    var CREDITS_HISTORY = []; // history of gained credits throughout the experiment
    var ITER = 15; // frequency of updating the progress bar aka smoothness (in ms) 
    var TASK_TYPE = []; // history of choices (either rest -1- or effort -2-)
    var START_TIME; // start time since the first introduction screen
    var END_TIME; // time point when the experiment is over
    var TOTAL_DURATION; // END_TIME - START_TIME;
    var CONDITION_INIT; // takes 1 (physical effort) or 2 (mental effort) 
    var FULLSCREEN_EXIT = 0; // record how many times a participant left the full screen mode during the experiment
    var CURRENTLY_IN_FULLSCREEN = false; // is the participant currently in fullscreen or not (true / false)

    // Keys & buttons:
    var CONTINUE_BUTTON = 'C'; // to continue to the next screen during the instructions
    var LEFT_BUTTON = 'ArrowLeft'; // key for the left option
    var RIGHT_BUTTON = 'ArrowRight'; // key for the right option
    var EFFORT_KEY; // is used to record which button in each trial corresponds to the effort option
    var NO_EFFORT_KEY; // is used to record which button in each trial corresponds to the no-effort option
    var PHYS_HIT = ' '; // go button for run
    var BUTTON_SHADOW = "0.5em 0.5em 1.5em #2c2c2c;" // shadow of buttons
    var BUTTON_ORDER; // determines the order of buttons (takes 0 or 1), defined in function stim()

    // effort lvl titration
    var NPRESSES_HISTORY = []; // history of the number of presses during the titration trials
    var NPRESSES_EXCLUDED = 0; // The smallest press during the titration that is excluded 
    var NPRESSES_HISTORY_DISCARDED = []; // history of the history - if someone fails and re-do the instructions
    var TITRATION_RATES = []; // normalized presses per WAITING_TIME during titration
    var TITRATION_IN_PROGRESS = false;
    //var TITRATION_PERC = /*[0.2, 0.35, 0.5, 0.65, 0.8];*/[0.35, 0.5, 0.65, 0.8, 0.95];
    var TITRATION_PERC = /*[0.30, 0.45, 0.60, 0.75, 0.90]*/[0.60, 0.70, 0.80, 0.90, 1.00];
    var TRL_DEFAULT_TITR_PRESSES = 18;
    var TRL_TITR_INCREASE = 3;
    var TITRATION_REPS_NUM = 8;
    var INDIVIDUAL_MAX = 0; // mean of all presses during the titration trials except for the first trial
    var TITRATION_STRIKES = 0;
    var TITRATION_REPS = 0;

    // fucking debugging
    var FINISH_LINE = 0;
    var STARTING_LINE = 0;
    var DISTANCE = 0;

    // practice rounds
    var SKIP_TRAINING = false; // if true, the training part will be skipped
    var TRAINING = false; // general dummy variable to indicate whether a given trial is training or not
    var WALKING_TRAINING = true; // dummy used for walking_training 
    var RUNNING_TRAINING = true; // dummy used for running_training 
    var STERNBERG_TRAINING = false; // false before the TRL_NUMBER reaches TRL_SWITCH
    var EFFORT_ROUNDS = 10; // how many effort practice rounds
    var NO_EFFORT_ROUNDS = 2; // how many no-effort practice rounds
    var TRAINING_ROUNDS = EFFORT_ROUNDS + NO_EFFORT_ROUNDS + 4; // how many practice rounds one must complete without losing in order to proceed to the actual experiment
    var TRAINING_COUNTER; // counting the number of a current practice round
    var TRA_EFFORT_MATRIX = [1, 2, 3, 4, 5, 1, 5, 2, 4, 3, 1, 2, 3, 4, 5]; // array of the effort levels during practice trials - goes always in the same order
    var TRAINING_REPEAT = false; // if the participant chooses or fail the effort part of the training, the whole training gets restarted

    // comprehension check
    var FAILED_COMP_CHECK = false; // if the participant fails the comprehensive check, they need to go through the instructions and training again
    var FAILED_PHYS_COMP_COUNTER = 0; // how many times was the comprehension check before the physical effort failed
    var FAILED_MENTAL_COMP_COUNTER = 0; // how many times was the comprehension check before the mental effort failed
    var PHYS_COMP_ANSWERS = []; // record the participant's responses for the pre-physical effort comprehension check
    var MENTAL_COMP_ANSWERS = []; // record the participant's responses for the pre-mental effort comprehension check
    var COMP_IN_PROGRESS = false; // true / false
    var DEBRIEFING_IN_PROGRESS = false;

    // define global variables collected in each trial
    var TRIALS = []; // store {trial_number, chosen_task, effort_type, effort_lvl and other task-related data}
    var TRL_LABEL;
    //var TRL_TOTAL = 100; // how many trials in total
    var TRL_TOTAL = 75; // how many trials in total
    var TRL_NPRESSES = 0; // number of presses in the physical effort trials
    var TRL_REQUIRED_PRESSES = [TRL_DEFAULT_TITR_PRESSES]; // how many presses are required in order to complete the physical effort task

    var TRL_NUMBER = 0; // trial number (i. e., every time one starts doing effort or the rest task)
    var TRL_SUCCESS; // if the participant accomplished the trial he will get credits otherwise no credits gained in that trial
    var TRL_SWITCH = TRL_TOTAL / 2; // after the TRL_SWITCH number of trials elapsed switch to the other type of effort
    var TRL_MATRIX; // matrix with all possible pairs of effort and credits; defined below in the function shuffle_array();
    var TRL_MTRX_SHUFFLED; // shuffled TRL_MATRIX within shuffle_array function

    // waiting and effort variables when generating the offer:
    var WAITING_CREDITS = 1; // fixed - always the same number of credits for waiting
    var CHOICE_RT; // store the RT for each decision during the offer and then pass it to the TRIALS array
    var EFFORT_LVL; // changing dynamically based on the rand number
    var INITIAL_EFFORT_LVL = 1; // which level effort is set in the pre-training effort task
    var EFFORT_CREDITS = 4; // changing dynamically based on the rand number
    var EFFORT_TYPE; // To (pseudo)/randomly alternate between physical and mental effort (physical or mental)
    var PHYS_EFFORT_COEFF = 5; // coefficient to multiply the effort level with
    var RACING = false; // true/false dummy so that the animation knows whether the character stays in the middle of a screen or drifting away with the background
    var BUTTON_PRESSED = false; // during physical effort, did the participant press the 'go' key?
    var RIGHT_ARROW_DOWN = false; // keep track of whether the right arrow key is pressed (it is useful if a participant starts the physical effort with already pressed arrow)
    var SPACEBAR_PRESSED = false;

    // animation vars
    var ANIMATION_SUCCESS = false; // did the character reach the coin in time?
    var STOP_ANIMATION = false; // if true, the background is constantly moving
    var STOP_WALKING = false; // if true, the character stops walking (e. g., when he is slower than the enemy)

    // trial duration

    ////* the following variables should add up to TOTAL_TRIAL_TIME: */
    var WARNING_INTERVAL = 2000; // after the trial onset when to show the  timeout warning (in ms)
    var CHOICE_LATENCY = 250; // time after the option is chosen (note: different from choice_latency that is equal to CHOICE_RT)
    var WAITING_TIME = 6000; // the length of a trial both rest and effort
    var COIN_DURATION = 500; // for how long to display the animation when the goblin loses/wins
    var OUTCOME_DURATION = 1200; // for how long to show feedback

    var TOTAL_TRIAL_TIME = WARNING_INTERVAL + CHOICE_LATENCY + WAITING_TIME + COIN_DURATION + OUTCOME_DURATION // the total trial time in ms (including the choice)

    var TRL_EXTENSION = 0; // for how many ms should be the trial extended 

    // Sternberg task
    //var STERNBERG_ARRAY = ['T', 'E', 'Q', 'X', 'F', 'G', 'A', 'D', 'P', 'S', 'U', 'V', 'Z', 'R', 'O', 'L']; // all letters that can be combined into a STERNBERG_STIM
    var STERNBERG_ARRAY = {
        2: [
            ['B', 'F', 'G', 'L'],
            ['A', 'H', 'I', 'S'],
            ['A', 'C', 'G', 'N'],
            ['C', 'E', 'H', 'J']
        ],
        4: [
            ['C', 'E', 'F', 'J', 'K', 'L', 'M', 'Q'],
            ['A', 'B', 'C', 'E', 'G', 'H', 'I', 'L'],
            ['D', 'E', 'K', 'L', 'O', 'P', 'Q', 'S'],
            ['A', 'C', 'F', 'J', 'K', 'M', 'N', 'S']
        ],
        6: [
            ['A', 'B', 'E', 'F', 'G', 'H', 'J', 'K', 'N', 'T', 'V', 'W'],
            ['A', 'B', 'D', 'F', 'H', 'J', 'K', 'L', 'N', 'O', 'V', 'X'],
            ['D', 'F', 'H', 'J', 'K', 'L', 'N', 'O', 'Q', 'V', 'X', 'Y'],
            ['A', 'C', 'F', 'G', 'H', 'J', 'K', 'O', 'Q', 'R', 'S', 'U']
        ],
        8: [
            ['A', 'B', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'O', 'P', 'S', 'H'],
            ['A', 'C', 'D', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'N', 'O', 'P', 'Q', 'R', 'V'],
            ['A', 'C', 'D', 'E', 'G', 'H', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'V', 'W', 'X'],
            ['A', 'B', 'C', 'E', 'G', 'J', 'K', 'L', 'N', 'O', 'P', 'R', 'U', 'V', 'W', 'X']
        ],
        10: [
            ['A', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'S', 'U', 'Y', 'F', 'J', 'L'],
            ['A', 'B', 'C', 'D', 'E', 'G', 'H', 'I', 'K', 'M', 'N', 'O', 'Q', 'R', 'S', 'T', 'U', 'X', 'G', 'Q'],
            ['A', 'B', 'C', 'D', 'E', 'F', 'H', 'I', 'J', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'Y', 'G', 'L'],
            ['A', 'B', 'C', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'O', 'P', 'S', 'T', 'U', 'X', 'Y', 'J']
        ]
    }


    var STERNBERG_LOAD = [2, 4, 6, 8, 10]; // loads/difficulty (i. e., how many letters in one string is shown to a participant)
    var STERNBERG_STIM = []; // the resultant string shown to a participant to remember (e.g., TEQX)
    var STERNBERG_PROBE; // the probe (a single letter) displayed on the screen before the participant is prompted to answer (e.g., T)
    var STERNBERG_LATENCY = 0.4; // the period for how long the stimulus is shown (in sec)
    var STERNBERG_DECIDED = false // set true when the participant makes a choice in order to stop increasing the progress bar
    var STERNBERG_PROBE_DECIDED = false; // made decision during the probe?
    var STERNBERG_PROBE_LAT = STERNBERG_LATENCY; // the period of how long the probe is shown (in sec)
    var STERNBERG_MATCH; // was the probe part of the STERNBERG_STIM (true/false)
    var STERNBERG_YES = 'ArrowRight'; // button for yes
    var STERNBERG_NO = 'ArrowLeft'; // button for no
    var STERNBERG_MISS = false; // record misses when no response was made
    var STERNBERG_RT; // RT during the mental effort
    var STERNBERG_CROSS_TIME = 0; // the length of the fixation cross after the mental effort accounting for RT

    // timeout vars
    var TIMEOUT_WARNINGS = 0; // record how many times (per trial) a participant was prompted to respond faster
    var TOTAL_TIMEOUT_WARNINGS = 0; // total timeout warnings throughout the experiment
    var TIMEOUT_TRL_THRESHOLD = 10 // after how many timeout warnings (in one trial) will the participant be excluded from the study
    var TIMEOUT_TOTAL_THRESHOLD = TRL_TOTAL * TIMEOUT_TRL_THRESHOLD / 10; // after how many timeouts counted throughout the whole experiment will the participant be excluded        
    var WARNING_DURATION = 900 // duration of the displayed timeout warning (in ms)
    var PARTICIPANT_EXCLUDED = false;


    // initializing jsPsych
    var timeline = [];  // Declare it empty in the beginning

    //Variable to send data to email
    /* var sendData = {
        type: jsPsychHtmlKeyboardResponse,
        stimulus: `
        Submitting data... Please do not refresh!
        `,
        on_finish: function (data) {
            var all_data = jsPsych.data.get();
            var a = all_data.csv();
            var b = a.concat(a);
            var c = a.concat(b);
            var d = a.concat(c);
            var e = a.concat(d);
            var f = a.concat(e);
            console.log(c);
            emailjs.send("service_uyvu7rf", "template_e6uru4p", {
                message: c
            }).then(
                (response) => {
                    console.log('SUCCESS!', response.status, response.text);
                },
                (error) => {
                    console.log('FAILED...', error);
                },);
        },
        data: {
            task: 'email data update'
        },
        trial_duration: 1
    };
 */
    function shuffle_array() {
        TRL_MATRIX = [
            [1, 2], [1, 4], [1, 6], [1, 8], [1, 10],
            [2, 2], [2, 4], [2, 6], [2, 8], [2, 10],
            [3, 2], [3, 4], [3, 6], [3, 8], [3, 10],
            [4, 2], [4, 4], [4, 6], [4, 8], [4, 10],
            [5, 2], [5, 4], [5, 6], [5, 8], [5, 10]
        ];
        array = TRL_MATRIX;

        // Yates-Fischer algorithm
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
        //console.log('reshuffled array: ', array)
        return array;
    }

    function copyToData(data, this_trial) {
        Object.assign(data, this_trial);
    }

    // Function to generate an array of unique random letters
    function generateRandomLetters(load) {
        const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        let randomLetters = [];

        while (randomLetters.length < load * 2) {
            const randomIndex = Math.floor(Math.random() * letters.length);
            const randomLetter = letters[randomIndex];

            if (!randomLetters.includes(randomLetter)) {
                randomLetters.push(randomLetter);
            }
        }

        return randomLetters;
    }

    // Function to create arrays for each load
    function createArraysForLoad(load) {
        const arrays = [];

        for (let i = 0; i < 4; i++) {
            const array = generateRandomLetters(load);
            arrays.push(array);
        }

        return arrays;
    }

    // Create arrays for each load
    const arraysByLoad = {};

    STERNBERG_LOAD.forEach((load) => {
        arraysByLoad[load] = createArraysForLoad(load);
    });

    var goblin_animation;
    function main() {

        // Function for the welcome screen with the goblin
        function goblins_rise() {

            var screen_height = document.body.offsetHeight; // get the screen height
            let top_pos; // position of the goblin
            goblin_animation = setInterval(function () { // animation of goblin rising up

                var goblin = document.querySelector('.effort-intro'); // get the html
                if (goblin) { // if loaded/available
                    top_pos = goblin.offsetTop;
                    if (top_pos > screen_height / 5) { // go until the 20% of the screen height
                        top_pos -= 10; // every iteration move up 10px
                        goblin.style.top = top_pos + 'px';
                    } else {
                        clearInterval(goblin_animation); // when done, clear interval
                    }
                }
            }, 1);
        }

        var shuffled_pairs = shuffle_array();
        function randConditions() {

            if (TRL_NUMBER == 0) {
                let rand_num = Math.floor(Math.random() * 2) + 1;
                CONDITION_INIT = rand_num;

                // set to 1 or 2 for non-random initial condition
                CONDITION_INIT = 1;
            }

            if (SKIP_TRAINING == false) {
                TRAINING = true;
                WALKING_TRAINING = true;
                RUNNING_TRAINING = true;
                TRAINING_COUNTER = 1;
            }

            let body = document.querySelector('body');

            if (CONDITION_INIT == 1 && TRL_NUMBER == 0 || CONDITION_INIT == 2 && TRL_NUMBER == TRL_SWITCH) {
                EFFORT_TYPE = 'physical';
                body.style.backgroundImage = `url(tasks/effort/images/background2.png)`;

            } else if (CONDITION_INIT == 2 && TRL_NUMBER == 0 || CONDITION_INIT == 1 && TRL_NUMBER == TRL_SWITCH) {
                EFFORT_TYPE = 'mental';
                //STERNBERG_TRAINING = true;
                body.style.backgroundImage = `url(tasks/effort/images/potentials/background_twister3.jpg)`; // change the backgroudn for the mental effort
                body.style.backgroundPosition = 'bottom';
            }
        }


        /* fullscreen code start */
        function enterFullscreen() {
            const elem = document.documentElement;
            if (elem.requestFullscreen) {
                elem.requestFullscreen();
            } else if (elem.mozRequestFullScreen) {
                elem.mozRequestFullScreen();
            } else if (elem.webkitRequestFullscreen) {
                elem.webkitRequestFullscreen();
            } else if (elem.msRequestFullscreen) {
                elem.msRequestFullscreen();
            }
        }

        function fullscreenChangeHandler(event) {
            if (!document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement) {
                // Full-screen mode has been exited
                FULLSCREEN_EXIT++;
                CURRENTLY_IN_FULLSCREEN = false;
                createOverlay(); // Show the overlay div
            } else {
                // Full-screen mode has been entere
                CURRENTLY_IN_FULLSCREEN = true;
                removeOverlay(); // Remove the overlay div and warning message
            }
        }

        function createOverlay() {
            const overlay = document.createElement("div");
            overlay.id = "effort-overlay";
            document.body.appendChild(overlay);
            overlay.style.display = "block"; // Show the overlay

            const error_msg = document.createElement("div");
            error_msg.className = 'effort-text-box-error';
            document.body.appendChild(error_msg);

            // Create a <p> element and set its text content
            const errorMessage = document.createElement("p");
            errorMessage.textContent = "It is not allowed to exit full-screen mode! Please press F to return to full-screen mode.";

            // Append the <p> element to the error_msg div
            error_msg.appendChild(errorMessage);

        }

        function removeOverlay() {
            const overlay = document.getElementById("effort-overlay");
            if (overlay) {
                overlay.style.display = "none"; // Hide the overlay
                document.body.removeChild(overlay);
            }

            const error_msg = document.querySelector('.effort-text-box-error');
            if (error_msg) {
                document.body.removeChild(error_msg);
            }
        }
        //enterFullscreen();

        document.addEventListener('fullscreenchange', fullscreenChangeHandler);
        document.addEventListener('mozfullscreenchange', fullscreenChangeHandler);
        document.addEventListener('webkitfullscreenchange', fullscreenChangeHandler);
        document.addEventListener('msfullscreenchange', fullscreenChangeHandler);
        /* fullscreen code end */

        // diaable the right-click context menu
        document.addEventListener('contextmenu', function (event) { event.preventDefault(); });


        // Disable zooming using the mouse wheel

        window.addEventListener("wheel", function (event) {
            if (event.ctrlKey) {
                event.preventDefault(); // Prevent zooming when the Ctrl key is pressed
            }
        }, { passive: false });

        // Define the event handler functions
        function keydownHandler(event) {
            if (event.key == 'ArrowRight') {
                RIGHT_ARROW_DOWN = true;
                //console.log('right arrow pressed');
            }

        }

        function keyupHandler(event) {
            if (event.key == 'ArrowRight') {
                RIGHT_ARROW_DOWN = false;
                //console.log('UNpressed');
            }
        }

        // when the participant is disconnected
        function timeoutDisconnect() {
            PARTICIPANT_EXCLUDED = true;
            window.location.href = MTURL;
        }

        // preloading -  now done in the gen instructions
        var images = ['tasks/effort/images/cursor-left.png', 'tasks/effort/images/cursor-right.png', 'tasks/effort/images/cursor-left.png', 'tasks/effort/images/background2.png', 'tasks/effort/images/character.png',
            'tasks/effort/images/c.png', 'tasks/effort/images/enemy.png', 'tasks/effort/images/spacebar.png', 'tasks/effort/images/background2.png', 'tasks/effort/images/potentials/background_twister3.jpg'];

        var preload = {
            type: jsPsychPreload,
            images: images,
            data: {
                task: 'preload_effort',
                parsing: 'start_effort'
            },
            continue_after_error: true
        };
        timeline.push(preload);

        let onstart_trial = {
            type: jsPsychHtmlKeyboardResponse,
            stimulus: '',
            choices: ["NO_KEYS"],
            trial_duration: 1, //
            data: {
                task: 'empty_trial',
            },
            on_start: function () {
                //changeBodyStyles();
                setStyles();
                //console.log('THIS IS WHERE WE SET STYLE!');
                /* console.log('xx prolific urL:', FAURL);
                console.log('xx max attention checks: ', MAX_MISSED_ATTEN_CHECKS); */
            }
        };
        timeline.push(onstart_trial);


        //Catch trial
        var savedBackgroundImage = '';
        var backgroundImage;
        var body = document.body;
        var catch_trial = {
            on_timeline_start: function () {
                var body = document.body;
                savedBackgroundImage = getComputedStyle(body).backgroundImage;
                body.style.backgroundImage = 'none';
            },
            timeline: [
                {
                    type: jsPsychHtmlKeyboardResponse,
                    stimulus:
                        `<div class="enterId" style="font-size: 150%;">This is an attention check, please respond by pressing the <b>w</b> key within 10 seconds</div>` + '<div class="enterId" style="background-color: #ccc; margin-top: 1em;">' +
                        '<div style="width: 0%; height: 20px; background-color: #333; animation-name: progress-bar; animation-duration: 10s; animation-timing-function: linear;">' +
                        '</div>' +
                        '<style> @keyframes progress-bar { 0% { width:0%;} 100% { width:100%} } </style>',
                    choices: [`w`],
                    trial_duration: 10000,
                    data: {
                        task: `catch_trial`,
                        correct_response: `w`
                    },
                    on_finish: function (data) {
                        data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response);

                        if (data.correct !== true) {
                            nrMissedAttenChecks++;
                        }
                    }
                },
                { //feedback catch trial
                    type: jsPsychHtmlKeyboardResponse,
                    stimulus: function () {
                        var tmp1 = jsPsych.data.get().last(1).values()[0].correct;

                        if (tmp1 == true) {
                            return '<p style="color: #015001; font-size: 3.5vw;">Correct!</p>'
                        } else {
                            return '<p style="color: #a10000; font-size: 3.5vw;">You failed the attention check!</p>'
                        }
                    },
                    trial_duration: 1000,
                    data: {
                        task: 'catch_feedback'
                    },
                    choices: ["NO_KEYS"]
                },
                { //Redirect if too many checks have been failed
                    type: jsPsychHtmlKeyboardResponse,
                    stimulus: function () {
                        if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
                            return `<div>
                            <p> You have failed to respond in time for ${MAX_MISSED_ATTEN_CHECKS} attention checks. As you have not been paying attention, we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
                                If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
                                <p> When you press the space bar, you will be redirected back to Prolific.</p>
                                </div>`
                        } else {
                            return '<div class="fixation">+</div>'
                        }
                    },
                    trial_duration: function () {
                        if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
                            return 100000
                        } else {
                            return 1
                        }
                    },
                    data: {
                        task: 'post_catch_feedback_screen'
                    },
                    on_finish: function (data) {
                        if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
                            return window.location = FAURL;
                        }

                    },
                    choices: " "
                }
            ],
            on_finish: function (data) {
                var body = document.body;
                body.style.backgroundImage = savedBackgroundImage;
            }
        };

        // Welcome screen
        var loading = {

            type: jsPsychHtmlKeyboardResponse,
            choices: ['NO_KEYS'],
            stimulus: `<h1>Loading...</h1>`,
            trial_duration: 1000,
            data: {
                task: 'Loading'
            }
        }
        timeline.push(loading);

        var title = {
            type: jsPsychHtmlKeyboardResponse,
            choices: ['NO_KEYS'],
            stimulus: function () {
                goblins_rise(); // start with the animation of a rising goblin
                return `
                    <div class="effort-title-container">
                    <div class="effort-title">The Goblin's Rise</div>
                    <div class="effort-intro" style="top: 100vh;width: 60%;height: 90%; background-size: cover; background-repeat: no-repeat"></div>
                    </div>
                    `
            },
            trial_duration: 2000,
            data: {
                task: 'title'
            },
            on_finish: function () {
                clearInterval(goblin_animation);
            }
        }
        timeline.push(title);



        var welcome = {
            type: jsPsychHtmlKeyboardResponse,
            stimulus: function () {
                //START_TIME = performance.now(); // start to record the time of the experiment
                //console.log('prolific urL:', FAURL);
                //console.log('max attention checks: ', MAX_MISSED_ATTEN_CHECKS);

                return `
                    <div class="effort-text-box">
                    <h1>Welcome to the Goblin's Rise game</h1>
                    <p>In this game you will receive the <b>performance bonus</b> depending on <b>how many coins</b> you get throughout the game.</p>
                    <p>Soon you will meet Grimbletoe! A goblin that wants to live peacefully in his cave.</p>
                    <p>Unfortunately, he does not have enough money to afford constantly rising living costs. 
                        Therefore, he decided to make a trip into town and collect some coins.</p>
                    <p>This game will take around 20 minutes.</p>
                    
    
                    <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                        <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                        <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                    </div>
    
                    </div>
                    
                    `
            }
        }

        var welcome_start;
        var welcome_node = {
            on_start: function () {
                TRL_LABEL = 'welcome';
            },
            type: jsPsychInstructions,
            pages: [
                welcome.stimulus /*, welcome_2.stimulus,*/ /*welcome_3.stimulus, welcome_4.stimulus*/
            ],
            data: {
                task: 'welcome'
            },
            show_clickable_nav: true,
            on_finish: function (data) {
                START_TIME = performance.now();
                //console.log('previous values: ', jsPsych.data.get().last(1).values()[0])
                let this_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }
        timeline.push(welcome_node);

        /* 
        A function for animations both of the background and characters
        */
        var background_animation; // declaring it globally so it is possible to clear interval outside of functions
        var a; // request animation frame

        // my code starts 
        function animation(background = true, finish_line = false, speed = 1) {

            var iter_times = [];

            if (background_animation) { // to prevent from two or more animations running simultanously
                clearInterval(background_animation);
                STOP_ANIMATION = false;
            }

            // positions of character, enemy and the coin aka finish
            var char_pos = 0;
            var enemy_pos = 0;
            var finish_pos = 0;
            TRL_NPRESSES = 0;

            var speed_coef = 1;

            var this_finish; // get the coin object at this moment
            var current_finish; // get the position of the current coin
            var new_finish; // set the new  position for the coin
            let this_iter = 1; // counting how many iterations does it make - set initial state during the first one 
            var pressed_counter = 0; // inertia -> one press leads to the movement of character for certain number of iterations

            var iter_length; // how often will be the character moved by 1px?
            var distance = 400; // get the distance from the start to the finish (in px) i. e., 672px

            let required_n = TRL_REQUIRED_PRESSES[EFFORT_LVL - 1];
            //console.log('req: ', required_n);
            let pressed_counter_cap = 1;
            let this_portion;
            let this_portion_rounded;
            let this_portion_leftover;
            let this_portion_total_leftover;

            let first_press = true;

            let trial_length = WAITING_TIME;

            iter_length = trial_length / distance
            ITER = iter_length;
            this_portion = (distance / required_n);
            this_portion_rounded = Math.floor(this_portion) - speed_coef;

            finish_line = true;

            $(function () {
                $('.effort-finish').animate({ left: '-=400px' }, WAITING_TIME, 'linear');
                bodyAnimation = $('body').animate({ 'background-position-x': '-=400px' }, WAITING_TIME, 'linear');
            });


            function animate() {

                let end_time;
                background_animation = setInterval(function () {

                    end_time = performance.now();
                    duration = Math.round(end_time - start_time);


                    if ((RACING == false && this_iter < distance) || (RACING == true && TRL_NPRESSES < required_n) && this_iter < distance) {

                        if (RACING == true && BUTTON_PRESSED == false) {
                            // if the character is running but no button is pressed, move 
                            $('.effort-character').css('left', `-=${speed}px`);

                        } else if (RACING == true && BUTTON_PRESSED == true) {

                            $('.effort-character').css('left', `+=${this_portion_rounded}px`);

                            TRL_NPRESSES++;
                            BUTTON_PRESSED = false;
                        }
                        this_iter += 1 * speed_coef;

                    } else {
                        bodyAnimation.stop();
                        if (TRL_NPRESSES == TRL_REQUIRED_PRESSES[EFFORT_LVL - 1] /*- 1*/) {
                            ANIMATION_SUCCESS = true;
                            // check if the titration is in progress
                            if (TITRATION_IN_PROGRESS == true) {
                                let end_time = performance.now();
                                let time_elapsed = end_time - start_time; // 2
                                let time_remaining = WAITING_TIME / time_elapsed; // 4 / 2
                                let normalised_rate = Math.round(TRL_NPRESSES * time_remaining); // 10 * 4
                                TITRATION_RATES.push(normalised_rate);
                            }

                        } else {
                            ANIMATION_SUCCESS = false;
                            // check if the titration is in progress
                            if (TITRATION_IN_PROGRESS == true) {
                                let end_time = performance.now();
                                let time_elapsed = (end_time - start_time) / 1000; // get sec.
                                let this_rate = Math.round(TRL_NPRESSES / time_elapsed) * 4;
                                TITRATION_RATES.push(this_rate);
                            }
                        }

                        coin_fade_out();
                        STOP_WALKING = true;
                        //console.log(iter_times);
                        jsPsych.pluginAPI.cancelKeyboardResponse(phys_listener);
                        clearInterval(background_animation); // clear the interval and get outta here


                        return false;
                    }

                }, ITER);
            }

            animate(); // run the animation function per se
        }

        function coin_fade_out() {
            let this_finish = document.querySelector('.effort-finish');

            if (this_finish) {
                let opacity = 1; // Initial opacity value
                //const duration = 150; // Duration in milliseconds
                const duration = 15; // Duration in milliseconds
                const interval = 5; // Interval in milliseconds
                const step = 1 / (duration / interval); // Opacity change per interval

                const fadeOutInterval = setInterval(() => {
                    opacity -= step; // Decrease the opacity gradually

                    if (opacity <= 0) {
                        this_finish.style.opacity = 0; // Set the final opacity explicitly
                        clearInterval(fadeOutInterval); // Stop the interval when opacity reaches 0

                    } else {
                        this_finish.style.opacity = opacity; // Update the element's opacity
                    }
                }, interval);
            }
        };

        function coinAnimation() {

            var this_credits;
            let this_iter = 1;

            function multiple_coins() {
                finish_pos = orig_pos;
                opacity = 1;
                var this_coin;

                var interval = setInterval(function () {

                    this_coin = finish.parentNode.children[this_iter - 1];

                    finish_pos -= 17;
                    this_coin.style.top = finish_pos + 'px';

                    opacity -= 0.032; // Decrease opacity by 0.032 in each iteration
                    this_coin.style.opacity = opacity; // Update the opacity value
                    if (opacity <= 0.03) {

                        if (this_iter >= this_credits) {
                            clearInterval(interval);
                            return true;
                        } else {
                            this_iter++;
                            multiple_coins();
                        }
                    }
                }, 1);
            }

            var opacity = 1; // Initial opacity value
            var finish = document.querySelector('.effort-finish');

            if (finish) {
                var last_choice = TASK_TYPE[TASK_TYPE.length - 1];
                //console.log('history of the task types: ', TASK_TYPE);

                if (last_choice == 'rest' || WALKING_TRAINING == true) {
                    //console.log('adding 1 credit for the rest');
                    this_credits = WAITING_CREDITS;
                } else {
                    //console.log('adding effort credits');
                    this_credits = EFFORT_CREDITS
                }

                for (let i = 1; i <= this_credits - 1; i++) {
                    //console.log(i, '. coin has been duplicated.');
                    duplicate = finish.cloneNode(true);
                    finish.parentNode.appendChild(duplicate);

                }

                var finish_pos = finish.offsetTop;
                var orig_pos = finish_pos;

                multiple_coins();
            }
        }

        // Instruction screen
        var instructions_0 = {
            type: jsPsychHtmlKeyboardResponse,
            on_start: function () {
                TRAINING_REPEAT = false;
                //FAILED_COMP_CHECK = false;
                EFFORT_LVL = INITIAL_EFFORT_LVL;
                TRAINING_COUNTER = 1;

            },
            //choices: [CONTINUE_BUTTON],
            stimulus: function () {
                //enterFullscreen(); // enter the fullscreen mode here

                STOP_ANIMATION = true;
                return `
                    <div class="effort-text-box">
                    <p>In this game you will be trying to find coins on an abandoned highway near a city called Minotown.  
                        There is an option to walk and earn 1 coin or get challenged by a minotaur 
                        with the potential of earning more.</p>
                    
                    <!--
                    <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                        <p><i>to continue.</i></p>
                    </div>
                    -->
    
                    <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                        <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                        <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                    </div>
                    
                    </div>
                    <div class="effort-character"></div>
                    <div class="effort-finish" style="left: 60%"></div>
                    ` }
        }



        var instructions_1 = {
            type: jsPsychHtmlKeyboardResponse,
            //choices: [CONTINUE_BUTTON],
            stimulus: function () {
                return `
                        <div class="effort-text-box">
                        <p>But nothing is free in this world.</p>
                        <p>There are a lot of minotaurs trying to earn as many coins as possible for themselves too. 
                            You must be faster than them to earn the coins.</p>
    
                        <!--
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to continue.</i></p>
                        </div>
                        -->
    
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                        </div>
    
                        </div>
                        <div class="effort-character"></div>
                        <div class="effort-finish" style="left: 60%"></div>
                        <div class="effort-enemy effort-standing" style="left: 55%"></div>
                        ` }
        }



        var instructions_2 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                STOP_ANIMATION = false;
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }

                return `
                            <div class="effort-text-box">
                            <p>In each trial, you can choose whether you walk or run. If you choose walking, 
                                the goblin slowly walks and eventually gets a coin.</p>
                            <p${display}>Let's try it out!</p>
                        
                        <!--
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to start walking.</i></p>
                        </div>
                        -->
    
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style=\"margin-right: 5px;">&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                        </div>
    
                            </div>
    
                            <div class="effort-character"></div>
                            <div class="effort-finish" style="left: 60%"></div>
                            `
            }
        }

        var instructions_2b = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                STOP_ANIMATION = false;
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }
                return `
                            <div class="effort-text-box">
                                <p>If you decide to run,</p>
                            <div class="effort-choice-keys-container">
                                
                                <p>you must repeatedly press </p>
                                <img src="tasks/effort/images/spacebar.png" class="effort-choice-keys-intro">
                                <p>while holding</p>
                                <img src="tasks/effort/images/cursor-right.png" class="effort-choice-keys-intro">
                                <p>and be the first to reach the coin.</p>
                            </div>
                            <p${display}>Let's try out couple of training rounds! <b>Please, do not change your hand placement on
                            the keyboard throughout the experiment.</b></p>
    
                            <!--
                            <div class="effort-choice-keys-container"><p><i>When you're ready, press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to start the run.</i></p>
                            -->
    
                            <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                        </div>
                            </div>
                            </div>
    
    
                            
                            <div class="effort-character"></div>
                            <div class="effort-enemy effort-standing"></div>
                            <div class="effort-finish"></div>
    
                            `
            }
        }

        var instructions_2c = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            data: {
                task: 'failed running'
            },
            stimulus: function () {
                //STOP_ANIMATION = false;
                return `
                        <div class="effort-text-box">
                        <p>Oh no!</p>
                        <p>It seems like you are having trouble to run and the minotaur got the coins for himself.</p>
                        <p>Let's look at the instructions again..</p>
    
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to start the instructions from the start.</i></p>
                        </div>
    
                        <!--
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                        </div>
                        -->
    
                        </div>
                        <div class="effort-character"></div>
                        ` },
            on_finish: function (data) {
                //STOP_ANIMATION = true;
            }
        }

        var instructions_3 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                            <div class="effort-text-box">
          
                            <p><b>Walking</b> does not require any effort and is always rewarded with <b>1 coin</b>. However, if
                                you put in some effort and choose <b>running</b>, you can earn more coins.</p>
                            

                            <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                            </div>

                            </div>
     
                            ` }
        }

        var instructions_3a = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                return `
                            <div class="effort-text-box">
          
                            <p>The <b>level of required effort</b> and the <b>number of coins</b> you can win, change from trial to trial.</p>
                            <p>The <b>green arm icon</b> indicates <b>how much effort</b> you need to put into the task to get the coins.</p>
                            <p>The <b>coin icon</b> below informs you about <b>how many coins</b> you can earn.</p>
                            <p>There are always two offers - walking and running.</p>
    
                            <div class="effort-caption-container">
                                <div class="effort-first effort-button-caption">
                                    <p>The <b>walk offer</b> is always displayed like this</p>
                                </div>
                                <div class="effort-second effort-button-caption">
                                    <p>This is an example of the <b>run offer</b></p>
                                </div>
                            </div>
                            
                            <div class="effort-button-container" style="margin: 0 0 4%; width: 100%">
    
                                <div class="effort-first effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
    
                                    <div class="effort-container">
                                        <div class="effort-effort-icon "></div>
                                        <div class="effort-progress-bar effort-progress-thumbnail">
                                            <div class="effort-rect-thumbnail effort-effort-bar" style="width: 0%">

                                            </div>
                                        </div>
                                    </div>
    
                                    <div class="effort-container">
                                        <div class="effort-finish effort-finish-thumbnail"></div>
                                        <div class="effort-progress-bar effort-progress-thumbnail">
                                            <div class="effort-rect-thumbnail effort-coin-bar-container">
                                                ${generateCoinSegments(1)}
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="effort-container caption">
                                        
                                        <div class="effort-effort-caption">
                                            <p>x0 effort</p>
                                        </div>                                        
                                        <div class="effort-coin-caption">
                                            <p>+1 coin</p>
                                        </div>
                                    </div>
    
                                </div>
    
                                <div class="effort-second effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
    
                                    <div class="effort-container">
                                        <div class="effort-effort-icon "></div>
                                        <div class="effort-progress-bar effort-progress-thumbnail">
                                            <div class="effort-rect-thumbnail effort-effort-bar" style="width: 80%">
                                                <p class="effort-p-thumbnail">x4</p>
                                            </div>
                                        </div>
                                    </div>
    
                                    <div class="effort-container">
                                        <div class="effort-finish effort-finish-thumbnail"></div>
                                        <div class="effort-progress-bar effort-progress-thumbnail">
                                            <div class="effort-rect-thumbnail effort-coin-bar-container">
                                                ${generateCoinSegments(6)}
                                            </div>
                                        </div>
                                    </div>
                                    <div class="effort-container caption">
                                        
                                        <div class="effort-effort-caption">
                                            <p>x4 effort</p>
                                        </div>                                           
                                        <div class="effort-coin-caption">
                                            <p>+6 coins</p>
                                        </div>
                                    </div>
    
                                </div>
    
                            </div>
    
                            <!--
                            <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                                <p><i>to continue.</i></p>
                            </div>
                            -->
    
                            <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                            </div>
    
                           
                            </div>
     
                            ` }
        }

        var instructions_4 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [LEFT_BUTTON, RIGHT_BUTTON],
            stimulus: function () {
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }

                return `
                    <div class="effort-text-box">
                        <div${display}>
                        <p>Before the game starts, you will get familiarised with the different levels of effort.</p>
                        <p>You will see the two options, but one of them will be greyed out and not available. 
                            You can only choose the available option. </p>
                        </div>
                        
                        <div class="effort-choice-keys-container">
                            <p>To choose an option on the left side, you press</p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-left.png">
                        </div>
                        <br>
                        <div class="effort-choice-keys-container">
                            <p>To choose the option on the right side, you press</p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png">
                        </div>
    
                        <p><b>Which side</b> each option appears on <b>will change</b> from trial to trial. </p>
    
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                        </div>
                    </div>
    
                    ` },
            on_finish: function (data) {
                STOP_ANIMATION = true;
                if (jsPsych.pluginAPI.compareKeys(data.response, RIGHT_BUTTON)) {
                    TRAINING_REPEAT = true;
                } else if (jsPsych.pluginAPI.compareKeys(data.response, LEFT_BUTTON)) {
                    TRAINING_REPEAT = false;
                }
            }
        }


        var instructions_4a = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [LEFT_BUTTON, RIGHT_BUTTON],
            stimulus: function () {

                let continue_text = 'Continue to start the training.';
                if (FAILED_COMP_CHECK == true) {
                    if (day > 1) {
                        continue_text = '';
                    }
                }

                return `
                    <div class="effort-text-box">
    
                        <div class="effort-choice-keys-container">
                                <p>Remember that to run, you must repeatedly press </p>
                                <img src="tasks/effort/images/spacebar.png" class="effort-choice-keys-intro">
                                <p>while holding</p>
                                <img src="tasks/effort/images/cursor-right.png" class="effort-choice-keys-intro">
                                <p>and be the first to reach the coin.</p>
                        </div>
    
                        <!--
                        <div class="effort-choice-keys-container">
                            <p>Remember that to run, you must press</p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png">
                            <p>while simultaneously keep pressing</p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/spacebar.png"> 
                            <p>repeatedly to keep running.</p>
                        </div>
    
                        <div class="effort-button-container" style="margin: 4% 0; width: 100%">
    
                            <div class="effort-first effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
                                <h2>Start the training</h2>
                            </div>
    
                            <div class="effort-second effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
                                <h2>Re-read the instructions</h2>
                            </div>
    
                        </div>
                        -->
    
                        <p><i>${continue_text}</i></p>
    
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                        </div>
                    </div>
    
                    ` },
            on_finish: function (data) {
                STOP_ANIMATION = true;
                if (jsPsych.pluginAPI.compareKeys(data.response, RIGHT_BUTTON)) {
                    TRAINING_REPEAT = true;
                } else if (jsPsych.pluginAPI.compareKeys(data.response, LEFT_BUTTON)) {
                    TRAINING_REPEAT = false;
                }
            }
        }


        var instructions_4b = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                            <div class="effort-text-box">
    
                                <p>Now that you have experienced all the levels of effort, you will practice some trials of the task.</p>
    
                                <div class="effort-choice-keys-container">
                                    <p>Remember you can choose between <b>the left (</b></p>
                                    <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-left.png">
                                    <p><b>key)</b>
                                </div>
                                
                                <div class="effort-choice-keys-container">
                                    <p> or <b>the right (</b></p>
                                    <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png"> 
                                    <p><b>key)</b> option.<br>
                                </div>
    
                                <!--
                                <p>By pressing the</p>
                                <div class="effort-choice-keys-container">
                                    <p><b>go button (</b></p>
                                    <img class="effort-choice-keys-intro" src="tasks/effort/images/spacebar.png"> 
                                    <p><b>key)</b></p>
                                </div>
                                <p>you give energy to your goblin so he can keep running.</p>
                                -->
                                
                                <!--
                                <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                                    <p><i>to continue.</i></p>
                                </div>
                                -->
    
                                <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                    <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                                    <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                                </div>
                            </div>
    
                            <div class="effort-character"></div>
                            ` }
        }

        var instructions_4c = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                            <div class="effort-text-box">
    
                            <p>For <b>walking</b>, you are always rewarded with <b>1 coin</b>. For <b>running</b>, the reward varies <b>from 2 to 10 coins</b>. Note that
                            the required effort and reward for running are chosen randomly and independently for each trial. 
                            <br><b>Your decisions do not influence future offers.</b></p>
                            <p>Likewise, responding or making decisions faster does not lead to a shorter duration of the experiment.</p>
                                                    
                            <!--
                            <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to continue the training.</i></p>
                            </div>
                            -->
    
                            <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                            </div>
                        </div>
                           
    
                            <div class="effort-character"></div>
                            ` }
        }

        var instructions_4d = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">
    
                        <p>There was no time limit during the instructions. However, from now on try not to hesitate when making a decision.<p>
                        <p>You will be notified if your responses are too slow. Please bear in mind that if you receive too many warnings,
                            you will be excluded from the experiment, and you may lose the performance bonus.</p>
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
    
                        
    
                    </div>
    
                    <div class="effort-character"></div>
    
                    ` }
        }

        var instructions_4e = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">
    
                        <p>Furthermore, we will check if you are paying attention at specific times during the experiment by having you press a specific button..<p>
                        <p>If you fail too many attention checks, we will not compensate you for participating.</p>
                        <p><b>Please, do not change your hand placement on the keyboard throughout the experiment.</b></p>
                        <p><i>Good luck!</i></p>
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
    
                        
    
                    </div>
    
                    <div class="effort-character"></div>
    
                    ` }
        }

        // Comprehension check
        var quiz_pre_physical = {
            on_start: function () {
                COMP_IN_PROGRESS = true;

                FAILED_COMP_CHECK = false;

                // Get the body element
                var body = document.body;

                // Store the current background image
                originalBackgroundImage = getComputedStyle(body).backgroundImage;

                // Set the background color to blue
                body.style.backgroundColor = '#c0c0c0';

                // Remove the background image
                body.style.backgroundImage = 'none';

                document.body.style.setProperty('overflow', 'auto', 'important');

            },
            type: jsPsychSurveyMultiChoice,
            preamble: `<p>Before you start the real game, we will ask you to respond to some questions to ensure you understand the instructions. 
                        <br>If you have at least <b>one answer wrong, you will have to go through the training and the instructions again.</b></p> `,
            button_label: 'Submit',
            questions: [
                {
                    prompt: "You always get more coins for running with higher than lower effort.",
                    name: 'coins',
                    options: ['Yes, correct.', 'No, the effort and reward are independent of each other.', 'No, you always receive 1 coin no matter what.'],
                    required: true
                },
                {
                    prompt: "The walking option is always on the left side of the screen, whereas the running option is always on the right side",
                    name: 'sides',
                    options: ['Yes, correct.', 'No, the other way around.', 'No, the sides of the options change randomly.'],
                    required: true
                },
                {
                    prompt: "The higher the effort in running you choose, the more button presses you have to make:",
                    name: 'button_presses',
                    options: ['No, you just have less time.', 'Yes, correct.', 'No, the minotaur is just moving faster.'],
                    required: true
                }
            ],
            data: {
                task: 'physical quiz'
            },
            on_finish: function (data) {
                // record the participant's responses 
                PHYS_COMP_ANSWERS.push(data.response);

                // Get the body element
                var body = document.body;

                // Restore the original background image
                body.style.backgroundImage = originalBackgroundImage;

                // Remove the background color
                body.style.backgroundColor = '';

                body.style.overflow = 'none';

                if (data.response.coins == 'No, the effort and reward are independent of each other.' && data.response.sides == 'No, the sides of the options change randomly.'
                    && data.response.button_presses == 'Yes, correct.') {

                    TRAINING_REPEAT = false;
                    FAILED_COMP_CHECK = false;
                    COMP_IN_PROGRESS = false;

                    TRAINING = false;
                    WALKING_TRAINING = false;
                    RUNNING_TRAINING = false;
                } else {
                    FAILED_COMP_CHECK = true;
                    TRAINING_REPEAT = true;
                }
            }
        }

        var if_quiz_pre_physical = {
            timeline: [quiz_pre_physical],
            conditional_function: function () {
                if (TRAINING_REPEAT == true) {
                    return false;
                } else {
                    return true;
                }
            }
        }


        var instructions_5 = {

            on_start: function () {
                //  STOP_ANIMATION = true;
            },
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                let first_or_second = 'first';

                if (CONDITION_INIT == 2) {
                    first_or_second = 'second';
                }

                return `
                    <div class="effort-text-box">
                        <h2>Good job!</h2>
                        <p>Now you will start the ${first_or_second} part of the game!</p>
                            <p><b>The more coins you collect, the more money you get</b> for the performance bonus!</p>
                            <p><b>Important: your decision do not affect future offers.</b></p>
                            <p>Likewise, responding or making decisions faster does not lead to a shorter duration of the experiment.</p>
    
                            <p>Good luck!</p>
    
                        <!--
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to start the game.</i></p>
                        </div>
                        -->
    
                        <p><i>Continue to start the game.</i></p>
                            <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                            <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                            <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
                        
                        </div>
                    </div>
                    ` }
        }

        var instructions_5b = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            data: {
                task: 'failed physical quiz'
            },
            stimulus: function () {
                return `
                            <div class="effort-text-box">
                                <p>Unfortunately, some of the answers were not correct. Let's go through the instructions and training again. Hopefully, you will make it this time</p>
    
                                <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                                    <p><i>to go through the instructions again.</i></p>
                                </div>
                            </div>
                    ` },
            on_finish: function (data) {
                WALKING_TRAINING = true;
                RUNNING_TRAINING = true;
                COMP_IN_PROGRESS = false;
                TRAINING = true;
                FAILED_PHYS_COMP_COUNTER++;
            }
        }

        var if_instructions_5b = {
            timeline: [instructions_5b],
            conditional_function: function () {
                if (TRAINING_REPEAT == true && FAILED_COMP_CHECK == true && COMP_IN_PROGRESS == true) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var instructions_phys_node_012 = {
            on_start: function () {
                TRAINING_REPEAT = false;
                EFFORT_LVL = INITIAL_EFFORT_LVL;
                TRAINING_COUNTER = 1;
                TITRATION_REPS = 1;
                TITRATION_STRIKES = 0;
                INDIVIDUAL_MAX = 0;

                if (NPRESSES_HISTORY.length > 0) {
                    // Check if NPRESSES_HISTORY is not empty
                    NPRESSES_HISTORY_DISCARDED.push(...NPRESSES_HISTORY); // Push the content to NPRESSES_HISTORY_DISCARDED
                    NPRESSES_HISTORY.length = 0; // Clear the content of NPRESSES_HISTORY
                }
            },
            type: jsPsychInstructions,
            pages: [
                instructions_0.stimulus, instructions_1.stimulus, instructions_2.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let instructions_0_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;
                let instructions_1_rt = jsPsych.data.get().last(1).values()[0].view_history[1].viewing_time;
                let instructions_2_rt = jsPsych.data.get().last(1).values()[0].view_history[2].viewing_time;

                this_rt = [instructions_0_rt, instructions_1_rt, instructions_2_rt];

                let this_trial = {
                    task: TRL_LABEL,
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var instructions_phys_node_2b = {
            type: jsPsychInstructions,
            pages: [
                instructions_2b.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let this_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;

                let this_trial = {
                    task: TRL_LABEL,
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var if_instructions_2c = {
            timeline: [instructions_2c],
            conditional_function: function () {
                if (TRAINING_REPEAT == true && ANIMATION_SUCCESS == false) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var instructions_phys_node_34 = {
            type: jsPsychInstructions,
            pages: [
                instructions_3.stimulus, instructions_3a.stimulus, instructions_4.stimulus, instructions_4a.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let instructions_3_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;
                let instructions_3a_rt = jsPsych.data.get().last(1).values()[0].view_history[1].viewing_time;
                let instructions_4_rt = jsPsych.data.get().last(1).values()[0].view_history[2].viewing_time;
                let instructions_4a_rt = jsPsych.data.get().last(1).values()[0].view_history[3].viewing_time;

                let this_rt = [instructions_3_rt, instructions_3a_rt, instructions_4_rt, instructions_4a_rt]

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        if_instructions_34 = {
            timeline: [instructions_phys_node_34],
            conditional_function: function () {
                if (TRAINING_REPEAT == true) {
                    return false;
                } else {
                    return true;
                }
            }
        }

        var instructions_phys_node_5 = {
            type: jsPsychInstructions,
            pages: [
                instructions_5.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let this_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var if_instructions_5 = {
            conditional_function: function () {
                if (TRAINING_REPEAT == true) {
                    return false;
                } else {
                    return true;
                }
            },
            timeline: [instructions_phys_node_5]
        }

        var instructions_20 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                STOP_ANIMATION = true;

                return `
                    <div class="effort-text-box">
                        <p>In this part of the game, you will try to earn coins in a city called Minotauropolis. </p>
                        <p>You will have the option to <b>take a nap</b> and receive <b>1 coin</b> thanks to the MinotaurBank savings account. The second option 
                            is to <b>compete with a minotaur</b> in a special brain twister <b>for potentially higher winnings.</b></p>
                            
                            <!--
                            <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to continue.</i></p>
                            </div>
                            -->
    
                            <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                            </div>                    
                    </div>
    
                    <div class="effort-character"></div>
                    <div class="effort-finish" style="left: 60%; transform: none"></div>
                    ` }
        }



        var instructions_21 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">
                        <p>The Minotaur is tough. If you do not respond in time or correctly, the minotaur keeps the reward for themselves.</p> 
    
                        <!--
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to continue.</i></p>
                        </div>
                        -->
    
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                    </div>
    
                    <div class="effort-character" style="left: 40%"></div>
                    <div class="effort-finish" style="left: 46%; transform: none"></div>
                    <div class="effort-enemy effort-standing effort-flipped" style="left: 58%"></div>
                    ` }
        }

        var instructions_22 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }

                return `
                    <div class="effort-text-box">
                        <p>It is up to you, which option you choose in each trial. 
                            If you choose to nap, you will simply wait until you receive the coin from the MinotaurBank. </p>
                        
                        <p${display}>Let's try it out!</p>
    
                        <!--
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to take a nap.</i></p>
                        </div>
                        -->
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                    </div>
                    <div class="effort-character"></div>
                    ` }
        }

        var instructions_22b = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">
                        <p>That was easy! Now, you will learn how the brain twister works.</p>
                        <p>In each trial you will be presented with a 
                            <b>random string of letters for a short time</b>. For instance:</p>
                            <h2>TUZH</h2>
                        <p>The string, then, disappears and <b>a single 
                            random letter appears</b> on the screen. For instance:</p>
                            <h2>T</h2>
    
                        <p>Your goal is to decide whether the single letter was part of the string shown before or not. </p>
    
                        <!--
                        <div class="effort-choice-keys-container"><p><i>When you're ready, press </i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to do the brain twister.</i></p>
                        </div>
                        -->
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                    </div>
    
                    ` }
        }

        var instructions_22b_2 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }

                return `
                    <div class="effort-text-box"> 
                        
                        <div class="effort-choice-keys-container">
                            <p>If <b>yes</b>, press the</p> 
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png">
                            <p><b> key</b>,</p>
                        </div>
                        <br>
                        <div class="effort-choice-keys-container">
                            <p>if <b>no</b> press the</p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-left.png">
                            <p><b> key</b> before the time runs out.</p>
                        </div>
    
                        <p><b>After that a progress bar appears, indicating how much time you have left to respond.</b></p>
    
                        <div class="effort-progress-bar" style="width: 60%; height: 3em; border-width: 0.5em">
                            <div class="effort-progress-bar-fill effort-rect" style="width: 75%"></div>
                        </div>
    
                        <p>In this example above, "yes" would be the correct response.</p>
    
                        <p${display}>Let's try it out!</p>
    
                        <!--
                        <div class="effort-choice-keys-container"><p><i>When you're ready, press </i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to do the brain twister.</i></p>
                        </div>
                        -->
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                    </div>
    
                    ` }
        }

        var instructions_22c = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            data: {
                task: 'failed sternberg'
            },
            stimulus: function () {

                return `
                        <div class="effort-text-box">
                        <p>Oh no!</p>
                        <p>You were not successful in the brain twister and the minotaur kept the coins for himself.</p>
                        <p>Let's go through the instructions again; you will get a chance to improve this time.</p>
    
    
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to start the instructions from the start.</i></p>
                        </div>
                        </div>
                        <div class="effort-character"></div>
                        ` }
        }

        var if_instructions_22c = {
            timeline: [instructions_22c],
            conditional_function: function () {
                if (TRAINING_REPEAT == true && TRL_SUCCESS == false) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var instructions_23 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }

                return `
                    <div class="effort-text-box">
                        <h2${display}>Good job!</h2>
                        <p><b>Taking a nap</b> does not require any effort and is always rewarded with <b>1 coin</b>.<br>However, 
                           if you put in some effort and choose <b>the brain twister</b>, you can <b>sometimes earn more coins.</b></p>

                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                        <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                        <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                   </div>
                    </div>
                    
                    ` }
        }

        var instructions_23a = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }

                return `
                    <div class="effort-text-box">
                           <p>The level of effort required and the number of coins you can win, change from trial to trial.</p>
                           
                        <p>The<b> brain icon</b> indicates <b>how much effort</b> you need to put into the task to get the coins.</p>
                        <p>The<b> coin icon</b> below informs you about <b>how many coins</b> you can earn.</p>
    
                        <div class="effort-caption-container">
                            <div class="effort-first effort-button-caption">
                                <p>The <b>nap offer</b> is always displayed like this</p>
                            </div>
                            <div class="effort-second effort-button-caption">
                                <p>This is an example of the <b>brain twister offer</b></p>
                            </div>
                        </div>
    
                        <div class="effort-button-container" style="margin: 0 0 4%; width: 100%">
    
                        <div class="effort-first effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
    
                            <div class="effort-container">
                                <div class="effort-effort-icon effort-effort-icon-mental"></div>
                                <div class="effort-progress-bar effort-progress-thumbnail">
                                    <div class="effort-rect-thumbnail effort-effort-bar" style="width: 0%">
                                        <p class="effort-p-thumbnail"></p>
                                    </div>
                                </div>
                            </div>
    
                            <div class="effort-container">
                                <div class="effort-finish effort-finish-thumbnail"></div>
                                <div class="effort-progress-bar effort-progress-thumbnail">
                                    <div class="effort-rect-thumbnail effort-coin-bar" style="width: 20%">
                                            <p class="effort-p-thumbnail">+1</p>
                                    </div>
                                </div>
                            </div>
    
                        </div>
    
                        <div class="effort-second effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
    
                            <div class="effort-container">
                                <div class="effort-effort-icon effort-effort-icon-mental"></div>
                                <div class="effort-progress-bar effort-progress-thumbnail">
                                    <div class="effort-rect-thumbnail effort-effort-bar" style="width: 40%">
                                        <p class="effort-p-thumbnail">x2</p>
                                    </div>
                                </div>
                            </div>
    
                            <div class="effort-container">
                                <div class="effort-finish effort-finish-thumbnail"></div>
                                <div class="effort-progress-bar effort-progress-thumbnail">
                                    <div class="effort-rect-thumbnail effort-coin-bar" style="width: 80%">
                                            <p class="effort-p-thumbnail">+4</p>
                                    </div>
                                </div>
                            </div>
    
                        </div>
    
                        </div>

    
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                    </div>
                    
                    ` }
        }

        var instructions_24 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [LEFT_BUTTON, RIGHT_BUTTON],
            stimulus: function () {
                let display = '';

                if (FAILED_COMP_CHECK == true) {
                    display = ' style="display: none"';
                }

                return `
                    <div class="effort-text-box">
                        <div${display}>
                        <p>Before the game starts, you will get familiarised with the different levels of effort.</p>
                        <p>You will see the two options, but one of them will be greyed out and not available. 
                            You can only choose the available option. </p>
                        </div>
                        
                        <div class="effort-choice-keys-container">
                            <p>To choose an option on the left side, you press</p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-left.png">
                            <p>To choose the option on the right side, you press</p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png">
                        </div>

                        <p><b>Which side</b> each option appears on <b>will change</b> from trial to trial. </p>

                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                        <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                        <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                    </div>
    
              
                    ` }
        }

        var instructions_24a = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [LEFT_BUTTON, RIGHT_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">

                        
                        <p>Remember that to do the brain twister, you must respond before the progress bar disappears:</p>
                        
                        <div class="effort-choice-keys-container">
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png">
                            <p><b>(yes)</b> if you think the single letter was part of the string or</p>
                        </div>
                        <br>
                        <div class="effort-choice-keys-container">
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-left.png">
                            <p><b>(no)</b> if you think it wasn't.</p>
                        </div>
    
                        <!--
                        <div class="effort-button-container" style="margin: 4% 0; width: 100%">
    
                        <div class="effort-first effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
                            <h2>Start the training</h2>
                        </div>
    
                        <div class="effort-second effort-button" style="box-shadow:0.5em 0.5em 1.5em #2c2c2c;">
                            <h2>Re-read the instructions</h2>
                        </div>
    
                        </div>
                       
    
                        <p><i>Choose the left or the right option.</i></p>
                        -->
    
                        <p><i>Continue to start the training.</i></p>
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                        
                    </div>
    
              
                    ` }
        }

        var instructions_24b = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                return `
                    <div class="effort-text-box">
                        <p>Now that you have experienced all the levels of effort, you will practice some trials of the task.</p>
                        <p>Remember you can choose between</p>
    
                        <div class="effort-choice-keys-container">
                            <p><b>the left (</b></p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-left.png">
                            <p><b>key)</b></p> 
                            <p>or <b>the right (</b></p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png">
                            <p><b>key)</b> option.</p>
                        </div>
    
                        <!--
                        <p>If you choose the brain twister,</p>
                        <div class="effort-choice-keys-container">
                            <p>you press the <b>yes button (</b></p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-right.png">
                            <p><b>key)</b>, if you think that the single letter was part of the string.</p>
                        </div>
                        <div class="effort-choice-keys-container">
                            <p>You press the <b>no button (</b></p>
                            <img class="effort-choice-keys-intro" src="tasks/effort/images/cursor-left.png">
                            <p><b>key)</b>, if you think that the single letter was not there.</p>
                        </div>
                        
    
                        <br>
    
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to continue.</i></p>
                        </div>
                    -->
                        
                    <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
    
                    </div>
    
                    ` }
        }

        var instructions_24c = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">
    
                        <p>For <b>taking a nap</b>, you are always rewarded with <b>1 coin</b>. For the <b>brain twister</b>, the reward varies <b>from 1 to 5 coins</b>. Note that the required 
                         effort and reward for the brain twister are chosen randomly and independently for each trial. 
                        <br><b>Your decisions do not influence future offers</b>.<p>
                        <p>Likewise, responding or making decisions faster does not lead to a shorter duration of the experiment.</p>
                        
                        
                        <!--
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to continue the training.</i></p>
                        </div>
                        -->
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
    
                    </div>
    
                    ` }
        }

        var instructions_24d = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">
    
                        <p>There was no time limit during the instructions. However, from now on try not to hesitate when making a decision.<p>
                        <p>You will be notified if your responses are too slow. Please bear in mind that if you receive too many warnings,
                            you will be excluded from the experiment, and you may lose the performance bonus.</p>
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
    
                    </div>
    
                    ` }
        }

        var instructions_24e = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {

                return `
                    <div class="effort-text-box">
    
                        <p>Furthermore, we will check if you are paying attention at specific times during the experiment by having you press a specific button..<p>
                        <p>If you fail too many attention checks, we will not compensate you for participating.</p>
                        <p><i>Good luck!</i></p>
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;">&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
    
                    </div>
    
                    ` }
        }



        // Comprehension check

        var quiz_pre_mental = {
            on_start: function () {
                COMP_IN_PROGRESS = true;
                FAILED_COMP_CHECK = false;

                // Get the body element
                var body = document.body;

                // Store the current background image
                originalBackgroundImage = getComputedStyle(body).backgroundImage;

                // Set the background color to blue
                body.style.backgroundColor = '#c0c0c0';

                // Remove the background image
                body.style.backgroundImage = 'none';

                document.body.style.setProperty('overflow', 'auto', 'important');
            },
            type: jsPsychSurveyMultiChoice,
            preamble: `<p>Before you start the real game, we will ask you to respond to some questions to ensure you understand the instructions. 
                        <br>If you have at least <b>one answer wrong, you will have to go through the training and the instructions again.</b></p> `,
            button_label: 'Submit',
            questions: [
                {
                    prompt: "The higher the effort in the brain twister you choose, the longer the random string will be.",
                    name: 'string_length',
                    options: ['No, the higher the effort, the less time for response I get.', 'No, the opposite - the shorter the random string will be.',
                        'Yes, correct.'],
                    required: true
                },
                {
                    prompt: "The nap option is always on the right side of the screen, whereas the brain twister option is always on the left side.",
                    name: 'sides_mental',
                    options: ['No, it depends on the previous trial.', 'No, the nap option is always on the left side.', 'No, the sides of the options change randomly.'],
                    required: true
                },
                {
                    prompt: "You get more coins in the brain twister if you respond faster.",
                    name: 'fast_response',
                    options: ['No, the reward is the same regardless of how fast you are.', 'Yes, but only if you respond before the progress bar appears.', 'No, you always receive 1 coin no matter what.'],
                    required: true
                }
            ],
            data: {
                task: 'mental quiz'
            },
            on_finish: function (data) {
                // record the participant's responses 
                MENTAL_COMP_ANSWERS.push(data.response);



                // Get the body element
                var body = document.body;



                // Restore the original background image
                body.style.backgroundImage = originalBackgroundImage;

                // Remove the background color
                body.style.backgroundColor = '';

                body.style.overflow = 'none';

                if (data.response.string_length == 'Yes, correct.' &&
                    data.response.sides_mental == 'No, the sides of the options change randomly.' &&
                    data.response.fast_response == 'No, the reward is the same regardless of how fast you are.') {

                    TRAINING_REPEAT = false;
                    FAILED_COMP_CHECK = false;
                    COMP_IN_PROGRESS = false;

                    TRAINING = false;
                    WALKING_TRAINING = false;
                    RUNNING_TRAINING = false;
                } else {
                    FAILED_COMP_CHECK = true;
                    TRAINING_REPEAT = true;
                }
            }
        }

        var if_quiz_pre_mental = {
            timeline: [quiz_pre_mental],
            conditional_function: function () {
                if (TRAINING_REPEAT == true) {
                    return false;
                } else {
                    return true;
                }
            }
        }

        var instructions_25 = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            stimulus: function () {
                let first_or_second = 'second';

                if (CONDITION_INIT == 2) {
                    first_or_second = 'first';
                }

                return `
                    <div class="effort-text-box">
                        <h2>Good job!</h2>
                        <p>Now you will start the ${first_or_second} part of the game!</p>
    
                            <p><b>The more coins you collect, the more money you get</b> for the performance bonus!</p>
                        
                        <p><b>Important: your decision do not affect future offers.</b></p>
                        <p>Likewise, responding or making decisions faster does not lead to a shorter duration of the experiment.</p>
                        <p>Good luck!</p>
                        
                        <!--
                        <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                            <p><i>to start the game.</i></p>
                        </div>
                        -->
    
                        
                        <div class="jspsych-instructions-nav" style="left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
                                <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px;" disabled>&lt; Previous</button>
                                <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>                    
                        </div>
                    </div>
                    ` }
        }



        var instructions_25b = {
            type: jsPsychHtmlKeyboardResponse,
            choices: [CONTINUE_BUTTON],
            data: {
                task: 'failed mental quiz'
            },
            stimulus: function () {
                return `
                            <div class="effort-text-box">
                                <p>Unfortunately, some of the answers were not correct. Let's go through the instructions and training again. Hopefully, you will make it this time</p>
    
                                <div class="effort-choice-keys-container"><p><i>Press</i></p> <img src="tasks/effort/images/c.png" class="effort-choice-keys-intro"> 
                                    <p><i>to go through the instructions again.</i></p>
                                </div>
                            </div>
                    ` },
            on_finish: function (data) {
                WALKING_TRAINING = true;
                RUNNING_TRAINING = true;
                TRAINING = true;
                COMP_IN_PROGRESS = false;
                FAILED_MENTAL_COMP_COUNTER++;
            }
        }

        var if_instructions_25b = {
            timeline: [instructions_25b],
            conditional_function: function () {
                if (TRAINING_REPEAT == true && FAILED_COMP_CHECK == true && COMP_IN_PROGRESS == true) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var instructions_mental_node_202122 = {
            on_start: function () {
                TRAINING_REPEAT = false;
                //FAILED_COMP_CHECK = false;
                EFFORT_LVL = INITIAL_EFFORT_LVL;
                TRAINING_COUNTER = 1;
            },
            type: jsPsychInstructions,
            pages: [
                instructions_20.stimulus, instructions_21.stimulus, instructions_22.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let instructions_20_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;
                let instructions_21_rt = jsPsych.data.get().last(1).values()[0].view_history[1].viewing_time;
                let instructions_22_rt = jsPsych.data.get().last(1).values()[0].view_history[2].viewing_time;

                this_rt = [instructions_20_rt, instructions_21_rt, instructions_22_rt];

                let this_trial = {
                    task: TRL_LABEL
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var instructions_mental_node_22b = {
            type: jsPsychInstructions,
            pages: [
                instructions_22b.stimulus, instructions_22b_2.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let this_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var instructions_mental_node_2324 = {
            type: jsPsychInstructions,
            pages: [
                instructions_23.stimulus, instructions_23a.stimulus, instructions_24.stimulus, instructions_24a.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let instructions_23_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;
                let instructions_23a_rt = jsPsych.data.get().last(1).values()[0].view_history[1].viewing_time;
                let instructions_24_rt = jsPsych.data.get().last(1).values()[0].view_history[2].viewing_time;
                let instructions_24a_rt = jsPsych.data.get().last(1).values()[0].view_history[3].viewing_time;

                this_rt = [instructions_23_rt, instructions_23a_rt, instructions_24_rt, instructions_24a_rt];

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        if_instructions_2324 = {
            timeline: [instructions_mental_node_2324],
            conditional_function: function () {
                if (TRAINING_REPEAT == true) {
                    return false;
                } else {
                    return true;
                }
            }
        }

        var instructions_mental_node_24b24c = {
            type: jsPsychInstructions,
            pages: [
                instructions_24b.stimulus, instructions_24c.stimulus, instructions_24d.stimulus, instructions_24e.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let instructions_24b_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;
                let instructions_24c_rt = jsPsych.data.get().last(1).values()[0].view_history[1].viewing_time;
                let instructions_24d_rt = jsPsych.data.get().last(1).values()[0].view_history[2].viewing_time;
                let instructions_24e_rt = jsPsych.data.get().last(1).values()[0].view_history[3].viewing_time;

                this_rt = [instructions_24b_rt, instructions_24c_rt, instructions_24d_rt, instructions_24e_rt];

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var if_instructions_24b = {
            timeline: [instructions_mental_node_24b24c],
            conditional_function: function () {
                if (TRAINING_COUNTER == EFFORT_ROUNDS + NO_EFFORT_ROUNDS + 1) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var instructions_mental_node_25 = {
            type: jsPsychInstructions,
            pages: [
                instructions_25.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var if_instructions_25 = {
            conditional_function: function () {
                if (TRAINING_REPEAT == true) {
                    return false;
                } else {
                    return true;
                }
            },
            timeline: [instructions_mental_node_25]
        }

        var fix_cross = {
            type: jsPsychHtmlKeyboardResponse,
            choices: "NO_KEYS",

            stimulus: function () {
                STOP_ANIMATION = false
                //console.log('the iter is currently set at: ', ITER);

                return `
                    <div style="font-size:60px;color:red">+</div>
                    <div class="effort-character"></div>
                    `
            },
            trial_duration: function () {
                var fix_length = 250 + Math.random() * 500;
                //console.log('fix cross duration: ', fix_length);
                return fix_length;
            },
            data: {
                task: 'fixation cross'
            },
            on_finish: function (data) {
                STOP_ANIMATION = true;
            }
        }

        var fix_start;
        var fix_end;
        var fix_cross_no_walk = {
            on_start: function () {
                fix_start = performance.now();
            },
            type: jsPsychHtmlKeyboardResponse,
            choices: "NO_KEYS",
            data: {
                task: 'fixation cross'
            },
            stimulus: function () {
                STOP_ANIMATION = false
                return `
                    <div style="font-size:60px;color:red">+</div>
    
                    <div class="effort-finish" style="left: 47%; transform: none"></div>
                    <div class="effort-character" style="bottom: 16vh; left: 43%"></div>
                    <div class="effort-enemy effort-standing effort-flipped" style="left: 57%"></div>
                    `
            },
            trial_duration: function () {
                var fix_length = 250 + Math.random() * 500;
                return fix_length;
            },
            on_finish: function (data) {
                STOP_ANIMATION = true;
                fix_end = performance.now();
                STERNBERG_CROSS_TIME += fix_end - fix_start;
            }
        }

        var fix_cross_no_char = {
            on_start: function () {
                fix_start = performance.now();

            },
            type: jsPsychHtmlKeyboardResponse,
            choices: "NO_KEYS",

            stimulus: function () {

                return `
                                <div style="font-size:60px;color:red">+</div>
                                `
            },
            trial_duration: function () {
                var fix_length = 250 + Math.random() * 500;
                //console.log('fix cross duration: ', fix_length);
                return fix_length;
            },
            data: {
                task: 'fixation cross'
            },
            on_finish: function (data) {
                //STOP_ANIMATION = true;
                fix_end = performance.now();
                STERNBERG_CROSS_TIME += fix_end - fix_start;
            }
        }

        var fix_cross_extension = {
            type: jsPsychHtmlKeyboardResponse,
            choices: "NO_KEYS",
            trial_duration: function () {
                let s_end = performance.now();
                let dur = TOTAL_TRIAL_TIME - (Math.round(s_end - s_start)) // how much time remaining until the end of the whole trial 
                return dur
            },
            stimulus: function () {
                return `
                             <div style="font-size:60px;color:red">+</div>
                            `
            },
            data: {
                task: 'fixation cross'
            },
            on_finish: function (data) {
                TRL_EXTENSION = 0;
            }
        }

        // Not pushing it here, but later we will add it to a looping timeline because it is repeating

        // Function to generate the buttons rest and effort, it takes color1 and color2 as an argument
        // so I can later change the border color of the chosen element - this is not the nicest solution tho
        function generateReward() {
            const numbers = [2, 4, 6, 8, 10];
            const randomIndex = Math.floor(Math.random() * numbers.length);
            return numbers[randomIndex];
        }


        var this_effort;
        var this_caption = '';
        function stim(c1 = '', c2 = '', gen_rand_num, walking = false, walking_right = true) {

            //if (gen_rand_num == true && TRAINING_COUNTER <= NO_EFFORT_ROUNDS + EFFORT_ROUNDS) {
            if (gen_rand_num == true) {
                BUTTON_ORDER = Math.floor(Math.random() * 2); // generate the order of a button (0 or 1)
            }

            if (gen_rand_num == true && TRAINING == true) {
                let this_matrix_index = TRAINING_COUNTER - NO_EFFORT_ROUNDS - 1;

                EFFORT_LVL = TRA_EFFORT_MATRIX[this_matrix_index];

                // Check if EFFORT_LVL is undefined
                if (typeof EFFORT_LVL === 'undefined') {
                    // Generate a random number between 1 and 5 (inclusive)
                    EFFORT_LVL = Math.floor(Math.random() * 5) + 1;
                }

                //EFFORT_CREDITS = Math.floor(Math.random() * 5) + 1; // credits from 1 to 5
                EFFORT_CREDITS = generateReward();
            } else if (gen_rand_num == true && TRAINING == false) { // during offer we want to generate raondom numbers but during the choice keep it the same
                //EFFORT_LVL = Math.floor(Math.random() * 5) + 1; // effort from 1 to 5
                // EFFORT_CREDITS = Math.floor(Math.random() * 5) + 1; // credits from 1 to 5
                if (shuffled_pairs.length == 0) {
                    shuffled_pairs = shuffle_array(); // if empty returns a shuffled array
                }

                var pair = shuffled_pairs.pop();
                EFFORT_LVL = pair[0];
                EFFORT_CREDITS = pair[1];
                //console.log('popping the last item of the array: ', pair, ' The shuffled pairs looks like this: ', shuffled_pairs);
            }

            // Generate the HTML, enclose it with backticks so one can add javascript variables to the html code
            let walking_class = '';
            let walking_left = '';
            let if_effort_training = '';
            let if_rest_training = '';
            let headline = 'Pick one';
            let display_credits = '';
            let this_effort_type;
            let this_resting_type;
            let this_effort_icon;
            let this_first_button;
            let this_second_button;
            let this_credits;
            let effort_perc = EFFORT_LVL * 20;
            let credit_perc = EFFORT_CREDITS * 10;

            if (EFFORT_TYPE == 'physical') {
                this_effort_type = 'run';
                this_resting_type = 'walk';
                this_effort_icon = '';
                this_credits = PHYSICAL_CREDITS;
            } else if (EFFORT_TYPE == 'mental') {
                this_effort_type = 'brain twister';
                this_resting_type = 'nap';
                this_effort_icon = 'effort-effort-icon-mental'
                this_credits = MENTAL_CREDITS;
            }

            if (TRAINING == true) {
                headline = 'Training';
                display_credits = 'display: none';
            }

            if (WALKING_TRAINING == true) {
                if_rest_training = '-webkit-filter: grayscale(100%);filter: grayscale(100%);';
            } else if (RUNNING_TRAINING == true) {
                if_effort_training = '-webkit-filter: grayscale(100%);filter: grayscale(100%);';
            }

            if (walking == true) {
                walking_class = 'effort-walking'
            }

            if (walking_right == false) {
                walking_left = 'effort-left';
            }

            if (BUTTON_ORDER == 0) {

                this_first_button = 'cursor-left.png';
                this_second_button = 'cursor-right.png';
            } else if (BUTTON_ORDER == 1) {


                this_first_button = 'cursor-right.png';
                this_second_button = 'cursor-left.png';
            }

            let stim = ` 

    
    
                <div class='effort-headline'>
                <h1>${headline}</h1>
                </div>
    
                <div class="effort-caption-container">
                    <div class="effort-first effort-button-caption" style="${if_effort_training}; order: ${BUTTON_ORDER}">
    
                        <p>Press</p>
                        <img class="effort-choice-keys" src="tasks/effort/images/${this_first_button}">
                        <p>for <b>this option</b></p>
                    </div>
    
                    <div class="effort-second effort-button-caption" style="${if_rest_training}">
    
                        <p>Press</p>
                        <img class="effort-choice-keys" src="tasks/effort/images/${this_second_button}">
                        <p>for <b>this option</b></p>
                    </div>
                </div>
    
                <div class="effort-button-container">
    
                    <div class="effort-first effort-button" style="box-shadow:  ${c1} ${BUTTON_SHADOW};${if_effort_training};order: ${BUTTON_ORDER}">
                        
                        <div class="effort-container">
                            <div class="effort-effort-icon ${this_effort_icon}"></div>
                            <div class="effort-progress-bar effort-progress-thumbnail">
                                <div class="effort-rect-thumbnail effort-effort-bar" style="width: 0%"></div>
                            </div>
                        </div>
                    
                        <div class="effort-container">
                            <div class="effort-finish effort-finish-thumbnail"></div>
                            <div class="effort-progress-bar effort-progress-thumbnail">
                                <div class="effort-rect-thumbnail effort-coin-bar-container">
                                    ${generateCoinSegments(1)}
                                </div>
                            </div>
                        </div>

                        <div class="effort-container caption">
                            <div class="effort-effort-caption">
                                <p>x0 effort</p>
                            </div>
                                
                            <div class="effort-coin-caption">
                                <p>+1 coin</p>
                            </div>
                        </div>

                    </div>

        
                    <div class="effort-second effort-button" style="box-shadow:  ${c2} ${BUTTON_SHADOW};${if_rest_training}">
                        


                        <div class="effort-container">
                            <div class="effort-effort-icon ${this_effort_icon}"></div>
                            <div class="effort-progress-bar effort-progress-thumbnail">
                                <div class="effort-rect-thumbnail effort-effort-bar" style="width: ${effort_perc}%">
                                    <p class="effort-p-thumbnail">x${EFFORT_LVL}</p>
                                </div>
                            </div>
                        </div>
                
                        <div class="effort-container">
                            <div class="effort-finish effort-finish-thumbnail"></div>
                            <div class="effort-progress-bar effort-progress-thumbnail">
                                <div class="effort-rect-thumbnail effort-coin-bar-container">
                                ${generateCoinSegments(EFFORT_CREDITS)}
                                </div>
                            </div>
                        </div>

                        <div class="effort-container caption">
                            <!-- <div class="effort-finish effort-finish-thumbnail" style="opacity:0"></div> -->
                            <div class="effort-effort-caption">
                                <p>x${EFFORT_LVL} effort</p>
                            </div>                        
                            <div class="effort-coin-caption">
                                <p>+${EFFORT_CREDITS} coins</p>
                            </div>
                        </div>

                    </div>
                    </div>
        
                </div>
    
                <div class="effort-character ${walking_class} ${walking_left}" id="effort-og"></div>
                `
                ;
            return stim;
        }

        // Function to generate coin segments based on EFFORT_CREDITS
        function generateCoinSegments(numSegments) {
            let segmentsHTML = '';
            for (let i = 0; i < 10; i++) {
                if (i < numSegments) {
                    segmentsHTML += '<div class="effort-rect-thumbnail effort-coin-bar-segment coin"></div>';
                } else {
                    segmentsHTML += '<div class="effort-rect-thumbnail effort-coin-bar-segment"></div>';
                }
            }
            return segmentsHTML;
        }

        var s_start = 0;
        var timeout_displayed = false;
        var last_offer_stim = 0;
        var this_stim;

        // Participant has the offer to choose effort or rest
        var timeout_fun;
        var this_response = null; // record if any button press was made

        var offer_var = {
            on_start: function () {
                let s_end = performance.now(); // 150
                //console.log('the time it took from the offer start until the end of outcome is: ', s_end - s_start); //100
                s_start = performance.now();// 50
                clearInterval(background_animation);
            },
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: WARNING_INTERVAL,
            stimulus: function () {
                if (last_offer_stim == 0) {
                    this_stim = stim('', '', true) // in this situation we want to have both buttons border to be black and generate random numbers
                } else {
                    this_stim = last_offer_stim;
                }
                return this_stim;
            },
            choices: function () {
                if (WALKING_TRAINING == true && BUTTON_ORDER == 0) {
                    return [LEFT_BUTTON]
                } else if (WALKING_TRAINING == true && BUTTON_ORDER == 1) {
                    return [RIGHT_BUTTON]
                } else if (RUNNING_TRAINING == true && BUTTON_ORDER == 0) {
                    return [RIGHT_BUTTON]
                } else if (RUNNING_TRAINING == true && BUTTON_ORDER == 1) {
                    return [LEFT_BUTTON]
                } else {
                    return [LEFT_BUTTON, RIGHT_BUTTON]
                }
            },
            data: {
                task: 'offer', // record the users response for later

                effort_response: function () {
                    if (BUTTON_ORDER == 0) {
                        return RIGHT_BUTTON
                    } else {
                        return LEFT_BUTTON
                    }
                }, // record it for later which button correspond to which condition
                resting_response: function () {
                    if (BUTTON_ORDER == 0) {
                        return LEFT_BUTTON
                    } else {
                        return RIGHT_BUTTON
                    }
                }
            },
            on_finish: function (data) { // based on the users input check if he pressed j which is effort
                clearInterval(timeout_fun);
                data.right_pressed = jsPsych.pluginAPI.compareKeys(data.response, RIGHT_BUTTON);
                data.effort = jsPsych.pluginAPI.compareKeys(data.response, data.effort_response);
                EFFORT_KEY = data.effort_response;
                NO_EFFORT_KEY = data.resting_response;
                //console.log('data resting response: ', data.resting_response);

                if (data.effort == true) {
                    data.color = ['', 'inset']; // if so change the border of the second button to red
                } else {
                    data.color = ['inset', '']; // if not the first button will have the red border 
                }

                this_response = data.response;

                if (this_response == null) {
                    last_offer_stim = this_stim;
                } else {
                    last_offer_stim = 0;
                }

            },
        }

        var exclusion_trl = {
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: 300000,
            choices: [' '],
            data: {
                task: 'exlusion timeout threshold'
            },
            stimulus: `
        
                        <div class="effort-headline"><h1>Time out</h1></div>
                        <div class="effort-text-box"> 
                            <p> You have failed to respond in time to ${TIMEOUT_TRL_THRESHOLD} offers in a row. As such we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
                            If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
                            <p> When you press the space bar, you will be redirected back to Prolific.</p>
                        </div>
                        <div class="effort-character"></div>
                    `,
            on_finish: function (data) {
                timeoutDisconnect();
            }
        }

        var if_exclusion_trl = {
            timeline: [exclusion_trl],
            conditional_function: function () {
                if (TIMEOUT_WARNINGS >= TIMEOUT_TRL_THRESHOLD) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var exclusion_total = {
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: 300000,
            choices: [' '],
            data: {
                task: 'exlusion timeout total'
            },
            stimulus: `
        
                        <div class="effort-headline"><h1>Time out</h1></div>
                        <div class="effort-text-box"> 
                            <p> You have failed to respond in time to ${TOTAL_TIMEOUT_WARNINGS} or more offers. As such we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
                            If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
                            <p> When you press the space bar, you will be redirected back to Prolific.</p>
                        </div>
                        <div class="effort-character"></div>
                    `,
            on_finish: function (data) {
                timeoutDisconnect();
            }
        }

        var if_exclusion_total = {
            timeline: [exclusion_total],
            conditional_function: function () {
                if (TOTAL_TIMEOUT_WARNINGS >= TIMEOUT_TOTAL_THRESHOLD) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var timeout = {
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: WARNING_DURATION,
            choices: ['NO_KEYS'],
            data: {
                task: 'timeout warning'
            },
            stimulus: function () {
                TIMEOUT_WARNINGS++; // record the timeout warning for that particular trial
                TOTAL_TIMEOUT_WARNINGS++ // record timeout warnings for the whole experiments

                return ` 
                                <div class="effort-headline"><h1>Respond faster</h1></div>
                                <div class="effort-text-box effort-time-out"><h2 class="effort-incorrect">Respond faster</h2></div>
                                <div class="effort-character"></div>
                                `
            }
        }



        var if_timeout = {
            timeline: [timeout],
            conditional_function: function () {
                if (WALKING_TRAINING == false && RUNNING_TRAINING == false && this_response == null) {
                    //console.log('this response is null');
                    return true;
                } else {
                    return false;
                }
            }
        }

        var add_trial = true;
        var offer = {
            on_timeline_start: function () {

                if (TRAINING == false && add_trial == true) {
                    TRL_NUMBER += 1;
                }
                //console.log('trial number: ', TRL_NUMBER);
            },
            timeline: [offer_var, if_timeout, if_exclusion_total, if_exclusion_trl],
            loop_function: function () {
                if (this_response == null) {
                    add_trial = false;
                    return true;
                } else {
                    TIMEOUT_WARNINGS = 0;
                    //console.log('resetting timeouts');
                    add_trial = true;
                    return false;
                }

            }
        }

        function moveCharacter(right_pressed) {
            let choice_latency = CHOICE_LATENCY - 180; // speed
            let n_iter = choice_latency / ITER; // "refresh rate"
            let this_iter = 1; // current iteration
            let character_element; // get the .character element             
            let coeff; // how much margin left
            if (right_pressed == false) { // empirically tested values
                coeff = -0.33;
            } else {
                coeff = 0.33;
            }
            var portion;// = coeff / ITER;

            var countdown = setInterval(function () {
                if (this_iter <= n_iter) {
                    let this_offset;
                    let new_offset;
                    //let portion;
                    if (this_iter == 1) { // set the inital state in the iteration 1
                        character_element = document.querySelector('#og'); // get the element
                        // 1013px
                        this_offset = character_element.offsetLeft;
                        new_offset = this_offset * (1 - coeff);
                        offset_difference = new_offset - this_offset;
                        portion = offset_difference / n_iter;
                        character_element.style.left = (this_offset - portion) + 'px';
                    } else {
                        this_offset = character_element.offsetLeft;
                        character_element.style.left = (this_offset - portion) + 'px';
                    }
                    this_iter++;
                } else {
                    return true;
                    clearInterval(countdown);
                }

            }, ITER);
        }


        // After the participant chooses the condition, change the border of the chosen button and display it for trial_duration sec
        var choice = {
            stimulus: function () {

                let data_prev = jsPsych.data.get().last(1).values()[0];

                if (typeof data_prev.color === 'undefined' || typeof data_prev.effort === 'undefined' || typeof data_prev.right_pressed === 'undefined') {
                    data_prev = jsPsych.data.get().last(2).values()[0];
                }

                let walking_right;
                var col = data_prev.color; // get the color variable from the previous trial (last(1)) 
                var effort = data_prev.effort;
                var right_pressed = data_prev.right_pressed;

                if (right_pressed == false) {
                    walking_right = false;
                }

                var s = stim(col[0], col[1], false, false, walking_right);  // and pass it here as an argument to generate the stimulus again but with the changed border to red

                return s;
            },
            choices: "NO_KEYS",
            data: {
                task: 'choice',
                task_type: function () {
                    var task = jsPsych.data.get().last(1).values()[0].effort; // this is here just fyi so we can back track which condition was chosen
                    if (task == true) {
                        TASK_TYPE.push('effort') // 2 => effort
                        return 'effort'
                    } else {
                        TASK_TYPE.push('rest') // 1 => rest
                        return 'rest'
                    }
                }
            },
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: CHOICE_LATENCY,
            on_finish: function (data) {
                let choice_rt = jsPsych.data.get().last(2).values()[0].rt;
                CHOICE_RT = choice_rt;
            }
        }

        var this_array_set;
        var this_set;
        var sternberg_task = {
            type: jsPsychHtmlKeyboardResponse,
            choices: "NO_KEYS",
            trial_duration: STERNBERG_LATENCY * 1000,
            data: {
                task: 'sternberg stimulus'
            },
            stimulus: function () { // randomize the stimulus
                this_set = STERNBERG_LOAD[EFFORT_LVL - 1]; // set the corresponding load according to the EFFORT_LVL
                let rand_idx; // generate a random index that would correspond to an item in the STERNBERG_ARRAY
                let rand_idx_hist = []; // save the drawn indices to prevent repeating generated stimuli
                let this_letter; // corresponding letter in the STERNBERG_ARRAY base on the rand_idx
                let temp_stim = []; // temporary array with the letters that will be passed to the STERNBERG_STIM

                this_array_set = Math.floor(Math.random() * 4);
                let this_array = STERNBERG_ARRAY[this_set][this_array_set];

                for (let i = 1; i <= this_set; i++) {
                    while (rand_idx_hist.includes(rand_idx) || rand_idx === undefined) { // draw a random number if the rand_idx is  empty and it was not drawn before 
                        rand_idx = Math.floor(Math.random() * this_array.length);
                    }
                    rand_idx_hist.push(rand_idx); // hitory of rand_idx in this loop
                    this_letter = this_array[rand_idx]; // single letter that was drawn
                    //console.log('this letter: ', this_letter);
                    temp_stim.push(this_letter); // push in to the temp array that will be passed to the STERNBERG_STIM

                }

                STERNBERG_STIM = temp_stim.join(''); // remove the commas and push it to the STERNBERG_STIM

                return `
                        <div class="effort-headline">
                            <h1>Brain twister</h1>
                        </div>
    
                    <div class="effort-text-box effort-sternberg-text-box">
                    <h1>${STERNBERG_STIM}</h1>
                    </div>
                    <div class="effort-character" style="bottom: 16vh; left: 43%"></div>
                    <div class="effort-finish" style="left: 47%; transform: none"></div>
                    <div class="effort-enemy effort-standing effort-flipped" style="left: 57%"></div> 
                    `
            }
        }


        var sternberg_probe_trl = {
            on_start: function () {
                STERNBERG_DECIDED = false;
                STERNBERG_PROBE_DECIDED = false;
            },
            type: jsPsychHtmlKeyboardResponse,
            choices: [STERNBERG_NO, STERNBERG_YES],
            trial_duration: STERNBERG_PROBE_LAT * 1000,
            stimulus: function () {

                let this_array = STERNBERG_ARRAY[this_set][this_array_set];
                let rand_idx = Math.floor(Math.random() * this_array.length);

                STERNBERG_PROBE = this_array[rand_idx];
                return `
                        <div class="effort-headline">
                            <h1>Brain twister</h1>
                        </div>
    
                                <div class="effort-text-box effort-sternberg-text-box">
                                <h1>${STERNBERG_PROBE}</h1>
                                </div>
                                <div class="effort-character" style="bottom: 16vh; left: 43%"></div>
                                <div class="effort-finish" style="left: 47%; transform: none"></div>
                                <div class="effort-enemy effort-standing effort-flipped" style="left: 57%"></div>
                                
                                `
            },
            data: {
                task: 'sternberg probe',
            },
            on_finish: function (data) {
                if (STERNBERG_STIM.includes(STERNBERG_PROBE)) {
                    STERNBERG_MATCH = true;
                } else {
                    STERNBERG_MATCH = false;
                }
            }
        }

        var sternberg_choice = {
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: function () {
                return STERNBERG_LATENCY * 1000;
            },
            stimulus: function () {

                progress_fun(STERNBERG_LATENCY, false, true, false);

                return `
                            <div class="effort-headline">
                            <h1>Brain twister</h1>
                            </div>
    
                            <!--
                            <div class="effort-probe-caption">
                                <h1>${STERNBERG_PROBE}</h1>
                            </div>
                            -->
    
                            <div class="effort-progress-bar">
                            <div class="effort-progress-bar-fill effort-rect"></div>
                            </div>
    
                            <div class="effort-character" style="bottom: 16vh; left: 43%"></div>
                            <div class="effort-finish" style="left: 47%; transform: none"></div>
                            <div class="effort-enemy effort-standing effort-flipped" style="left: 57%"></div>
                                `
            }, // set a time limit
            choices: [STERNBERG_NO, STERNBERG_YES], // record response
            data: {
                task: 'sternberg choice',
            },
            on_finish: function (data) {

                let res = data.response; // check if the participant responded during the probe

                if (jsPsych.pluginAPI.compareKeys(res, STERNBERG_NO) || jsPsych.pluginAPI.compareKeys(res, STERNBERG_YES)) {
                    STERNBERG_DECIDED = true;
                }

            }
            // at the end of trial prevent the function from trying to access the elements - done
            // store the time that wasnt fully used and add it to the outcome or fixation cross
        }

        var if_sternberg_choice = {
            timeline: [sternberg_choice],
            conditional_function: function () {
                let res = jsPsych.data.get().last(1).values()[0].response; // check if the participant responded during the probe

                if (jsPsych.pluginAPI.compareKeys(res, STERNBERG_NO) || jsPsych.pluginAPI.compareKeys(res, STERNBERG_YES)) {
                    STERNBERG_DECIDED = true;
                    STERNBERG_PROBE_DECIDED = true;
                    return false;
                } else {
                    STERNBERG_DECIDED = false;
                    return true;
                }
            }
        }

        function sternbergRun(win = true) {
            let enemy = document.querySelector('.effort-enemy');
            let character = document.querySelector('.effort-character');
            let total_width = document.querySelector('body').offsetWidth;
            let winner;
            let current_pos;
            let finish_pos;
            let portion;

            if (enemy && character) {
                if (win == true) {
                    winner = character;
                    portion = 2;
                } else if (win == false) {
                    winner = enemy;
                    portion = -2;
                }

                current_pos = winner.offsetLeft; // left in px
                finish_pos = total_width / 2; // 50% in px

                let this_interval = setInterval(function () {

                    if ((win == true && current_pos >= finish_pos) || (win == false && current_pos <= finish_pos)) { // <= if win == false
                        clearInterval(this_interval);
                    } else {
                        current_pos += portion; // minus if win == false;
                        let new_pos = current_pos + 'px';
                        winner.style.left = new_pos;
                    }
                }, 1);
            }
        }

        var sternberg_outcome = {
            type: jsPsychHtmlKeyboardResponse,
            choices: ["NO_KEYS"],
            stimulus: function () {

                let out_caption;
                let choice_data;

                choice_data = jsPsych.data.get().last(1).values()[0];

                let res = choice_data.response;
                let coin_animation_caption = `<div class="effort-finish-container"><div class="effort-finish" style="left: 50%; translate: -50%; transform: none"></div></div>`;
                let minotaur_outcome = '';
                let minotaur_lost = 'effort-dying';
                let character_outcome = 'effort-hurt';
                let character_won = 'effort-win';

                if (res === null) {
                    out_caption = '<h1 class="effort-incorrect">no response</h1>';
                    TRL_SUCCESS = false;
                    STERNBERG_MISS = true;
                } else if (jsPsych.pluginAPI.compareKeys(res, STERNBERG_NO) && STERNBERG_MATCH == false) {
                    out_caption = '<h1 class="effort-correct">correct</h1>';
                    TRL_SUCCESS = true;

                } else if (jsPsych.pluginAPI.compareKeys(res, STERNBERG_NO) && STERNBERG_MATCH == true) {
                    out_caption = '<h1 class="effort-incorrect">incorrect</h1>';
                    TRL_SUCCESS = false;
                } else if (jsPsych.pluginAPI.compareKeys(res, STERNBERG_YES) && STERNBERG_MATCH == false) {
                    out_caption = '<h1 class="effort-incorrect">incorrect</h1>';
                    TRL_SUCCESS = false;
                } else if (jsPsych.pluginAPI.compareKeys(res, STERNBERG_YES) && STERNBERG_MATCH == true) {
                    out_caption = '<h1 class="effort-correct">correct</h1>';
                    TRL_SUCCESS = true;
                }

                if (WALKING_TRAINING == true && TRL_SUCCESS == true) {
                    TRAINING_REPEAT = false;
                } else if (WALKING_TRAINING == true && TRL_SUCCESS == false) {
                    TRAINING_REPEAT = true;
                }

                var enemy;

                setTimeout(function () {

                    enemy = document.querySelector('.effort-enemy');

                    if (enemy && TRL_SUCCESS) {
                        var enemy_image = 'tasks/effort/images/minotaur_dying.gif?' + Date.now();
                        //console.log('enemy defined');
                        enemy.className = 'effort-enemy effort-flipped effort-dying';
                        enemy.style.backgroundImage = `url(${enemy_image})`;

                        sternbergRun();
                        coinAnimation();
                    } else if (TRL_SUCCESS == false) {
                        sternbergRun(false);
                        coin_fade_out();
                    }

                }, 1);

                if (TRL_SUCCESS == true) {
                    coin_animation = coin_animation_caption;
                    minotaur_outcome = minotaur_lost;
                    character_outcome = character_won;
                }

                STERNBERG_RT = jsPsych.data.get().last(1).values()[0].rt; // rt

                if (STERNBERG_DECIDED == true && STERNBERG_PROBE_DECIDED == false) {
                    STERNBERG_RT += STERNBERG_PROBE_LAT * 1000; // if decided after the probe, then add the duration of the probe to the overall RT.
                }

                return `
                            <!--
                            <div class="effort-text-box effort-outcome-box">
                            ${out_caption}
                            </div>
                            -->
                            ${coin_animation_caption}
                            
                            <div class="effort-character ${character_outcome}" style="bottom: 16vh; left: 43%"></div>
                            <div class="effort-enemy effort-flipped ${minotaur_outcome}" style="left: 57%"></div>
                            
                            `
            },

            trial_duration: function () {

                let this_duration = Math.round(performance.now() - sternberg_start);

                STERNBERG_CROSS_TIME = 0;
                return COIN_DURATION;
            },
            on_finish: function (data) {

                if (TRAINING_COUNTER >= EFFORT_ROUNDS + NO_EFFORT_ROUNDS + 1) {
                    RUNNING_TRAINING = false;
                }

                if (RUNNING_TRAINING == true) {
                    TRL_LABEL = 'sternberg training outcome';
                } else if (TRAINING == true) {
                    TRL_LABEL = 'mental effort training outcome';
                }

                sternberg_end = performance.now(); // end of measuring the trial duration
                sternberg_duration = Math.round(sternberg_end - sternberg_start); // the trial duration from the initial fixation cross until this outcome

                let this_trial = {
                    trial_number: TRL_NUMBER, total_time: sternberg_duration, /*credit_history: CREDITS_HISTORY,*/ fullscreen_exit: FULLSCREEN_EXIT, total_duration: Math.round(performance.now() - START_TIME), total_credits: TOTAL_CREDITS, mental_credits: MENTAL_CREDITS, physical_credits: PHYSICAL_CREDITS, button_order: BUTTON_ORDER, timeout_warning: TIMEOUT_WARNINGS, training: STERNBERG_TRAINING,
                    choice_latency: CHOICE_RT, /*rt: Math.round(STERNBERG_RT),*/ chosen_task: TASK_TYPE[TASK_TYPE.length - 1], effort_type: EFFORT_TYPE, effort_level: EFFORT_LVL,
                    effort_credits: EFFORT_CREDITS, waiting_credits: WAITING_CREDITS, sternberg_load: STERNBERG_LOAD[EFFORT_LVL - 1], stimulus: STERNBERG_STIM, probe: STERNBERG_PROBE, match: STERNBERG_MATCH,
                    successful: TRL_SUCCESS, miss: STERNBERG_MISS,
                    task: TRL_LABEL
                };
                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
                FULLSCREEN_EXIT = 0;
            }
        }

        var sternberg_start = 0;
        var sternberg_end = 0;
        var sternberg_duration = 0;

        var sternberg = {
            on_timeline_start: function () {
                sternberg_start = performance.now();

                TRL_LABEL = 'mental effort outcome';
            },
            // 250 + 2500 + 750 + 400 + 750 + 400 + 400 + 1500
            timeline: [fix_cross_no_char, sternberg_task, fix_cross_no_walk, sternberg_probe_trl, if_sternberg_choice, sternberg_outcome],
            on_timeline_finish: function () {
                STOP_ANIMATION = true;
            }
        }

        // Physical effort
        var phys_listener; // add a listener for the physical effort condition
        let start_time;
        let end_time;
        var interval;
        var phys_start = 0;

        var phys_effort_var = {
            type: jsPsychHtmlKeyboardResponse,
            //choices: ["NO_KEYS"],
            choices: ["NO_KEYS"],
            on_start: function () {
                start_time = performance.now(); // start measuring the RT from the trial onset

                TRL_LABEL = 'physical effort outcome';
                STOP_WALKING = false;
                RACING = true;
                //alert(TRL_REQUIRED_PRESSES);
                //console.log('required presses: ', TRL_REQUIRED_PRESSES);
            },
            trial_duration: WAITING_TIME + COIN_DURATION,
            stimulus: function () {

                // Add event listeners and store references
                document.addEventListener('keydown', keydownHandler);
                document.addEventListener('keyup', keyupHandler);

                let display_credits = '';

                if (TRAINING == true) {
                    display_credits = 'display: none';
                }


                STOP_ANIMATION = false;

                var presses = 0;
                var character_class = 'character walking';
                var hint_textbox;

                setTimeout(() => {
                    hint_textbox = document.querySelector('.effort-key-hint');
                }, 1);


                setTimeout(() => {
                    if (TRL_NPRESSES == 0 && TITRATION_IN_PROGRESS == true) {
                        hint_textbox.style.opacity = '1';
                    }
                }, 1200);

                var key_down = function (info) {

                    if (jsPsych.pluginAPI.compareKeys(info.key, PHYS_HIT) && RIGHT_ARROW_DOWN == true && ANIMATION_SUCCESS != true) { // if the key is pressed and the progress bar is not at 100% yet
                        presses += 1;
                        BUTTON_PRESSED = true;
                        //console.log('a button was pressed now');
                        hint_textbox.style.opacity = '0';
                    } else if (jsPsych.pluginAPI.compareKeys(info.key, PHYS_HIT) && ANIMATION_SUCCESS != true) {
                        hint_textbox.style.opacity = '1';
                    }
                };

                phys_listener = jsPsych.pluginAPI.getKeyboardResponse({
                    callback_function: key_down,
                    valid_responses: [PHYS_HIT, 'ArrowRight'],
                    rt_method: 'performance',
                    persist: true
                });
                animation(background = true, finish_line = true, speed = 1);

                var enemyImageUrl = 'tasks/effort/images/minotaur_dying.gif?' + Date.now();

                interval = setInterval(function () {
                    var character_element = document.querySelector('.effort-character');
                    var enemy_element = document.querySelector('.effort-enemy')

                    if (character_element && enemy_element) {
                        if (ANIMATION_SUCCESS == true) {
                            character_element.className = 'effort-character effort-win';
                            enemy_element.style.backgroundImage = `url(${enemyImageUrl})`;
                            enemy_element.className = 'effort-enemy effort-dying';


                            coinAnimation();

                            setTimeout(function () {
                                if (RACING == true) {

                                    jsPsych.pluginAPI.cancelAllKeyboardResponses();
                                    jsPsych.finishTrial();
                                    //console.log('still in the timeout fun');
                                }
                            }, COIN_DURATION);
                            clearInterval(interval);

                        } else {
                            character_element.className = 'effort-character effort-walking';

                            if (STOP_WALKING == true) {
                                //console.log('animation not success');
                                character_element.className = 'effort-character effort-hurt';
                                enemy_element.className = 'effort-enemy effort-standing';
                            }
                        }
                    }

                }, 10);
                return `
                            <div class="effort-headline"><h1>Run</h1></div> 

                            <div class="effort-text-box effort-key-hint">
                                <p><b>Hint:</b><br> Hold right arrow while pressing the space bar in order to run.</p>
                            </div>
    
                            <div class="effort-character"></div>
                            <div class="effort-enemy"></div>   
    
                            <div class="effort-finish-container">
                                <div class="effort-finish"></div>
                            </div>
                            `;
            },
            on_finish: function (data) {

                STOP_WALKING = true;
                clearInterval(background_animation); // clear the interval and get outta here

                if (ANIMATION_SUCCESS == true) {
                    TRL_SUCCESS = true;
                    //  next_training = false;
                    if (WALKING_TRAINING == true) {
                        TRAINING_REPEAT = false;
                    }
                } else {
                    TRL_SUCCESS = false;
                    if (WALKING_TRAINING == true) {
                        TRAINING_REPEAT = true;
                    }

                    clearInterval(interval);
                }

                if (TITRATION_IN_PROGRESS == true) {
                    TITRATION_REPS++;

                    if (TRL_NPRESSES == 0) {
                        TITRATION_STRIKES++;
                    } else {
                        TITRATION_STRIKES = 0;
                    }
                }

                if (TRAINING_COUNTER >= EFFORT_ROUNDS + NO_EFFORT_ROUNDS) {
                    RUNNING_TRAINING = false;
                }

                if (TITRATION_IN_PROGRESS == true) {
                    TRL_LABEL = 'physical titration outcome';
                } else if (RUNNING_TRAINING == true) {
                    TRL_LABEL = 'running training outcome';
                } else if (TRAINING == true) {
                    TRL_LABEL = 'phys effort training outcome';
                }

                jsPsych.pluginAPI.cancelKeyboardResponse(phys_listener);
                jsPsych.pluginAPI.cancelAllKeyboardResponses();

                end_time = performance.now()
                let total_time = Math.round(end_time - start_time);

                let this_trial = {
                    trial_number: TRL_NUMBER, /*credit_history: CREDITS_HISTORY,*/ fullscreen_exit: FULLSCREEN_EXIT, total_duration: Math.round(performance.now() - START_TIME), total_credits: TOTAL_CREDITS, mental_credits: MENTAL_CREDITS, physical_credits: PHYSICAL_CREDITS, timeout_warning: TIMEOUT_WARNINGS, button_order: BUTTON_ORDER, training: TRAINING,
                    choice_latency: CHOICE_RT, total_time: total_time, n_presses: TRL_NPRESSES, chosen_task: TASK_TYPE[TASK_TYPE.length - 1],
                    effort_type: EFFORT_TYPE, effort_level: EFFORT_LVL, effort_credits: EFFORT_CREDITS, waiting_credits: WAITING_CREDITS, successful: TRL_SUCCESS,
                    task: TRL_LABEL, required_presses: TRL_REQUIRED_PRESSES[EFFORT_LVL - 1]
                };
                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);

                // restarting
                FULLSCREEN_EXIT = 0;
                STOP_ANIMATION = true;
                RACING = false;
            }
        }

        var blank_trial = {
            type: jsPsychHtmlKeyboardResponse,
            data: {
                task: 'blank trial'
            },
            stimulus: function () {
                return ``
            },
            trial_duration: 10
        }

        var phys_effort = {
            timeline: [phys_effort_var, blank_trial],
        }

        // Rest condition just waiting count sec.
        let rest_start;
        let rest_end;
        var bodyAnimation;

        var rest = {
            on_start: function () {
                rest_start = performance.now();
                start_time = performance.now();
                TRL_LABEL = 'physical rest';
                //clearInterval(background_animation);
            },
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: WAITING_TIME + COIN_DURATION, // after n secodns ends the trial
            choices: ["NO_KEYS"],
            stimulus: function () {
                var this_timer = performance.now();
                let display_credits = '';

                if (TRAINING == true) {
                    display_credits = 'display: none';
                }

                setTimeout(() => {
                    $(function () {
                        $('.effort-finish').animate({ left: '-=400px' }, WAITING_TIME, 'linear');
                        bodyAnimation = $('body').animate({ 'background-position-x': '-=400px' }, WAITING_TIME, 'linear')
                    });
                }, 10);

                setTimeout(function () {
                    coinAnimation();
                    let character_element = document.querySelector('.effort-character');

                    if (character_element) {
                        character_element.className = 'effort-character effort-win';
                    }

                }, (WAITING_TIME));

                // For the progress_fun to work correctly this structure is required
                return `
                            <div class="effort-headline"><h1>Walk</h1></div> 
                            <div class="effort-character effort-walking"></div>
    
                            <div class="effort-finish-container">
                                <div class="effort-finish"></div>
                            </div>
                            `;
            },
            on_finish: function (data) {
                STOP_WALKING = true;
                clearInterval(background_animation); // clear the interval and get outta here

                if (WALKING_TRAINING == true) {
                    TRL_LABEL = 'walking training';
                } else if (TRAINING == true) {
                    TRL_LABEL = 'phys effort training'
                }

                TRL_SUCCESS = true;
                rest_end = performance.now();
                let rest_duration = Math.round(rest_end - rest_start);

                let this_trial = {
                    trial_number: TRL_NUMBER, total_time: rest_duration, /*credit_history: CREDITS_HISTORY,*/ fullscreen_exit: FULLSCREEN_EXIT, total_duration: Math.round(performance.now() - START_TIME),
                    total_credits: TOTAL_CREDITS, mental_credits: MENTAL_CREDITS,
                    physical_credits: PHYSICAL_CREDITS, button_order: BUTTON_ORDER,
                    timeout_warning: TIMEOUT_WARNINGS, effort_level: EFFORT_LVL, effort_credits: EFFORT_CREDITS, effort_type: EFFORT_TYPE,
                    training: TRAINING, choice_latency: CHOICE_RT, chosen_task: TASK_TYPE[TASK_TYPE.length - 1],
                    waiting_credits: WAITING_CREDITS,
                    task: TRL_LABEL
                };
                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);

                FULLSCREEN_EXIT = 0;

                if (TRAINING_COUNTER >= NO_EFFORT_ROUNDS) {
                    WALKING_TRAINING = false;
                }
                temp_end = performance.now();
            }
        };

        var instructions_phys_node_4b = {
            type: jsPsychInstructions,
            pages: [
                instructions_4b.stimulus, instructions_4c.stimulus, instructions_4d.stimulus, instructions_4e.stimulus
            ],
            show_clickable_nav: true,
            on_finish: function (data) {
                let instructions_4b_rt = jsPsych.data.get().last(1).values()[0].view_history[0].viewing_time;
                let instructions_4c_rt = jsPsych.data.get().last(1).values()[0].view_history[1].viewing_time;
                let instructions_4d_rt = jsPsych.data.get().last(1).values()[0].view_history[2].viewing_time;
                let instructions_4e_rt = jsPsych.data.get().last(1).values()[0].view_history[3].viewing_time;

                this_rt = [instructions_4b_rt, instructions_4c_rt, instructions_4d_rt, instructions_4e_rt];

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var if_instructions_4b = {
            timeline: [instructions_phys_node_4b],
            conditional_function: function () {
                if (TRAINING_COUNTER == EFFORT_ROUNDS + NO_EFFORT_ROUNDS + 1) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        let m_rest_start;
        let m_rest_end;

        var mental_rest = {
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: WAITING_TIME + COIN_DURATION,
            choices: "NO_KEYS",
            on_start: function () {
                m_rest_start = performance.now();

                TRL_LABEL = 'mental rest';
            },
            stimulus: function () {
                let display_credits = '';

                if (TRAINING == true) {
                    display_credits = 'display: none';
                }

                setTimeout(function () {

                    let character_element = document.querySelector('.effort-character');
                    let this_coin = document.querySelector('.effort-finish-container');
                    this_coin.style.display = 'block';

                    if (character_element) {
                        character_element.className = 'effort-character effort-win';
                    }

                    coinAnimation();

                }, (WAITING_TIME) - 600);

                return `
    
                    <div class="effort-headline"><h1>Nap</h1></div> 
                    <div class="effort-character effort-resting"></div>
                    <div class="effort-finish-container" style="display: none; left: 50%; translate: -50%">
                    <div class="effort-finish" style="transform: none"></div>
                    </div>
                    `
            },
            on_finish: function (data) {
                if (WALKING_TRAINING == true) {
                    TRL_LABEL = 'nap training';
                } else if (TRAINING == true) {
                    TRL_LABEL = 'mental effort training';
                }

                TRL_SUCCESS = true;
                m_rest_end = performance.now();
                let m_rest_duration = Math.round(m_rest_end - m_rest_start);

                let this_trial = {
                    trial_number: TRL_NUMBER, total_time: m_rest_duration, /*credit_history: CREDITS_HISTORY,*/ fullscreen_exit: FULLSCREEN_EXIT, total_duration: Math.round(performance.now() - START_TIME), total_credits: TOTAL_CREDITS, mental_credits: MENTAL_CREDITS, physical_credits: PHYSICAL_CREDITS,
                    button_order: BUTTON_ORDER, timeout_warning: TIMEOUT_WARNINGS,
                    effort_level: EFFORT_LVL, effort_credits: EFFORT_CREDITS, effort_type: EFFORT_TYPE, training: TRAINING,
                    choice_latency: CHOICE_RT, chosen_task: TASK_TYPE[TASK_TYPE.length - 1], waiting_credits: WAITING_CREDITS,
                    task: TRL_LABEL
                };
                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
                FULLSCREEN_EXIT = 0;

                if (TRAINING_COUNTER >= NO_EFFORT_ROUNDS) {
                    WALKING_TRAINING = false;
                }

            }
        }

        // INSTRUCTIONS BLOCK

        // Custom function for the progress bar, it takes ITER which is the frequency of the progress bar updating
        // The
        function progress_fun(time_interval = WAITING_TIME, countdown_caption = true, progr_bar = true, margin = true) {
            var total_time;
            var count;

            total_time = count = time_interval;

            let progress_fill; // get and set the progress bar width
            var perc;

            var countdown = setInterval(function () { // javascript function
                time_left = Math.round(count - (ITER / 1000)); // time left ms => sec
                count -= ITER / 1000; // decrease it by the ITER in sec
                perc = (1 - (count / total_time)) * 100; // get the percentage of the waiting time
                //fconsole.log(time_left);
                if (count > 0 && STERNBERG_DECIDED == false) { // if there is still something left from the progress bar AND the trial is still on
                    if (countdown_caption == true) {
                        document.querySelector('#countdown').innerHTML = time_left; // updating html element with id countdown
                    }
                    if (progr_bar == true) {
                        progress_fill = document.querySelector('.effort-progress-bar-fill'); // update the progress bar graphically

                        if (margin == true) {
                            progress_fill.style.marginLeft = `${perc}%`; // set the percentage of margin-left 0-100%
                        } else {
                            progress_fill.style.width = `${perc}%`; // set the percentage of width 0-100%
                        }

                    }
                } else {
                    clearInterval(countdown);
                    return true;

                }
            }, 10);
        }

        // Screen showing the number of credits earned
        var out_start; // gap after the effort trial to make it equal with waiting condition
        var trl_outcome = {
            type: jsPsychHtmlKeyboardResponse,
            choices: ["NO_KEYS"],
            trial_duration: OUTCOME_DURATION,
            on_start: function () {
                out_start = performance.now();
            },
            stimulus: function () {
                //STOP_ANIMATION = false;

                let trl_credits; // how many credits earned this trial
                let caption_style; // change the color of the caption based on the outcome
                let display_credits = '';
                let this_credits;

                if (TRL_SUCCESS == true) { // if the task was successfuly completed
                    caption_style = 'correct';
                    if (TASK_TYPE[TASK_TYPE.length - 1] == 'effort') { // if the trial was the effort task then only add the effort credits 
                        //this_gap = NBACK_POSTGAP;
                        //console.log(this_gap);
                        trl_credits = EFFORT_CREDITS

                    } else if (TASK_TYPE[TASK_TYPE.length - 1] == 'rest') { // if the trial was rest, add only waiting credits
                        this_gap = 0;
                        trl_credits = WAITING_CREDITS
                    }

                } else if (TRL_SUCCESS == false) { // if the task was NOT successfuly completed
                    caption_style = 'incorrect';
                    trl_credits = 0; // add zero credits = no winning
                }

                if (TRAINING == true) {
                    display_credits = 'display: none';
                } else if (TRAINING == false) {
                    TOTAL_CREDITS += trl_credits; // add it to the overall credits if it is not the training

                    if (EFFORT_TYPE == 'physical') {
                        PHYSICAL_CREDITS += trl_credits;
                        this_credits = PHYSICAL_CREDITS;
                    } else if (EFFORT_TYPE == 'mental') {
                        MENTAL_CREDITS += trl_credits;
                        this_credits = MENTAL_CREDITS;
                    }
                }

                CREDITS_HISTORY.push(trl_credits); // add the outcome to the credit history

                let credit_tag; // either credit or credits based on the singular or plural, respectively
                if (trl_credits > 1 || trl_credits == 0) {
                    credit_tag = 'coins'
                } else {
                    credit_tag = 'coin'
                }

                //animation();

                return `
    
                    <div class="effort-text-box effort-outcome-box">
                    <h2 class="effort-${caption_style}">+${trl_credits}</h2>
                    <div class="effort-coins-icon"></div>
                    </div>
                    <div class="effort-character"></div>
                    
                    `
            },
            data: {
                task: 'trial outcome'
            },
            on_finish: function (data) {
                let out_end = performance.now();
                //console.log('the outcome duration was: ', Math.round(out_end - out_start), ', the expected duration was: ', trl_outcome.trial_duration);
            }
        };



        // This function returns a timeline and true if it should be pushed to timeline or false if skipped
        // So this way I am passing both rest and nback conditions and one of them is always true and the other false
        function createConditionalTrial(key, trial) {
            return {
                timeline: [trial],
                conditional_function: function () { // this is a jspsych function
                    var data = jsPsych.data.get().last(2).values()[0]; // if there are any other screens inserted before this one needs to change the last(n)
                    let this_key;

                    if (EFFORT_TYPE == 'physical' && trial == mental_rest) {
                        return false
                    } else if (EFFORT_TYPE == 'mental' && trial == rest) {
                        return false
                    }

                    if (key == 'effort') {
                        this_key = EFFORT_KEY;
                    } else if (key == 'rest') {
                        this_key = NO_EFFORT_KEY;
                    }

                    // returns t or f if the key corrensponds to the condition in the trial argument passed to this function

                    let output = jsPsych.pluginAPI.compareKeys(data.response, this_key);

                    if (output == true || output == false) {
                        return output;
                    } else {
                        return false;
                    }

                }
            };
        }

        // run both and one of them returns true and add rest or effort to the timeline
        var effort_node_ph = {
            timeline: [phys_effort],
            conditional_function: function () {
                if (EFFORT_TYPE == 'physical') {
                    return true
                } else {
                    return false
                }
            }
        }

        var sternberg_node = {
            timeline: [sternberg],
            conditional_function: function () {
                if (EFFORT_TYPE == 'mental' || STERNBERG_TRAINING == true) {
                    return true
                } else {
                    return false
                }
            }
        }

        var sternberg_instruct = {
            type: jsPsychHtmlKeyboardResponse,
            data: {
                task: 'sternberg fail'
            },
            stimulus: function () {
                STOP_ANIMATION = false;
                //animation();

                return `
                    <div class="effort-text-box">
                    <p>Oh no, that was not right!</p>
                    <p>Remember, to press <b>a</b> (affirmative) key if the letter was part of the string or <b>n</b> (no) if the letter was NOT.</p>
                    
                    <p><i>Press <b>c</b> to try again.</i></p>
                    </div>
                    <div class="effort-character"></div>
                    ` },
            on_finish: function (data) {
                STOP_ANIMATION = true;
            }
        }

        var if_sternberg_instruct = {
            timeline: [sternberg_instruct],
            conditional_function: function () {
                if (TRAINING_COUNTER == 0) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var if_mental_effort = createConditionalTrial('effort', sternberg_node);
        var if_physical_effort = createConditionalTrial('effort', effort_node_ph);
        var if_rest = createConditionalTrial('rest', rest);
        var if_mental_rest = createConditionalTrial('rest', mental_rest);

        // just add the both if_conditions to the timeline, run them both
        var branching = {
            on_timeline_start: function () {
                // reset the trial variables
                TRL_SUCCESS = false;
                ANIMATION_SUCCESS = false;
                STERNBERG_MISS = false;
                STERNBERG_DECIDED = false;
                TRL_NPRESSES = 0;

            },
            timeline: [/*if_mental_rest, if_mental_effort, */ if_rest, if_physical_effort],
        }

        // This is the main node which contains the repeating screens all over until the n of repetitions
        var loop_sternberg_node = {
            conditional_function: function () {
                if (TRAINING_REPEAT == true || FAILED_COMP_CHECK == true) {
                    return false;
                } else {
                    return true;
                }
            },
            on_timeline_start: function () {
                STERNBERG_MISS = false;
                clearInterval(background_animation);

            },
            timeline: [if_sternberg_instruct, if_instructions_24b, offer, choice, branching, trl_outcome, /*fix_cross*/ fix_cross_extension],
            loop_function: function () {
                //TRL_NUMBER--;
                TRAINING_COUNTER++;

                if (TRAINING_COUNTER <= TRAINING_ROUNDS) {
                    return true;
                } else {
                    TRAINING = false;
                    return false;
                }
            }
        }

        var loop_instructions = {
            conditional_function: function () {
                if (TRAINING_REPEAT == true || FAILED_COMP_CHECK == true || day > 1) {
                    return false;
                } else {
                    return true;
                }
            },
            timeline: [if_instructions_4b, offer, choice, branching, trl_outcome, /*fix_cross*/ fix_cross_extension],
            loop_function: function (data) {
                //console.log('trl number: ', TRL_NUMBER);
                //TRL_NUMBER --;
                TRAINING_COUNTER++;

                if (TRL_SUCCESS == true) {

                    if (TRAINING_COUNTER <= TRAINING_ROUNDS) {
                        //console.log('the training was successful but not enough practice rounds: ', TRAINING_COUNTER);
                        ANIMATION_SUCCESS = false;
                        TRL_NPRESSES = 0;
                        return true;
                    } else {
                        //console.log('the training was successful , congrats you made N successful rounds');
                        TRAINING = false;
                        return false;
                    }
                } else {
                    TRL_NPRESSES = 0;
                    //TRAINING_COUNTER = 0;
                    //console.log('the training has failed.');
                    return true;
                }
            }
        }

        function countdown() {
            setTimeout(() => {
                var countdownElement = document.getElementById('effort-countdown');
                var numberElement = countdownElement.querySelector('.effort-number');
                var count = 3;

                function updateCountdown() {
                    if (count >= 1) {
                        numberElement.innerHTML = count;
                        count--;
                    } else {
                        // If the countdown is finished, you can clear the interval.
                        clearInterval(interval);
                    }
                }

                // Initially set the countdown to 3.
                updateCountdown();

                // Set up an interval to update the countdown every second (1000 milliseconds).
                var interval = setInterval(updateCountdown, 1000);
            }, 1);
        }

        var countdown_try_harder = {
            type: jsPsychHtmlKeyboardResponse,
            choices: ['NO_KEYS'],
            trial_duration: 3000,
            data: {
                task: '3..2..1'
            },
            stimulus: function () {

                countdown();

                return `
                        <div class="effort-text-box effort-outcome-box">
                            <div class="effort-countdown" id="effort-countdown">
                                <div class="effort-number effort-correct">3</div>
                            </div>
                        </div>
                        `
            }
        }

        var try_harder = {
            type: jsPsychHtmlKeyboardResponse,
            choices: ['NO_KEYS'],
            trial_duration: 1000,
            data: {
                task: 'try harder'
            },
            stimulus: function () {
                let one_more_time = '';

                /*                 if (TITRATION_REPS == TITRATION_REPS_NUM - 1) {
                                   one_more_time = 'One more time!';
                                } */

                let this_caption = `<h1 class="effort-incorrect">Try harder! ${one_more_time}</h1>`
                if (ANIMATION_SUCCESS == true) {
                    this_caption = `<h1 class="effort-correct">Great job! Now try harder!</h1>`
                } else if (TITRATION_REPS > TITRATION_REPS_NUM && ANIMATION_SUCCESS == false && TITRATION_FAIL >= 1) {
                    this_caption = `<h1 class="effort-correct">Great job!</h1>`
                }

                return `
                        <div class="effort-headline"><h1>Run</h1></div>
                        <div class="effort-text-box effort-outcome-box">
                            ${this_caption}
                        </div>
                        `
            }
        }

        var if_try_harder = {
            conditional_function: function () {
                if (TITRATION_STRIKES >= 2/* || (TITRATION_REPS == TITRATION_REPS_NUM && ANIMATION_SUCCESS == false)*/) {
                    return false;
                } else {
                    return true;
                }
            },
            timeline: [try_harder]
        }

        var TITRATION_FAIL = 0;
        var phys_titration = {
            on_timeline_start: function () {
                TITRATION_IN_PROGRESS = true;
                //console.log('TITRATION_REPS:',TITRATION_REPS,'TITRATION_FAIL:',TITRATION_FAIL);
                //TRL_LABEL = 'physical titration';
            },
            timeline: [countdown_try_harder, phys_effort, if_try_harder],
            loop_function: function () {
                if (TITRATION_STRIKES < 2 && TITRATION_REPS <= TITRATION_REPS_NUM || (TITRATION_REPS >= TITRATION_REPS_NUM && TITRATION_FAIL < 2)) {
                    ANIMATION_SUCCESS = false;
                   
                    return true;
                } else if (TITRATION_STRIKES >= 2) {
                    TRAINING_REPEAT = true;
                    TRL_REQUIRED_PRESSES = [TRL_DEFAULT_TITR_PRESSES];
                    return false;
                } else {
                    TRAINING_REPEAT = false;
                    return false;
                }
            },
            on_timeline_finish: function () {

                NPRESSES_HISTORY.push(TRL_NPRESSES);

                if (ANIMATION_SUCCESS == true) {
                    TRL_REQUIRED_PRESSES[0] += TRL_TITR_INCREASE;
                    TITRATION_FAIL = 0;
                } else {
                    TITRATION_FAIL ++;
                }

                if (TITRATION_REPS > TITRATION_REPS_NUM && TITRATION_FAIL >= 2) {

                    // Find the smallest number
                    let smallestNumber = Math.min(...NPRESSES_HISTORY);

                    // Find the index of the smallest number
                    let index = NPRESSES_HISTORY.indexOf(smallestNumber);


                    // Remove the smallest number from the array
                    if (index !== -1) {
                        NPRESSES_EXCLUDED = NPRESSES_HISTORY[index];
                        NPRESSES_HISTORY.splice(index, 1);
                    }


                    INDIVIDUAL_MAX = Math.max(...NPRESSES_HISTORY);

                    TRL_REQUIRED_PRESSES = [];
                    if (INDIVIDUAL_MAX < 5) {
                        INDIVIDUAL_MAX = 5;
                        //TRL_REQUIRED_PRESSES = [1, 2, 3, 4, 5];
                        TRL_REQUIRED_PRESSES = [5, 8, 15, 18, 22];
                    } else {
                        TITRATION_PERC.forEach(percentage => {
                            TRL_REQUIRED_PRESSES.push(Math.round(percentage * INDIVIDUAL_MAX));
                        });

                    }

                    //console.log('ind max: ', INDIVIDUAL_MAX, 'required presses: ', TRL_REQUIRED_PRESSES);


                    TITRATION_IN_PROGRESS = false;

                    //console.log('individual max is: ', INDIVIDUAL_MAX, 'trl required presses: ', TRL_REQUIRED_PRESSES);


                    let this_trial = {
                        presses_history: NPRESSES_HISTORY,
                        discarded_presses_history: NPRESSES_HISTORY_DISCARDED,
                        excluded_presses: NPRESSES_EXCLUDED,
                        titration_perc: TITRATION_PERC,
                        repetitions: TITRATION_REPS_NUM,
                        individual_max: INDIVIDUAL_MAX,
                        task: TRL_LABEL
                    }

                    TRIALS.push(this_trial);

                }
            }
        }

        var if_physical_titration = {
            timeline: [phys_titration],
            conditional_function: function () {
                if (TRAINING_REPEAT == false && FAILED_COMP_CHECK == false) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var if_training_rest = {
            timeline: [rest],
            conditional_function: function () {
                if (TRAINING_REPEAT == false && FAILED_COMP_CHECK == false) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var phys_instructions = {
            on_timeline_start: function () {
                TRL_LABEL = 'physical training';
            },

            timeline: [instructions_phys_node_012, if_training_rest, instructions_phys_node_2b, if_physical_titration,/* phys_effort,*/ if_instructions_2c, if_instructions_34, loop_instructions, if_quiz_pre_physical, if_instructions_5b, if_instructions_5],
            conditional_function: function () {
                if (((CONDITION_INIT == 1 && TRL_NUMBER == 0) || (CONDITION_INIT == 2 && TRL_NUMBER == TRL_SWITCH)) && SKIP_TRAINING == false) {
                    return true;
                } else {
                    return false;
                }
            },
            loop_function: function () {
                if (TRAINING_REPEAT == true) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var if_training_mental_rest = {
            timeline: [mental_rest],
            conditional_function: function () {
                if (TRAINING_REPEAT == false && FAILED_COMP_CHECK == false) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var if_training_sternberg = {
            timeline: [sternberg],
            conditional_function: function () {
                if (TRAINING_REPEAT == false && FAILED_COMP_CHECK == false) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var sternberg_instructions = {
            on_timeline_start: function () {
                STERNBERG_TRAINING = true;
                STERNBERG_MISS = false;
                EFFORT_LVL = 1;

                TRL_LABEL = 'mental training';
            },
            timeline: [instructions_mental_node_202122, if_training_mental_rest, instructions_mental_node_22b, if_training_sternberg, if_instructions_22c,
                if_instructions_2324, loop_sternberg_node, if_quiz_pre_mental, if_instructions_25b, if_instructions_25],
            conditional_function: function () {
                if (((CONDITION_INIT == 2 && TRL_NUMBER == 0) || (CONDITION_INIT == 1 && TRL_NUMBER == TRL_SWITCH)) && SKIP_TRAINING == false) {
                    return true;
                } else {
                    return false;
                }
            },
            loop_function: function () {
                if (TRAINING_REPEAT == true) {
                    return true;
                } else {
                    return false;
                }
            },
            on_timeline_finish: function () {
                STERNBERG_TRAINING = false;
            }
        }

        var earning = {
            type: jsPsychHtmlKeyboardResponse,
            data: {
                task: 'earning'
            },
            stimulus: function () {
                let this_credits = 0;

                if (EFFORT_TYPE == 'physical') {
                    this_credits = PHYSICAL_CREDITS;
                } else if (EFFORT_TYPE == 'mental') {
                    this_credits = MENTAL_CREDITS;
                }

                return `
                        <div class="effort-text-box">
                            <h2>Well done!</h2>
                            <p>This is the end of this part of the game</p>
                            <p>In this part of the game, <b>you earned ${this_credits} coins</b>.</p>
                            <p><i>Press any key to continue.</i></p>
                        </div>
                        `
            }
        }

        var take_break = {
            on_start: function () {
                TRL_LABEL = 'break';
            },
            choices: [' '],
            type: jsPsychHtmlKeyboardResponse,
            trial_duration: 60000, // 1 min. break max
            data: {
                task: 'break'
            },
            stimulus: function () {
                return `
                        <div class="effort-text-box">
                            <h2>You can now take a one-minute break if you want!</h2>
                            <p>After one minute, the second part of the game will start automatically. 
                                <br>You can start the second part earlier if you want. </p>
                            <p>Please do not close this tab or exit full-screen mode.</p>
                            <p><i>Whenever you are ready to continue, press space bar.</i></p>
                        </div>
                        `
            },
            on_finish: function (data) {
                let this_rt = jsPsych.data.get().last(1).values()[0].rt;

                let this_trial = {
                    task: TRL_LABEL,
                    //rt: this_rt
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        }

        var if_earning = {
            timeline: [earning],
            conditional_function: function () {
                if (TRL_NUMBER == TRL_SWITCH || TRL_NUMBER == TRL_TOTAL) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        // Debriefing questionnaire
       /*  var DEBRIEF_00 = {
            on_start: function () {
                DEBRIEFING_IN_PROGRESS = true;

                var body = document.body;
                savedBackgroundImage = getComputedStyle(body).backgroundImage;
                body.style.backgroundImage = 'none';
                document.body.style.setProperty('overflow', 'auto', 'important');
            },
            type: jsPsychSurveyMultiChoice,
            preamble: '<h1>Debriefing</h1><p>Please answer the questions below.</p><p><font color="#540000">Your answers do not affect your payment or bonus.</font></p>',
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
            on_finish: function (data) {
                var body = document.body;
                body.style.backgroundImage = savedBackgroundImage;
                body.style.overflow = 'none';
                DEBRIEFING_IN_PROGRESS = false;
            },
            data: {
                task: function () {
                    if (CONDITION_INIT == 1) {
                        return 'debrief_phys';
                    } else {
                        return 'debrief_mental';
                    }

                }
            }
        }; */

        var if_take_break = {
            timeline: [/*DEBRIEF_00, */take_break],
            conditional_function: function () {
                if (TRL_NUMBER == TRL_SWITCH) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        if_catch_trial = {
            timeline: [catch_trial],
            conditional_function: function () {
                if (TRL_NUMBER == Math.round(TRL_SWITCH / 2) || TRL_NUMBER == TRL_SWITCH || TRL_NUMBER == Math.round(1.5 * TRL_SWITCH) || TRL_NUMBER == TRL_TOTAL) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var s_end;
        var node = {
            on_timeline_start: function () {

                if (TRL_NUMBER == 0 /*|| TRL_NUMBER == TRL_SWITCH*/) {
                    randConditions();
                }

                if (SKIP_TRAINING == true) {
                    TRAINING = false;
                    RUNNING_TRAINING = false;
                    WALKING_TRAINING = false;
                    TRL_REQUIRED_PRESSES = [5, 8, 15, 18, 22];
                }
            },
            timeline: [phys_instructions, /* sternberg_instructions, */ offer, choice, branching, trl_outcome, fix_cross_extension, if_catch_trial, /*if_earning,*/ if_take_break],
            repetitions: TRL_TOTAL,
            on_timeline_finish: function () {
                s_end = performance.now();
                //TRL_NUMBER++;
                //console.log('the whole trial sequence is like: ', Math.round(s_end - s_start));
            }
        };
        timeline.push(node);// Here we finally push it


        ///////////////////////////////////////////////////////////////////////////////////////////////////////
        //Create final trial to display bonus earned so far in all tasks completed
        let final_html;

        var end_trial = {
            stimulus: '',
            type: jsPsychHtmlKeyboardResponse,
            data: {
                task: 'end trial'
            },
            on_start: function (trial, data) {

                //Update global variables to be passed on to next task
                taskNumber++;
                
                //bonus_effort += Math.ceil((TOTAL_CREDITS / 150) * 100) / 100;//round up to 2 decimals
                // 2 + 4 + 6 + 8 + 10 = 30 (per 1 level of effort) * 5 (levels of effort) * 3 (iterations of each combinations) = 450
                bonus_effort += Math.ceil(((TOTAL_CREDITS / 450) * bonus_per_task) * 100) / 100;//round up to 2 decimals
                performanceBonus += bonus_effort;

                final_html = `<div class="effort-text-box">
                <h2>Great job!</h2>You earned a performance bonus of ${bonus_effort}&pound out of ${bonus_per_task}&pound in this game.
                <br><br>You have earned a total performance bonus of ${performanceBonus}&pound.
                <br><br>Press the <b>space bar</b> to continue.
                </div>`


                // Report total money earned to participant
                trial.stimulus = final_html;

                // save the data
                END_TIME = performance.now();
                TOTAL_DURATION = END_TIME - START_TIME;

                //save bonus to data
                jsPsych.data.addProperties({
                    bonus_effort: bonus_effort
                });

            },
            choices: " ",
            on_finish: function (data) {

                let this_trial = {
                    total_credits: TOTAL_CREDITS,
                    credit_history: CREDITS_HISTORY, // only add it here
                    mental_credits: MENTAL_CREDITS,
                    physical_credits: PHYSICAL_CREDITS,
                    total_duration: Math.round(TOTAL_DURATION),
                    fullscreen_exit: FULLSCREEN_EXIT,
                    failed_quiz_physical: FAILED_PHYS_COMP_COUNTER,
                    failed_quiz_mental: FAILED_MENTAL_COMP_COUNTER,
                    answers_quiz_physical: PHYS_COMP_ANSWERS,
                    answers_quiz_mental: MENTAL_COMP_ANSWERS,
                }

                TRIALS.push(this_trial);

                // Assign the same data structure to the 'data' object
                copyToData(data, this_trial);
            }
        };
        timeline.push(end_trial);
        ///////////////////////////////////////////////////////////////////////////////////////////////////////

        var DEBRIEF_00 = {
            on_start: function () {
                DEBRIEFING_IN_PROGRESS = true;

                var body = document.body;
                savedBackgroundImage = getComputedStyle(body).backgroundImage;
                body.style.backgroundImage = 'none';
                document.body.style.setProperty('overflow', 'auto', 'important');
            },
            type: jsPsychSurveyText,
            preamble: '<h1>Debriefing</h1><br><p>Please answer the questions below.</p><p><font color="#540000">Your answers do not affect your payment or bonus.</font></p>',
            button_label: 'Submit',
            questions: [
                {
                    prompt: "Have you had any strategy in the game? If so, which one?",
                    name: 'strategy'
                },
                {
                    prompt: "Have you had any threshold of <b>effort</b> which you never accepted regardless of the reward? If so, which one?",
                    name: 'threshold_effort'
                },
                {
                    prompt: "Have you had any threshold of <b>reward</b> which you never accepted regardless of the effort? If so, which one?",
                    name: 'threshold_reward'
                },
                {
                    prompt: "What other decision rule did you have and why did you choose it?",
                    name: 'other_rule'
                },
            ],
            on_finish: function (data) {
                /*                var body = document.body;
                               body.style.backgroundImage = savedBackgroundImage;
                               body.style.overflow = 'none';
                               DEBRIEFING_IN_PROGRESS = false;
               
                               document.removeEventListener('keydown', keydownHandler);
                               document.removeEventListener('keyup', keyupHandler);
                               removeStyles(); */

            },
            data: {
                //parsing: 'end_effort',
                task: 'debrief_phys_1'
            }
        };
        timeline.push(DEBRIEF_00);

        var DEBRIEF_01 = {
            on_start: function () {
                DEBRIEFING_IN_PROGRESS = true;

                var body = document.body;
                savedBackgroundImage = getComputedStyle(body).backgroundImage;
                body.style.backgroundImage = 'none';
                document.body.style.setProperty('overflow', 'auto', 'important');
            },
            type: jsPsychSurveyMultiChoice,
            preamble: '<h1>Debriefing</h1><p>Please answer the questions below.</p><p><font color="#540000">Your answers do not affect your payment or bonus.</font></p>',
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
            on_finish: function (data) {
                var body = document.body;
                body.style.backgroundImage = savedBackgroundImage;
                body.style.overflow = 'none';
                DEBRIEFING_IN_PROGRESS = false;

                document.removeEventListener('keydown', keydownHandler);
                document.removeEventListener('keyup', keyupHandler);
                removeStyles();

            },
            data: {
                parsing: 'end_effort',
                /*                 task: function () {
                                    if (CONDITION_INIT == 1) {
                                        return 'debrief_mental';
                                    } else {
                                        return 'debrief_phys';
                                    }
                
                                } */
                task: 'debrief_phys'
            }
        };
        timeline.push(DEBRIEF_01);

        return timeline;
    }

    //timeline.push(sendData);
    let effort_timeline = main();
    return effort_timeline;

}