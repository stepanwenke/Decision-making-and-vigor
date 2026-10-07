function breakTrial(BATHROOM_BREAK_DURATION = 300000) {

    var styleElement;

    function setStyles() {
        setTimeout(() => {
            // Create a new <style> element
            styleElement = document.createElement('style');

            // Set the content of the <style> element to your styles
            let styles = break_styles;
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


    var break_length = BATHROOM_BREAK_DURATION / 60000;
    //Bathrrom break trial
    let bathroom_break = {
        type: jsPsychHtmlKeyboardResponse,
        on_load: function () {
            let timeLeft = BATHROOM_BREAK_DURATION;
            const countdownElem = document.getElementById('countdown');

            function formatTime(ms) {
                let totalSeconds = Math.floor(ms / 1000);
                let minutes = Math.floor(totalSeconds / 60);
                let seconds = totalSeconds % 60;
                return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            }

            countdownElem.textContent = formatTime(timeLeft);

            const interval = setInterval(() => {
                timeLeft -= 1000;
                if (timeLeft >= 0) {
                    countdownElem.textContent = formatTime(timeLeft);
                } else {
                    clearInterval(interval);
                }
            }, 1000);
        },
        stimulus: () => {
            return `
                <div class="textDiv" style="width: 55%">
                    <p>You may now take a longer break. After <b>${break_length} minutes</b>, the task will automatically continue.</p>
                    <p>The duration of the break does not affect your earnings.</p>
                    <p>Press the <b>space bar</b> if you wish to end the break and continue the task.</p>
                    <p style="margin-top: 20px;"><b>Time remaining:</b> <span id="countdown">Loading...</span></p>
                </div>
                            `;
        },
        choices: " ",
        on_start: function () {
            setStyles();
            console.log('THIS IS WHERE WE SET STYLE!');
        },
        trial_duration: BATHROOM_BREAK_DURATION,
        data: {
            task: 'bathroom_break'
        },
        on_finish: function () {
            removeStyles();
        }
    };
    timeline.push(bathroom_break);

    /* return the experimental trial */
    return timeline;
}
