
// image preloading 

var effort_images = ['tasks/effort/images/cursor-left.png', 'tasks/effort/images/cursor-right.png', 'tasks/effort/images/cursor-left.png', 'tasks/effort/images/background2.png', 'tasks/effort/images/character.png',
  'tasks/effort/images/c.png', 'tasks/effort/images/enemy.png', 'tasks/effort/images/spacebar.png', 'tasks/effort/images/background2.png', 'tasks/effort/images/potentials/background_twister3.jpg'];

var image_prefix = "tasks/foraging/experiment/run_exp/static/images/task_images/";
var image_prefix_button = "<img src=tasks/foraging/experiment/run_exp/static/images/task_images/";



var foraging_images = [image_prefix + "land.jpg", image_prefix + "dig.jpg", image_prefix + "barrel_text.jpg",
image_prefix + "rocket-01.jpg", image_prefix + "rocket-02.jpg", image_prefix + "rocket-03.jpg", image_prefix + "rocket-04.jpg", 
image_prefix + "rocket-05.jpg", image_prefix + "rocket-06.jpg", image_prefix + "rocket-07.jpg", image_prefix + "rocket-08.jpg",
image_prefix + "rocket-09.jpg", image_prefix + "opening_img-01.jpg", image_prefix + "home_base.jpg",
image_prefix + "time_out.jpg", image_prefix + "catch.jpg"];

/* RLWM IMAGES FOR PRELOADING */

//extract the image properties from test_stimuli (from rlwm/stimuli.js - needs to be above general.js in index.html)

var subID;
var experimentsOrder;
var nextRewardForaging;

//variables for task performance bonuses
var bonus_per_task = 1.5;

var bonus_rlwm = 0;
var bonus_gonogo = 0;
let bonus_effort = 0;
var bonus_foraging = 0;

//amount (in punds) received for completing the full experiment (excluding performance bonus)
var total_experiment_bonus = 14;
var total_experiment_bonus_day0 = 4;

var taskNumber = 0;
var performanceBonus = 0;
var fixedEarning = 0;
var CURRENTLY_IN_FULLSCREEN = true;
var FULLSCREEN_EXIT = 0;

var MAX_MISSED_ATTEN_CHECKS = 20000

const totalNrOfTasks = 4; //nr of tasks in the battery

var CURRENTLY_IN_FULLSCREEN;
var FULLSCREEN_EXIT;

//Prolific URLs (temporary just google)
const NCURL = "https://app.prolific.com/submissions/complete?cc=CN5V6VMK" //No Consent
const FAURL = "https://app.prolific.com/submissions/complete?cc=CT6BJ865" //Failed Attention check
const FCURL = "https://app.prolific.com/submissions/complete?cc=CIFXLZKN" //Full Completion
const MTURL = "https://app.prolific.com/submissions/complete?cc=CV8ZGMRJ" //too many Missed Trials

  // Call the shuffleArray function to shuffle tasksURL
/*   experimentsOrder = shuffleArray(tasksURL);
  experimentsOrder.push('end-index.html'); */


  // Get a token for the current participant/session
  tokenurl = window.location.search;

  // Keep track of the order of the task in the battery, add 1 each of the pavlovia on finish
  taskNumber = 0;
  performanceBonus = 0;
  fixedEarning = 0;
  CURRENTLY_IN_FULLSCREEN = false;
  FULLSCREEN_EXIT = 0;


function sum(nums) {
  var accumulator = 0;
  for (var i = 0, l = nums.length; i < l; i++)
    accumulator += nums[i];
  return accumulator;
}


/* fullscreen code start */
document.addEventListener('keydown', function (event) {
  if (CURRENTLY_IN_FULLSCREEN == false) {
    if (event.key === 'f' || event.key === 'F' || event.key === 'c' || event.key === 'C' || event.key === ' ' || event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      enterFullscreen();
    }
  }
});

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
  overlay.id = "overlay";

  // Apply CSS properties
  overlay.style.position = "fixed";
  overlay.style.top = "0";
  overlay.style.left = "0";
  overlay.style.width = "100%";
  overlay.style.height = "100%";
  overlay.style.backgroundColor = "rgba(0, 0, 0, 0.5)";
  overlay.style.backdropFilter = "blur(0.5em)";
  overlay.style.zIndex = "9999";
  overlay.style.display = "none";

  document.body.appendChild(overlay);
  overlay.style.display = "block"; // Show the overlay

  const error_msg = document.createElement("div");
  error_msg.className = 'text-box-error';

  // Apply CSS properties to .text-box-error
  error_msg.style.position = "absolute";
  error_msg.style.left = "50%";
  error_msg.style.width = "50vw";
  error_msg.style.transform = "translate(-50%, 100%)";
  error_msg.style.padding = "2em 6em";
  //error_msg.style.background = "#b1b7e1";
  //error_msg.style.border = "0.5em solid white";
  error_msg.style.borderRadius = "5em";
  error_msg.style.boxShadow = "0.5em 0.5em 1.5em #2c2c2c";
  error_msg.style.zIndex = "9999";

  document.body.appendChild(error_msg);

  // Create a <p> element and set its text content
  const errorMessage = document.createElement("p");
  errorMessage.textContent = "It is not allowed to exit full-screen mode! Please press F to return to full-screen mode.";

  // Append the <p> element to the error_msg div
  error_msg.appendChild(errorMessage);

}

function removeOverlay() {
  const overlay = document.getElementById("overlay");
  if (overlay) {
    overlay.style.display = "none"; // Hide the overlay
    document.body.removeChild(overlay);
  }

  const error_msg = document.querySelector('.text-box-error');
  if (error_msg) {
    document.body.removeChild(error_msg);
  }
}
