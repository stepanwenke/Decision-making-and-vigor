function day0() {

    // Initialize general timeline
    //let general_timeline = [];



    // Tasks initialization
    let timeline_genIn = generalInstructions(0); //general instructions
    let timeline_gonogo = gonogoTaskPositive(0); // Go/No-Go task
    let timeline_end = endTrial(0); // End trial

    // Push all tasks into general timeline in the correct order
    general_timeline = general_timeline.concat(timeline_genIn);   // Instructions
    general_timeline = general_timeline.concat(timeline_gonogo);  // Randomized first task (effort or go/nogo)
    general_timeline = general_timeline.concat(timeline_end);     // End trial

    // Run the experiment
    //console.log(general_timeline);
    jsPsych.run(general_timeline);
}  