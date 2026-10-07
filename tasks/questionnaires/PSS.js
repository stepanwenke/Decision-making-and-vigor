function PSS(includeAttentionChecks){
    let questionsPSS = []; 

    if(includeAttentionChecks == 1) {
        questionsPSS =[ 
            {
                prompt: `1. In the last month, how often have you been upset because of something that happened unexpectedly?`,
                name: `1`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `2. In the last month, how often have you felt that you were unable to control the important things in your life?`,
                name: `2`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `3. In the last month, how often have you felt nervous and stressed?`,
                name: `3`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `4. In the last month, how often have you felt confident about your ability to handle your personal problems?`,
                name: `4`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `5. In the last month, how often have you felt that things were going your way?`,
                name: `5`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `6. In the last month, how often have you found that you could not cope with all the things that you had to do?`,
                name: `6`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `Attention Check: Choose the option "3. Fairly Often" to indicate that you payed attention here.`,
                name: `AC`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `7. In the last month, how often have you been able to control irritations in your life?`,
                name: `7`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `8. In the last month, how often have you felt that you were on top of things?`,
                name: `8`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `9. In the last month, how often have you been angered because of things that happened that were outside of your control?`,
                name: `9`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
            {
                prompt: `10. In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?`,
                name: `10`,
                options: [`0. Never`,`1. Almost Never `,`2. Sometimes `,`3. Fairly Often`,`4. Very Often`],
                required:true
            },
        ]

    } 

    let PSS = {
        type: jsPsychSurveyMultiChoice,
        preamble:`<h1>Questionnaire 6/6</h1>
        <p>The questions in this scale ask about your feelings and thoughts
        during the last month. In each case, you will be asked to indicate how often you felt or thought a certain
        way. Although some of the questions are similar, there are differences between them and you should
        treat each one as a separate question. The best approach is to answer fairly quickly. That is, don't try to
        count up the number of times you felt a particular way; rather indicate the alternative that seems like
        a reasonable estimate</p>`,
        questions:questionsPSS,
        data:{
            task: "PSS",
        }

    }
    return PSS
};