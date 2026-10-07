function day1() {


    // Tasks initialization
    let timeline_genIn = generalInstructions(1); // General instructions
    let timeline_AMI = AMI(1); // 1 = included attention checks; 0 = version without attention checks
    let timeline_PANAS = PANAS(1); // PANAS questionnaire
    let timeline_ASRM = ASRM(); // ASRM questionnaire
    let timeline_CESD = CESD(1); // CESD questionnaire
    let timeline_SHPS = SHPS(1); // SHPS questionnaire
    let timeline_BIS_BAS = BIS_BAS(1); // BIS/BAS questionnaire
    let timeline_PSS = PSS(1); // PSS questionnaire
    let timeline_effort = effortTask(1); // Effort task
    let timeline_rlwm = rlwmTask(1); // RLWM task
    let timeline_break = breakTrial(); // Break trial
    let timeline_foraging = foragingTask(); // Foraging task
    let timeline_gonogo = gonogoTaskPositive(1); // Go/No-Go task
    let timeline_end = endTrial(1); // End trial

    // Randomly select the first two tasks from effort, go/nogo, rlwm, and foraging
    let tasks = [timeline_foraging, timeline_rlwm, timeline_gonogo, timeline_effort];

    // Shuffle tasks to determine the random order
    tasks = jsPsych.randomization.shuffle(tasks);

    let randomFirstTask = tasks[0];
    let randomSecondTask = tasks[1];
    let randomThirdTask = tasks[2];
    let randomFourthTask = tasks[3];

    // Push all tasks into general timeline in the correct order
    general_timeline = general_timeline.concat(timeline_genIn);    // Instructions 
    general_timeline = general_timeline.concat(randomFirstTask);   // Randomized first task
    general_timeline = general_timeline.concat(randomSecondTask);  // Randomized second task
    general_timeline = general_timeline.concat(timeline_break);    // Break
    general_timeline = general_timeline.concat(randomThirdTask);   // Randomized third task
    general_timeline = general_timeline.concat(randomFourthTask);  // Randomized fourth task
    general_timeline = general_timeline.concat(timeline_AMI);      // AMI
    general_timeline = general_timeline.concat(timeline_ASRM);     // ASRM
    general_timeline = general_timeline.concat(timeline_CESD);   // CESD
    general_timeline = general_timeline.concat(timeline_SHPS);     // SHPS
    general_timeline = general_timeline.concat(timeline_BIS_BAS);   // BIS/BAS
    general_timeline = general_timeline.concat(timeline_PSS);      // PSS
    general_timeline = general_timeline.concat(timeline_end);      // End trial

    // Run the experiment

    console.log("General timeline: ", general_timeline);

    jsPsych.run(general_timeline);
}
