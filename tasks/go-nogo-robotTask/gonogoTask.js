function gonogoTask(day) {

  var styleElement;
  var BREAK_DURATION = 60000; //Duration for the break in between blocks
  var FAST_VER_GONOGO = false; //if true: faster version (6 trials and no instructions), if false full version

  function setStyles() {
    setTimeout(() => {
      // Create a new <style> element
      styleElement = document.createElement('style');

      // Set the content of the <style> element to your styles
      let styles = gonogo_styles;
      styleElement.innerHTML = styles;

      // Append the <style> element to the document's <head>
      document.head.appendChild(styleElement);
    }, 1);
  }

  function removeStyles() {
    styleElement.parentNode.removeChild(styleElement);
    /* styleElement.parentNode.removeChild(styleElement); */
  }

  

  // Define experiment fullscreen.

  /* var FULLSCREEN = {
     type: jsPsychFullscreen,
     fullscreen_mode: true,
   } */

  /* fullscreen listeners */

  document.addEventListener('fullscreenchange', fullscreenChangeHandler);
  document.addEventListener('mozfullscreenchange', fullscreenChangeHandler);
  document.addEventListener('webkitfullscreenchange', fullscreenChangeHandler);
  document.addEventListener('msfullscreenchange', fullscreenChangeHandler);

  document.addEventListener('keydown', function (event) {
    if (CURRENTLY_IN_FULLSCREEN == false) {
      if (event.key === 'f' || event.key === 'F') {
        enterFullscreen();
      }
    }
  });
  /* end of fullscreen listeners */

  // Define timeline.
  var timeline = [];

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
}; */

  //Pavlovia initialization
    /* if (PAV == true) { */
      /* let pavlovia_init = {
        type: jsPsychPavlovia,
        command: "init",
        setPavloviaInfo: function (info) {
          console.log(info);
          pavloviaInfo = info;
        }
      };
      timeline.push(pavlovia_init) */
    /* } */

  //for setting styles (CSS)
  let onstart_trial = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '',
    choices: ["NO_KEYS"],
    trial_duration: 1, //
    data: {
      task: 'empty_trial',
      parsing: 'start_gonogo'
    },
    on_start: function () {
      setStyles();
/*       console.log('THIS IS WHERE WE SET STYLE!');
      console.log('xx prolific urL:', FAURL);
      console.log('xx max attention checks: ', MAX_MISSED_ATTEN_CHECKS); */
    }
  };
  //timeline.push(onstart_trial);

  let break_trial = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `<div class="gng-textDiv" style="width: 55%"><p>You may now take a break. After <b>1 minute</b>, the task will automatically continue. Press the space bar if you wish to end the break and continue the task.</p></div>`/*  + '<div class="enterId" style="background-color: #ccc; margin-top: 1em;">' +
      '<div style="width: 0%; height: 20px; background-color: #333; animation-name: progress-bar; animation-duration: 60s; animation-timing-function: linear;">' +
      '</div>' +
      '<style> @keyframes progress-bar { 0% { width:0%;} 100% { width:100%} } </style>' */,
    choices: " ",
    trial_duration: BREAK_DURATION,
    data: {
      task: 'break_trial'
    }
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

  //Assemble experiment timeline
  timeline = timeline.concat(onstart_trial);             // onstart trial to turn on task-specific styles


  /* Fast or full version*/

  if (FAST_VER_GONOGO) { //faster version for testing
    timeline = timeline.concat(PGNG.slice(0, 6));    // TEMP SHORTER FOR TESTING
    timeline = timeline.concat(CATCH);                // Attention check (catch trial)
    timeline = timeline.concat(FINISHED);               // End of task
    timeline = timeline.concat(FEEDBACK);               // Display bonus earned
    timeline = timeline.concat(DEBRIEF_01);             // Debriefing form

  } else { // else the full version
    timeline = timeline.concat(set_runes_var);
    if (day == 0) {
      timeline = timeline.concat(INSTRUCTIONS);           // Experiment instructions
    } else if (day == 1) {
      timeline = timeline.concat(INSTRUCTIONS_DAY1);           // Experiment instructions
    }
    timeline = timeline.concat(READY_01);               // Ready check (block 1)
    timeline = timeline.concat(CATCH);                // TEMP FOR TESTING REMOVE LATER
    timeline = timeline.concat(PGNG.slice(0, 40));    // PGNG task (block 1) - FULL VERSION
    /* timeline = timeline.concat(PGNG.slice(0, 10));    // PGNG task (block 1) - MEDIUM VERSION */
    timeline = timeline.concat(CATCH);              // Attention check (catch trial)
    timeline = timeline.concat(PGNG.slice(40, 80));    // PGNG task (block 1) - FULL VERSION
    /* timeline = timeline.concat(PGNG.slice(10, 20));    // PGNG task (block 1) - MEDIUM VERSION */
    timeline = timeline.concat(CATCH);              // Attention check (catch trial)
    timeline = timeline.concat(break_trial);               // 1-min break
    timeline = timeline.concat(PGNG.slice(80, 120));    // PGNG task (block 1) - FULL VERSION
    timeline = timeline.concat(CATCH);              // Attention check (catch trial)
    /* timeline = timeline.concat(PGNG.slice(20, 30));    // PGNG task (block 1) - MEDIUM VERSION */
    timeline = timeline.concat(PGNG.slice(120, 168));  // PGNG task (block 2) - FULL VERSION
    /* timeline = timeline.concat(PGNG.slice(30, 40));    // PGNG task (block 1) - MEDIUM VERSION */
    timeline = timeline.concat(CATCH);                // Attention check (catch trial)
    //timeline = timeline.concat(PGNG.slice(160, 200));  // PGNG task (block 2) - FULL VERSION
    /* timeline = timeline.concat(PGNG.slice(40, 50));    // PGNG task (block 1) - MEDIUM VERSION */
    //timeline = timeline.concat(CATCH);                // Attention check (catch trial)
    //timeline = timeline.concat(PGNG.slice(200, 240));  // PGNG task (block 2) - FULL VERSION
    /* timeline = timeline.concat(PGNG.slice(50, 60));    // PGNG task (block 1) - MEDIUM VERSION */
    timeline = timeline.concat(FINISHED);               // End of task
    timeline = timeline.concat(FEEDBACK);               // Display bonus earned
    timeline = timeline.concat(DEBRIEF_01);             // Debriefing form
    //timeline = timeline.concat(sendData);
  }


  // Execute timeline.
  //jsPsych.run(timeline);

  return timeline;
};