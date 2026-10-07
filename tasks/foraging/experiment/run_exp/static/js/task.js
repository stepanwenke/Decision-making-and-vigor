var alien = 1;
var aliens_copy = [];

var the_rest_of_timeline;

// when to end block timing
var b_num = 1;
var block_num_planet = 0;

var prac_b_num = 1;
var prac_block_num_planet = 0;


function foragingTask(day) {

  var styleElement;
  day = day || 1;

  function setStyles() {
    setTimeout(() => {
      // Create a new <style> element
      styleElement = document.createElement('style');

      // Set the content of the <style> element to your styles
      let styles = foraging_styles + bootstrap_styles;
      styleElement.innerHTML = styles;

      // Append the <style> element to the document's <head>
      document.head.appendChild(styleElement);
    }, 1);
  }

  function removeStyles() {
    styleElement.parentNode.removeChild(styleElement);
    //styleElement.parentNode.removeChild(styleElement);
  }

  /*
   * Requires:
   *     psiturk.js
   *     utils.js
   */

  /********************
  * HTML manipulation
  *
  * All HTML files in the templates directory are requested
  * from the server when the PsiTurk object is created above. We
  * need code to get those pages from the PsiTurk object and
  * insert them into the document.
  *
  ********************/
  var debug_mode = 0; // debug mode determines how long the blocks are, 5 sec in debug mode, 5 minutes in actual experiment
  var SKIP_TRAINING_FORAGING = false;
  //var data_save_method = 'csv_server_py';
  var data_save_method = 'csv_server_py';

  // timeout vars
  var TIMEOUT_WARNINGS = 0; // record how many times (per trial) a participant was prompted to respond faster
  var TOTAL_TIMEOUT_WARNINGS = 0; // total timeout warnings throughout the experiment
  var TIMEOUT_TRL_THRESHOLD = 10 // after how many timeout warnings (in one trial) will the participant be excluded from the study
  var TIMEOUT_TOTAL_THRESHOLD = 40; // after how many timeouts counted throughout the whole experiment will the participant be excluded        
  var WARNING_DURATION = 900 // duration of the displayed timeout warning (in ms)
  var PARTICIPANT_EXCLUDED = false;

  // atentional checks
  var nrMissedAttenChecks = 0;
  //var MAX_MISSED_ATTEN_CHECKS = 2;



  /* Disable right-click/context menu */
  if (debug_mode == false) {
    document.addEventListener('contextmenu', function (event) { event.preventDefault(); });
  }

  /* Escape key or exit fullscreen ends experiment */

  // Callback function for handling potential end-experiment-triggering events
  function exit_handler(event) {
    var exit_message = "The experiment was ended by pressing the escape key or exiting fullscreen.";
    // If 'esc' key pressed or exiting fullscreen (but not if experiment-triggered exit)
    if (event.code == 'Escape' || (event.type == 'fullscreenchange' && !document.webkitIsFullScreen &&
      !document.mozFullScreen && !document.msFullscreenElement) && normal_exit == false) {
      jsPsych.endExperiment(exit_message);
    }
  }


  // for playiing audio
  function sound(src) {
    this.sound = document.createElement("audio");
    this.sound.src = src;
    this.sound.setAttribute("preload", "auto");
    this.sound.setAttribute("controls", "none");
    this.sound.style.display = "none";
    document.body.appendChild(this.sound);
    this.play = function () {
      this.sound.play();
    }
    this.stop = function () {
      this.sound.pause();
    }
  }

  // Yates-Fischer algorithm
  function shuffle(a) {
    var j, x, i;
    for (i = a.length - 1; i > 0; i--) {
      j = Math.floor(Math.random() * (i + 1));
      x = a[i];
      a[i] = a[j];
      a[j] = x;
    }
    return a;
  }

  // for getting a list of random numbers 0 to 42
  function rand_list(upper_bound) {
    var arr = Array.from(Array(upper_bound).keys())
    arr = arr.map(function (val) { return ++val; });
    shuffle(arr);
    return arr
  }


  // check if arrays match, for quiz checking purposes
  var arraysMatch = function (arr1, arr2) {
    // Check if the arrays are the same length
    if (JSON.stringify(arr1) === JSON.stringify(arr2)) {
      return true;
    } else {
      return false
    }
  };


  var get_answers = function (answers_dict) {
    var answers = []
    var keys = ["Q0", "Q1", "Q2"]

    keys.forEach(function (item, index) {
      answers.push(answers_dict[item])
    });
    return answers
  }

  var timeline = []; // structures the experiment

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

  //console.log('this is the timeline foraging: ', timeline);


  // Will be set to true when experiment is exiting fullscreen normally, to prevent above end experiment code
  var normal_exit = false;
  var window_height = window.screen.height;


  // Randomly generate an 8-character alphanumeric subject ID via jsPsych
  var subject_id = jsPsych.randomization.randomID(8);




  var image_prefix = "tasks/foraging/experiment/run_exp/static/images/task_images/";
  var new_gems_prefix = "tasks/foraging/experiment/run_exp/static/images/task_images/new_gems/"
  var image_prefix_button = "<img src=tasks/foraging/experiment/run_exp/static/images/task_images/";

  var all_images = [new_gems_prefix + "1.jpg",new_gems_prefix + "2.jpg",new_gems_prefix + "3.jpg",new_gems_prefix + "4.jpg",new_gems_prefix + "5.jpg",
  new_gems_prefix + "6.jpg", new_gems_prefix + "7.jpg",new_gems_prefix + "8.jpg",new_gems_prefix + "9.jpg",new_gems_prefix + "10.jpg",
  new_gems_prefix + "11.jpg",image_prefix + "land.jpg", image_prefix + "dig.jpg", image_prefix + "barrel_text.jpg",
  image_prefix + "rocket-01.jpg", image_prefix + "rocket-02.jpg", image_prefix + "rocket-03.jpg",
  image_prefix + "rocket-04.jpg", image_prefix + "rocket-05.jpg", image_prefix + "rocket-06.jpg", image_prefix + "rocket-07.jpg",
  image_prefix + "rocket-08.jpg", image_prefix + "rocket-09.jpg", image_prefix + "gems/0.jpg", image_prefix + "gems/1.jpg",
  image_prefix + "opening_img-01.jpg", image_prefix + "home_base.jpg",
  image_prefix + "time_out.jpg", image_prefix + "catch.jpg"];

  var neccesary_images = [image_prefix + "land.jpg", image_prefix + "dig.jpg", image_prefix + "barrel_text.jpg",
  image_prefix + "rocket-01.jpg", image_prefix + "rocket-02.jpg", image_prefix + "rocket-03.jpg",
  image_prefix + "rocket-04.jpg", image_prefix + "rocket-05.jpg", image_prefix + "rocket-06.jpg", image_prefix + "rocket-07.jpg",
  image_prefix + "rocket-08.jpg", image_prefix + "rocket-09.jpg"];

  var preload = {
    type: jsPsychPreload,
    images: [all_images, neccesary_images],
    data: {
      task: 'preload_foraging',
      parsing: 'start_foraging'
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
      task: 'empty_trial'
    },
    on_start: function () {
      setStyles();

      /* console.log('xx prolific urL:', FAURL);
      console.log('xx max attention checks: ', MAX_MISSED_ATTEN_CHECKS); */

      let cur_pos = jsPsych.timeline.progress.current_location;
      the_rest_of_timeline = jsPsych.timeline.timeline_parameters.timeline.slice(cur_pos + experimentArray.length + 1); // everything that is after the experimentArray.length doesn't belong to foraging - keep it in the_rest_of_timeline for later
      //console.log('the rest of the timeline: ', the_rest_of_timeline, 'experiment array length: ', experimentArray.length + 1);
      jsPsych.timeline.timeline_parameters.timeline.splice(cur_pos + experimentArray.length + 1); // removing the rest of the timeline that doesn't belong to foraging (+1 because of preload)
    }
  };
  timeline.push(onstart_trial);

  // default images
  const decision_img = [image_prefix + "land.jpg"];
  const land_img = [image_prefix + "land.jpg"]
  const dig_img = [image_prefix + "dig.jpg"];
  const space_treasure_img = [image_prefix + "gems/100.jpg"];
  const galaxy_prac_img = [image_prefix + "galaxy_prac.jpg"];
  const harvest_practice_img = [image_prefix + "barrel_text.jpg"];
  const travel_sequence = [image_prefix + "rocket-01.jpg", image_prefix + "rocket-02.jpg", image_prefix + "rocket-03.jpg",
  image_prefix + "rocket-04.jpg", image_prefix + "rocket-05.jpg", image_prefix + "rocket-06.jpg", image_prefix + "rocket-07.jpg",
  image_prefix + "rocket-08.jpg", image_prefix + "rocket-09.jpg"];

  /* const dig_sequence = [image_prefix + "dig.jpg", image_prefix + "land.jpg", image_prefix + "dig.jpg"]; */
  const dig_sequence = [image_prefix + "dig.jpg", image_prefix + "land.jpg", image_prefix + "dig.jpg", image_prefix + "land.jpg", image_prefix + "dig.jpg", image_prefix + "land.jpg"];
  //const dig_sequence = [image_prefix + "dig.jpg",image_prefix + "dig.jpg",image_prefix + "dig.jpg",image_prefix + "land.jpg",image_prefix + "land.jpg",image_prefix + "land.jpg",];

  const time_out_img = [image_prefix + "time_out.jpg"];
  const catch_img = [image_prefix + "catch.jpg"];

  // when to end block timing

  if (debug_mode) {
    var total_num_blocks = 1;
    var block_len = [20000];
    var n_prac_trials = 1;
  } else {
    var total_num_blocks = 2;
    //var block_len = [360000,360000,360000,360000,360000]; // array of how long block_len should be
    var block_len = [390000,390000]; // xxx 390000 originally
    //var block_len = [3900, 3900, 3900, 3900]; // short times for testing purposes
    var n_prac_trials = 6;

  }

  //var practice_block_len = 120000; // 2 minutes for practice block
  var practice_block_len = 120000; // 2 minutes for practice block xxx

  // number of planets visited and time spent on planet
  //const condition = 1;
  var planet = 0;
  var prt = 0;
  var total_space_treasure = 0;
  //var cents_per_gem = 0.0001; /* 5000 gems you get a dollar */ //I divided it by 2, so now it's 10000 games for a pound - to get max 2 pounds /MN
  //var cents_per_gem = 0.0008; // 10 times more cents per gem since there are ten times less gems if we have only 10 and not 100. CHANGE TO 10
  //var cents_per_gem = 0.0006; // 0.0008/1.3333 to account for max bonus of 1.5 GBP
  //var cents_per_gem = 0.0024; // for one condition
  var cents_per_gem = 0.0012; // we have two conditions now - 0.0006 * 2

  var planet_left, planet_right, alien_left, alien_right;
  var num_planets = []; // keep track of number of planets we visit in each block
  /* var block_num_planet = 0; */

  // practice trials
  var curr_prac_trial = 1;
  var n_prac_rounds = 1;
  var curr_travel_trial = 1;
  var n_travel_rounds = 2;

  // aliens
  var aliens_prac = [118, 119, 120, 121, 122, 123, 124, 125, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  var aliens = rand_list(120); // will pop every time use a new alien


  var num_quiz_failures = 0;
  // for quiz
  var correct_answers = ['C', 'B', 'B', 'A'];

  /* STRUCTURE OF GAME - TYPES OF TRIALS */
  // arival at new planet
  var landing = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <img src='${land_img}' class='fullscreen-image'>
    `,
    //prompt: "<p style = 'color:white;'>Dig here or travel to a new planet?</p>",
    stimulus_height: 700,
    choices: "NO_KEYS",
    stimulus_duration: 500,
    trial_duration: 500,
    on_finish: function (data) {
      /*data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(100, 5), 135), 0));*/
      //data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(100, 10), 150), 0));
      data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(10, 1), 15), 0) * 10) / 10; // CHANGE TO 10
      //console.log('reward fetched from landing: ', data.next_reward);

      data.planet = planet;
      data.trial_type = "land";
    }
  }

  var landing_prac = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <img src='${land_img}' class='fullscreen-image'>
    `,
    stimulus_height: 700,
    choices: "NO_KEYS",
    stimulus_duration: 500,
    trial_duration: 500,
    on_finish: function (data) {
      /*       data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(100, 5), 135), 0));*/
      //data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(100, 10), 150), 0));
      data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(10, 1), 15), 0) * 10) / 10; // CHANGE TO 10
      //console.log('reward fetched from landing prac: ', data.next_reward);
      nextRewardForaging = data.next_reward;
      data.planet = planet;
      data.trial_type = "land_prac";
      //console.log('landing prac current reward, harvest img: ', data.next_reward);
    }
  }

  // digging digging
  var dig = {
    type: jsPsychAnimation,
    stimuli: dig_sequence,
    frame_time: 500 /* 667 */,
    choices: "NO_KEYS",
    on_start: function (dig) {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      if (last_trial_data.trial_type == "decision") {

        var src = "tasks/foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
        var tt_sec = /* adjusted_rt */ 3000 / 1000 + 1.5; //need to convert to seconds
        var axe_audio = new sound(src.concat(tt_sec.toString()))
        axe_audio.play()
      } else {
        var src = "tasks/foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
        var tt_sec = 4.5; //need to convert to seconds
        var axe_audio = new sound(src.concat(tt_sec.toString()))
        axe_audio.play()
      }
    },
    on_finish: function (data) {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      data.next_reward = last_trial_data.next_reward;
      data.planet = planet;
      data.trial_type = "dig";
    }
  };

  var dig_instruc = {
    type: jsPsychAnimation,
    stimuli: dig_sequence,
    choices: "NO_KEYS",
    frame_time: 500,
    on_start: function (dig_instruc) {
      //console.log('dig seq: ', dig_sequence);

      var src = "tasks/foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
      var tt_sec = 4.5; //need to convert to seconds
      var axe_audio = new sound(src.concat(tt_sec.toString()))
      axe_audio.play()

    },
    on_finish: function (data) {
      data.trial_type = "dig_instruc";
    }
  }

  var dig_prac = {
    type: jsPsychAnimation,
    stimuli: dig_sequence,
    choices: "NO_KEYS",
    frame_time: 500,
    on_start: function (dig_prac) {

      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      if (last_trial_data.trial_type == "decision") {

        var src = "tasks/foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
        var tt_sec = 4.5; //need to convert to seconds
        var axe_audio = new sound(src.concat(tt_sec.toString()))
        axe_audio.play()
      } else {
        var src = "tasks/foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
        var tt_sec = 4.5; //need to convert to seconds
        var axe_audio = new sound(src.concat(tt_sec.toString()))
        axe_audio.play()
      }
    },
    on_finish: function (data) {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      data.next_reward = last_trial_data.next_reward;
      //console.log('dig prac last trial: ', last_trial_data);
      //console.log('next reward in dig_prac: ', data.next_reward);
      data.planet = planet;
      data.trial_type = "dig_prac";
    }
  }

  // digging up the treasure, displaying how many gems they got
  var harvest = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <img src='${space_treasure_img}' class='fullscreen-image'>
    `,
    stimulus_height: 700,
    stimulus_duration: 1500, // in milliseconds
    trial_duration: 1500,
    choices: "NO_KEYS",
    on_start: function (harvest) {

      var last_trial_data = jsPsych.data.get().last(2).values()[0]; // last trial was dig, before that was decision
      var reward = last_trial_data.next_reward; // round to one decimal point
      var folder_prefix = 'tasks/foraging/experiment/run_exp/static/images/task_images/new_gems/';

      var integer;
      if (reward > 11) {
        integer = 11;
      } else if (reward < 1) {
        integer = 1;
      } else {
        integer = reward;
      }


      integer = Math.round(integer.toString());
      var img_suffix = '.jpg'
      var harvest_img = folder_prefix.concat(integer, img_suffix)

      /* console.log('reward: ', reward);
      console.log('integer: ', integer);
      console.log('harvest_img: ', harvest_img);
      console.log('last_trial_data: ', last_trial_data); */

      harvest.stimulus = `
      <img class="fullscreen-image" src="${harvest_img}">
      <p class="dug-up">You dug up ${reward} gems!</p>
      `;
    },
    on_finish: function (data) {
      var last_trial_data = jsPsych.data.get().last(3).values()[0];
      var galaxy_type = struc[b_num - 1][block_num_planet - 1]
      var decay_rate = get_decay_rate(galaxy_type);
      //console.log('decay_rate: ', decay_rate, 'galaxy_type: ', galaxy_type, 'last_trial_data: ', last_trial_data, 'b_num: ', b_num, 'block_num_planet: ', block_num_planet);
      data.reward_received = last_trial_data.next_reward; // what did we receive from this harvest
      //data.next_reward = Math.round(last_trial_data.next_reward * decay_rate);
      data.next_reward = Math.round(last_trial_data.next_reward * decay_rate * 10) / 10; //CHANGE TO 10
      data.decay_rate_actual = decay_rate;
      data.decay_rate_exp = data.next_reward / last_trial_data.next_reward; // calculate the decay rate as seen by the  participant not what was actual sampled
      data.planet = planet;
      data.galaxy_type = galaxy_type;
      data.trial_type = "harvest";
      window.total_space_treasure = total_space_treasure + last_trial_data.next_reward;
      total_space_treasure = window.total_space_treasure;

    },
  };

  // display barrels of gems instead of actual gems
  var harvest_prac = {
    type: jsPsychHtmlKeyboardResponse,

    stimulus: `
    <img class="fullscreen-image" src="${space_treasure_img}">
    `,
    stimulus_height: 700,
    stimulus_duration: 1500, // in milliseconds
    trial_duration: 1500,
    choices: "NO_KEYS",
    on_start: function (harvest_prac) {

      var last_trial_data = jsPsych.data.get().last(2).values()[0]; // last trial was dig, before that was decision
      //console.log('last trial data: ', last_trial_data);
      //console.log('harvest last trial: ', last_trial_data);
      var reward = last_trial_data.next_reward; // round to one decimal point
      var folder_prefix = 'tasks/foraging/experiment/run_exp/static/images/task_images/new_gems/';

      var integer;
      if (reward > 11) {
        integer = 11;
      } else if (reward < 1) {
        integer = 1;
      } else {
        integer = reward;
      }

      integer = Math.round(integer.toString());
      var img_suffix = '.jpg'
      var harvest_img = folder_prefix.concat(integer, img_suffix)
      harvest_prac.stimulus = `
      <img class="fullscreen-image" src="${harvest_img}">
      <p class="dug-up">You dug up ${reward} gems!</p>
      `;

      //console.log('harvest img: ', harvest_prac.stimulus);
      //console.log('harvest_prac next reward: ', reward, 'the integer: ', integer);
    },
    on_finish: function (data) {
      var last_trial_data = jsPsych.data.get().last(3).values()[0];
      var decay_rate = prac_get_decay_rate(); //mean 0.9
      data.reward_received = last_trial_data.next_reward; // what did we receive from this harvest
      data.next_reward = Math.round(last_trial_data.next_reward * decay_rate * 10) / 10; //CHANGE TO 10
      data.decay_rate_actual = decay_rate;
      data.decay_rate_exp = data.next_reward / last_trial_data.next_reward; // calculate the decay rate as seen by the  participant not what was actual sampled
      data.planet = planet;
      data.trial_type = "harvest_prac";
    }
  }

  //var instruc_gems = 100;
  var reward_prac_iteration = 0;
  var harvest_instruc = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <img class='fullscreen-image' src='${space_treasure_img}'>
    `,
    stimulus_height: 700,
    stimulus_duration: 1500, // in milliseconds
    trial_duration: 1500,
    choices: "NO_KEYS",
    on_start: function (harvest_instruc) {
      var current_rew;
      if (quiz_correct_check == 2) {//if they have failed the quiz
        //current_rew = 100;
        current_rew = 10; // CHANGE TO 10 
      }
      else {
        current_rew = reward_prac[reward_prac_iteration];
      }

      harvest_instruc.stimulus = `
      <img class="fullscreen-image" src="tasks/foraging/experiment/run_exp/static/images/task_images/new_gems/${current_rew}.jpg">
      <p class="dug-up">You dug up ${current_rew} gems!</p>
      `;
    },
    on_finish: function (data) {
      data.trial_type = "harvest_instruc";
      //instruc_gems -= 15;
      reward_prac_iteration++;

    }
  };


  var travel = {
    type: jsPsychAnimation,
    stimuli: travel_sequence,
    frame_time: 1111, // in milliseconds
    choices: "NO_KEYS",
    on_start: function (travel) {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];

      var galaxy_type = struc[b_num - 1][block_num_planet - 1]
      var tt_sec = 999999;

      if (galaxy_type == 0 || galaxy_type == 2) {
        travel.frame_time = 6000 / 9;
        tt_sec = 6 - 0.5; //need to convert to seconds (-3 removed now that alien is removed)
      } else if (galaxy_type == 1 || galaxy_type == 3) {
        travel.frame_time = 12000 / 9;
        tt_sec = 12 - 0.5; //need to convert to seconds (-3 removed now that alien is removed)
      }

      var src = "tasks/foraging/experiment/run_exp/static/audio/rocket.mp3#t=0,"
      var rocket_audio = new sound(src.concat(tt_sec.toString()))
      rocket_audio.play()
    },
    on_finish: function (data) {
      data.trial_type = "travel";
      data.planet = planet;
    }
  };

  var travel_prac_iteration = 0;
  var travel_prac = {
    type: jsPsychAnimation,
    stimuli: travel_sequence,
    frame_time: 1111, // in milliseconds
    choices: "NO_KEYS",
    on_start: function (travel_prac) {
      var current_speed;
      if (quiz_correct_check == 1) { //before they have taken the quiz
        current_speed = travel_prac_speeds[travel_prac_iteration];
      } else if (quiz_correct_check == 2) { //if they have failed practice quiz
        current_speed = 8000;
      } else { //if they have succeded with the quiz
        current_speed = 9000;
      }
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      var tt_sec = current_speed / 1000 - 0.5;

      //travel speed
      travel_prac.frame_time = (current_speed) / 9;

      var src = "tasks/foraging/experiment/run_exp/static/audio/rocket.mp3#t=0,"
      var rocket_audio = new sound(src.concat(tt_sec.toString()))
      rocket_audio.play()
    },
    on_finish: function (data) {
      data.trial_type = "travel_prac";
      data.planet = planet;
      if (quiz_correct_check == 1) {
        travel_prac_iteration++;
      }
    },
  }

  var catch_trial_finished = false;
  var catch_trial_fail = {
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
          //console.log('nrMissedAttenChecks: ', nrMissedAttenChecks);
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

          data.trial_type = "attention check";
          var last_trial_data = jsPsych.data.get().last(4).values()[0];
          //console.log('last trial data: ', last_trial_data)
          data.next_reward = last_trial_data.next_reward;

        },
        choices: " "
      }
    ]
  };

  // when the participant is disconnected
  function timeoutDisconnect() {
    PARTICIPANT_EXCLUDED = true;
    window.location.href = MTURL;
  }

  var exclusion_trl = {
    type: jsPsychHtmlKeyboardResponse,
    trial_duration: 300000,
    choices: [' '],
    stimulus: `
  
        <div class="headline"><h1>Time out</h1></div>
        <div class="text-box"> 
            <p> You have failed to respond in time to ${TIMEOUT_TRL_THRESHOLD} offers in a row. As such we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
            If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
            <p> When you press the space bar, you will be redirected back to Prolific.</p>
            </div>
        <div class="character"></div>
    `,
    on_finish: function () {
      timeoutDisconnect();
    }
  }

  var exclusion_total = {
    type: jsPsychHtmlKeyboardResponse,
    trial_duration: 300000,
    choices: [' '],
    stimulus: `
  
        <div class="headline"><h1>Time out</h1></div>
        <div class="text-box"> 
            <p> You have failed to respond in time to ${TIMEOUT_TOTAL_THRESHOLD} or more offers. As such we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
            If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
            <p> When you press the space bar, you will be redirected back to Prolific.</p>
            </div>
        <div class="character"></div>
    `,
    on_finish: function () {
      timeoutDisconnect();
    }
  }

  var decision = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus_height: 700,
    trial_duration: 2000,
    stimulus: `
    <div class='text-box'>
      <p>Dig here or travel to a new planet?</p>
    </div>
    <img src='${decision_img}' class='fullscreen-image'>
    `,
    choices: ['A', 'L'],
    on_finish: function (data) {
      var last_trial_data = jsPsych.data.get().last(2).values()[0];
      var last_two_trial_data = jsPsych.data.get().last(8).values()[0];

      //console.log(last_trial_data)
      //console.log(last_two_trial_data)

      data.next_reward = last_trial_data.next_reward;
      data.time_in_block = Date.now() - block_start;
      data.block_num = b_num;
      data.planet = planet;
      data.prt = prt;
      data.trial_type = "decision";


      // end of block/ experiment
      if ((data.time_in_block >= block_len[b_num - 1]) | (block_num_planet == 20)) { // if the block time runs out or all planets are visited
        num_planets.push(planet)

        // if this is the last block
        if (b_num == total_num_blocks) { // end of block or end of exp

          jsPsych.addNodeToEndOfTimeline({ timeline: [catch_trial, end_of_experiment, DEBRIEF_01/* , end_trial */], }, jsPsych.resumeExperiment);

          // this is the first block
        } else if (b_num == 1) {
          jsPsych.addNodeToEndOfTimeline({ timeline: [catch_trial, end_of_block], }, jsPsych.resumeExperiment);
          // other blocks
        } else { // if this is the firs =t or second and choose to leave
          jsPsych.addNodeToEndOfTimeline({ timeline: [catch_trial, end_of_block], }, jsPsych.resumeExperiment);
        }

        window.prt = 0;
        window.block_num_planet = 0;
        data.last_trial_on_planet = true;
        window.b_num = b_num + 1;
        // not the end
      } else if (data.time_in_block * 2 >= block_len[b_num - 1] && catch_trial_finished == false) {

        jsPsych.addNodeToEndOfTimeline({
          timeline: [catch_trial_fail, decision],
        }, jsPsych.resumeExperiment);
        catch_trial_finished = true;
        data.last_trial_on_planet = false;

      } else {
        // travel
        if (jsPsych.pluginAPI.compareKeys(data.response, 'L')) {
          jsPsych.addNodeToEndOfTimeline({ timeline: [travel, alien_welcome, landing, dig, harvest, decision] }, jsPsych.resumeExperiment);
          data.last_trial_on_planet = true;
          window.prt = 0;

          TIMEOUT_WARNINGS = 0; // restart for the next trial
          // stay
        } else if (jsPsych.pluginAPI.compareKeys(data.response, 'A')) {
          jsPsych.addNodeToEndOfTimeline({
            timeline: [dig, harvest, decision],
          }, jsPsych.resumeExperiment);

          window.prt = prt + 1;
          data.last_trial_on_planet = false;

          if ((last_two_trial_data.next_reward == last_trial_data.next_reward) & last_trial_data.next_reward < 5) {
            data.next_reward = 0
          }

          TIMEOUT_WARNINGS = 0; // restart for the next trial
          // didn't make choice
        } else {
          jsPsych.addNodeToEndOfTimeline({
            timeline: [time_out, decision],
          }, jsPsych.resumeExperiment);
          // add timeout +1
          // timeout vars
          TIMEOUT_WARNINGS++;
          TOTAL_TIMEOUT_WARNINGS++;
          data.last_trial_on_planet = false;

          if (TIMEOUT_WARNINGS >= TIMEOUT_TRL_THRESHOLD) {
            //console.log('disconnected because of many timeouts during a trial');
            jsPsych.addNodeToEndOfTimeline({
              timeline: [exclusion_trl],
            }, jsPsych.resumeExperiment);
          } else if (TOTAL_TIMEOUT_WARNINGS >= TIMEOUT_TOTAL_THRESHOLD) {
            //console.log('disconnected because of overall trial misses.');
            jsPsych.addNodeToEndOfTimeline({
              timeline: [exclusion_total],
            }, jsPsych.resumeExperiment);
          }
        }
      }
    }
  }


  var decision_prac = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus_height: 700,
    trial_duration: 2000,
    choices: ['A', 'L'],
    stimulus: `
    <div class='text-box'>
      <p><strong>Practice</strong></p> <p>Dig here ('A') or travel to a new planet ('L')?</p>
    </div>
    <img src='${decision_img}' class='fullscreen-image'>
    `,
    on_finish: function (data) {
      //console.log('curr_prac_trial: ', curr_prac_trial);
      data.trial_type = "decision_prac";
      data.time_in_block = Date.now() - block_start;

      if (data.time_in_block > practice_block_len) {
        jsPsych.addNodeToEndOfTimeline({
          timeline: [run_instructions_3,quiz_prac],
        }, jsPsych.resumeExperiment);
        data.n_prac_rounds = n_prac_rounds

      } else if (jsPsych.pluginAPI.compareKeys(data.response, 'A')) {
        // they chose to arvest
        window.curr_prac_trial = curr_prac_trial + 1;
        curr_prac_trial += 1;

        jsPsych.addNodeToEndOfTimeline({
          timeline: [dig_prac, harvest_prac, decision_prac],
        }, jsPsych.resumeExperiment);

      } else if (jsPsych.pluginAPI.compareKeys(data.response, 'L')) {

        window.curr_prac_trial = curr_prac_trial + 1;
        curr_prac_trial += 1;
        curr_travel_trial += 1;
        //they chose travel
        jsPsych.addNodeToEndOfTimeline({
          timeline: [travel_prac, alien_welcome_prac, landing_prac, dig_prac, harvest_prac, decision_prac],
        }, jsPsych.resumeExperiment);

      } else {
        jsPsych.addNodeToEndOfTimeline({
          timeline: [time_out, decision_prac],
        }, jsPsych.resumeExperiment);
      }
      last_trial_data = jsPsych.data.get().last(2).values()[0];
      //console.log('decision trial data: ', last_trial_data);
      data.next_reward = last_trial_data.next_reward;
      data.curr_prac_trial = curr_prac_trial;
    }
    //}
  };

  var time_out = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <img src='${time_out_img}' class='fullscreen-image'>
    `,
    stimulus_height: 700,
    stimulus_duration: 2000, // in milliseconds
    trial_duration: 2000,
    choices: "NO_KEYS",
    on_finish: function (data) {
      data.trial_type = "time_out";
      var last_trial_data = jsPsych.data.get().last(2).values()[0];
      data.next_reward = last_trial_data.next_reward;
      //console.log('timeout trial data: ', last_trial_data)
    }
  }

  var catch_trial = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <img src='${catch_img}' class='fullscreen-image'>
    `,
    stimulus_height: 700,
    stimulus_duration: 10000, // in milliseconds
    trial_duration: 10000,
    choices: ['Z'],
    on_finish: function (data) {
      data.trial_type = "catch";
      var last_trial_data = jsPsych.data.get().last(2).values()[0];
      data.next_reward = last_trial_data.next_reward;
    }
  }

  var catch_trial_prac = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <img src='${catch_img}' class='fullscreen-image'>
    `,
    stimulus_height: 700,
    stimulus_duration: 10000, // in milliseconds
    trial_duration: 10000,
    choices: ['Z'],
    on_finish: function (data) {
      data.trial_type = "prac_catch";
      var last_trial_data = jsPsych.data.get().last(2).values()[0];
      data.next_reward = last_trial_data.next_reward;
    }
  }

  //Below are some questions to check that you understand the game. You can't move forward until you get all of them correct.</strong>
  // to check their understanding of the instructions
  var quiz_prac = {
    type: jsPsychSurveyHtmlForm,
    html: "<p><strong><h2>To continue, please answer the questions below:</h2></strong> </p><br><br><div class='quiz-container'><p>What affects the amount of bonus money you will earn?</p><input type='radio' name='Q0' value='A'> The number of planets you visit<br><input type='radio' name='Q0' value='B'>  How fast can you dig<br><input type='radio' name='Q0' value='C'> The number of gems you collect<br><br><p>The length of this experiment </p><input type='radio' name='Q1' value='A'> depends on how many planets you've visited.<br><input type='radio' name='Q1' value='B'> is fixed. <br><input type='radio' name='Q1' value='C'> depends on how many gems you've collected.<br><br><p>Every planet within one galaxy has different properties (such as the distance between the planets).</p><input type='radio' name='Q2' value='A'> True<br><input type='radio' name='Q2' value='B'> False<br><br><p>When do you appear in a new galaxy?</p><input type='radio' name='Q3' value='A'> After the break in the home base.<br><input type='radio' name='Q3' value='B'> At a random time.<br><input type='radio' name='Q3' value='C'> After you travel many times.<br> <br><br><br></div>",
    on_finish: function (data) {

      var answers_dict = [data.response.Q0, data.response.Q1, data.response.Q2, data.response.Q3];
      //console.log('my answers: ', answers_dict);

      data.trial_type = "quiz_prac";
      if (arraysMatch(correct_answers, answers_dict)) {
        // yay everything correct, can move forward
        quiz_correct_check = 3;

        jsPsych.addNodeToEndOfTimeline({
          timeline: [quiz_correct,instructions_begin_exp/*, instructions_practice_game, new_galaxy_prac, alien_welcome_prac, landing_prac, dig_prac, harvest_prac, decision_prac*/],
        }, jsPsych.resumeExperiment);


      } else {
        // got at least one thing wrong, need to go through instructions again
        quiz_correct_check = 2;
        jsPsych.addNodeToEndOfTimeline({
          timeline: [quiz_incorrect, run_instructions_1, instructions_dig, dig_instruc, harvest_instruc, instructions_travel, travel_prac, /* instructions_galaxy,*/  run_instructions_3, quiz_prac],
        }, jsPsych.resumeExperiment);

        window.num_quiz_failures = num_quiz_failures + 1;

      }
    }
  }

  var quiz_correct = {
    type: jsPsychSurveyHtmlForm,
    html: "<p><strong>Good job! You got all the questions correct!</strong></p> <br><br><div class='quiz-container'><p>What affects the amount of bonus money you will earn?</p><input type='radio' name='Q0' value='A'> The number of planets you visit<br><input type='radio' name='Q0' value='B'>  How fast can you dig<br><input type='radio' name='Q0' value='C' checked> The number of gems you collect<br><br><p>The length of this experiment </p><input type='radio' name='Q1' value='A'> depends on how many planets you've visited.<br><input type='radio' name='Q1' value='B' checked> is fixed. <br><input type='radio' name='Q1' value='C'> depends on how many gems you've collected.<br><br><p>Every planet within one galaxy has different properties (such as the distance between the planets).</p><input type='radio' name='Q2' value='A'> True<br><input type='radio' name='Q2' value='B' checked> False<br><br><p>When do you appear in a new galaxy?</p><input type='radio' name='Q3' value='A' checked> After the break in the home base.<br><input type='radio' name='Q3' value='B'> At a random time.<br><input type='radio' name='Q3' value='C'> After you travel many times.<br> <br><br><br></div>",
    button_label: 'Continue',
    on_finish: function (data) {
      data.trial_type = 'quiz_correct';
    }
  }

  var quiz_incorrect = {
    type: jsPsychSurveyHtmlForm,
    html: "<p><strong>You did not answer some questions correctly! You'll have to read over the instructions again.</strong></p>",
    button_label: 'read instructions again',
    on_finish: function (data) {
      data.trial_type = 'quiz_incorrect';
    }
  }

  var alien_welcome = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: time_out_img,
    stimulus_height: 700,
    stimulus_duration: 1, // in milliseconds
    trial_duration: 1,
    choices: "NO_KEYS",
    on_start: function (alien_welcome) {
      //console.log('aliens:', aliens);
      window.alien = aliens.shift().toString(); 
      window.aliens_copy.push(alien)
      var stim = "tasks/foraging/experiment/run_exp/static/images/task_images/aliens/alien_planet-".concat(alien, '.jpg')
      alien_welcome.stimulus = `<img src='${land_img}' class='fullscreen-image'>`;
    },
    on_finish: function (data) {
      window.planet = planet + 1;
      window.block_num_planet = block_num_planet + 1;
      data.alien = alien;
      data.aliens = aliens; // save the list of aliens here
      data.trial_type = "alien_welcome";
    }
  }

  var alien_welcome_prac = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: time_out_img,
    stimulus_height: 700,
    stimulus_duration: 1, // in milliseconds
    trial_duration: 1,
    choices: "NO_KEYS",
    on_start: function (alien_welcome_prac) {
      //console.log('aliens_prac', aliens_prac);
      window.alien = aliens_prac.pop().toString();
      //console.log('alien: ', alien, 'window.alien: ', window.alien);
      var stim = "tasks/foraging/experiment/run_exp/static/images/task_images/aliens/alien_planet-".concat(alien, '.jpg')
      alien_welcome_prac.stimulus = `<img src='${land_img}' class='fullscreen-image'>`;
    },
    on_finish: function (data) {
      window.planet = planet + 1;
      window.prac_block_num_planet = prac_block_num_planet + 1;
      data.trial_type = "alien_welcome_prac";
    }
  }


  /* INSTRUCTIONS   */

  // Welcome
  var welcome = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box' style='top: 0vh'>
      <p>In this game, you are an explorer traveling through space to collect space treasure.</p>
      <p>Your mission is to collect as much treasure as possible.</p>
      
      <br>
      <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
        <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px" disabled>&lt; Previous</button>
        <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
      </div>

    </div>
    <br><br>
    <img src='tasks/foraging/experiment/run_exp/static/images/task_images/opening_img-01.jpg' height='600' width='auto'>
    
    `,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_welcome";
    }
  };

  var instructions_goal = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box' style='top: 0vh'>
    <p>As a space explorer, you visit different planets to dig for space treasure, these pink gems.</p> 
    <p>The more space treasure you mine, the more performance bonus you get!</p>

    <br>
    <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
      <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px">&lt; Previous</button>
      <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;">Next &gt;</button>
    </div>

    </div>
    <br><br><p><img src='tasks/foraging/experiment/run_exp/static/images/task_images/pink_gem.png' height='300' width='auto'></p>
    `,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_goal";
    }
  };

  // instructions
  var instructions_dig = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>When you arrive at a new planet, you will dig once before you can make any choice.</p> 
    <p>Then, you get to decide if you want to stay on the planet and dig again or travel to a new planet and dig there.</p>
    <p> Press the letter <strong>'A'</strong> on the keyboard to stay and dig.</p><p>Try pressing it now! </p>

    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['A'],
    on_finish: function (data) {
      //data.next_reward = 100.0;
      data.next_reward = 10; // CHANGE TO 10
      data.trial_type = "instruc_dig"
    }
  };

  var instructions_travel = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p> The longer you mine a planet, the fewer gems you get with each dig.</p>
    <p>When gems are running low, you may want to travel to a new planet that has not been overmined. </p>
    <p> Planets are far apart, so it takes some time to travel between them. </p>
    <p> There are lots of planets for you to visit, so you cannot return to any planets you have already visited.</p>
    
    <!-- <p>Moreover, every planet has the same characteristics in terms of richness of gems and the distance to the other planets.</p> -->

    <p> Press the letter <strong>'L'</strong> on the keyboard to leave a planet and travel to a new one. Try pressing it now! </p>
    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/rocket-01.jpg' height='600' width='auto'></p>
    
    `,
    choices: ['L'],
    button_html: ['<button id="close-image" style="border-radius: 10px;"><img src="tasks/foraging/experiment/run_exp/static/images/task_images/button-travel.jpg" height=80></button>'],
    on_finish: function (data) {
      data.trial_type = "instruc_travel";
    }
  };
 //<p> Whenever you arrive to a new planet, an alien from that planet will greet you!</p>
  var instructions_alien = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box' style='top: -38vh'>
    <p> Now that you understand the choices you can make, travel or dig, you should know a few more things. </p>
      
      <br>
      <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
        <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px" disabled>&lt; Previous</button>
        <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;" >Next &gt;</button>
      </div>
    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    `,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_alien_greet";
    }
  }

  var decision_trial_dur = decision.trial_duration / 1000; //decision trial duration in seconds
  var instructions_time_out = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>You have ${decision_trial_dur} seconds to choose between digging or traveling.</p>
    <p>If you are too slow to make a choice, you have to wait a few seconds before you can make another one.</p>
    <p>While waiting, you cannot dig for more gems or travel to new planets. You just have to sit and wait.</p>
    <p><b>TIP:</b> You will spend in total <b>13 minutes playing the game</b> so try to maximize the amount of gems that will be converted to
    performance bonus.</p>
    
    <br>
    <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
      <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px">&lt; Previous</button>
      <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;" >Next &gt;</button>
    </div>
    </div>
    <br><p><img class='fullscreen-image' src="tasks/foraging/experiment/run_exp/static/images/task_images/time_out.jpg"  height="700" width="auto"></p>`,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "time_out";
    }
  }



  var instructions_galaxy = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>You will be playing the game in <b>2 different galaxies.</b></p>
    <p>In one galaxy, there are plenty of gems, and the gems you get will decrease slowly every time you dig. </p>
    <p>In other galaxies, gems are more rare, and the gems you get will quickly decrease after each dig. </p>
    <p> Press the <strong>space bar</strong> to continue </p>

    <br>
    <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
      <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px">&lt; Previous</button>
      <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;" >Next &gt;</button>
    </div>
    </div>
    <br><p><img class='fullscreen-image' src="tasks/foraging/experiment/run_exp/static/images/task_images/galaxy_prac.jpg"  height="700" width="auto"></p>`,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_galaxy";
    }
  };

  var instructions_galaxy_2 = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>You will be playing the game in <b>2 different galaxies.</b></p>
    <p>The distance between the planets is different for each galaxy. </p>
    <p>In one galaxy, planets are close together, and the travel time is faster.</p>
    <p>In the other galaxy, planets are further apart, and travel time is slower. </p>
    <p>You start in one galaxy and then move to the other galaxy after a break. </p>
    <p>The order of the galaxies is random and you will not be told in which galaxy you are. You need to figure it out by yourself. </p>
    <!-- <p> Press the <strong>space bar</strong> to continue </p> -->

    <br>
    <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
      <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px">&lt; Previous</button>
      <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;" >Next &gt;</button>
    </div>
    </div>
    <br><p><img class='fullscreen-image' src="tasks/foraging/experiment/run_exp/static/images/task_images/galaxy_prac.jpg"  height="700" width="auto"></p>`,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_galaxy";
    }
  };

  var instructions_practice_travel_1 = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>You will now perform a series of travels to experience how travel speed may change between galaxies.</p> 
    <p>You will travel 2 times in a row and then go to a different training galaxy and travel again. </p>
    <p> Press <strong>'L'</strong> to travel! </p>

    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['l']
  };

  var instructions_practice_travel_2a = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p> Press <strong>'L'</strong> to travel again! </p>

    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['l']
  };

  var instructions_practice_travel_2b = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p><p>You will now travel 2 more times in a second training galaxy. </p>
    <p>Press <strong>'L'</strong> to travel again! </p>

    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['l']
  };

  var instructions_galaxy_3 = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box' style='top: -36vh'>
    <p>You will need to consider the travel time and rate at which gems decrease when you decide whether to stay and dig or
    leave for a new planet. </p>

    <br>
    <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
      <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px">&lt; Previous</button>
      <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;" >Next &gt;</button>
    </div>
    </div>
    <br><p><img class='fullscreen-image' src="tasks/foraging/experiment/run_exp/static/images/task_images/galaxy_prac.jpg"  height="700" width="auto"></p>`,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_galaxy";
    }
  };

  var instructions_practice_dig_1 = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>You will now perform a series of digs to experience how the amount of gems collected may change between galaxies.</p> 
    <p> You will dig 3 times in a row and then go to a different training galaxy and dig again.</p>
    <p>The speed at which the gems decrease after each dig will differ between the two training galaxies. </p>
    <p>Press <strong>'A'</strong> to dig!</p>

    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['A'],
    on_finish: function (data) {
      //data.next_reward = 100.0;#
      data.next_reward = 10; //CHANGE TO 10
      data.trial_type = "instructions_practice_dig_1"
    }
  };

  var instructions_practice_dig_2a = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>Press <strong>'A'</strong> to dig a second time!</p>

    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['A'],
    on_finish: function (data) {
      //data.next_reward = 100.0;#
      data.next_reward = 10; //CHANGE TO 10
      data.trial_type = "instructions_practice_dig_1"
    }
  };

  var instructions_practice_dig_2b = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>Press <strong>'A'</strong> to dig a third time!</p>
    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['A'],
    on_finish: function (data) {
      //data.next_reward = 100.0;#
      data.next_reward = 10; //CHANGE TO 10
      data.trial_type = "instructions_practice_dig_1"
    }
  };

  var instructions_practice_dig_3 = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p>You will now perform 3 more digs in a second training galaxy. <p>
    <p>Press <strong>'A'</strong> to dig!</p>

    </div>
    <p><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>
    
    `,
    choices: ['A'],
    on_finish: function (data) {
      //data.next_reward = 100.0;#
      data.next_reward = 10; //CHANGE TO 10
      data.trial_type = "instructions_practice_dig_1"
    }
  };

  var instructions_break = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
    <p> After digging and traveling in the first galaxy, you will take a break at home base. </p>
    <p>You can spend at most 1 minute at home base - there are still a lot of gems left to collect! </p>
    <p>You will spend totally <strong>13 minutes</strong> mining gems and traveling to new planets no matter what.</p>
    <p>You will see a total of <b>2 galaxies</b> and visit the home base once during the game.</p>
    <p>You will arrive in a new galaxy after you leave the home base and stay there until the end of the game. </p>
    
    <br>
    <div class="jspsych-instructions-nav" style="display: block; left: 50%; position: absolute;transform: translateX(-50%);bottom: 5%;">
      <button id="jspsych-instructions-back" class="jspsych-btn" style="margin-right: 5px">&lt; Previous</button>
      <button id="jspsych-instructions-next" class="jspsych-btn" style="margin-left: 5px;" >Next &gt;</button>
    </div>
    </div>
    <br><img class='fullscreen-image' src='tasks/foraging/experiment/run_exp/static/images/task_images/home_base.jpg' height='700' width='auto'>
    `,
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_break";
    }
  }

  var instructions_practice_game = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box' style='top: 0vh'>
    <p> Now that you understand the rules of the game, you will play a practice game in a training galaxy.</p>
    <p> In this training galaxy, things are very similar to the real game. </p>
    <p> The travel speed and the speed at which gems decrease after each dig, however, differs from the real game. </p>
    <p> You will spend <strong>2 minutes</strong> practicing. </p>

    <p> Press the <strong>space bar</strong> to begin practice! </p>
    </div>
    <br><br>
    <img src='tasks/foraging/experiment/run_exp/static/images/task_images/opening_img-01.jpg' height='600' width='auto'>
    `,
    choices: [' '],
    on_finish: function (data) {
      window.block_start = Date.now();
      data.trial_type = "instruc_prac_game";
    }
  }

  var new_galaxy = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
      <h1>You are now travelling to a new galaxy!</h1>
    </div>
    
      
    
    `,
    trial_duration: 3000,
    choices: "NO_KEYS",
    data: {
      trial_type: "new_galaxy"
    },
    on_start: function (new_galaxy) {


      var block_str = b_num.toString();

      var str_to_display = `
      <div class='text-box'>
        <p style='font-size:25px;'>You are now traveling to galaxy #${block_str}</p>
      </div>

      <img src='tasks/foraging/experiment/run_exp/static/images/task_images/galaxy_${block_str}.jpg' class='fullscreen-image' width='auto'>
      `

      new_galaxy.stimulus = str_to_display;

    }
  };

  var new_galaxy_prac = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <div class='text-box'>
      <p style='font-size:25px;'>You are now travelling to a new training galaxy! </p>
    </div>
    <br>
    <img src='tasks/foraging/experiment/run_exp/static/images/task_images/galaxy_prac.jpg' class='fullscreen-image' width='auto'>
    `,
    trial_duration: 3000,
    choices: "NO_KEYS",
    data: {
      trial_type: "new_galaxy_prac"
    }
  };

  var instructions_begin_exp = {
    type: jsPsychHtmlButtonResponse,
    stimulus: `
    <div class='text-box'  style='top: 0vh'>
    <h3 "margin-top: 0px">Practice finished!</h3>
    <p>Now that you know how  to dig for space treasure and travel to new planets, you can start exploring the universe! </p>
    </div>
    <br>
    <img src='tasks/foraging/experiment/run_exp/static/images/task_images/opening_img-01.jpg' height='600' width='auto'>`
    ,
    choices: ['Move on to the real game'],
    on_finish: function (data) {

      jsPsych.addNodeToEndOfTimeline({
        timeline: [/*new_galaxy,*/ alien_welcome, landing, dig, harvest, decision],
      }, jsPsych.resumeExperiment);
      data.n_prac_rounds = n_prac_rounds;
      window.block_start = Date.now();

      data.trial_type = "instruc_begin_exp";
    }
  };


  var end_of_block = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p> You have been traveling for a while in that galaxy. Time to take a rest at home base! </p> <p> When you are ready to continue, press <strong>continue</strong>. </p><p><img src='tasks/foraging/experiment/run_exp/static/images/task_images/home_base.jpg' height='700' width='auto'>",
    choices: [' '],
    stimulus_duration: 60000, // in milliseconds
    trial_duration: 60000,
    on_start: function (end_of_block) {
      var begin_para = "<p> You have been traveling for a while in that galaxy. Time to take a 1-minute rest at home base! </p> <p> If you are ready to move on to a <b>new galaxy</b> earlier, press the <strong>space bar</strong>. </p>"
      var img = "<img src='tasks/foraging/experiment/run_exp/static/images/task_images/home_base.jpg' class='fullscreen-image' width='auto'>";
      var block_str = '';
      var home_base = "<p style='font-size:25px;'> Home Base Visit";
      var para_end = "</p>";
      var str_to_display = home_base.concat(block_str, begin_para, para_end);
      end_of_block.stimulus = `
      <div class='text-box'>
        <p>${str_to_display}</p>
      </div>
      ${img}
      `;
    },
    on_finish: function (data) {
      window.block_space_treasure = 0;
      data.trial_type = "end_of_block";
      jsPsych.addNodeToEndOfTimeline({
        timeline: [/* new_galaxy, */ alien_welcome, landing, dig, harvest, decision],
      }, jsPsych.resumeExperiment);
      window.block_start = Date.now();
      catch_trial_finished = false;
      //save_data(false) //save data at end of block
    }
  };

  var end_of_block_prac = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p> You have been traveling for a while. Time to take a rest at home base! </p> <p> When you are ready to continue, press <strong>continue</strong>. </p><p><img src='tasks/foraging/experiment/run_exp/static/images/task_images/home_base.jpg' height='700' width='auto'>",
    choices: [' '],
    stimulus_duration: 60000, // in milliseconds
    trial_duration: 60000,
    on_start: function (end_of_block_prac) {
      var begin_para = "<p> You have been traveling for a while. Time to take a rest at home base! </p> <p> When you are ready to move one, press the <strong>space bar</strong>. </p>"
      var img = "<img src='tasks/foraging/experiment/run_exp/static/images/task_images/home_base.jpg' class='fullscreen-image' width='auto'>";
      var block_str = (prac_b_num - 1).toString();
      var home_base = "<p style='font-size:25px;'> Home Base Visit #";
      var para_end = "</p>";
      var str_to_display = home_base.concat(block_str, begin_para, para_end);
      end_of_block_prac.stimulus = `
      <div class='text-box'>
        <p>${str_to_display}</p>
      </div>
      ${img}
      `;
    },
    on_finish: function (data) {
      window.block_space_treasure = 0;
      data.trial_type = "prac_end_of_block";
      jsPsych.addNodeToEndOfTimeline({
        timeline: [new_galaxy_prac, alien_welcome_prac, landing_prac, dig_prac, harvest_prac, decision_prac],
      }, jsPsych.resumeExperiment);
      window.block_start = Date.now();
      catch_trial_finished = false;
      //save_data(false) //save data at end of block
    }
  };

  var end_of_experiment = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<p> Congrats! You are done with the game!</p> <p> Make sure to submit your HIT! Press the <strong>space bar</strong> to quit. </p><br><br><p><img src="tasks/foraging/experiment/run_exp/static/images/task_images/opening_img-01.jpg"</p>',
    choices: [' '],
    on_start: function (end_of_experiment) {

      bonus_foraging = Math.round(total_space_treasure * cents_per_gem * 100) / 100; //2 decimals
      //console.log('bonus_foraging: ', bonus_foraging, 'window.total_space_treasure: ', window.total_space_treasure, 'total_space_treasure: ', total_space_treasure, 'cents_per_gem: ', cents_per_gem);

      //Update global variables to be passed on to next task
      taskNumber++
      performanceBonus += bonus_foraging;
      //console.log('performanceBonus: ', performanceBonus, 'taskNumber: ', taskNumber);

      var begin_para = "<p> <b>Congrats!</b> You are done with the game!</p>";
      var begin_bonus = "<p> You earned a performance bonus of ";
      var bonus_str = bonus_foraging.toString();
      var end_bonus = `&pound out of ${bonus_per_task}&pound in this game.</p>`;

      var total_bonus_all_tasks = "<p>You have earned a total performance bonus of "
      var perform_show = performanceBonus.toString();
      var perform_end = "&pound. </p>"

      var end_para = "<p> You will just answer some questions and then you will be finished! </p><p>Press the <strong>space bar</strong> to continue. </p><br><br><p><img src='tasks/foraging/experiment/run_exp/static/images/task_images/opening_img-01.jpg' height='600' width='auto'></p>"
      end_of_experiment.stimulus = begin_para.concat(begin_bonus, bonus_str, end_bonus, total_bonus_all_tasks, perform_show, perform_end, end_para)
      window.bonus = bonus_foraging;

      //save bonus to data
      jsPsych.data.addProperties({
        bonus_foraging: bonus_foraging
      });

    },
    on_finish: function (data) {
      /* data.bonus_foraging = bonus_foraging; */
      data.num_failures = num_quiz_failures
      data.trial_type = "end_of_exp";

    }
  };


  var demographics = {
    type: jsPsychSurveyHtmlForm,
    html: "<p>How old are you in years? Enter '-1' if you would prefer not to respond.</p><input id='age' name='age' type='number' min='-1' style='height:45px; width:80px'/><div class='question'> <p class='questiontext'><br>What gender do you identify with?</p><select id='gender' name='gender'><option value='noresp' SELECTED></option><option value='female'>Female</option><option value='male'>Male</option><option value='other'>Other</option><option value='noresponse'>I'd prefer not to respond</option><select></div>",
    on_finish: function (data) {
      data.trial_type = "demo"
    }
  };

  var quic_intro = {
    type: jsPsychSurveyHtmlForm,
    html: "The following questions will ask about your childhood. They will ask about the environment you grew up in and events you may have experienced.<br><br>",
    on_finish: function (data) {
      data.trial_type = "quic_intro"
    }
  };

  var quic_options = ["Yes", "No", "Prefer not to answer"];

  var quic_prior_12 = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<strong>Please answer these questions about your childhood prior to age 12.</strong>",
    questions: [{ prompt: "I had a set morning routine on school days (i.e., I usually did the same thing each day to get ready).", options: quic_options, required: true },
    { prompt: "My parents kept track of what I ate (e.g., made sure that I didn't skip meals or tried to make sure I ate healthy food).", options: quic_options, required: true },
    { prompt: "My family ate a meal together most days.", options: quic_options, required: true },
    { prompt: "My parents tried to make sure I got a good night's sleep (e.g., I had a regular bedtime, my parents checked to make sure I went to sleep).", options: quic_options, required: true },
    { prompt: "I had a bedtime routine (e.g., my parents tucked me in, my parents read me a book, I took a bath).", options: quic_options, required: true },
    { prompt: "In my afterschool or free time hours at least one of my parents knew what I was doing", options: quic_options, required: true },
    { prompt: "At least one of my parents regularly checked that I did my homework", options: quic_options, required: true },
    { prompt: "My parents were often late to pick me up (e.g. from school, aftercare or sports).", options: quic_options, required: true },
    { prompt: "I usually knew when my parents were going to be home.", options: quic_options, required: true },
    ],
    on_finish: function (data) {
      data.trial_type = "quic_prior_12"
    }
  };

  var quic_prior_18 = {
    type: jsPsychSurveyMultiChoice,
    preamble: "<strong>Please answer these questions about your childhood prior to age 18.</strong>",
    questions: [{ prompt: "At least one of my parents regularly kept track of my school progress", options: quic_options, required: true },
    { prompt: "At least one parent made time each day to see how I was doing", options: quic_options, required: true },
    { prompt: "At least one of my parents had punishments that were unpredictable", options: quic_options, required: true },
    { prompt: "I often wondered whether or not one of my parents would come home at the end of the day.", options: quic_options, required: true },
    { prompt: "My family planned activities to do together.", options: quic_options, required: true },
    { prompt: "At least one of my parents would plan something for the family, but then not follow through with the plan.", options: quic_options, required: true },
    { prompt: "My family had holiday traditions that we did every year (e.g., cooking a special food at a particular time of year/decorate the house the same way).", options: quic_options, required: true },
    { prompt: "At least one of my parents was disorganized", options: quic_options, required: true },
    { prompt: "At least one of my parents was unpredictable", options: quic_options, required: true },
    { prompt: "For at least one of my parents, when they were upset I did not know how they would act", options: quic_options, required: true },
    { prompt: "One of my parents could go from calm to furious in an instant", options: quic_options, required: true },
    { prompt: "One of my parents could go from calm to stressed or nervous in an instant", options: quic_options, required: true },
    { prompt: "There was a long period of time when I didn't see one of my parents (e.g. military deployment, jail time, custody arrangements)", options: quic_options, required: true },
    { prompt: "I experienced changes in my custody arrangement", options: quic_options, required: true },
    { prompt: "At least one of my parents changed jobs frequently", options: quic_options, required: true },
    { prompt: "There were times when one of my parents was unemployed and couldn't find a job even though he/she wanted one.", options: quic_options, required: true },
    { prompt: "My parents had a stable relationship with each other.", options: quic_options, required: true },
    { prompt: "My parents got divorced.", options: quic_options, required: true },
    { prompt: "At least one of my parents had many romantic partners", options: quic_options, required: true },
    { prompt: "There were often people coming and going in my house that I did not expect to be there", options: quic_options, required: true },
    { prompt: "I moved frequently", options: quic_options, required: true },
    { prompt: "I changed schools frequently", options: quic_options, required: true },
    { prompt: "I changed schools mid-year", options: quic_options, required: true },
    { prompt: "I lived in a clean house.", options: quic_options, required: true },
    { prompt: "I lived in a cluttered house (e.g., piles of stuff everywhere)", options: quic_options, required: true },
    { prompt: "In my house things I needed were often misplaced so that I could not find them", options: quic_options, required: true },
    { prompt: "There was a period of time when I often worried that I was not going to have enough food to eat", options: quic_options, required: true },
    { prompt: "There was a period of time when I often worried that my family would not have enough money to pay for necessities like clothing or bills", options: quic_options, required: true },
    { prompt: "There was a period of time when I did not feel safe in my home", options: quic_options, required: true },
    ],
    on_finish: function (data) {
      data.trial_type = "quic_prior_18"
    }
  };



  // Debriefing questionnaire
  var DEBRIEF_01 = {
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
    on_finish: function () {
      removeStyles();
      jsPsych.timeline.timeline_parameters.timeline = jsPsych.timeline.timeline_parameters.timeline.concat(the_rest_of_timeline); // concat the rest of the timeline 
    },
    data: {
      parsing: 'end_foraging',
      task: 'debrief_foraging'
    }
  }

  /* Run the instructions */

  //Pages for the first set of instructions
  const instruct_stimuli_1 = [
    welcome.stimulus,
    instructions_goal.stimulus,
  ];

  //first set of instructions
  var run_instructions_1 = {
    type: jsPsychInstructions,
    pages: instruct_stimuli_1,
    data: {
      task: 'welcome'
    },
    show_clickable_nav: true,
  };

  //second set of instructions
  const run_instructions_2 = [
    instructions_dig,
    dig_instruc,
    harvest_instruc,
    instructions_travel,
    travel_prac
  ];

  const instruct_stimuli_2b = [
    instructions_galaxy_2.stimulus
  ];

  var run_instructions_2b = {
    type: jsPsychInstructions,
    pages: instruct_stimuli_2b,
    data: {
      task: 'decay travel instruc'
    },
    show_clickable_nav: true,
  }

  //Pages for the third set of instructions
  const instruct_stimuli_3 = [
    instructions_alien.stimulus,
    instructions_time_out.stimulus,
    instructions_galaxy_2.stimulus,
    instructions_break.stimulus
    
  ];

  //third set of instructions
  var run_instructions_3 = {
    type: jsPsychInstructions,
    pages: instruct_stimuli_3,
    data: {
      task: 'welcome'
    },
    show_clickable_nav: true,
  };

  const instruct_stimuli_4 = [
    instructions_alien.stimulus,
    instructions_time_out.stimulus,
/*     instructions_galaxy.stimulus,
     instructions_galaxy_2.stimulus,
    instructions_break.stimulus*/
  ];

  var run_instructions_4 = {
    type: jsPsychInstructions,
    pages: instruct_stimuli_4,
    data: {
      task: 'welcome'
    },
    show_clickable_nav: true,
  };

  // Create an array with all the variables
  var experimentArray = [
    //welcome,  // Welcome to the experiment
    //instructions_goal, // introduce goal of the game
    
    run_instructions_1,
    instructions_dig, // Practice pressing A to dig
    dig_instruc,
    harvest_instruc,
    instructions_travel, //practice pressing L to travel
    travel_prac,
    instructions_practice_game,
    landing_prac, //landing on a new planet
    decision_prac, //practice making a decision

    /* instructions_galaxy, */ //you will travel to different galaxies (with different decay rates)

/*     instructions_practice_dig_1, //they will now perform some digs, speed at which the gems decrease after each dig will differ between the two training galaxies.
    dig_instruc, //dig animation
    harvest_instruc, //the harvest
    instructions_practice_dig_2a, //press A to dig second time
    dig_instruc, //dig animation
    harvest_instruc, //the harvest
    instructions_practice_dig_2b, //press A to dig third time
    dig_instruc, //dig animation
    harvest_instruc, //the harvest

    new_galaxy_prac, //you are now going to a new galaxy - change? Training?
    instructions_practice_dig_3, //time for 3 more digs - needs to be updated
    dig_instruc, //dig animation
    harvest_instruc, //the harvest
    instructions_practice_dig_2a, //press A to dig second time
    dig_instruc, //dig animation
    harvest_instruc, //the harvest
    instructions_practice_dig_2b, //press A to dig third time
    dig_instruc, //dig animation
    harvest_instruc, //the harvest */

/*     instructions_galaxy_2, //the distance between planets also varies (some are close, others far apart) - remove next?
    instructions_practice_travel_1, //You will now perform a series of TRAVEL ETC ETC - needs to be updated
    travel_prac, //travel
    instructions_practice_travel_2a, //press L to travel again- needs to be updated
    travel_prac, //travel

    new_galaxy_prac, //you are now going to a new galaxy - change? Training?
    instructions_practice_travel_2b, //and another time travel (new galaxy) - - needs to be updated 
    travel_prac, //travel
    instructions_practice_travel_2a, //press L to travel again- needs to be updated
    travel_prac, //travel */

    // Add to the end of the training
    //run_instructions_3, //rest of instructions: alien will greet you at new planet, timeout, and home base 
    // Show them home base
    //quiz_prac,   // quiz to check understanding
  ];
  // Push the experimentArray to the timeline array
  if (SKIP_TRAINING_FORAGING == true || day > 1) {
    experimentArray = [
    run_instructions_1,
    instructions_dig, // Practice pressing A to dig
    dig_instruc,
    harvest_instruc,
    instructions_travel, //practice pressing L to travel
    travel_prac,
    run_instructions_3,
    quiz_prac
    ];

    timeline.push(...experimentArray);
  } else {
    timeline.push(...experimentArray);
  }
  //console.log('this is the foraging timeline: ', timeline);


  //console.log('This is the timeline returned from the foraging task!!!!  ', timeline)
  return timeline;
}