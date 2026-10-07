function ASRM() {
    let questionsASRM = [];

    questionsASRM = [
        {
            prompt: `1. Positive Mood`,
            name: `1`,
            options: [
                `1. I do not feel happier or more cheerful than usual.`,
                `2. I occasionally feel happier or more cheerful than usual.`,
                `3.  I often feel happier or more cheerful than usual. `,
                `4.  I feel happier or more cheerful than usual most of the time.`,
                `5.  I feel happier or more cheerful than usual all of the time.`],
            required: true
        },
        {
            prompt: `2. Self-Confidence`,
            name: `2`,
            options: [
                `1. I do not feel more self-confident than usual.`,
                `2. I occasionally feel more self-confident than usual.`,
                `3. I often feel more self-confident than usual.`,
                `4. I feel more self-confident than usual.`,
                `5. I feel extremely self-confident all of the time.`
            ],
            required: true
        },
        {
            prompt: `3. Sleep Patterns`,
            name: `3`,
            options: [
                `1. I do not need less sleep than usual.`,
                `2. I occasionally need less sleep than usual.`,
                `3. I often need less sleep than usual.`,
                `4. I frequently need less sleep than usual.`,
                `5. I can go all day and night without any sleep and still not feel tired.`
            ],
            required: true
        },
        {
            prompt: `Attention check: Select the option "3. Monstly Untrue" to indicate that you payed attention here.`,
            name: `AC`,
            options:  [`4. Completely Untrue`,`3. Mostly Untrue`,`2. Neither True Nor Untrue `,`1. Quite True`, `0. Completely True`],
            required: true
        },
        {
            prompt: `4. Speech`,
            name: `4`,
            options: [
                `1. I do not talk more than usual.`,
                `2. I occasionally talk more than usual.`,
                `3. I often talk more than usual.`,
                `4. I frequently talk more than usual.`,
                `5. I talk constantly and cannot be interrupted.`
            ],
            required: true
        },
        {
            prompt: `5. Activity Level`,
            name: `5`,
            options: [
                `1. I have not been more active (either socially, sexually, at work, home or school) than usual.`,
                `2. I have occasionally been more active than usual.`,
                `3. I have often been more active than usual.`,
                `4. I have frequently been more active than usual.`,
                `5. I am constantly active or on the go all the time.`
            ],
            required: true
        }

    ]


    let ASRM = {
        type: jsPsychSurveyMultiChoice,
        preamble: `<h1>Questionnaire 2/6</h1>
            <h2>Instructions</h2>
            <p>There are 5 groups of statements in this questionnaire, read each group of statements carefully. 
            You should choose the statement in each group that best describes the way you have been feeling for the past week.</p>
            <p>Please note: The word "occasionally" when used here means once or twice; "often" means several times or more and "frequently" means most of the time. </p>`,
        questions: questionsASRM,
        data: {
            task: "ASRM",
        }
    };
    return ASRM
}
