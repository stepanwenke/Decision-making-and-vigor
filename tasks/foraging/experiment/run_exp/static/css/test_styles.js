var foraging_styles = `

body {
    padding:0px;
    margin: 0px;
    background-color: #c0c0c0!important;
    color: black;
    font-weight: 300; 
    font-size: 13pt;
}



/* text styling */
strong {
  font-weight: 600;         
}

.dug-up {
  color: white;
  font-size: 3em;
  top: 30%;
  position: absolute;
  left: 50%;
  translate: -50%;
}

img, canvas {
  height: 65vh!important
}

.fullscreen-image,
#jspsych-animation-image {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw!important;
  height: 100vh!important;
  z-index: -1;
  object-fit: contain;
}

.jspsych-instructions-nav {
  display: none
}

.text-box {
  padding: 1.5em;
  border: 0.5em solid #942a1a;
  background: antiquewhite;
  border-radius: 5em;
  position: relative;
  top: -25vh;
  box-shadow: 0.5em 0.5em 1.5em #2c2c2c;
  
}

.warm {
  color: steelblue;
  text-align: justify;
}

.cool {
  color: #ccccff;
}

h1 {
  margin-top: 0px;
}


/* these are all the same for now, but easy to modify individually */
#container-not-an-ad, #container-error, #container-exp, #container-consent, #container-instructions, #container-questionnaire {
    background: white;
    margin: 30px;
}

/* ad.html  - the ad that people view first */
#adlogo {
    width: 140px;
    padding: 2px;
    border: 1px solid #ccc;
    margin-right: 1em;
}

/* consent.html - the consent form */
#consent {
  margin: 0 auto;
  margin-top: 0;
  width: 800px;
  font-size: 100%;
}

.legal {
  text-align: justify;
  font-size: 11pt;
  line-height: 1.1em;
}

#trial {
  margin: 0 auto;
  width: 800px;
  text-align: center;
}

#query {
  color: darkgray;
}

.question {
  margin-bottom: 30px;
}

.quiz-container {
  text-align: left; 
  margin-left: 50%; 
  transform: translateX(-50%);
  width: 30vw;
}

/* errors */
#error img {
  padding-right: 10px;
  padding-top: 15px;
}

/* ---------------------------------- */
/*      Full-screen element           */
/* ---------------------------------- */

.text-box-error {
    border: 0.5em solid #db4343 /* white */;
    background-color: #cbd1d1 /* rgb(56, 65, 65) */;
  }

@media screen and (max-height: 800px) {
    .text-box {
        padding: 1em;
        line-height: normal;
    }
}

`