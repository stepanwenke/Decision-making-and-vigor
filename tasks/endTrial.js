function endTrial(day) {

    var styleElement;

    function setStyles() {
        setTimeout(() => {
            // Create a new <style> element
            styleElement = document.createElement('style');

            // Set the content of the <style> element to your styles
            let styles = end_styles;
            styleElement.innerHTML = styles;

            // Append the <style> element to the document's <head>
            document.head.appendChild(styleElement);
        }, 1);
    }

    function removeStyles() {
        styleElement.parentNode.removeChild(styleElement);
        /* styleElement.parentNode.removeChild(styleElement); */
    }

    // initializing jsPsych
    var timeline = [];  // Declare it empty in the beginning

    /* if (PAV == true) {
        var pavlovia_init = {
            type: jsPsychPavlovia,
            command: "init",
            setPavloviaInfo: function (info) {
                console.log('initializing pavlovia: ', info);
                pavloviaInfo = info;
            }
        };
        timeline.push(pavlovia_init);
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

    /*     let final_feedback = {
            type: jsPsychSurvey,
            pages: [
                [
                    {
                        type: 'html',
                        prompt: `<h3>You are one step before finishing this experiment. Your feedback is valuable and can affect our future research.
                        If you feel like sharing something with us before leaving, you are more than welcome!</h3>
                        `
                    },
                    {
                        type: 'text',
                        prompt: "What did you like about the tasks?",
                        placeholder: 'e.g., features, gamification, fun, nothing etc.',
                        name: 'like',
                        required: false,
                    },
                    {
                        type: 'text',
                        prompt: "What did NOT like you about the tasks?",
                        placeholder: "e.g., length, boring, unclear, stressful etc.",
                        name: 'dislike',
                        required: false,
                    },
                    {
                        type: 'text',
                        prompt: "Was there any error / bug or something we can improve for future participants?",
                        placeholder: 'e.g., lagging, animation errors, calculation errors etc.',
                        name: 'bugs',
                        required: false,
                    }
                ]
            ],
            title: 'Final feedback',
            text: 'Finish',
            data: {
                task: 'final_feedback'
            }
        };
        timeline.push(final_feedback); */

    //prompt the user for their Prolific (participant) ID
    var final_feedback_day0 = {
        on_start: function () {
            setStyles();
        },
        type: jsPsychSurveyText,
        preamble:
            `<h3>You are one step before finishing this experiment. Your feedback is valuable and can affect our future research.
            If you feel like sharing something with us before leaving, you are more than welcome!</h3>`,
        questions: [
            {
                prompt: "What did you like about the tasks?",
                name: 'like'
            },
            {
                prompt: "What did you NOT like you about the tasks?",
                name: 'dislike'
            },
            {
                prompt: "Were there any errors or bugs we can improve for future participants?",
                name: 'bugs'
            }
        ],
        data: {
            task: 'final_feedback_day0'
        }
    };

    var final_feedback = {
        on_start: function () {
            setStyles();
        },
        type: jsPsychSurveyText,
        preamble:
            `<h3>You are one step before finishing this experiment. Your feedback is valuable and can affect our future research.
            If you feel like sharing something with us before leaving, you are more than welcome!</h3>
            <p>The last question regarding medication serves to improve our statistical models. You will not be judged or affected
            in any way in the future participation. The more truthful, the better for our understanding of how certain drugs affect 
            decision-making in population. If you feel that it is too personal, you can write "Prefer not to say".</p>`,
        questions: [
            {
                prompt: "What did you like about the tasks?",
                name: 'like'
            },
            {
                prompt: "What did you NOT like you about the tasks?",
                name: 'dislike'
            },
            {
                prompt: "Were there any errors or bugs we can improve for future participants?",
                name: 'bugs'
            },
            {
                prompt: "Are you currently taking any prescribed medication or drugs (including substances taken prior this experiment)?",
                name: 'drugs'
            }
        ],
        data: {
            task: 'final_feedback'
        }
    };

    /*     if (day != 999) {
            timeline.push(final_feedback);
        } */
    if (day == 0) {
        timeline.push(final_feedback_day0);
    } else {
        timeline.push(final_feedback);
    }

    // if it is not eqaual to day 999 then assign 1 to day

    var final_trial_html;
    //Final trial of the experiment
    let end_experiment = {
        type: jsPsychHtmlKeyboardResponse,
        stimulus: '',
        choices: /* ["NO_KEYS"] */" ",
        on_start: function (trial) {

            //console.log('THIS IS WHERE WE SET STYLE!');
            //performanceBonus += 10;
            if (day == 0) {
                total_experiment_bonus = total_experiment_bonus_day0;
            } 

            total_experiment_bonus = total_experiment_bonus + performanceBonus;
            final_trial_html = `<div class="textDiv" style="width: 55%"><p>Thank you for participating! You made ${total_experiment_bonus}&pound. Press <b>space</b> to be redirected to Prolific.</p></div>`
            console.log('final_trial_html: ', final_trial_html);

            // Report total money earned to participant
            trial.stimulus = final_trial_html;

        },
        trial_duration: 60000,
        data: {
            task: 'final_trial'
        },
        on_finish: function (data) {
            removeStyles();
            console.log('bonus_rlwm: ', bonus_rlwm, 'data.bonus_rlwm: ', bonus_rlwm);

        }
    };
    timeline.push(end_experiment);


    //Finish Pavlovia to save data
    var pavlovia_finish = {
        type: jsPsychPavlovia,
        command: "finish",
        participantId: "day_" + day + "_" + subID, //function get real ID - get any trial from data.subjID
        // Thomas Pronk; your filter function here
        dataFilter: function (data) {
            // Printing the data received from jsPsych.data.get().csv(); a CSV data structure
            //console.log(data);
            // You can also access the data directly, for instance getting it as JSON
            //console.log(jsPsych.data.get().json());
            // Return whatever data you'd like to store
            //console.log('this is data: ', data/* , "subID: ", subID */);
            return data;
        },
        // Thomas Pronk; call this function when we're done with the experiment and data reception has been confirmed by Pavlovia
        completedCallback: function () {
            //alert('data successfully submitted!');
            var a = + "?nocache=" + Math.random().toString(36).substring(7);
            console.log('data success, unique code: ', a)
            // redirecting
            //window.location = FCURL;

        }
    };

    /* if (PAV == true) {
        timeline.push(pavlovia_finish);
    } else {
        alert('Pavlovia is set to FALSE');
    } */

    timeline.push(pavlovia_finish);

    var redirect = {
        type: jsPsychHtmlKeyboardResponse,
        trial_duration: 2000,
        stimulus: "<p>Thank you, please wait while we redirect you back to Prolific...</p> <p>If your browser shows a dialog window asking you to <b>leave the site appears, confirm it. </b></p>",
        on_finish: function () {
            window.location = FCURL;
        }
    };
    timeline.push(redirect);

    /* return the experimental trial */
    return timeline;
}
