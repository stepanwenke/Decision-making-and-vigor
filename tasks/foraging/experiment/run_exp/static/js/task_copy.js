var alien = 1;
var aliens_copy = [];

// when to end block timing
var b_num = 1;
var block_num_planet = 0;

function foragingTask() {

  var styleElement;

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


  var debug_mode = 0; // debug mode determines how long the blocks are, 5 sec in debug mode, 5 minutes in actual experiment
  //var data_save_method = 'csv_server_py';
  var data_save_method = 'csv_server_py';

  // timeout vars
  var TIMEOUT_WARNINGS = 0; // record how many times (per trial) a participant was prompted to respond faster
  var TOTAL_TIMEOUT_WARNINGS = 0; // total timeout warnings throughout the experiment
  var TIMEOUT_TRL_THRESHOLD = 3 // after how many timeout warnings (in one trial) will the participant be excluded from the study
  var TIMEOUT_TOTAL_THRESHOLD = 4; // after how many timeouts counted throughout the whole experiment will the participant be excluded        
  var WARNING_DURATION = 900 // duration of the displayed timeout warning (in ms)
  var PARTICIPANT_EXCLUDED = false;

  // atentional checks
  var nrMissedAttenChecks = 0;
  var MAX_MISSED_ATTEN_CHECKS = 2;

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

  // Will be set to true when experiment is exiting fullscreen normally, to prevent above end experiment code
  var normal_exit = false;
  var window_height = window.screen.height;


  var image_prefix = "foraging/experiment/run_exp/static/images/task_images/";
  var image_prefix_button = "<img src=foraging/experiment/run_exp/static/images/task_images/";

  var all_images = [image_prefix + "land.jpg", image_prefix + "dig.jpg", image_prefix + "barrel_text.jpg",
  image_prefix + "rocket-01.jpg", image_prefix + "rocket-02.jpg", image_prefix + "rocket-03.jpg",
  image_prefix + "rocket-04.jpg", image_prefix + "rocket-05.jpg", image_prefix + "rocket-06.jpg", image_prefix + "rocket-07.jpg",
  image_prefix + "rocket-08.jpg", image_prefix + "rocket-09.jpg", image_prefix + "gems/0.jpg", image_prefix + "gems/1.jpg",
  image_prefix + "gems/2.jpg", image_prefix + "gems/3.jpg", image_prefix + "gems/4.jpg", image_prefix + "gems/5.jpg",
  image_prefix + "gems/6.jpg", image_prefix + "gems/7.jpg", image_prefix + "gems/8.jpg", image_prefix + "gems/9.jpg",
  image_prefix + "gems/10.jpg", image_prefix + "gems/11.jpg", image_prefix + "gems/12.jpg", image_prefix + "gems/13.jpg",
  image_prefix + "gems/14.jpg", image_prefix + "gems/15.jpg", image_prefix + "gems/16.jpg", image_prefix + "gems/17.jpg",
  image_prefix + "gems/18.jpg", image_prefix + "gems/19.jpg", image_prefix + "gems/20.jpg", image_prefix + "gems/21.jpg",
  image_prefix + "gems/22.jpg", image_prefix + "gems/23.jpg", image_prefix + "gems/24.jpg", image_prefix + "gems/25.jpg",
  image_prefix + "gems/26.jpg", image_prefix + "gems/27.jpg", image_prefix + "gems/28.jpg", image_prefix + "gems/29.jpg",
  image_prefix + "gems/30.jpg", image_prefix + "gems/31.jpg", image_prefix + "gems/32.jpg", image_prefix + "gems/33.jpg",
  image_prefix + "gems/34.jpg", image_prefix + "gems/35.jpg", image_prefix + "gems/36.jpg", image_prefix + "gems/37.jpg",
  image_prefix + "gems/38.jpg", image_prefix + "gems/39.jpg", image_prefix + "gems/40.jpg", image_prefix + "gems/41.jpg",
  image_prefix + "gems/42.jpg", image_prefix + "gems/43.jpg", image_prefix + "gems/44.jpg", image_prefix + "gems/45.jpg",
  image_prefix + "gems/46.jpg", image_prefix + "gems/47.jpg", image_prefix + "gems/48.jpg", image_prefix + "gems/49.jpg",
  image_prefix + "gems/50.jpg", image_prefix + "gems/51.jpg", image_prefix + "gems/52.jpg", image_prefix + "gems/53.jpg",
  image_prefix + "gems/54.jpg", image_prefix + "gems/55.jpg", image_prefix + "gems/56.jpg", image_prefix + "gems/57.jpg",
  image_prefix + "gems/58.jpg", image_prefix + "gems/59.jpg", image_prefix + "gems/60.jpg", image_prefix + "gems/61.jpg",
  image_prefix + "gems/62.jpg", image_prefix + "gems/63.jpg", image_prefix + "gems/64.jpg", image_prefix + "gems/65.jpg",
  image_prefix + "gems/66.jpg", image_prefix + "gems/67.jpg", image_prefix + "gems/68.jpg", image_prefix + "gems/69.jpg",
  image_prefix + "gems/70.jpg", image_prefix + "gems/71.jpg", image_prefix + "gems/72.jpg", image_prefix + "gems/73.jpg",
  image_prefix + "gems/74.jpg", image_prefix + "gems/75.jpg", image_prefix + "gems/76.jpg", image_prefix + "gems/77.jpg",
  image_prefix + "gems/78.jpg", image_prefix + "gems/79.jpg", image_prefix + "gems/80.jpg", image_prefix + "gems/81.jpg",
  image_prefix + "gems/82.jpg", image_prefix + "gems/83.jpg", image_prefix + "gems/84.jpg", image_prefix + "gems/85.jpg",
  image_prefix + "gems/86.jpg", image_prefix + "gems/87.jpg", image_prefix + "gems/88.jpg", image_prefix + "gems/89.jpg",
  image_prefix + "gems/90.jpg", image_prefix + "gems/91.jpg", image_prefix + "gems/92.jpg", image_prefix + "gems/93.jpg",
  image_prefix + "gems/94.jpg", image_prefix + "gems/95.jpg", image_prefix + "gems/96.jpg", image_prefix + "gems/97.jpg",
  image_prefix + "gems/98.jpg", image_prefix + "gems/99.jpg", image_prefix + "gems/100.jpg", image_prefix + "gems/101.jpg",
  image_prefix + "gems/102.jpg", image_prefix + "gems/103.jpg", image_prefix + "gems/104.jpg", image_prefix + "gems/105.jpg",
  image_prefix + "gems/106.jpg", image_prefix + "gems/107.jpg", image_prefix + "gems/108.jpg", image_prefix + "gems/109.jpg",
  image_prefix + "gems/110.jpg", image_prefix + "gems/111.jpg", image_prefix + "gems/112.jpg", image_prefix + "gems/113.jpg",
  image_prefix + "gems/114.jpg", image_prefix + "gems/115.jpg", image_prefix + "gems/116.jpg", image_prefix + "gems/117.jpg",
  image_prefix + "gems/118.jpg", image_prefix + "gems/119.jpg", image_prefix + "gems/120.jpg", image_prefix + "gems/121.jpg",
  image_prefix + "gems/122.jpg", image_prefix + "gems/123.jpg", image_prefix + "gems/124.jpg", image_prefix + "gems/125.jpg",
  image_prefix + "gems/126.jpg", image_prefix + "gems/127.jpg", image_prefix + "gems/128.jpg", image_prefix + "gems/129.jpg",
  image_prefix + "gems/130.jpg", image_prefix + "gems/131.jpg", image_prefix + "gems/132.jpg", image_prefix + "gems/133.jpg",
  image_prefix + "gems/134.jpg", image_prefix + "gems/135.jpg", image_prefix + "opening_img-01.jpg", image_prefix + "home_base.jpg",
  image_prefix + "time_out.jpg", image_prefix + "catch.jpg", image_prefix + "aliens/alien_planet-1.jpg",
  image_prefix + "aliens/alien_planet-1.jpg", image_prefix + "aliens/alien_planet-2.jpg", image_prefix + "aliens/alien_planet-3.jpg",
  image_prefix + "aliens/alien_planet-4.jpg", image_prefix + "aliens/alien_planet-5.jpg", image_prefix + "aliens/alien_planet-6.jpg",
  image_prefix + "aliens/alien_planet-7.jpg", image_prefix + "aliens/alien_planet-8.jpg", image_prefix + "aliens/alien_planet-9.jpg",
  image_prefix + "aliens/alien_planet-10.jpg", image_prefix + "aliens/alien_planet-11.jpg", image_prefix + "aliens/alien_planet-12.jpg",
  image_prefix + "aliens/alien_planet-13.jpg", image_prefix + "aliens/alien_planet-14.jpg", image_prefix + "aliens/alien_planet-15.jpg",
  image_prefix + "aliens/alien_planet-16.jpg", image_prefix + "aliens/alien_planet-17.jpg", image_prefix + "aliens/alien_planet-18.jpg",
  image_prefix + "aliens/alien_planet-19.jpg", image_prefix + "aliens/alien_planet-20.jpg", image_prefix + "aliens/alien_planet-21.jpg",
  image_prefix + "aliens/alien_planet-22.jpg", image_prefix + "aliens/alien_planet-23.jpg", image_prefix + "aliens/alien_planet-24.jpg",
  image_prefix + "aliens/alien_planet-25.jpg", image_prefix + "aliens/alien_planet-26.jpg", image_prefix + "aliens/alien_planet-27.jpg",
  image_prefix + "aliens/alien_planet-28.jpg", image_prefix + "aliens/alien_planet-29.jpg", image_prefix + "aliens/alien_planet-30.jpg",
  image_prefix + "aliens/alien_planet-31.jpg", image_prefix + "aliens/alien_planet-32.jpg", image_prefix + "aliens/alien_planet-33.jpg",
  image_prefix + "aliens/alien_planet-34.jpg", image_prefix + "aliens/alien_planet-35.jpg", image_prefix + "aliens/alien_planet-36.jpg",
  image_prefix + "aliens/alien_planet-37.jpg", image_prefix + "aliens/alien_planet-38.jpg", image_prefix + "aliens/alien_planet-39.jpg",
  image_prefix + "aliens/alien_planet-40.jpg", image_prefix + "aliens/alien_planet-41.jpg", image_prefix + "aliens/alien_planet-42.jpg",
  image_prefix + "aliens/alien_planet-43.jpg", image_prefix + "aliens/alien_planet-44.jpg", image_prefix + "aliens/alien_planet-45.jpg",
  image_prefix + "aliens/alien_planet-46.jpg", image_prefix + "aliens/alien_planet-47.jpg", image_prefix + "aliens/alien_planet-48.jpg",
  image_prefix + "aliens/alien_planet-49.jpg", image_prefix + "aliens/alien_planet-50.jpg", image_prefix + "aliens/alien_planet-51.jpg",
  image_prefix + "aliens/alien_planet-52.jpg", image_prefix + "aliens/alien_planet-53.jpg", image_prefix + "aliens/alien_planet-54.jpg",
  image_prefix + "aliens/alien_planet-55.jpg", image_prefix + "aliens/alien_planet-56.jpg", image_prefix + "aliens/alien_planet-57.jpg",
  image_prefix + "aliens/alien_planet-58.jpg", image_prefix + "aliens/alien_planet-59.jpg", image_prefix + "aliens/alien_planet-60.jpg",
  image_prefix + "aliens/alien_planet-61.jpg", image_prefix + "aliens/alien_planet-62.jpg", image_prefix + "aliens/alien_planet-63.jpg",
  image_prefix + "aliens/alien_planet-64.jpg", image_prefix + "aliens/alien_planet-65.jpg", image_prefix + "aliens/alien_planet-66.jpg",
  image_prefix + "aliens/alien_planet-67.jpg", image_prefix + "aliens/alien_planet-68.jpg", image_prefix + "aliens/alien_planet-69.jpg",
  image_prefix + "aliens/alien_planet-70.jpg", image_prefix + "aliens/alien_planet-71.jpg", image_prefix + "aliens/alien_planet-72.jpg",
  image_prefix + "aliens/alien_planet-73.jpg", image_prefix + "aliens/alien_planet-74.jpg", image_prefix + "aliens/alien_planet-75.jpg",
  image_prefix + "aliens/alien_planet-76.jpg", image_prefix + "aliens/alien_planet-77.jpg", image_prefix + "aliens/alien_planet-78.jpg",
  image_prefix + "aliens/alien_planet-79.jpg", image_prefix + "aliens/alien_planet-80.jpg", image_prefix + "aliens/alien_planet-81.jpg",
  image_prefix + "aliens/alien_planet-82.jpg", image_prefix + "aliens/alien_planet-83.jpg", image_prefix + "aliens/alien_planet-84.jpg",
  image_prefix + "aliens/alien_planet-85.jpg", image_prefix + "aliens/alien_planet-86.jpg", image_prefix + "aliens/alien_planet-87.jpg",
  image_prefix + "aliens/alien_planet-88.jpg", image_prefix + "aliens/alien_planet-89.jpg", image_prefix + "aliens/alien_planet-90.jpg",
  image_prefix + "aliens/alien_planet-91.jpg", image_prefix + "aliens/alien_planet-92.jpg", image_prefix + "aliens/alien_planet-93.jpg",
  image_prefix + "aliens/alien_planet-94.jpg", image_prefix + "aliens/alien_planet-95.jpg", image_prefix + "aliens/alien_planet-96.jpg",
  image_prefix + "aliens/alien_planet-97.jpg", image_prefix + "aliens/alien_planet-98.jpg", image_prefix + "aliens/alien_planet-99.jpg",
  image_prefix + "aliens/alien_planet-100.jpg", image_prefix + "aliens/alien_planet-101.jpg", image_prefix + "aliens/alien_planet-102.jpg",
  image_prefix + "aliens/alien_planet-103.jpg", image_prefix + "aliens/alien_planet-104.jpg", image_prefix + "aliens/alien_planet-105.jpg",
  image_prefix + "aliens/alien_planet-106.jpg", image_prefix + "aliens/alien_planet-107.jpg", image_prefix + "aliens/alien_planet-108.jpg",
  image_prefix + "aliens/alien_planet-109.jpg", image_prefix + "aliens/alien_planet-110.jpg", image_prefix + "aliens/alien_planet-111.jpg",
  image_prefix + "aliens/alien_planet-112.jpg", image_prefix + "aliens/alien_planet-113.jpg", image_prefix + "aliens/alien_planet-114.jpg",
  image_prefix + "aliens/alien_planet-115.jpg", image_prefix + "aliens/alien_planet-116.jpg", image_prefix + "aliens/alien_planet-117.jpg",
  image_prefix + "aliens/alien_planet-118.jpg", image_prefix + "aliens/alien_planet-119.jpg", image_prefix + "aliens/alien_planet-120.jpg",
  image_prefix + "aliens/alien_planet-121.jpg", image_prefix + "aliens/alien_planet-122.jpg", image_prefix + "aliens/alien_planet-123.jpg",
  image_prefix + "aliens/alien_planet-124.jpg", image_prefix + "aliens/alien_planet-125.jpg"];

  // default images
  const decision_img = [image_prefix + "land.jpg"];
  const land_img = [image_prefix + "land.jpg"]
  const dig_img = [image_prefix + "dig.jpg"];
  const space_treasure_img = [image_prefix + "gems/100.jpg"];
  const harvest_practice_img = [image_prefix + "barrel_text.jpg"];
  const travel_sequence = [image_prefix + "rocket-01.jpg", image_prefix + "rocket-02.jpg", image_prefix + "rocket-03.jpg",
  image_prefix + "rocket-04.jpg", image_prefix + "rocket-05.jpg", image_prefix + "rocket-06.jpg", image_prefix + "rocket-07.jpg",
  image_prefix + "rocket-08.jpg", image_prefix + "rocket-09.jpg"];

  const dig_sequence = [image_prefix + "dig.jpg", image_prefix + "land.jpg", image_prefix + "dig.jpg"];

  const time_out_img = [image_prefix + "time_out.jpg"];
  const catch_img = [image_prefix + "catch.jpg"];


  if (debug_mode) {
    var total_num_blocks = 0;
    var block_len = 20000;
    var n_prac_trials = 0;
  } else {
    var total_num_blocks = 2;
    //var block_len = [360000,360000,360000,360000,360000]; // array of how long block_len should be
    var block_len = [30000, 30000];
    var n_prac_trials = 6;

  }

  // number of planets visited and time spent on planet
  //const condition = 1;
  var planet = 0;
  var prt = 0;
  var total_space_treasure = 0;
  var cents_per_gem = 0.01; /* 5000 gems you get a dollar */
  var planet_left, planet_right, alien_left, alien_right;
  var num_planets = []; // keep track of number of planets we visit in each block
  /* var block_num_planet = 0; */

  // practice trials
  var curr_prac_trial = 1;
  var n_prac_rounds = 1;

  // aliens
  var aliens_prac = [118, 119, 120, 121, 122, 123, 124];
  var aliens = rand_list(120); // will pop every time use a new alien
  /* var aliens_copy = []; */
  /*  var alien = 1; */


  var num_quiz_failures = 0;
  // for quiz
  var correct_answers = ['C', 'B', 'B'];

  // when the participant is disconnected
  function timeoutDisconnect() {
    PARTICIPANT_EXCLUDED = true;
    window.location.href = MTURL;
  }


  //##########//#//##//////##//######//#///////#//##////#//######/////////####///######///####///#//##////#//////////////////////////////////////////
  //////#///////#//#/#////#/#//#///////#///////#//#/#///#//#//////////////#///#//#///////#///////#//#/#///#//////////////////////////////////////////
  //////#///////#//#//#//#//#//#####///#///////#//#//#//#//#####//////////####///####////#//##///#//#//#//#//////////////////////////////////////////
  //////#///////#//#///##///#//#///////#///////#//#///#/#//#//////////////#///#//#///////#////#//#//#///#/#//////////////////////////////////////////
  //////#///////#//#////////#//######//######//#//#////##//######/////////####///######///####///#//#////##//////////////////////////////////////////


  var timeline = []; // structures the experiment


  //Pavlovia initialization
  if (PAV == true) {
    let pavlovia_init = {
      type: jsPsychPavlovia,
      command: "init",
      setPavloviaInfo: function (info) {
        console.log('initializing pavlovia: ', info);
        pavloviaInfo = info;
      }
    };
    timeline.push(pavlovia_init);
  }



  var preload = {
    /* on_start: function () {
      setStyles();
      console.log('THIS IS WHERE WE SET STYLE!');
    }, */
    type: jsPsychPreload,
    images: all_images,
  };


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
      console.log('THIS IS WHERE WE SET STYLE!');
    }
  };

  /////////////////////////////////////////// /* STRUCTURE OF GAME - TYPES OF TRIALS */ ///////////////////////////////////////////////////////////


  /* arival at new planet */
  var landing = {
    type: jsPsychImageKeyboardResponse,
    stimulus: land_img,
    prompt: "<p style = 'color:white;'>Dig here or travel to a new planet?</p>",
    stimulus_height: 700,
    choices: "NO_KEYS",
    stimulus_duration: 500,
    trial_duration: 500,
    /* data: {
      next_reward: Math.round(Math.max(Math.min(normalRandomScaled(100, 5), 135), 0)),
      planet: planet,
      trial_type : "land"
    }, */
    on_finish: function (data) {
      data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(100, 5), 135), 0));
      data.planet = planet;
      data.trial_type = "land";
    }
  };

  /* arival at new planet - practice */
  var landing_prac = {
    type: jsPsychImageKeyboardResponse,
    stimulus: land_img,
    prompt: "<p style = 'color:white;'><strong>Practice Trial</strong></p> <p style = 'color:white;'>Dig here ('Q') or travel to a new planet ('P')?</p>",
    stimulus_height: 700,
    choices: "NO_KEYS",
    stimulus_duration: 5000,
    trial_duration: 5000,
    on_finish: function (data) {
      data.next_reward = Math.round(Math.max(Math.min(normalRandomScaled(100, 5), 135), 0));
      data.planet = planet;
      data.trial_type = "land_prac";
    }
  };

  /*digging */
  var dig = {
    type: jsPsychAnimation,
    stimuli: dig_sequence,
    prompt: "<p style = 'color:white;'> Dig here or travel to a new planet?</p>",
    frame_time: 667,
    choices: "NO_KEYS",
    on_start: function (dig) {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      if (last_trial_data.trial_type == "decision") {
        var adjusted_rt = 2000 - last_trial_data.rt;
        dig.frame_time = adjusted_rt / 3;
        var src = "foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
        var tt_sec = adjusted_rt / 1000 + 1.5; //need to convert to seconds
        var axe_audio = new sound(src.concat(tt_sec.toString()))
        axe_audio.play()
      } else {
        var src = "foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
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

  /*digging - instructions trial*/
  var dig_instruc = {
    type: jsPsychAnimation,
    stimuli: dig_sequence,
    prompt: "<p style = 'color:white;'> Dig here or travel to a new planet?</p>",
    choices: "NO_KEYS",
    frame_time: 667,
    on_start: function (dig_instruc) {
      var src = "foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
      var tt_sec = 4.5; //need to convert to seconds
      var axe_audio = new sound(src.concat(tt_sec.toString()))
      axe_audio.play()
    },
    on_finish: function (data) {
      data.trial_type = "dig_instruc";
    }
  }

  /*digging - practice trial*/
  var dig_prac = {
    type: jsPsychAnimation,
    stimuli: dig_sequence,
    prompt: "<p style = 'color:white;'><strong>Practice Trial</strong></p> <p style = 'color:white;'>Dig here ('Q') or travel to a new planet ('P')?</p>",
    choices: "NO_KEYS",
    frame_time: 667,
    on_start: function (dig_prac) {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      if (last_trial_data.trial_type == "decision") {
        var adjusted_rt = 2000 - last_trial_data.rt;
        dig_prac.frame_time = adjusted_rt / 3;
        var src = "foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
        var tt_sec = adjusted_rt / 1000 + 1.5; //need to convert to seconds
        var axe_audio = new sound(src.concat(tt_sec.toString()))
        axe_audio.play()
      } else {
        var src = "foraging/experiment/run_exp/static/audio/axe.mp3#t=1.5,"
        var tt_sec = 4.5; //need to convert to seconds
        var axe_audio = new sound(src.concat(tt_sec.toString()))
        axe_audio.play()
      }
    },
    on_finish: function (data) {
      data.trial_type = "dig_prac";
    }
  };

  /* harvest - digging up the treasure & displaying the reward */
  var harvest = {
    type: jsPsychImageKeyboardResponse,
    stimulus: space_treasure_img,
    prompt: "<p style ='color:white;'>Dig here or travel to a new planet?</p>",
    stimulus_height: 700,
    stimulus_duration: 1500, // in milliseconds
    trial_duration: 1500,
    choices: "NO_KEYS",
    on_start: function (harvest) {
      var last_trial_data = jsPsych.data.get().last(2).values()[0]; // last trial was dig, before that was decision
      var reward = last_trial_data.next_reward; // round to one decimal point
      var folder_prefix = 'foraging/experiment/run_exp/static/images/task_images/gems/';
      var integer = Math.round(reward.toString());
      var img_suffix = '.jpg'
      var harvest_img = folder_prefix.concat(integer, img_suffix)
      harvest.stimulus = harvest_img;
    },
    on_finish: function (data) {
      var last_trial_data = jsPsych.data.get().last(3).values()[0];
      var galaxy_type = struc[b_num - 1][block_num_planet - 1]
      var decay_rate = get_decay_rate(galaxy_type);
      console.log('decay_rate: ', decay_rate, 'galaxy_type: ', galaxy_type, 'last_trial_data: ', last_trial_data, 'b_num: ', b_num, 'block_num_planet: ', block_num_planet);
      data.reward_received = last_trial_data.next_reward; // what did we receive from this harvest
      data.next_reward = Math.round(last_trial_data.next_reward * decay_rate);
      data.decay_rate_actual = decay_rate;
      data.decay_rate_exp = data.next_reward / last_trial_data.next_reward; // calculate the decay rate as seen by the  participant not what was actual sampled
      data.planet = planet;
      data.trial_type = "harvest";
      window.total_space_treasure = total_space_treasure + last_trial_data.next_reward;

    },
  };

  /* harvest - practice: display barrels of gems instead of actual gems */
  var harvest_prac = {
    type: jsPsychImageKeyboardResponse,
    prompt: "<p style = 'color:white;'><strong>Practice Trial</strong></p> <p style = 'color:white;'>Dig here ('Q') or travel to a new planet ('P')?</p>",
    stimulus: harvest_practice_img,
    stimulus_height: 700,
    stimulus_duration: 1500, // in milliseconds
    trial_duration: 1500,
    choices: "NO_KEYS",
    on_finish: function (data) {
      data.trial_type = "harvest_prac";
    }
  };

  /* harvest - instructions: always show 100 gems */
  var harvest_instruc = {
    type: jsPsychImageKeyboardResponse,
    stimulus: 'foraging/experiment/run_exp/static/images/task_images/gems/100.jpg',
    prompt: "<p style ='color:white;'>Dig here or travel to a new planet?</p>",
    stimulus_height: 700,
    stimulus_duration: 1500, // in milliseconds
    trial_duration: 1500,
    choices: "NO_KEYS",
    on_finish: function (data) {
      data.trial_type = "harvest_instruc";
    }
  };

  /* travel - the space ship is moving */
  var travel = {
    type: jsPsychAnimation,
    stimuli: travel_sequence,
    prompt: "<p style ='color:white;'>Dig here or travel to a new planet?</p>",
    frame_time: 1111, // in milliseconds
    choices: "NO_KEYS",
    on_start: function (travel) {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      var last_rt = last_trial_data.rt;
      var adjusted_travel_time = 10000 - last_rt;
      travel.frame_time = adjusted_travel_time / 9;
      var src = "foraging/experiment/run_exp/static/audio/rocket.mp3#t=0,"
      var tt_sec = adjusted_travel_time / 1000 - 0.5; //need to convert to seconds
      var rocket_audio = new sound(src.concat(tt_sec.toString()))
      rocket_audio.play()
    },
    on_finish: function (data) {
      data.trial_type = "travel";
      data.planet = planet;
    }
  };

  /* travel - practice: the space ship is moving */
  var travel_prac = {
    type: jsPsychAnimation,
    stimuli: travel_sequence,
    prompt: "<p style = 'color:white;'><strong>Practice Trial</strong></p> <p style = 'color:white;'>Dig here ('Q') or travel to a new planet ('P')?</p>",
    frame_time: 1111, // in milliseconds
    choices: "NO_KEYS",
    on_start: function () {
      var last_trial_data = jsPsych.data.get().last(1).values()[0];
      var last_rt = last_trial_data.rt;
      var adjusted_travel_time = 10000 - last_rt;
      travel.frame_time = adjusted_travel_time / 9;
      var src = "foraging/experiment/run_exp/static/audio/rocket.mp3#t=0,"
      var tt_sec = adjusted_travel_time / 1000 - 0.5; //need to convert to seconds
      var rocket_audio = new sound(src.concat(tt_sec.toString()))
      rocket_audio.play()
    },
    on_finish: function (data) {
      data.trial_type = "travel_prac";
      data.planet = planet;
    },
  };

  /* time out trial - asking participant to please respond faster  */
  var time_out = {
    type: jsPsychImageKeyboardResponse,
    stimulus: time_out_img,
    prompt: "<p style = 'color:white;'>Dig here or travel to a new planet?</p>",
    stimulus_height: 700,
    stimulus_duration: 2000, // in milliseconds
    trial_duration: 2000,
    choices: "NO_KEYS",
    on_finish: function (data) {
      data.trial_type = "time_out";
      var last_trial_data = jsPsych.data.get().last(2).values()[0];
      //var last_trial_data =
      data.next_reward = last_trial_data.next_reward;
      console.log(last_trial_data)
    }
  };
  

  var alien_welcome = {
    type: jsPsychImageKeyboardResponse,
    prompt: "<p style ='color:white;'>Dig here or travel to a new planet?</p>",
    stimulus: time_out_img,
    stimulus_height: 700,
    stimulus_duration: 5000, // in milliseconds
    trial_duration: 5000,
    choices: "NO_KEYS",
    on_start: function (alien_welcome) {
      console.log('aliens:', aliens);
      window.alien = aliens.shift().toString();
      window.aliens_copy.push(alien)
      alien_welcome.stimulus = "foraging/experiment/run_exp/static/images/task_images/aliens/alien_planet-".concat(alien, '.jpg')
    },
    on_finish: function (data) {
      window.planet = planet + 1;
      window.block_num_planet = block_num_planet + 1;
      data.alien = alien;
      data.aliens = aliens; // save the list of aliens here
      data.trial_type = "alien_welcome";
    }
  };

  var alien_welcome_prac = {
    type: jsPsychImageKeyboardResponse,
    stimulus: time_out_img,
    prompt: "<p style = 'color:white;'><strong>Practice Trial</strong></p> <p style = 'color:white;'>Dig here ('Q') or travel to a new planet ('P')?</p>",
    stimulus_height: 700,
    stimulus_duration: 5000, // in milliseconds
    trial_duration: 5000,
    choices: "NO_KEYS",
    on_start: function (alien_welcome_prac) {
      console.log('aliens_prac', aliens_prac);
      window.alien = aliens_prac.pop().toString();
      console.log('alien: ',alien, 'window.alien: ', window.alien);
      alien_welcome_prac.stimulus = "foraging/experiment/run_exp/static/images/task_images/aliens/alien_planet-".concat(alien, '.jpg')
    },
    on_finish: function (data) {
      data.trial_type = "alien_welcome_prac";
    }
  };

  /* INSTRUCTIONS   */

  // Welcome
  var welcome = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p>In this game, you are an explorer traveling through space to collect space treasure.</p><p>Your mission is to collect as much treasure as possible.</p><p>Press the <strong>space button</strong> to begin reading the instructions!</p><br><br><p><img src='foraging/experiment/run_exp/static/images/task_images/opening_img-01.jpg' height='600' width='auto'></p>",
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_welcome";
      /* data.condition = condition;*/
    }
  };

  var instructions_goal = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p>As a space explorer, you visit different planets to dig for space treasure, these pink gems.</p> <p>The more space treasure you mine, the more performance bonus you get!</p><p>Press the <strong>space button</strong> to continue. </p><br><br><p><img src='foraging/experiment/run_exp/static/images/task_images/pink_gem.jpg' height='300' width='auto'></p>",
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_goal";
    }
  };

  // instructions
  var instructions_dig = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p>When you arrive at a new planet, you will dig once before you can make any choice.</p> <p>Then, you get to decide if you want to stay on the planet and dig again or travel to a new planet and dig there.</p> <p> To stay and dig, press the letter <strong>'A'</strong> on the keyboard. Try pressing it now! </p><p><img src='foraging/experiment/run_exp/static/images/task_images/land.jpg' height='700' width='auto'></p>",
    choices: ['A'],
    on_finish: function (data) {
      data.next_reward = 100.0;
      data.trial_type = "instruc_dig"
    }
  };

  var instructions_travel = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p> The longer you mine a planet, the fewer gems you get with each dig.</p><p>When gems are running low, you may want to travel to a new planet that has not been overmined. </p> <p> Planets are very far apart in this galaxy, so it takes some time to travel between them. </p> <br><p> There are lots and lots of planets for you to visit, so you are not able to return to any planets you have already visited. </p><br><p>To leave this planet and travel to a new one, press the letter <strong>'L'</strong> on the keyboard. Try pressing it now! </p><p><img src='foraging/experiment/run_exp/static/images/task_images/rocket-01.jpg' height='600' width='auto'></p>",
    choices: ['L'],
    button_html: ['<button id="close-image" style="border-radius: 10px;"><img src="foraging/experiment/run_exp/static/images/task_images/button-travel.jpg" height=80></button>'],
    on_finish: function (data) {
      data.trial_type = "instruc_travel";
    }
  };

  var instructions_alien = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<p>When you arrive at a new planet, an alien from that planet will greet you!</p><p>Press the <strong>space button</strong> to continue. </p><br><p><img src="foraging/experiment/run_exp/static/images/task_images/aliens/alien_planet-125.jpg"  height="700" width="auto"></p>',
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_alien_greet";
    }
  }

  var instructions_time_out = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<p><p>If you are not fast enough in making a choice, you have to wait a few seconds before you can make another one.</p><p>You cannot dig for more gems or travel to new planets. You just have to sit and wait.</p><p>Press the <strong>space button</strong> to continue. </p><br><p><img src="foraging/experiment/run_exp/static/images/task_images/time_out.jpg"  height="700" width="auto"></p>',
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "time_out";
    }
  }


  var instructions_break = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p> After digging and traveling for a while, you will be able to take a break at home base. </p> <p>You can spend at most 1 minute at home base - there are still a lot of gems left to collect! </p> <p>You will spend <strong>26 minutes</strong> mining gems and traveling to new planets no matter what.</p><p>You will visit the home base once during the game.</p><p>Press the <strong>space button</strong> to continue. </p><br><img src='foraging/experiment/run_exp/static/images/task_images/home_base.jpg' height='700' width='auto'>",
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_break";
    }
  }

  var instructions_practice_game = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: "<p> Now, you will play a practice game where you can make 6 choices. You can choose between mining space treasure or traveling to new planets. </p> <p>In the practice game, you'll be digging up barrels of gems. But, in the real game, you'll be digging up the gems themselves. </p><p> Press the <strong>space button</strong> to begin practice! </p>",
    choices: [' '],
    on_finish: function (data) {
      data.trial_type = "instruc_prac_game";
    }
  }










  //Run timeline
  timeline.push(preload); //preload all images
  timeline.push(onstart_trial); //for loading task-specific CSS styles

  //enter full screen if not debug mode (remove later)
  if (!debug_mode) {
    timeline.push({
      type: jsPsychFullscreen,
      fullscreen_mode: true
    });
  }
  
  timeline.push(welcome); //welcome to the experiment
  timeline.push(instructions_goal); //introduce goal of the game
  timeline.push(instructions_dig); //practice pressing Q to dig
  timeline.push(dig_instruc); //the character digs
  timeline.push(harvest_instruc); //see harvest (reward - 100 gems)
  timeline.push(instructions_travel); //practice pressing P to travel
  timeline.push(travel_prac); //spaceshift travels
  timeline.push(instructions_alien); //show an alien greeting them on new planet
  timeline.push(instructions_time_out); //tell them about time out for responding slowly
  timeline.push(instructions_break); //show them home base





  if (PAV == true) {
    var pavlovia_finish = {
      type: jsPsychPavlovia,
      command: "finish",
      participantId: "JSPSYCH-V1",
      // Thomas Pronk; your filter function here
      dataFilter: function (data) {
        // Printing the data received from jsPsych.data.get().csv(); a CSV data structure
        //console.log(data);
        // You can also access the data directly, for instance getting it as JSON
        //console.log(jsPsych.data.get().json());
        // Return whatever data you'd like to store
        return data;
      },
      // Thomas Pronk; call this function when we're done with the experiment and data reception has been confirmed by Pavlovia
      completedCallback: function () {
        alert('data successfully submitted!');
      }
    };
    //timeline.push(pavlovia_finish);
  }



  return timeline;
}