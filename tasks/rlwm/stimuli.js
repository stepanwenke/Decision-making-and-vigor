var imageDirectory = 'tasks/rlwm/img/';
var dayDirectory = 'Day 1/';
var day2Directory = 'Day 2/';

//Other images
var KILogo = imageDirectory + 'KILogo.png'; //Ki logo for consent form
var instructImg2 = imageDirectory + 'sofa.jpg';
var instructImg3 = imageDirectory + 'armchair.jpg';

const backgroundImage = imageDirectory + 'silver.png';

imageDirectoryDay1 = imageDirectory + dayDirectory
imageDirectoryDay2 = imageDirectory + day2Directory


//create stimulus list
var test_stimuli = [
    { img: imageDirectoryDay1 + 'Animals/cow.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Animals/dromedary.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Animals/elephant.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Animals/horse.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Animals/rhino.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Animals/zebra.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '6' },
    { img: imageDirectoryDay1 + 'Buildings/castle.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Buildings/cathedral.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Buildings/church.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Buildings/pagoda.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Buildings/pyramid.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Buildings/tower.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '6' },
    { img: imageDirectoryDay1 + 'Clothing/bathrobe.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Clothing/coat.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Clothing/shirt.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Clothing/socks.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Clothing/trousers.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Clothing/undershirt.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '6' },
    { img: imageDirectoryDay1 + 'Flowers/carnation.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Flowers/daisy.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Flowers/orchid.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Flowers/pansy.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Flowers/poppy.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Flowers/sunflower.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '6' },
    { img: imageDirectoryDay1 + 'Fruits/apple.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Fruits/banana.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Fruits/grapes.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Fruits/lemon.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Fruits/orange.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Fruits/pear.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '6' },
    { img: imageDirectoryDay1 + 'Musical_Inst/accordion.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Musical_Inst/drum.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Musical_Inst/guitar.jpg', correct_response:'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Musical_Inst/piano.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Musical_Inst/saxophone.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Musical_Inst/violin.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '6' },
    { img: imageDirectoryDay1 + 'Tools/axe.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Tools/chisel.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Tools/hammer.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Tools/handsaw.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Tools/pliers.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Tools/screwdriver.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '6' },

    { img: imageDirectoryDay1 + 'Kitchen_Uten/fork.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Kitchen_Uten/frying_pan.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Kitchen_Uten/peeler.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Kitchen_Uten/sharpening_steel.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Kitchen_Uten/small_saucepan.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Kitchen_Uten/strainer.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '6' },

    { img: imageDirectoryDay1 + 'Vegetables/carrot.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Vegetables/cauliflower.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Vegetables/eggplant.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Vegetables/onion.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Vegetables/pepper.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Vegetables/potato.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '6' },
    { img: imageDirectoryDay1 + 'Vehicles/bus.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '1' },
    { img: imageDirectoryDay1 + 'Vehicles/car.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '2' },
    { img: imageDirectoryDay1 + 'Vehicles/motorbike.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '3' },
    { img: imageDirectoryDay1 + 'Vehicles/plane.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '4' },
    { img: imageDirectoryDay1 + 'Vehicles/ship.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '5' },
    { img: imageDirectoryDay1 + 'Vehicles/train.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '6' }
];

var test_stimuli_day2 = [
    { img: imageDirectoryDay2 + 'Animals/cheetah.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Animals/lioness.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Animals/platypus.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Animals/tapir.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Animals/tiger.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Animals/turtle.jpg', correct_response: 'q', stimulus_type: 'Animals', block: '1', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Buildings/factory.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Buildings/house.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Buildings/lighthouse.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Buildings/mill.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Buildings/palace.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Buildings/skyscraper.jpg', correct_response: 'q', stimulus_type: 'Buildings', block: '2', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Clothing/biretta.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Clothing/cap.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Clothing/clog.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Clothing/glove.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Clothing/jacket.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Clothing/shoe.jpg', correct_response: 'q', stimulus_type: 'Clothing', block: '3', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Flowers/araceae.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Flowers/bellflowers.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Flowers/geranium.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Flowers/lilac.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Flowers/rose.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Flowers/tulip.jpg', correct_response: 'q', stimulus_type: 'Flowers', block: '4', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Fruits/coconut.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Fruits/custard_apple.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Fruits/mango.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Fruits/melon.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Fruits/quince.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Fruits/watermelon.jpg', correct_response: 'q', stimulus_type: 'Fruits', block: '5', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Musical_Inst/balalaika.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Musical_Inst/clarinet.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Musical_Inst/harp.jpg', correct_response:'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Musical_Inst/tambourine.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Musical_Inst/trumpet.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Musical_Inst/tuba.jpg', correct_response: 'q', stimulus_type: 'Musical_Inst', block: '6', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Tools/cold_chisel.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Tools/nut.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Tools/pincers.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Tools/screw.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Tools/showel.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Tools/trowel.jpg', correct_response: 'q', stimulus_type: 'Tools', block: '7', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Kitchen_Uten/coking_pot.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Kitchen_Uten/cup.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Kitchen_Uten/fondue.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Kitchen_Uten/pot.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Kitchen_Uten/saucepan.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Kitchen_Uten/teapot.jpg', correct_response: 'q', stimulus_type: 'Kitchen_Uten', block: '8', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Vegetables/cabbage.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Vegetables/celery.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Vegetables/chard.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Vegetables/leek.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Vegetables/red_cabbage.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Vegetables/tomato.jpg', correct_response: 'q', stimulus_type: 'Vegetables', block: '9', stim_id: '6' },
    { img: imageDirectoryDay2 + 'Vehicles/boat.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '1' },
    { img: imageDirectoryDay2 + 'Vehicles/cart.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '2' },
    { img: imageDirectoryDay2 + 'Vehicles/scooter.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '3' },
    { img: imageDirectoryDay2 + 'Vehicles/skateboard.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '4' },
    { img: imageDirectoryDay2 + 'Vehicles/tractor.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '5' },
    { img: imageDirectoryDay2 + 'Vehicles/van.jpg', correct_response: 'q', stimulus_type: 'Vehicles', block: '10', stim_id: '6' }
];

 ////////////////////How key-pairings was initially generated/////////////////////////////////////////

/* const NUMBER_OF_BLOCKS = 10;
const RESPONSE_BUTTONS = ['q', 'w', 'e'];

const B1 = RESPONSE_BUTTONS[0];
const B2 = RESPONSE_BUTTONS[1];
const B3 = RESPONSE_BUTTONS[2];
    
let jsPsych = initJsPsych({
    on_finish: function() {
        jsPsych.data.displayData();
    }
});

//create a vector of randomly selected keys (to be paired with stimuli)
let key_pairings = []; //do only once for experiment (in separate file then?)?
for (let i = 0; i < 6*NUMBER_OF_BLOCKS; i++) {
    key_pairings[i] = randKeys(1);     
}


//define function for randomizing response keys
function randKeys(nrSamples) { //kinda problematic because it can give e.g., q,q,q,q,e,q. 
    var responseKeys = RESPONSE_BUTTONS;
    var tmp = jsPsych.randomization.sampleWithoutReplacement(responseKeys, nrSamples);
    var randKey = tmp.toString()
    return randKey
} */



