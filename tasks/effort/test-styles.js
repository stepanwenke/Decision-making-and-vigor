var effort_styles = `

.effort-rect-thumbnail.effort-coin-bar-container, .effort-rect-thumbnail.effort-effort-bar-container {
    width: 100%;
    height: 100%;
    display: flex;
}

.effort-rect-thumbnail.effort-coin-bar-segment, .effort-rect-thumbnail.effort-effort-bar-segment {
    height: 100%;
    flex-grow: 1;
    border-right: 2px solid white; /* White border between segments */
}

.effort-rect-thumbnail.effort-coin-bar-segment.coin {
    background: #f0b41e;
}

.effort-rect-thumbnail.effort-effort-bar-segment.effort {
    background: rgb(31, 83, 31);
}

.effort-rect-thumbnail.effort-coin-bar-segment:last-child, .effort-rect-thumbnail.effort-effort-bar-segment:last-child {
    border-right: none; /* Remove border from the last segment */
}

.effort-coin-caption, .efffort-effort-caption {
    margin: 0 auto
}

.effort-coin-caption p {
    margin: 0;
    color: #ffe49e;
    font-weight: bold;
}

.effort-effort-caption p {
    margin: 0;
    color: #00ff00;
    font-weight: bold;
}

#effort-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    /* Transparent black background */
    backdrop-filter: blur(0.5em);
    /* Apply blur effect */
    z-index: 9999;
    display: none;
    /* Initially hidden */
}

 body {
    background-color: #8db6d3!important;
    background-repeat: repeat-x;
    background-size: cover;
    overflow: hidden !important;
    font-family: 'Libre Franklin', sans-serif !important;
    
} 

.effort-title-container {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: #8db6d3;
}

.effort-title {
    font-family: 'Kablammo', cursive;
    font-size: 11vw;
    position: absolute;
    top: 25vh;
    left: 50vw;
    translate: -50%;
    height: 100%;
    width: 100%;
}

.effort-headline {
    background: #fffb7f;
    box-shadow: 1em 1em 4em;
    border-radius: 5em;
    border: 0.5em solid white;
    width: 25vw;
    position: absolute;
    left: 50%;
    translate: -50%;
    top: 2vw;
    margin: 0 auto 15vh;

}

.effort-text-box,
.effort-text-box-error {
    position: absolute;
    left: 50%;
    width: 50vw;
    min-width: 750px;
    translate: -50% -50%;
    padding: 2em 6em 3em;
    background: #b1b7e1;
    border: 0.5em solid white;
    border-radius: 5em;
    box-shadow: 0.5em 0.5em 1.5em #2c2c2c;
}

.effort-outcome-box {
    display: flex;
    justify-content: center;
    align-items: center;
}


.effort-text-box-error {
    z-index: 9999;
    translate: -50% 100%;
}

.effort-outcome-box,
.effort-text-box-error,
.effort-sternberg-text-box {
    padding: 2em 6em !important;
}

.effort-key-hint {
    opacity: 0;
    -webkit-transition: opacity 0.5s ease-in-out;
    -moz-transition: opacity 0.5s ease-in-out;
    transition: opacity 0.5s ease-in-out;
}

.effort-key-hint p {
    font-size: 2em
}

.effort-time-out {
    top: 50%;
    z-index: 999;
    padding: 5em 6em;
    /*display: none;*/
}

.effort-coins-icon {
    background: url(tasks/effort/images/finish.png) no-repeat center/contain;
    width: 4em;
    height: 2.5em;
}

.effort-coins-amount {
    font-weight: bold;
    font-size: 1.5em;

}

.effort-button-container {
    display: flex;
    justify-content: space-between;
    /* width: 46em;*/
}

.effort-button,
.effort-button-caption {
    border: 0.5em solid white;
    border-radius: 2.5em;
    padding: 2% 5%;
    width: 30%;
    background: #b185fc;
    background: #464371;
}

.effort-caption-container {
    display: flex;
    justify-content: space-between;
}

.effort-button-caption {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.4em;
    border-color: antiquewhite;
    background-color: antiquewhite;
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
    padding: 0 5% 6%;
    margin-bottom: -7%;
}

.effort-choice-keys {
    width: 14%;
}

.effort-choice-keys-intro {
    width: auto;
    height: 2em;
}

.effort-choice-keys-container {
    display: inline-flex;
    align-items: center;
    gap: 0.6em;
    flex-wrap: wrap;
    justify-content: center;
}

.effort-selected.button {
    border: 2px solid red;
}

.effort-correct {
    color: rgb(31, 83, 31);
}

.effort-incorrect {
    color: rgb(218, 60, 60)
}

.effort-out-caption,
.effort-n {
    height: 128px;
    margin: 0;
    padding: 0;
}

.effort-progress-container {
    font-size: 0;
}

.effort-progress-bar {
    border: 1em solid white;
    border-radius: 5em;
    background-color: #c4c4c4;
    width: 50vw;
    /* ratio w x h: 0.12 */
    height: 6vw;
    position: relative;
    display: inline-block;
    overflow: hidden;
    box-shadow: 0.5em 0.5em 1.5em #2c2c2c;
}

.effort-open-ended {
    border-right: none;
}

.effort-finish {
    position: absolute;
    /*border: 3px solid yellow;*/
    /* left: 85%; */
    left: 51%;
    transform: translateX(400px);
    bottom: 14%;
    background: url(tasks/effort/images/finish.png) no-repeat center/contain;
    /*
    background-size: 100% 100%;
    background-repeat: no-repeat;
    
    width: 120px;
    height: 110px;
    */
    width: 6em;
    height: 5.5em;
    /* ratio w x progress-bar w 0.16 */
    /*background-position: left;*/
    /*transform: translateX(-50%);*/
}

.effort-enemy {
    height: 7em;
    /*border: 3px solid brown;*/
    background-color: rgb(98, 98, 194);
    background: url(tasks/effort/images/minotaur_walking.gif) no-repeat center/cover;
    width: 7em;
    position: absolute;
    z-index: 50;
    bottom: 10vh;
    left: 50%;
    transform: translateX(-50%);
}

.effort-dying {
    background: url(tasks/effort/images/minotaur_dying.gif) no-repeat center/cover;
}

.effort-standing {
    background: url(tasks/effort/images/enemy.png) no-repeat center/cover;
}

.effort-flipped {
    -webkit-transform: scaleX(-1) translateX(50%);
    transform: scaleX(-1) translateX(50%);
}

.effort-character,
.effort-intro {
    /*border: 3px solid green;*/
    position: absolute;
    /* position the top  edge of the element at the middle of the parent */
    left: 50%;
    /* position the left edge of the element at the middle of the parent */

    transform: translateX(-50%);
    bottom: 16vh;
    width: 7em;
    height: 7em;
    background: url(tasks/effort/images/character.png);
    background-size: cover;
    z-index: 50;
}

.effort-walking {
    background: url(tasks/effort/images/goblin_walking.gif);
    background-size: cover;
}

.effort-left {
    background: url(tasks/effort/images/character_left.png);
    background-size: cover;
}

.effort-hurt {
    background: url(tasks/effort/images/goblin_hurt.gif);
    background-size: cover;
}

.effort-win {
    background: url(tasks/effort/images/goblin_win.gif);
    background-size: cover;
}

.effort-resting {
    background: url(tasks/effort/images/goblin_rest.gif) no-repeat center/cover;
}

.effort-container {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.effort-container.caption {
    flex-direction: column;
    margin-top: 1em!important;
}


.effort-container+.effort-container {
    margin-top: 0.4em;
}

.effort-effort-icon {
    background: url(tasks/effort/images/potentials/biceps.png);
    background-size: cover;
    height: 2.5em;
    width: 2.5em;
}

.effort-effort-icon-mental {
    background-image: url(tasks/effort/images/potentials/brain.png);
    width: 3.5em;
}

.effort-character-thumbnail {
    height: 3em;
    width: 2.5em;
    position: unset;
    transform: none;
}

.effort-stacked {
    margin: 0 -0.65em;
}

.effort-progress-thumbnail {
    /* height: 1.5em; OG */ 
    height: 2.5em;
    width: 70%;
    border-width: 0.2em;
    background-color: #e9e9e9;
}

.effort-rect-thumbnail {
    /* height: 1.5em !important; OG */
    height: 2.5em !important;
}

.effort-effort-bar {
    background-color: rgb(31, 83, 31);
    color: #fff3db;
}

.effort-coin-bar {F
    background-color: #f0b41e;
    color: black;
}

.effort-finish-thumbnail {
    position: unset;
    transform: none;
    width: 2.5em;
    height: 2.3em;
}

.effort-char-container {
    display: flex;
}

.effort-p-thumbnail {
    margin: 0;
    padding: 0.5em 0;
}

.effort-rect {
    background: rgb(98, 98, 194);
    width: 0%;
    height: 100%;
    border-radius: 50em;

}

.effort-probe-caption {
    padding: 0.5vw;
    width: 20%;
    margin: 0 auto;
    border-top-left-radius: 2.5em;
    border-top-right-radius: 2.5em;
    background: #b1b7e1;
    border: 0.5em solid white;
    border-bottom: 0;
}

.effort-number {
    font-size: 48px;
    opacity: 1;
    transition: opacity 1s ease-in-out;
}

.effort-fade-out {
    opacity: 0;
}

.text-box-error {
    border: 0.5em solid #db4343 /* white */;
    background-color: #cbd1d1 /* rgb(56, 65, 65) */;
  }
`
