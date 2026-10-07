
// For the "break" trial (dynamic depending on RT)
// Initialize HTML.
var new_html = '';

// Insert CSS (window animation).
new_html += `<style>
      body {
        height: 100vh;
        max-height: 100vh;
        overflow: hidden;
        position: fixed;
        background: -webkit-gradient(linear, left bottom, left top, from(#808080), color-stop(50%, #606060), color-stop(50%, rgba(28, 25, 23, 0.5)), to(rgba(179, 230, 230, 0.5)));
        background: linear-gradient(0deg, #808080 0%, #606060 50%, #A0A0A0 50%, #D3D3D3 100%);
      }
      .jspsych-content-wrapper {
        overflow: hidden;
      }
     <!-- @-webkit-keyframes pavlovian {
        0%    {border-bottom-color: rgba(0, 0, 0, 0);}
        90%   {border-bottom-color: rgba(0, 0, 0, 0);}
        100%  {border-bottom-color: rgba(0, 0, 0, 0);}
      }
      @keyframes pavlovian {
        0%    {border-bottom-color: rgba(0, 0, 0, 0);}
        90%   {border-bottom-color: rgba(0, 0, 0, 0);}
        100%  {border-bottom-color: rgba(0, 0, 0, 0);}
      }

      -->
      </style>`;

// Add robot factor wrapper.
new_html += '<div class="gng-factory-wrap">';

// Add factory machine parts (back).
new_html += '<div class="gng-machine-back"></div>';
new_html += '<div class="gng-still-conveyor"></div>';
new_html += '<div class="gng-shadows"></div>';

// Add robot 1 (active).
/*       new_html += '<div class="robot" status="active">';
      new_html += '<div class="antenna"></div>';
      new_html += '<div class="head"></div>';
      new_html += '<div class="torso">';
      new_html += '<div class="left"></div>';
      new_html += '<div class="right"></div>';
      //new_html += `<div class="rune" set="${trial.rune_set}" id="rune"><p>${trial.robot_rune}</p></div></div>`;
      new_html += '<div class="foot"></div></div>'; */

// Add robot 2 (hidden).
new_html += '<div class="gng-still-robot">';
new_html += '<div class="gng-antenna"></div>';
new_html += '<div class="gng-head"></div>';
new_html += '<div class="gng-torso">';
new_html += '<div class="gng-left"></div>';
new_html += '<div class="gng-right"></div>';
new_html += `<div class="gng-rune"></div></div>`;
new_html += '<div class="gng-foot"></div></div>';

// Add factory window.
//new_html += `<div class="scanner-light" style="border-bottom-color: ${trial.scanner_color}"></div>`;

// Add factory machine parts (front).
new_html += '<div class="gng-machine-front">';
new_html += '<div class="gng-score-container">';
new_html += '<div class="gng-score" id="outcome"></div>';
new_html += '</div></div>';
new_html += '<div class="gng-machine-top"></div>';

// Close wrapper.
new_html += '</div>';

// Display HTML
//display_element.innerHTML = new_html;


//------------------------------------//
// Define experiment parameters.
//------------------------------------//

// Define trial structure.
runsheets = jsPsych.randomization.shuffle(runsheets)

console.log('runsheets: ', runsheets);

// Define rune sets.
const rune_sets = ['elianto', 'bacs1', 'bacs2'];
const rune_prob = [0.33, 0.33, 0.33];

// Define aesthetics.
if (Math.random() < 1) {
  var instr_color_win = 'blue';
  var scanner_color_win = '#3366ff99';
  var outcome_color_win = '#1a3ea7';
  var instr_color_lose = 'red';
  var scanner_color_lose = '#f73b6a7A';
  var outcome_color_lose = '#930a25';
} else {
  var instr_color_win = 'red';
  var scanner_color_win = '#f73b6a7A';
  var outcome_color_win = '#930a25';
  var instr_color_lose = 'blue';
  var scanner_color_lose = '#3366ff99';
  var outcome_color_lose = '#1a3ea7';
}

// Define go key.
const key_go = " ";

// Define timings.
const trial_duration = 1300;         // Duration of trial (response phase)
const feedback_duration = 1200;      // Duration of feedback (minimum)

// Define payment.
const completion_bonus = 0;
var performance_bonus = bonus_per_task;

// Define catch trial variables
const CATCH_TRIAL_DURATION = 10000; //arbitrary reason
const CATCH_TRIAL_FEEDBACK_DURATION = 1000; //arbitrary reason
//var MAX_MISSED_ATTEN_CHECKS = 2; //threshold for maximum allowed missed catch trials (reaching the threshold leads to exclusion)
const CATCH_BUTTONS = ['ArrowUp', 'ArrowDown', 'g', '3', 'h', 't', 'k', '7', 'a', '5'];
const CB = jsPsych.randomization.sampleWithoutReplacement(CATCH_BUTTONS, 1);
var nrMissedAttenChecks = 0; //initialize number of missed catch trials

// Define screen size parameters.
var min_width = 500;
var min_height = 450;

//------------------------------------//
// Define rune order.
//------------------------------------//

// Randomly select rune set.
//const rune_set = jsPsych.randomization.sampleWithReplacement(rune_sets, 1, rune_prob)[0];

// Set the inital ones, change them once the task starts
var rune_set = 'bacs2';
var runes_a = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
var runes_b = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
var runes = (Math.random() < 0.5) ? [runes_a, runes_b] : [runes_b, runes_a];

function set_runes() {
  const subjIDToRuneSet = {
    '5a062680c259f300017656b3': 'elianto',
    '5bf56163c901570001b813b2': 'elianto',
    '5c689deb8654fe00018d5606': 'bacs2',
    '5d350282cec7150015d16494': 'bacs1',
    '5d453e8723a5bb0001492546': 'elianto',
    '5d68c8aa40524c00189e8ac2': 'elianto',
    '5de8d53cd0e07e836599d816': 'elianto',
    '5e62ca4538141f030869529f': 'elianto',
    '5e8a5a892f6f027054a83d88': 'bacs1',
    '5f119c0375440c01d8f8310b': 'bacs2',
    '5f60713e595007000a8e1da7': 'elianto',
    '5f8998f6bfe9d6067c4b8a72': 'bacs2',
    '601129f77e0c21000b0c408a': 'elianto',
    '60130bd289b4b215f94d9979': 'bacs2',
    '603a293ee62ae15da2674441': 'bacs2',
    '60553b36cb4eb3269931ed21': 'bacs1',
    '606b94352e103bc54d43321b': 'bacs2',
    '60b7b8126c0c4524e913236e': 'elianto',
    '60d2c59451b12e36fb281477': 'bacs2',
    '60dc8adb066b3880665cd120': 'elianto',
    '60ddfb3db6a71ad9ba75e387': 'bacs2',
    '60ec51c51a3158a50ded8a3e': 'bacs1',
    '60f9739250a5c6f6e4726336': 'bacs2',
    '6103a3ece71ab061d5624402': 'bacs1',
    '612376826a580ca0368bb19f': 'bacs1',
    '612403f04e5d1f0dbfeb93f3': 'bacs1',
    '612634726f66f02657790b35': 'bacs2',
    '61267b828ead584bcf092e35': 'bacs2',
    '61717173748006894b2b54ff': 'bacs2',
    '6272892b05043371638ee032': 'elianto',
    '62aa33eec600b41d4dc4b4e8': 'bacs2',
    '62b44f66a16d45783569fad6': 'elianto',
    '62d6d87d91cf24a3c1c0f10c': 'bacs2',
    '63468b5809bf04222262bfed': 'elianto',
    '63469effac5117e39352c13b': 'bacs1',
    '63af557b3d4f219c3226b7d6': 'bacs1',
    '63ea4564de250efaacb1cceb': 'bacs1',
    '63ee65e3470c23cb401ca89a': 'bacs2',
    '64e8b9c1512a8828109c5ae3': 'elianto',
    '64e8c14bbe184c20cb9d0583': 'elianto',
    '64e90980b61f9d9b18570af5': 'bacs2',
    '65257c1a7780ceee7f6ef9bd': 'elianto',
    '653135c4caa65b61c5cabbbb': 'bacs1',
    '6557ecc93cc84dd3699e608c': 'bacs1',
    '659599a35a45f68375c3f06a': 'bacs2',
    '659ff67b392280e39ead5360': 'bacs1',
    '65ae78fc9cd81e8e26612cb2': 'bacs2',
    '65c0f98cdf650fa372206adf': 'bacs1',
    '65ce2a4ff956b6a7e2282d49': 'elianto',
    '65cf6d8a589a67afcab54e6f': 'elianto'
  };
  

  let previousRuneSet = subjIDToRuneSet[subID];
  //console.log("previousRuneSet: ", previousRuneSet);
  // Choose the other character set than previously on the first test
  if (previousRuneSet === 'bacs2') { // those who had bacs2
    window.rune_set = (Math.random() < 0.5) ? 'elianto' : 'bacs1';
  } else if (previousRuneSet === 'bacs1') {  // those who had bacs1
    window.rune_set = (Math.random() < 0.5) ? 'elianto' : 'bacs2';
  } else if (previousRuneSet === 'elianto') { // those who had elianto
    window.rune_set = (Math.random() < 0.5) ? 'bacs1' : 'bacs2';
  } else { // if any issue or the participant types in the wrong ID
    window.rune_set = jsPsych.randomization.sampleWithReplacement(rune_sets, 1, rune_prob)[0];
    //window.rune_set = "bacs2"
  }

  //console.log("rune_set", rune_set);

  // Gather rune orders.
  if (window.rune_set == 'elianto') {
    window.runes_a = ['U', 'L', 'A', 'G', 'P', 'S', 'W', 'E', 'K', 'D', 'J', 'V'];
    window.runes_b = ['M', 'R', 'Y', 'H', 'Z', 'C', 'B', 'T', 'X', 'F', 'N', 'Q'];
  } else if (window.rune_set == 'bacs1') {
    window.runes_a = ['B', 'Z', 'J', 'R', 'V', 'E', 'T', 'F', 'A', 'C', 'L', 'Q'];
    window.runes_b = ['Y', 'H', 'P', 'M', 'U', 'S', 'K', 'D', 'O', 'I', 'G', 'N'];
  } else if (window.rune_set == 'bacs2') {
    window.runes_a = ['J', 'W', 'X', 'Z', 'G', 'O', 'C', 'E', 'H', 'Q', 'T', 'Y'];
    window.runes_b = ['M', 'B', 'K', 'V', 'R', 'P', 'L', 'S', 'U', 'A', 'F', 'N'];
  } /* else if (window.rune_set == 'bacs2') {
    window.runes_a = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
    window.runes_b = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
  } */

  //console.log(runes_a, "runes_a");

  // Randomize presentation order.
  if (Math.random() < 0.5) { window.runes_a = window.runes_a.reverse(); }
  if (Math.random() < 0.5) { window.runes_b = window.runes_b.reverse(); }
  window.runes = (Math.random() < 0.5) ? [window.runes_a, window.runes_b] : [window.runes_b, window.runes_a];
}



//------------------------------------//
// Define experiment.
//------------------------------------//
// One block of the PGNG task is comprised of 8-12 exposures to 12 robots, or
// 120 total trials. 80% of trials provide correct feedback. There are 2 total
// blocks, or 240 total trials.

// Preallocate space.
var PGNG = [];
// Iteratively define trials.
var n = 0;
for (let i = 0; i < runsheets.length; i++) { // 2 => runsheets = [runsheet_s00, runsheet_s03];

  for (let j = 0; j < runsheets[i]['robots'].length; j++) { // 30 => sets of robots (each set has 4)

    jsPsych.randomization.shuffle([0, 1, 2, 3]).forEach(function (k) {

      // Extract trial information.
      const robot = runsheets[i]['robots'][j][k];
      const stimulus = runsheets[i]['stimuli'][j][k];

      // Define trial metadata.
      const valence = (robot < 2) ? 'win' : 'lose';
      const action = (robot % 2 == 0) ? 'go' : 'no-go';

      // Define trial outcomes.
      const sham = (Math.random() < 0.8) ? 0 : 1;
      if (valence == 'win' && sham == 0) {
        var outcome_correct = '+10';
        var outcome_incorrect = '+1';
      } else if (valence == 'win') {
        var outcome_correct = '+1';
        var outcome_incorrect = '+10';
      } else if (valence == 'lose' && sham == 0) {
        var outcome_correct = '-1';
        var outcome_incorrect = '-10';
      } else {
        var outcome_correct = '-10';
        var outcome_incorrect = '-1';
      }

      // Define screen check.
      const screen_check = {
        timeline: [{
          type: jsPsychScreenCheck,
          min_width: min_width,
          min_height: min_height
        }],
        conditional_function: function () {
          if (window.innerWidth >= min_width && window.innerHeight >= min_height) {
            return false;
          } else {
            return true;
          }
        }
      }

      // Define trial.
      const trial = {
        type: jsPsychPgngTrial,
        robot_rune: function() {return runes[i][stimulus]},
        scanner_color: valence == 'win' ? scanner_color_win : scanner_color_lose,
        outcome_color: valence == 'win' ? outcome_color_win : outcome_color_lose,
        outcome_correct: outcome_correct,
        outcome_incorrect: outcome_incorrect,
        correct: robot % 2 == 0 ? key_go : -1,
        rune_set: function() {return rune_set},
        valid_responses: [key_go],
        trial_duration: trial_duration,
        feedback_duration: feedback_duration,
        data: {
          block: i + 1,
          trial: n + 1,
          stimulus: stimulus,
          robot: robot + 1,
          valence: valence,
          action: action,
          sham: sham
        },
        on_finish: function (data) {

          // Store number of browser interactions
          data.browser_interactions = jsPsych.data.getInteractionData().filter({ trial: data.trial_index }).count();
        }
      };

      const blank_trial = {
        type: jsPsychHtmlKeyboardResponse,
        trial_duration: function (data) {
          trial_data_rt = jsPsych.data.get().last(2).trials[1].rt; //allData.trials[2];
          //console.log("trial_data: ", trial_data_rt);
          if (trial_data_rt == -1) {//no response
            break_time = 0;
            //console.log("break time no reponse: ", break_time);
          } else {
            break_time = trial_duration - trial_data_rt; //faster response leads to longer feedback, keeping trial length equal
            //console.log("break time after response: ", break_time);
          }
          return break_time;

        },
        stimulus: function () {
          return new_html;
        }
      }

      // Define trial node.
      const trial_node = {
        timeline: [screen_check, trial, blank_trial]
      }

      // Replace the runes with re-rest ones
      /*       if (n == 0) {
        PGNG.push(set_runes_var);
      } */

      // Append.
      PGNG.push(trial_node)

      n++;

    })

  }

}

//------------------------------------//
// Define transition screens.
//------------------------------------//

/* // Define ready screen.
var READY = {
  type: jsPsychPgngInstructions,
  pages: [
    "Great job! You've passed the comprehension check.",
    "Get ready to begin the task demo.<br>Press next when you're ready to start.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
} */

var set_runes_var = {
  type: jsPsychHtmlKeyboardResponse,
  trial_duration: 1,
  stimulus: "",
  on_finish: function() {
    console.log('setting runes now');
    set_runes();
  }
}

// Define ready screen 1
var READY_01 = {
  type: jsPsychPgngInstructions,
  pages: [
    "Great job! You've passed the comprehension check.",
    "<b>One final thing</b>: we will check if you are paying attention at specific times during the experiment by having you press a specific button.",
    "If you fail these attention checks, the experiment will end, and you will not be compensated for participating.",
    "Get ready to begin <b>Block 1 of 2</b>. Each block will take ~6 minutes.<br>Press next when you're ready to start.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
}

// Define ready screen 2
var READY_02 = {
  type: jsPsychPgngInstructions,
  pages: [
    "Take a break for a few moments and press next when you are ready to continue.",
    "Get ready to begin <b>Block 2 of 2</b>. Each block will take ~8 minutes.<br>Press next when you're ready to start.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
}

// Define finish screen.
var FINISHED = {
  type: jsPsychPgngInstructions,
  pages: [
    "Great job! You've finished the task.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
}

/* prompt the user for their Prolific (participant) ID and loop if they give no answer*/
let resp = 0;
let participantID = {
  type: jsPsychSurveyText,
  preamble:
    `<p style="margin: auto;width: 50%; font-size: 1.5vw; line-height: 4vmin;">In order to be able to reward you for participating in this experiment, we need your Prolific ID.
    It is very important that this is entered correctly. If it isn't entered correctly, we will 
            not be able to compensate you for participating in this experiment. 
    </p>`,
  questions: [
    { prompt: `Please enter your Prolific ID here:`, name: `ID` },
  ],
  data: {
    task: `initial_instructions`,
  },
  on_finish: function (data) {
    //let subject = data.response.ID;
    jsPsych.data.addProperties({ subjID: data.response.ID }); //remove nrMissedTrials?

    //record if they responded anything
    var subj_response = jsPsych.data.get().last(1).values()[0].response;
    //console.log('response: ', subj_response.ID);
    if (subj_response.ID == '') {
      //console.log('EMPTY RESPONSE');
      resp = 1;
    } else {
      resp = 0;
    }
  }
};

//if the user provides no text at all, repeat the same trial
var participantID_node = {
  timeline: [participantID],
  loop_function: function (data) {
    if (resp == 1) {
      return true;
    } else {
      return false;
    }
  }
}

// Define feedback screen.
var FEEDBACK = {
  stimulus: '',
  type: jsPsychHtmlKeyboardResponse,
  on_start: function (trial) {

    // Compute overall accuracy.
    var accuracy = jsPsych.data.get().filter([{ block: 1 }, { block: 2 }]).select('accuracy');
    var accuracy = accuracy.mean();

    // Compute payment.
    var bonus = completion_bonus + Math.ceil(performance_bonus * accuracy * 100) / 100;
    var total = completion_bonus + performance_bonus;
    //console.log('completion_bonus: ', completion_bonus);

    //add to global
    bonus_gonogo = bonus;

    //Update global variables to be passed on to next task
    taskNumber++
    performanceBonus += bonus;

    //console.log('bonus: ', bonus, 'total: ', total, 'taskNumber: ', taskNumber, 'bonus_gonogo: ', bonus_gonogo, 'performanceBonus: ', performanceBonus);

    // Report accuracy to subject.
    trial.stimulus = `<h2>Great job!</h2>You earned a performance bonus of ${bonus}&pound out of ${total}&pound in this game.
    <br>You have earned a total performance bonus of ${performanceBonus}&pound.
    <br><br>Press the <b>space bar</b> to continue.`

    /* `You earned a bonus of ${bonus}&pound out of ${total}&pound.<br><br>Press the <b>space bar</b> to continue.` */

    //save bonus to data
    jsPsych.data.addProperties({
      bonus_gonogo: bonus_gonogo
    });

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

// Define catch trial (attention check)
var CATCH = {
  timeline: [
    {
      type: jsPsychHtmlKeyboardResponse,
      stimulus:
        `<div>This is an attention check, please respond by pressing the <b>${CB}</b> button within 10 seconds</div>` + '<div style="background-color: #ccc; margin-top: 1em;">' +
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
        //console.log('nrMissedAttenChecks: ', nrMissedAttenChecks);
      }
    },
    { //feedback catch trial
      type: jsPsychHtmlKeyboardResponse,
      stimulus: function () {
        var tmp1 = jsPsych.data.get().last(1).values()[0].correct;

        if (tmp1 == true) {
          return '<p style="color: #015001; font-size: 3.5vw;">Correct!</p>';
        } else {
          return '<p style="color: #a10000; font-size: 3.5vw;">You failed the attention check!</p>'
        }
      },
      trial_duration: CATCH_TRIAL_FEEDBACK_DURATION,
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
          return '<div class="gng-fixation">+</div>'
        }
      },
      trial_duration: function () {
        if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
          return 300000
        } else {
          return 1
        }
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
    parsing: 'end_gonogo',
    task: 'debrief_gonogo'
  }
}

/* var DEBRIEF_02 = {
      type: jsPsychSurveyText,
      preamble: '<h1>Debriefing</h1><p>Please answer the questions below.</p><p><font color="#c87606">Your answers do not affect your payment or bonus.</font></p>',
      button_label: 'Submit',
      questions: [
        {prompt: '<p style="padding: 0 0;">Did you use any strategies during the task (e.g. write things down)?</p>', placeholder: 'Optional...', rows:3, columns: 55},
        {prompt: 'Do you have any other comments?', placeholder: 'Optional...', rows:1, columns: 55}
      ]
    }; */