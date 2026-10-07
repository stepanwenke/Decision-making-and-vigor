function generalInstructions(day) {

    var styleElement;
    let number_of_games, this_exp_bonus, this_total_perf_bonus, all, duration, inviting_again_text, in_two_occasions;

    if (day == 0) {
        number_of_games = 'one game';
        this_exp_bonus = total_experiment_bonus_day0;
        this_total_perf_bonus = '1.5';
        all = 'both';
        duration = '40 minutes';
        inviting_again_text = `<li style ='text-align:left;'>If asked, you decide if you want to participate in the same experiment again in the near future.</li><br/>`;
        in_two_occasions = '';
        multiple_or_one = 'a single';
        s_or_not = '';
        each = 'the';
    } else if (day == 1) {
        number_of_games = 'four unrelated games';
        this_exp_bonus = total_experiment_bonus;
        this_total_perf_bonus = '6';
        all = 'all';
        duration = '2 hours';
        inviting_again_text = `<li style ='text-align:left;'>We would like you to do this experiment twice that is why you will be invited to do this again 5 days later.</li><br/>`;
        in_two_occasions = ' in separate test two occasions 5 days apart';
        multiple_or_one = 'four separate';
        s_or_not = 's';
        each = 'each';
    } else if (day == 2) {
        number_of_games = 'four unrelated games';
        this_exp_bonus = total_experiment_bonus;
        this_total_perf_bonus = '6';
        all = 'all';
        duration = '2 hours';
        inviting_again_text = '';
        in_two_occasions = ' in separate test two occasions 5 days apart';
        multiple_or_one = 'four separate';
        s_or_not = 's';
        each = 'each';
    }

    function setStyles() {
        setTimeout(() => {
            // Create a new <style> element
            styleElement = document.createElement('style');

            // Set the content of the <style> element to your styles
            let styles = genIn_styles;
            styleElement.innerHTML = styles;

            // Append the <style> element to the document's <head>
            document.head.appendChild(styleElement);
        }, 1);
    }

    function removeStyles() {
        styleElement.parentNode.removeChild(styleElement);
    }

    const projectTitle = 'DecisionDynamics';


    //Global variables
    let resp = 0; //to track whether or not participant responds anything during the participant ID trial
    let nrMissedTrials = 0; //number of null responses

    //Images
    const KILogo = 'tasks/KILogo.png'; //Ki logo for consent form

    //##########//#//##//////##//######//#///////#//##////#//######/////////####///######///####///#//##////#//////////////////////////////////////////
    //////#///////#//#/#////#/#//#///////#///////#//#/#///#//#//////////////#///#//#///////#///////#//#/#///#//////////////////////////////////////////
    //////#///////#//#//#//#//#//#####///#///////#//#//#//#//#####//////////####///####////#//##///#//#//#//#//////////////////////////////////////////
    //////#///////#//#///##///#//#///////#///////#//#///#/#//#//////////////#///#//#///////#////#//#//#///#/#//////////////////////////////////////////
    //////#///////#//#////////#//######//######//#//#////##//######/////////####///######///####///#//#////##//////////////////////////////////////////

    //create empty timeline
    let timeline = [];

    //initialize Pavlovia plugin
    let pavlovia_init = {
        type: jsPsychPavlovia,
        command: "init",
        setPavloviaInfo: function (info) {
            console.log('initializing pavlovia: ', info);
            pavloviaInfo = info;
            //alert('Pavlovia is initialized');
        }
    };
    //timeline.push(pavlovia_init);

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

    let empty_trial = {
        on_start: function () {
            console.log('first empty trial');
        },
        type: jsPsychHtmlKeyboardResponse,
        stimulus: 'Loading...',
        choices: ["NO_KEYS"],
        trial_duration: 1000, //
        data: {
            task: 'empty_trial',
            parsing: 'start_genIn'
            //exp_order: order_of_exp //task order
        }
    };
    timeline.push(empty_trial);

    let empty_trial2 = {
        on_start: function () {
            console.log('second empty trial');
        },
        type: jsPsychHtmlKeyboardResponse,
        stimulus: 'Loading...',
        choices: ["NO_KEYS"],
        trial_duration: 1000, //
        data: {
            task: 'empty_trial'
        }
    };
    timeline.push(empty_trial2);

    //Initial welcome screen
    var welcome = {
        on_start: function () {
            setStyles();
        },
        type: jsPsychHtmlButtonResponse,
        stimulus: `<div class="genIn-textDiv">
            <p style="font-size: 2.5vw">Welcome to the experiment!</p>
				<p>Before we begin, we ask you to read 
                through the information on the next page and decide if you consent to participate in this experiment.
				</div>`,
        data: {
            task: `welcome_page`,
        },
        choices: [`Continue`],
    };

    var close_tabs = {
        type: jsPsychHtmlButtonResponse,
        stimulus: `<div class="genIn-textDiv">
            <p>To ensure the experiment is running smoothly, please close as many tabs and applications opened on your computer as possible.</p>
				</div>`,
        data: {
            task: `close_tabs`,
        },
        choices: [`Continue`],
    };

    //Consent form screen
    var consent = {
        type: jsPsychHtmlButtonResponse,
        stimulus: `<div class="genIn-consentContainerDiv">
				<img class="genIn-KILogoIMG" src ='${KILogo}' alt="Karolinska Institutet's logo">
				<div class="genIn-textDivConsent">
					<h1>Informed consent <br></h1>

					<p><b><u><br/>Project title: ${projectTitle}</u></b></p>

					<p><b><br/>Request to participate in a research study</b></p>
					<p>We research decision-making, and we invite you to participate in our study. Karolinska Institutet in Sweden is principally responsible 
                    for the research (forskningshuvudman). Before you decide whether or not you wish to participate, it is important that you understand the background of the study and 
                    what participation entails. Therefore, please read through this information. Let us know if anything needs clarification or if you require further information. </p>
					
					<p><b><br/>What does participation in this study entail?</b></p>
					<div class="genIn-consentList">
						<ol>
						<li style ='text-align:left;'>You carefully read through this information and decide whether or not you wish to participate.</li> <br/>
						<li style ='text-align:left;'>You click the 'I Accept' button to consent to participate in the experiment.</li> <br/>
						<li style ='text-align:left;'>You participate in an experiment where you are presented with different scenarios and choose different alternatives. 
                        Your behavioural responses and web browser interactions are recorded during the experiment.</li><br/>
						<li style ='text-align:left;'>You fill out a set of psychological questionnaires.</li><br/>
						${inviting_again_text}
						</ol>
					</div>
					<p><b>The purpose of the study</b></p>
					<p>This study's primary purpose is to investigate decision-making mechanisms in healthy individuals. In the long run, we hope that our research will contribute to an improved 
                    understanding of decision-making and when it might be considered problematic, which is the case in certain psychological disorders (for example, depression).</p>
					
					<p><b><br/>The outline of the study</b></p>
					<p>The study involves playing ${multiple_or_one} decision-making game${s_or_not}${in_two_occasions}. You are going to get more detailed instructions before ${each} game starts.
                    You will never lose your own money, but you can gain more money if you perform well.  
                    The entire experiment will take about ${duration} to complete.

					<br/></p>
					
					<p><b><br/>Potential risks and discomfort</b></p>
					<p>We expect no risks or discomfort.</p>

					<p><b><br/>Please note that you can quit your participation at any point during the experiment!</b><p>

					<p>Your data are protected.<br/>
					The project will collect and record behavioural data, but we will not collect personal data. There is, therefore, no way for the researchers to trace the data back to your person. 
					As such, you are completely anonymous when participating in this study.  
					Researchers involved in the study are required to apply professional secrecy concerning everything that happens in your contact with us. 
					When the study is finished, the data will be processed and presented statistically at the group level, 
					graphically, or as numbers in a table wherein individual information will be untraceable. 
					In the interest of transparency and reproducibility, de-identified data may be posted on an online depository, such as Open Science Framework, 
					to be available for other researchers. There will be no way for these data to be linked to you. 
					After publication, information and data collected will be stored for at least 10 years. 
					The Archiving Act regulates the archiving of information collected in this study, and the Swedish National Archives is the regulatory authority. 
					Data management and archiving will take place in accordance with Karolinska Insititutet's rules.</p>

					<p><b><br/>How do you get information about the results of the study?</b></p>
					<p>If you are interested in receiving information about the study's results, feel free to mention it to the experiment leader through the messaging system on this 
                    website. We will send you more information when the study and analyses are completed. Note that we cannot disclose individual results, only group-level results.</p>

					<p><b><br/>Participation is voluntary</b></p>
					<p>Your participation is voluntary, and you can choose to quit at any time by closing the current tab of your web browser. If you choose not to participate or want to 
                    cancel your participation, you do not need to indicate why. You will, however, not be able to be compensated for your participation if you cancel your participation. </p>
					
					<p><b>Do you want to know more?</b><br/>
					If you have any questions or require further information, please get in touch with the experimenter through the messaging system on this website. 
					The Main researcher responsible for the study is Marc Guitart-Masip, Ph.D., at the Aging Research Centre at Karolinska Institutet in Sweden.</p>
					
					<p><b><br/>Consent to participate in the study</b> <br/> 
					I have received written information about the study. I may keep the written information by right-clicking and selecting to print the current screen. <br/> <br/>
					- I agree to participate in the project <i>${projectTitle}.</i> <br/> <br/>
					- I agree that my data is stored as described in the participant's information sheet (this document). <br/> <br/>
					If you click "I Accept", you agree to these terms, and the experiment will begin. 
					If you click "I Decline", the current tab will close, and your participation will be aborted.</p>
				</div>
			</div>`,
        choices: [`I Accept`, `I Decline`],
        data: {
            task: `const_form`,
        },
        on_finish: function (data) {
            if (data.response == 1) {
                return window.location = NCURL
                //close();
            }
        }
    };

    //prompt the user for their Prolific (participant) ID
    var participantID = {
        type: jsPsychSurveyText,
        preamble:
            `<div class="genIn-textDiv"><p>
            To reward you for participating in this experiment, we need your Prolific ID. This must be entered correctly in the box below. 
            If the Prolific ID is incorrectly entered, we cannot compensate you for participating in this experiment, so please be careful. 
			</p></div>`,
        questions: [
            { prompt: `<div class="genIn-textDiv">Please enter your Prolific ID here:</div>`, name: `ID` },
        ],
        data: {
            task: `initial_instructions`,
        },
        on_finish: function (data) {
            //let subject = data.response.ID;
            jsPsych.data.addProperties({ subjID: data.response.ID, nrMissedTrials: nrMissedTrials }); //remove nrMissedTrials?
            subID = data.response.ID;

            //record if they responded anything
            console.log(jsPsych.data.get().last(1).values()[0]);
            var subj_response = jsPsych.data.get().last(1).values()[0].response;
            console.log('response: ', subj_response.ID);
            if (subj_response.ID == '') {
                console.log('EMPTY RESPONSE');
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
    };

    var enterFullscreenMode = {
        type: jsPsychHtmlButtonResponse,
        choices: ['continue'],
        stimulus: function () {
            return `
            <p>The experiment will switch to full screen mode when you press the button below</p>
            `
        },
        on_finish: function () {
            enterFullscreen();
        }
    }
    //We have divided these five tasks into two sessions: one with two tasks and one with three.
    //You will receive 10&pound per session you complete.

    //In other words, if you were to only finish three tasks, you would not receive any performance bonus, no matter how many points you collect.


    //General instructions

    let page_1, page_2, page_3, page_4, page_5, page_6, page_7, page_8, page_9, page_10, page_11, page_12, page_13;

    if (day == 0) {
        page_1 = `<div class="genIn-textDiv" style="width: 60%"><p>In this experiment, you will play a game. It will measure different aspects of decision-making.</p></div>`;
        page_2 = `<div class="genIn-textDiv" style="width: 60%"><p>In this game you will collect points. The better you perform, the more points you can earn.</p></div>`;
        page_3 = `<div class="genIn-textDiv" style="width: 60%"><p>You will receive 4&pound for completing the experiment. At the end of the game, we will also convert your collected points into a <b>performance bonus</b>. The performance bonus is up to 1.5&pound, in addition to the 4&pound you will receive from completing the experiment.</p></div>`;
        page_4 = `<div class="genIn-textDiv" style="width: 60%"><p>Please note that <b>you will only receive payment upon completing the whole game</b>.</p></div>`;
        page_5 = `<div class="genIn-textDiv" style="width: 60%"><p>You will make various decisions, such as which button to press or which option to choose.</p></div>`;
        page_6 = `<div class="genIn-textDiv" style="width: 60%"><p>We cannot use your data if you miss too many decisions. Should this happen, we will terminate the experiment, and you will not receive any compensation, including the performance bonus.</p></div>`;
        page_7 = `<div class="genIn-textDiv" style="width: 60%"><p>The experiment will terminate if you miss 10 or more decisions in a row.</p></div>`;
        page_8 = `<div class="genIn-textDiv" style="width: 60%"><p>The experiment will terminate if you miss 10% of the total decisions in any game. </p></div>`;
        page_9 = `<div class="genIn-textDiv" style="width: 60%"><p>The whole experiment will run in full-screen mode. It is essential that you stay focused while playing the games and avoid tabbing out, minimizing the full-screen, or leaving the computer. If you leave the full-screen, the game will continue running in the background, and the experiment will likely terminate. </p></div>`;
        page_10 = `<div class="genIn-textDiv" style="width: 60%"><p>We will implement checks during the game to ensure you are paying attention. If you miss too many of these attention checks, the experiment will terminate.</p></div>`;
        page_11 = `<div class="genIn-textDiv" style="width: 60%"><p>We will provide more game-specific instructions before the game starts.</p></div>`;
        page_12 = `<div class="genIn-textDiv" style="width: 60%"><p>The entire experiment takes roughly 40 minutes to complete .</p></div>`;
        page_13 = `<div class="genIn-textDiv" style="width: 60%"><p>You will have multiple 1-minute breaks spread throughout the game. <b>Therefore, please take breaks only when you are asked to.</b></p></div>`;
    } else {
        page_1 = `<div class="genIn-textDiv" style="width: 60%"><p>In this experiment, you will play ${number_of_games} - ${each} game will measure different aspects of decision-making.</p></div>`;
        page_2 = `<div class="genIn-textDiv" style="width: 60%"><p>In each of these games, you will collect points. The better you perform, the more points you can earn.</p></div>`;
        page_3 = `<div class="genIn-textDiv" style="width: 60%"><p>You will receive ${this_exp_bonus}&pound for completing the experiment. At the end of each game, we will also convert your collected points into a <b>performance bonus</b>. The performance bonus is up to 1.5&pound per game, which means you can earn up to ${this_total_perf_bonus}&pound in addition to the ${this_exp_bonus}&pound you will receive from completing the experiment.</p></div>`;
        page_4 = `<div class="genIn-textDiv" style="width: 60%"><p>Please note that <b>you will only receive payment upon completing ${all} games</b>.</p></div>`;
        page_5 = `<div class="genIn-textDiv" style="width: 60%"><p>As part of each game, you will make various decisions, such as which button to press or which option to choose.</p></div>`;
        page_6 = `<div class="genIn-textDiv" style="width: 60%"><p>We cannot use your data if you miss too many decisions. Should this happen, we will terminate the experiment, and you will not receive any compensation, including the performance bonus.</p></div>`;
        page_7 = `<div class="genIn-textDiv" style="width: 60%"><p>The experiment will terminate if you miss 10 or more decisions in a row.</p></div>`;
        page_8 = `<div class="genIn-textDiv" style="width: 60%"><p>The experiment will terminate if you miss 10% of the total decisions in any game. </p></div>`;
        page_9 = `<div class="genIn-textDiv" style="width: 60%"><p>Every game will run in full-screen mode. It is essential that you stay focused while playing the games and avoid tabbing out, minimizing the full-screen, or leaving the computer. If you leave the full-screen, the game will continue running in the background, and the experiment will likely terminate. </p></div>`;
        page_10 = `<div class="genIn-textDiv" style="width: 60%"><p>We will implement checks during the games to ensure you are paying attention. If you miss too many of these attention checks, the experiment will terminate.</p></div>`;
        page_11 = `<div class="genIn-textDiv" style="width: 60%"><p>We will provide more game-specific instructions before each game starts.</p></div>`;
        page_12 = `<div class="genIn-textDiv" style="width: 60%"><p>The entire experiment will take roughly ${duration} to complete.</p></div>`;
        page_13 = `<div class="genIn-textDiv" style="width: 60%"><p>You will have multiple 1-minute breaks spread throughout each game, as well as a 5-minute bathroom break in the middle of the experiment. <b>Therefore, please take breaks only when you are asked to.</b></p></div>`;
    }
    
    var general_instructions = {
        type: jsPsychInstructions,
        pages: [
            page_1, page_2, page_3, page_4, page_5,
            page_6, page_7, page_8, page_9, page_10,
            page_11, page_12, page_13
        ],
        data: {
            game: `experiment_instructions`,
            parsing: 'end_genIn'
        },
        on_finish: function () {
            removeStyles();
        },
        show_clickable_nav: true
    };
    
    //exit fullscreen
    const exitFullscreen = {
        type: jsPsychFullscreen,
        fullscreen_mode: false,
        delay_after: 0
    };
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //timeline.push(preload);

    timeline.push(welcome);
    timeline.push(consent);
    timeline.push(close_tabs);
    timeline.push(participantID_node);
    timeline.push(enterFullscreenMode);
    timeline.push(general_instructions);

    return timeline;
}

