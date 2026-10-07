
// For the "break" trial (dynamic depending on RT)
// Initialize HTML.
var new_html = '';

// Insert CSS (window animation).
new_html += `<style>
      body {
        height: 100vh;
        max-height: 100vh;
        overflow: hidden;
        position: fixed;
        background: -webkit-gradient(linear, left bottom, left top, from(#808080), color-stop(50%, #606060), color-stop(50%, rgba(28, 25, 23, 0.5)), to(rgba(179, 230, 230, 0.5)));
        background: linear-gradient(0deg, #808080 0%, #606060 50%, #A0A0A0 50%, #D3D3D3 100%);
      }
      .jspsych-content-wrapper {
        overflow: hidden;
      }
     <!-- @-webkit-keyframes pavlovian {
        0%    {border-bottom-color: rgba(0, 0, 0, 0);}
        90%   {border-bottom-color: rgba(0, 0, 0, 0);}
        100%  {border-bottom-color: rgba(0, 0, 0, 0);}
      }
      @keyframes pavlovian {
        0%    {border-bottom-color: rgba(0, 0, 0, 0);}
        90%   {border-bottom-color: rgba(0, 0, 0, 0);}
        100%  {border-bottom-color: rgba(0, 0, 0, 0);}
      }

      -->
      </style>`;

// Add robot factor wrapper.
new_html += '<div class="gng-factory-wrap">';

// Add factory machine parts (back).
new_html += '<div class="gng-machine-back"></div>';
new_html += '<div class="gng-still-conveyor"></div>';
new_html += '<div class="gng-shadows"></div>';

// Add robot 1 (active).
/*       new_html += '<div class="robot" status="active">';
      new_html += '<div class="antenna"></div>';
      new_html += '<div class="head"></div>';
      new_html += '<div class="torso">';
      new_html += '<div class="left"></div>';
      new_html += '<div class="right"></div>';
      //new_html += `<div class="rune" set="${trial.rune_set}" id="rune"><p>${trial.robot_rune}</p></div></div>`;
      new_html += '<div class="foot"></div></div>'; */

// Add robot 2 (hidden).
new_html += '<div class="gng-still-robot">';
new_html += '<div class="gng-antenna"></div>';
new_html += '<div class="gng-head"></div>';
new_html += '<div class="gng-torso">';
new_html += '<div class="gng-left"></div>';
new_html += '<div class="gng-right"></div>';
new_html += `<div class="gng-rune"></div></div>`;
new_html += '<div class="gng-foot"></div></div>';

// Add factory window.
//new_html += `<div class="scanner-light" style="border-bottom-color: ${trial.scanner_color}"></div>`;

// Add factory machine parts (front).
new_html += '<div class="gng-machine-front">';
new_html += '<div class="gng-score-container">';
new_html += '<div class="gng-score" id="outcome"></div>';
new_html += '</div></div>';
new_html += '<div class="gng-machine-top"></div>';

// Close wrapper.
new_html += '</div>';

// Display HTML
//display_element.innerHTML = new_html;


//------------------------------------//
// Define experiment parameters.
//------------------------------------//

// Define trial structure.
runsheets = jsPsych.randomization.shuffle(runsheets)

//console.log('runsheets: ', runsheets);

// Define rune sets.
const rune_sets = ['elianto', 'bacs1', 'bacs2'];
const rune_prob = [0.33, 0.33, 0.33];

// Define aesthetics.
if (Math.random() < 1) {
  var instr_color_win = 'blue';
  var scanner_color_win = '#3366ff99';
  var outcome_color_win = '#1a3ea7';
  var instr_color_lose = 'red';
  var scanner_color_lose = '#f73b6a7A';
  var outcome_color_lose = '#930a25';
} else {
  var instr_color_win = 'red';
  var scanner_color_win = '#f73b6a7A';
  var outcome_color_win = '#930a25';
  var instr_color_lose = 'blue';
  var scanner_color_lose = '#3366ff99';
  var outcome_color_lose = '#1a3ea7';
}

// Define go key.
const key_go = " ";

// Define timings.
const trial_duration = 1300;         // Duration of trial (response phase)
const feedback_duration = 1200;      // Duration of feedback (minimum)

// Define payment.
const completion_bonus = 0;
var performance_bonus = bonus_per_task;

// Define catch trial variables
const CATCH_TRIAL_DURATION = 10000; //arbitrary reason
const CATCH_TRIAL_FEEDBACK_DURATION = 1000; //arbitrary reason
//var MAX_MISSED_ATTEN_CHECKS = 2; //threshold for maximum allowed missed catch trials (reaching the threshold leads to exclusion)
const CATCH_BUTTONS = ['ArrowUp', 'ArrowDown', 'g', '3', 'h', 't', 'k', '7', 'a', '5'];
const CB = jsPsych.randomization.sampleWithoutReplacement(CATCH_BUTTONS, 1);
var nrMissedAttenChecks = 0; //initialize number of missed catch trials

// Define screen size parameters.
var min_width = 500;
var min_height = 450;

//------------------------------------//
// Define rune order.
//------------------------------------//

// Randomly select rune set.
//const rune_set = jsPsych.randomization.sampleWithReplacement(rune_sets, 1, rune_prob)[0];

// Set the inital ones, change them once the task starts
var rune_set = 'bacs2';
var runes_a = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
var runes_b = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
var runes = (Math.random() < 0.5) ? [runes_a, runes_b] : [runes_b, runes_a];

function set_runes() {
  const subjIDToRuneSet = {
    /*     '55ac3198fdf99b6de3b68b23': ['bacs1'],
        '571a78f06a1c6300114b8d80': ['elianto'],
        '57d5ab3a722df500017f3622': ['bacs2'],
        '58a5cf959e040a0001399f07': ['bacs2'],
        '5af82cf9e066a40001136ace': ['bacs1'],
        '5b07e80e9d397e0001919fba': ['bacs1'],
        '5bbb5e3f118c0600013c3202': ['bacs2'],
        '5bea9d9805619d0001072057': ['elianto'],
        '5bf3199ebe7c7300017b710a': ['bacs2'],
        '5c18daaae467040001e68fc4': ['elianto'],
        '5c2e93f52c45d400014aa665': ['bacs1'],
        '5c3ce83e9883d400014200a5': ['bacs1'],
        '5c45ad3793f3690001c46767': ['bacs2'],
        '5c7ceda01d2afc0001f4ad1d': ['elianto'],
        '5c882fbb42ff490016c7e47b': ['bacs2'],
        '5d5b0dd7c032a2001ad7cf5d': ['bacs1'],
        '5d66b4f503b0d900195ca627': ['bacs1'],
        '5d951ede9b6f880018f63b6e': ['bacs2'],
        '5da330e8656efc001626ea3e': ['elianto'],
        '5dc0856370d51c032949d2db': ['bacs1'],
        '5dd05d80b2204f1487f7812c': ['bacs2'],
        '5df8d8d6b7b3306449876d43': ['bacs1'],
        '5e4066ed9eec8d2a184e4ff4': ['bacs1'],
        '5e5a96f5a2f2c528edf70f6e': ['bacs2'],
        '5e5c993cd0394c474f7cc502': ['bacs2'],
        '5e6e853c1b327543ad8df90e': ['elianto'],
        '5e73ded1027e893642055f86': ['bacs2'],
        '5ed9c3054268815691ed0e2c': ['elianto'],
        '5ee7fbc114d0a60f9b076fb6': ['bacs2'],
        '5f233d7f53212b0e22bf055d': ['bacs2'],
        '5f4dc319c9fb1509b77d8b84': ['bacs2'],
        '5f54cdbcd2fd0a8484ef4645': ['bacs1'],
        '5f632ea32e85353d93872c67': ['bacs2'],
        '5f8893a5e2f88a04b1833278': ['bacs2'],
        '5fabca68273dd403ab40e361': ['bacs1'],
        '5fb9adb28a52968d9f561808': ['bacs1'],
        '5fc0d12ee844ed0b32c5d4d8': ['elianto'],
        '5fed47cfcb429d79af4f8ded': ['bacs1'],
        '5ff454f2f0b5ed607169fba6': ['bacs1'],
        '5ffa1a0f5395ad3a679fb0f0': ['bacs2'],
        '5fff2877a99bcb65a14a223c': ['elianto'],
        '60317fc2c8f6320ecde4bcb3': ['bacs2'],
        '60471ddd0b6ed718cb843760': ['bacs2'],
        '604fa685e33606f9a0ee8189': ['bacs1'],
        '605211b8ebd0a5605f0f961b': ['elianto'],
        '605db73fe547ff7c425f59de': ['bacs1'],
        '607ee7232fb723e021ea8bd5': ['bacs1'],
        '609bfd97a7c95881330491d4': ['bacs2'],
        '60a0b744298c64d46b63e893': ['elianto'],
        '60a0dfc6f9936b0d30dfea15': ['elianto'],
        '60bd28cc95ab27d4f4f6ada3': ['bacs1'],
        '60d9dfd4dcc09cf57dc92cb1': ['bacs1'],
        '60e0dc6be0772b7dfdad9b2c': ['bacs2'],
        '60e45a7bc4730383ee2fecb6': ['bacs1'],
        '60e7218db2691424068d718c': ['bacs2'],
        '60e858204e148e07ef3ef257': ['elianto'],
        '6122f45e2e93a3ff9a7b7a5d': ['elianto'],
        '613f59d7f0f631a278aca6e8': ['bacs2'],
        '6140ef8d27499e70e8740918': ['bacs2'],
        '615dd36156bf443246c0b660': ['bacs1'],
        '6161cb3de3d274978d46575b': ['bacs2'],
        '6167088739fc87bf9028db4c': ['bacs1'],
        '61687ebcd2a35ffb762d1928': ['bacs2'],
        '616cc1c4244b5866081d3f72': ['elianto'],
        '616dbc894ee323e3893f8919': ['bacs2'],
        '6171946a19f6673fb215c0c7': ['bacs2'],
        '61fa90b1d42cb19beec491c3': ['elianto'],
        '627e7e91d0e389328983e765': ['elianto'],
        '62a0b34cbcc5987a8fa73c39': ['bacs2'],
        '6315fd72852e279a1a13e5f1': ['bacs2'],
        '631610af8e747093cd90e00d': ['bacs1'],
        '63222311994c6e4c35bb2a55': ['elianto'],
        '6346b5a6ea546c77fae4c827': ['bacs2'],
        '637774fa068c5a7fb372e6be': ['elianto'],
        '63d13c066352266a8621cc2a': ['elianto'],
        '645cf23cf9229b8dd5453a6e': ['elianto'],
        '647869e6f69318bacc341d53': ['elianto'],
        '64ef4386a31700e2d88622c9': ['bacs1'],
        '64feeabd355b506d0512d862': ['bacs2'],
        '650f65aac58fe4dc08bbe23f': ['elianto'],
        '652e9eb14b23a3ccf4c340f4': ['bacs2'],
        '655b901b23209ae4a194a402': ['elianto'],
        '655f8bf6de805f7bd81e5811': ['bacs1'],
        '65651805d1afb42ba1a55476': ['bacs2'],
        '65672c69a3737224f1d0bbfa': ['bacs1'],
        '65956ab743aa1e8fe002ba3b': ['elianto'],
        '6597f894ae0302a96b69adda': ['bacs2'],
        '65a3ec77f674ac3e98f0c6ac': ['bacs2'],
        '65a69ce9c8cf8262d34f646a': ['elianto'],
        '65ab079fde17d72bca5e774b': ['elianto'],
        '65ba64c07847d4c34ec00de1': ['elianto'],
        '65f0770588878297865a0cc4': ['elianto'],
        '65faeb7145b8262f7a342099': ['bacs2'],
        '65fb34c4df61f03ce0dd6dd9': ['elianto'],
        '660453c9877e571d12b555f7': ['bacs1'],
        '6604b1a8441e527fc9590694': ['elianto'],
        '66059f112a799642519f8e87': ['bacs2'],
        '66083cd0a45e1ce399e6a85f': ['bacs2'],
        '6633f36862c583c2e9dfa550': ['bacs2'],
        '6640e5d6c304dc7b28316078': ['bacs2'],
        '6640fd54ac9d9313a68cb312': ['elianto'],
        '66428090de7c2db3caed1c77': ['bacs2'],
        '6643be675817fd2a43298a04': ['bacs2'],
        '66446d88662725412dc27d06': ['bacs1'],
        '664c9a37d570871d534dd3c2': ['elianto'],
        '664cf2037353bb98801436b5': ['bacs2'],
        '664db585355de70e17541e5a': ['bacs2'],
        '664e326b5579c6f6ca3fd1ff': ['bacs1'],
        '6655fc1f1ff86ee869fd7c8c': ['bacs1'],
        '6658ba167affbe300577b93d': ['elianto'],
        '6658c4239af9537eefdfbcc9': ['bacs2'],
        '66598536c019b32cd7fa1fda': ['bacs2'],
        '6659fa442c09453f80c77223': ['bacs1'],
        '665b3d986d036dd09e90668c': ['elianto'],
        '665e65e919f6e1f21ea08fbd': ['bacs1'],
        '66645dfa2639fc47c5bca0a6': ['bacs2'],
        '6665fdcffb9c8e828cd159cd': ['bacs2'],
        '66689a7d46d958da3b4cbc9b': ['elianto'],
        '66708c3d9418ec5491c5483e': ['bacs1'],
        '66796effe38fac0691c3aa9d': ['bacs2'],
        '667971a555af1f83d3f29ae7': ['bacs1'],
        '667aca76f4fb2f1d50d80c2e': ['bacs1'],
        '667c2175b570aa694ce2f63c': ['bacs2'],
        '66967693c26744e18f260d47': ['bacs1'],
        '6697c39cfbf1e3381e6ee45c': ['elianto'],
        '669a6bba1fd09527cf41717a': ['elianto'],
        '66a8f084f705eed3539032be': ['bacs1'],
        '66ac73d57afd901d475f6331': ['bacs1'],
        '66ae8009444d73606d34c640': ['bacs2'],
        '66af7ed56686510c31dbaff2': ['bacs1'],
        '66b030a3b56fc1387defa633': ['bacs1'],
        '66b1d733bdd6068a179dfcf8': ['bacs1'],
        '66b2c7262f4631f5eea8e729': ['elianto'],
        '66b39d642d5d3c9ab18111e8': ['bacs2'],
        '66b3baa4900bec0442ea4647': ['elianto'],
        '66bdcc89cd2d130299a4122a': ['bacs2'],
        '66c0e527746d984d9bff5f3f': ['bacs1'],
        '66c49547930d772bd1c165af': ['bacs2'],
        '66cc7fbe78be09cb3ad5092f': ['elianto'],
        '66cf222c4ad795da94032254': ['bacs1'],
        '66cf23e7fcc02fb37eaa4acd': ['bacs2'],
        '66cfab152c56aa0472529001': ['elianto'],
        '66e34b8c7794ea31ff3f31cf': ['bacs2'],
        '66f47421b650b6c39e80fa0d': ['bacs1'],
        '6712264b956f8f9b305ee14b': ['elianto'],
        '6712d5b9e3d84e9a520966fd': ['bacs1'],
        '67137ef4fadb42cb7e9bb2f5': ['bacs2'],
        '67165ac6aa9eeeac4a29c541': ['bacs1'],
        '671a6c6227da7c097cfe8caf': ['bacs2'],
        '6720fbc84253185973cbe564': ['bacs2'],
        '6723ed19397f05950faeb338': ['bacs1'],
        '672879d614dce67b8c3090ea': ['bacs1'],
        '672e22142aab65aaeec4135f': ['bacs1'],
        '6730f804fa4635ef9ba8c46c': ['bacs2'],
        '673321669f5c5d443040682b': ['bacs2'],
        '673542851cdc90296fd26ccf': ['bacs2'],
        '673908d3631ba98a384c1e4e': ['bacs1'],
        '673a0fa7ed1b0189b74d67db': ['bacs1'],
        '673a2fd10c2b00e48a23906a': ['bacs1'],
        '673bf9c0212c1ae07ff6c22e': ['elianto'],
        '6741ce8667002c96f0362d34': ['elianto'],
        '67447a01deb7398581f3b3be': ['bacs2'],
        '674ad268871de890c03a9d26': ['elianto'],
        '674eae0026291e33be89b46f': ['bacs1'],
        '6751b5745c43d993456b8b36': ['bacs2'],
        '675436e14d7ef1173a74a5b8': ['elianto'],
        '675a35800dc96d8b29feb198': ['elianto'],
        '675b566662337f54d9e25c18': ['elianto'],
        '675cca3a27cd0a6fc7c16a9a': ['bacs2'],
        '6765e4378ca57f3d9246fe5e': ['elianto'],
        '676d40e2915d059bf7ef62e8': ['bacs1'],
        '67700724f07c694ad429287a': ['bacs2'],
        '677009b08130c3028f6a8a6d': ['bacs1'],
        '6774f9e03114a09130a1e78f': ['bacs1'],
        '6776b99a8215d150863a71b4': ['bacs2'],
        '677e5e95206b838ea1484b04': ['elianto'],
        '67803b5508f3d995ef13696b': ['bacs1'],
        '6780f243d9c3c26d13d69c61': ['elianto'],
        '67826c0cd5858c9d420da7ff': ['bacs1'],
        '6782e521cbe48b635ea6bf98': ['bacs2'],
        '67851f4cba98f2087f182764': ['bacs2'],
        '6787fb5bb06281752adc7bc2': ['bacs1'],
        '678b5f5e023e304c0386d11f': ['bacs2'],
        '678e3421027098be1a2b36f6': ['bacs1'],
        '67927a8f03e4f9cd8de6e7da': ['elianto'],
        '67a507f52decb8dbaacc29e3': ['elianto'],
        '67ab0f831a9497dbaba74161': ['elianto'],
        '67adb092487be88c66cc52e3': ['bacs2'],
        '67b607307878fc6ed61b1cf3': ['bacs1'],
        '67be9cc9db559147a6f5a9d7': ['elianto'],
        '67bf2c95cf70e4409f3fb705': ['elianto'],
        '67c7672373207a4fb29efe7f': ['bacs1'],
        '67cd50f22f22938860f85a66': ['bacs2'],
        '67cee8d6088dc3c843f48e48': ['bacs1'],
        '67cf0db7f086206b403d6112': ['bacs2'],
        '67d001f0cfd9e6550910c00e': ['elianto'],
        '67d0052a3f36525d24f021be': ['bacs1'],
        '67d0581ffe3bbe5188426aff': ['bacs1'],
        '67d095bc257ecc840642912e': ['bacs2'],
        '67d290dfcdd49e8081645a4a': ['elianto'],
        '67d305fe7dfa52d5cdc42696': ['bacs1'],
        '67d4118ea7ca5cd9f4e3af9c': ['elianto'],
        '67d78ea41b8c245feb328dde': ['bacs2'],
        '67d7fa657f5ac0292a291a38': ['bacs1'],
        '67d9a91f56a568412eecda60': ['elianto'],
        '67dc135e06eee79a0b0324ef': ['elianto'],
        '67dd99d3c51c82d903d13e54': ['bacs2'],
        '67dfa60d9b39b429c33e2d79': ['elianto'],
        '67e2a5b83621fdee51b6277e': ['bacs1'],
        '67e361c8903b8fdd6e80c176': ['elianto'],
        '67e5cf90b79d0874e1cf16b0': ['bacs2'],
        '67eab317b6f969b3df440160': ['bacs1'],
        '67ed3b6e40f0da0854a063b1': ['bacs2'],
        '67ed4e79983b8a8ba5517548': ['elianto'],
        '67ef17aab6360e90f6d47c67': ['elianto'],
        '67efbb40455d7da8f3441f58': ['elianto'],
        '67f128cbba790167d00275fc': ['bacs1'],
        '67f13ade269626b1da6d025e': ['bacs2'],
        '67f2cf906dab7da43bf66027': ['bacs2'],
        '67f2f4b9769f12d21471a6b9': ['elianto'],
        '67f4ccddecca204ee42d44dc': ['bacs1'],
        '67f65a16d76fa76c28091ede': ['bacs2'],
        '67f6a640d2046b13fcf33328': ['bacs1'],
        '67f7c74584da18f7cd5fceeb': ['elianto'],
        '67f93edfe74b47a1b0baa6d6': ['bacs1'],
        '67faf61829e07433820ec62d': ['elianto'],
        '680cae1ead1322f04555243d': ['bacs2'],
        '680df2488347a3170bcde7f3': ['bacs2'],
        '6813da744902baf71269402d': ['bacs2'],
        '6818d2a7bd23beaf96347daf': ['bacs2'],
        'unknown': ['bacs1'],
    
        // 2nd collection - including the extra 10 participants
        '559c3b0efdf99b32b6963e81': ['elianto'],
        '56b0e4d16399f9000ad8d48f': ['bacs2'],
        '5a77529ff49c9a0001f2fdbd': ['elianto'],
        '5b0c1fdebd9c3100015641ae': ['bacs1'],
        '5bb7aae585ac1e000108c7f6': ['elianto'],
        '5c549c6372fd9000018b5968': ['bacs1'],
        '5caccbc4976d010014b9cd9d': ['elianto'],
        '5cad063d22389a0017fa6d7e': ['bacs2'],
        '5d3873197860c8001a106e02': ['elianto'],
        '5e248b6f0c0b31718a9d3f31': ['bacs2'],
        '5eef7da8a4868b05c902ef2d': ['bacs1'],
        '5ef7204033605901ce86c0b0': ['elianto'],
        '5f297863044037075955df67': ['bacs2'],
        '5f4a00484ad3d6567e29c130': ['elianto'],
        '5f983fad466c460c50a7889f': ['elianto'],
        '5fe3932b8d3c668577f04f13': ['elianto'],
        '601d922bc0e663137b95ea2f': ['bacs1'],
        '60205f5ba5fe0165fa0e5e01': ['bacs2'],
        '603659d5c391045d1e4b332b': ['bacs1'],
        '60b932147633bf0dd446941e': ['bacs2'],
        '60e343946a7faddde88fbe3c': ['bacs1'],
        '613df323177af3b16b144281': ['bacs2'],
        '614b55e22ff3944a165736bb': ['elianto'],
        '6287745dd285a8be832879dc': ['bacs2'],
        '63d6f2705562fd353b7948dc': ['bacs1'],
        '63d9d5072e083033fc895df1': ['elianto'],
        '641384b3dffcf39ec42d3c23': ['bacs2'],
        '647e5f4c5b7dfbc365335f72': ['elianto'],
        '6501c0a2e788b5556c24569d': ['bacs1'],
        '65b26a99fe500245f7a7c750': ['bacs1'],
        '65c4b120898ec14b2db32dd5': ['elianto'],
        '65ca9c729a13f898ae374552': ['elianto'],
        '65fc95c627592d85499ae358': ['elianto'],
        '66019a2d78c560a07df25403': ['bacs2'],
        '6606b31155457e4f162ecf5a': ['bacs1'],
        '66114a0b05f2eab8dffe8205': ['bacs1'],
        '6614daf007670261189c3e8a': ['bacs2'],
        '66227700b26cd7c01ca380af': ['elianto'],
        '6655d509b424a0f55a92f2c9': ['bacs2'],
        '6659ebda18cf5c43dbcc7354': ['bacs2'],
        '665c5d94303fdf202ac9ded0': ['bacs1'],
        '666b0b42bb6fa2822fa27a32': ['elianto'],
        '666f43036fd75346ffd84f1f': ['bacs1'],
        '66730185dbb7a524a62c6787': ['bacs1'],
        '6676e60e8deb2236412d6466': ['bacs1'],
        '667dd23ef327afa96cf9cfdc': ['bacs1'],
        '66a3b486230b71f8d86a5eec': ['elianto'],
        '66b732e2824f3862c1739187': ['bacs2'],
        '66c9f7305f8a64d04cb5344c': ['bacs2'],
        '66cb2c5ed2169db778550223': ['bacs2'],
        '66ce541cd8da920539a1c3cc': ['elianto'],
        '66d29886c53f1949f8275cba': ['elianto'],
        '66d467b96245ae7aed624dd4': ['bacs1'],
        '66dbae604ef428aad150a680': ['bacs1'],
        '6723b5a6fd2f96dc69f5b0ee': ['elianto'],
        '673fc88106d7779a0f39642e': ['elianto'],
        '6767e3338fb21303557a8903': ['bacs2'],
        '6776a104d40aac30b9e49748': ['bacs2'],
        '677c0cccea3b2a0052c056e7': ['bacs1'],
        '67824f0e0821560427e7e637': ['bacs2'],
        '678c41cb023e304c03871747': ['bacs2'],
        '67a3a3a4718a95ea163ebd91': ['elianto'],
        '67be037a305dc26acd401309': ['bacs1'],
        '67c048a816027b2413687ae6': ['bacs2'],
        '67d5bc0eb679f324ed49e4c8': ['bacs1'],
        '67e6e73a9a192e805dad3a03': ['bacs1'],
        '67f3619e16d4ca195fbd1bd0': ['elianto'],
        '67f7bb9aaa1cb67247023347': ['bacs2'],
        '67feb525a7759f2034a95f22': ['elianto'],
        '6813b1104ed957e80182dd64': ['elianto'], */

    // Day 1
    '571a78f06a1c6300114b8d80': ['elianto', 'bacs1'],
    '57d5ab3a722df500017f3622': ['bacs2', 'elianto'],
    '58a5cf959e040a0001399f07': ['bacs2', 'bacs1'],
    '5a77529ff49c9a0001f2fdbd': ['elianto', 'bacs2'],
    '5af82cf9e066a40001136ace': ['bacs1', 'bacs2'],
    '5bbb5e3f118c0600013c3202': ['bacs2', 'bacs1'],
    '5bf3199ebe7c7300017b710a': ['bacs2', 'bacs1'],
    '5c18daaae467040001e68fc4': ['elianto', 'bacs1'],
    '5c3ce83e9883d400014200a5': ['bacs1', 'elianto'],
    '5c45ad3793f3690001c46767': ['bacs2', 'elianto'],
    '5c549c6372fd9000018b5968': ['bacs1', 'bacs2'],
    '5c7ceda01d2afc0001f4ad1d': ['elianto', 'bacs2'],
    '5caccbc4976d010014b9cd9d': ['elianto', 'bacs1'],
    '5d3873197860c8001a106e02': ['elianto', 'bacs1'],
    '5d66b4f503b0d900195ca627': ['bacs1', 'elianto'],
    '5da330e8656efc001626ea3e': ['elianto', 'bacs1'],
    '5dc0856370d51c032949d2db': ['bacs1', 'elianto'],
    '5dd05d80b2204f1487f7812c': ['bacs2', 'bacs1'],
    '5df8d8d6b7b3306449876d43': ['bacs1', 'bacs2'],
    '5e4066ed9eec8d2a184e4ff4': ['bacs1', 'elianto'],
    '5e5a96f5a2f2c528edf70f6e': ['bacs2', 'bacs1'],
    '5e5c993cd0394c474f7cc502': ['bacs2', 'elianto'],
    '5e73ded1027e893642055f86': ['bacs2', 'elianto'],
    '5ee7fbc114d0a60f9b076fb6': ['bacs2', 'elianto'],
    '5eef7da8a4868b05c902ef2d': ['bacs1', 'bacs2'],
    '5f4a00484ad3d6567e29c130': ['elianto', 'bacs2'],
    '5f54cdbcd2fd0a8484ef4645': ['bacs1', 'bacs2'],
    '5f632ea32e85353d93872c67': ['bacs2', 'bacs1'],
    '5f8893a5e2f88a04b1833278': ['bacs2', 'bacs1'],
    '5fabca68273dd403ab40e361': ['bacs1', 'bacs2'],
    '5fb9adb28a52968d9f561808': ['bacs1', 'elianto'],
    '5fc0d12ee844ed0b32c5d4d8': ['elianto', 'bacs2'],
    '5fed47cfcb429d79af4f8ded': ['bacs1', 'bacs2'],
    '5ff454f2f0b5ed607169fba6': ['bacs1', 'elianto'],
    '5fff2877a99bcb65a14a223c': ['elianto', 'bacs2'],
    '601d922bc0e663137b95ea2f': ['bacs1', 'elianto'],
    '60205f5ba5fe0165fa0e5e01': ['bacs2', 'elianto'],
    '60317fc2c8f6320ecde4bcb3': ['bacs2', 'bacs1'],
    '604fa685e33606f9a0ee8189': ['bacs1', 'elianto'],
    '605211b8ebd0a5605f0f961b': ['elianto', 'bacs2'],
    '605db73fe547ff7c425f59de': ['bacs1', 'bacs2'],
    '609bfd97a7c95881330491d4': ['bacs2', 'bacs1'],
    '60a0b744298c64d46b63e893': ['elianto', 'bacs2'],
    '60a0dfc6f9936b0d30dfea15': ['elianto', 'bacs1'],
    '60b932147633bf0dd446941e': ['bacs2', 'bacs1'],
    '60d9dfd4dcc09cf57dc92cb1': ['bacs1', 'bacs2'],
    '60e0dc6be0772b7dfdad9b2c': ['bacs2', 'elianto'],
    '60e45a7bc4730383ee2fecb6': ['bacs1', 'bacs2'],
    '6122f45e2e93a3ff9a7b7a5d': ['elianto', 'bacs2'],
    '613df323177af3b16b144281': ['bacs2', 'elianto'],
    '613f59d7f0f631a278aca6e8': ['bacs2', 'elianto'],
    '6140ef8d27499e70e8740918': ['bacs2', 'elianto'],
    '615dd36156bf443246c0b660': ['bacs1', 'elianto'],
    '6161cb3de3d274978d46575b': ['bacs2', 'elianto'],
    '61687ebcd2a35ffb762d1928': ['bacs2', 'bacs1'],
    '616cc1c4244b5866081d3f72': ['elianto', 'bacs1'],
    '616dbc894ee323e3893f8919': ['bacs2', 'bacs1'],
    '627e7e91d0e389328983e765': ['elianto', 'bacs1'],
    '6315fd72852e279a1a13e5f1': ['bacs2', 'elianto'],
    '631610af8e747093cd90e00d': ['bacs1', 'elianto'],
    '637774fa068c5a7fb372e6be': ['elianto', 'bacs2'],
    '63d9d5072e083033fc895df1': ['elianto', 'bacs1'],
    '641384b3dffcf39ec42d3c23': ['bacs2', 'elianto'],
    '645cf23cf9229b8dd5453a6e': ['elianto', 'bacs1'],
    '64ef4386a31700e2d88622c9': ['bacs1', 'bacs2'],
    '64feeabd355b506d0512d862': ['bacs2', 'elianto'],
    '650f65aac58fe4dc08bbe23f': ['elianto', 'bacs1'],
    '652e9eb14b23a3ccf4c340f4': ['bacs2', 'bacs1'],
    '655b901b23209ae4a194a402': ['elianto', 'bacs2'],
    '655f8bf6de805f7bd81e5811': ['bacs1', 'bacs2'],
    '65651805d1afb42ba1a55476': ['bacs2', 'elianto'],
    '65956ab743aa1e8fe002ba3b': ['elianto', 'bacs2'],
    '6597f894ae0302a96b69adda': ['bacs2', 'bacs1'],
    '65a3ec77f674ac3e98f0c6ac': ['bacs2', 'elianto'],
    '65a69ce9c8cf8262d34f646a': ['elianto', 'bacs2'],
    '65ab079fde17d72bca5e774b': ['elianto', 'bacs2'],
    '65b26a99fe500245f7a7c750': ['bacs1', 'bacs2'],
    '65ba64c07847d4c34ec00de1': ['elianto', 'bacs2'],
    '65c4b120898ec14b2db32dd5': ['elianto', 'bacs2'],
    '65f0770588878297865a0cc4': ['elianto', 'bacs2'],
    '65faeb7145b8262f7a342099': ['bacs2', 'elianto'],
    '65fb34c4df61f03ce0dd6dd9': ['elianto', 'bacs2'],
    '65fc95c627592d85499ae358': ['elianto', 'bacs2'],
    '660453c9877e571d12b555f7': ['bacs1', 'elianto'],
    '6604b1a8441e527fc9590694': ['elianto', 'bacs2'],
    '6606b31155457e4f162ecf5a': ['bacs1', 'elianto'],
    '66083cd0a45e1ce399e6a85f': ['bacs2', 'elianto'],
    '66114a0b05f2eab8dffe8205': ['bacs1', 'elianto'],
    '6614daf007670261189c3e8a': ['bacs2', 'bacs1'],
    '6640e5d6c304dc7b28316078': ['bacs2', 'elianto'],
    '6640fd54ac9d9313a68cb312': ['elianto', 'bacs1'],
    '66428090de7c2db3caed1c77': ['bacs2', 'elianto'],
    '6643be675817fd2a43298a04': ['bacs2', 'elianto'],
    '66446d88662725412dc27d06': ['bacs1', 'bacs2'],
    '664c9a37d570871d534dd3c2': ['elianto', 'bacs1'],
    '664cf2037353bb98801436b5': ['bacs2', 'bacs1'],
    '664db585355de70e17541e5a': ['bacs2', 'bacs1'],
    '664e326b5579c6f6ca3fd1ff': ['bacs1', 'bacs2'],
    '6655fc1f1ff86ee869fd7c8c': ['bacs1', 'elianto'],
    '665c5d94303fdf202ac9ded0': ['bacs1', 'bacs2'],
    '66645dfa2639fc47c5bca0a6': ['bacs2', 'elianto'],
    '6665fdcffb9c8e828cd159cd': ['bacs2', 'bacs1'],
    '66689a7d46d958da3b4cbc9b': ['elianto', 'bacs2'],
    '666b0b42bb6fa2822fa27a32': ['elianto', 'bacs1'],
    '666f43036fd75346ffd84f1f': ['bacs1', 'elianto'],
    '66708c3d9418ec5491c5483e': ['bacs1', 'bacs2'],
    '66730185dbb7a524a62c6787': ['bacs1', 'bacs2'],
    '6676e60e8deb2236412d6466': ['bacs1', 'bacs2'],
    '66796effe38fac0691c3aa9d': ['bacs2', 'elianto'],
    '667971a555af1f83d3f29ae7': ['bacs1', 'bacs2'],
    '667aca76f4fb2f1d50d80c2e': ['bacs1', 'elianto'],
    '667c2175b570aa694ce2f63c': ['bacs2', 'elianto'],
    '66967693c26744e18f260d47': ['bacs1', 'elianto'],
    '6697c39cfbf1e3381e6ee45c': ['elianto', 'bacs1'],
    '669a6bba1fd09527cf41717a': ['elianto', 'bacs1'],
    '66ac73d57afd901d475f6331': ['bacs1', 'bacs2'],
    '66b030a3b56fc1387defa633': ['bacs1', 'elianto'],
    '66b1d733bdd6068a179dfcf8': ['bacs1', 'bacs2'],
    '66b2c7262f4631f5eea8e729': ['elianto', 'bacs1'],
    '66b3baa4900bec0442ea4647': ['elianto', 'bacs1'],
    '66c49547930d772bd1c165af': ['bacs2', 'bacs1'],
    '66cb2c5ed2169db778550223': ['bacs2', 'elianto'],
    '66ce541cd8da920539a1c3cc': ['elianto', 'bacs2'],
    '66cf222c4ad795da94032254': ['bacs1', 'elianto'],
    '66cf23e7fcc02fb37eaa4acd': ['bacs2', 'elianto'],
    '66cfab152c56aa0472529001': ['elianto', 'bacs1'],
    '66d467b96245ae7aed624dd4': ['bacs1', 'elianto'],
    '66dbae604ef428aad150a680': ['bacs1', 'bacs2'],
    '66e34b8c7794ea31ff3f31cf': ['bacs2', 'bacs1'],
    '6712264b956f8f9b305ee14b': ['elianto', 'bacs2'],
    '6712d5b9e3d84e9a520966fd': ['bacs1', 'elianto'],
    '67165ac6aa9eeeac4a29c541': ['bacs1', 'bacs2'],
    '6720fbc84253185973cbe564': ['bacs2', 'elianto'],
    '6723ed19397f05950faeb338': ['bacs1', 'elianto'],
    '672879d614dce67b8c3090ea': ['bacs1', 'elianto'],
    '672e22142aab65aaeec4135f': ['bacs1', 'elianto'],
    '6730f804fa4635ef9ba8c46c': ['bacs2', 'elianto'],
    '673321669f5c5d443040682b': ['bacs2', 'bacs1'],
    '673542851cdc90296fd26ccf': ['bacs2', 'bacs1'],
    '673bf9c0212c1ae07ff6c22e': ['elianto', 'bacs1'],
    '673fc88106d7779a0f39642e': ['elianto', 'bacs2'],
    '6741ce8667002c96f0362d34': ['elianto', 'bacs2'],
    '674ad268871de890c03a9d26': ['elianto', 'bacs1'],
    '674eae0026291e33be89b46f': ['bacs1', 'bacs2'],
    '6751b5745c43d993456b8b36': ['bacs2', 'elianto'],
    '675436e14d7ef1173a74a5b8': ['elianto', 'bacs2'],
    '675a35800dc96d8b29feb198': ['elianto', 'bacs2'],
    '675b566662337f54d9e25c18': ['elianto', 'bacs2'],
    '675cca3a27cd0a6fc7c16a9a': ['bacs2', 'elianto'],
    '6765e4378ca57f3d9246fe5e': ['elianto', 'bacs1'],
    '6767e3338fb21303557a8903': ['bacs2', 'elianto'],
    '676d40e2915d059bf7ef62e8': ['bacs1', 'elianto'],
    '67700724f07c694ad429287a': ['bacs2', 'bacs1'],
    '677009b08130c3028f6a8a6d': ['bacs1', 'elianto'],
    '6774f9e03114a09130a1e78f': ['bacs1', 'bacs2'],
    '6776a104d40aac30b9e49748': ['bacs2', 'bacs1'],
    '6776b99a8215d150863a71b4': ['bacs2', 'elianto'],
    '677e5e95206b838ea1484b04': ['elianto', 'bacs1'],
    '67803b5508f3d995ef13696b': ['bacs1', 'bacs2'],
    '6780f243d9c3c26d13d69c61': ['elianto', 'bacs2'],
    '67824f0e0821560427e7e637': ['bacs2', 'bacs1'],
    '67826c0cd5858c9d420da7ff': ['bacs1', 'bacs2'],
    '6782e521cbe48b635ea6bf98': ['bacs2', 'bacs1'],
    '67851f4cba98f2087f182764': ['bacs2', 'elianto'],
    '6787fb5bb06281752adc7bc2': ['bacs1', 'elianto'],
    '678b5f5e023e304c0386d11f': ['bacs2', 'bacs1'],
    '67b607307878fc6ed61b1cf3': ['bacs1', 'elianto'],
    '67be9cc9db559147a6f5a9d7': ['elianto', 'bacs1'],
    '67c7672373207a4fb29efe7f': ['bacs1', 'bacs2'],
    '67cd50f22f22938860f85a66': ['bacs2', 'bacs1'],
    '67cf0db7f086206b403d6112': ['bacs2', 'bacs1'],
    '67d0052a3f36525d24f021be': ['bacs1', 'elianto'],
    '67d0581ffe3bbe5188426aff': ['bacs1', 'bacs2'],
    '67d095bc257ecc840642912e': ['bacs2', 'bacs1'],
    '67d4118ea7ca5cd9f4e3af9c': ['elianto', 'bacs2'],
    '67d78ea41b8c245feb328dde': ['bacs2', 'elianto'],
    '67d7fa657f5ac0292a291a38': ['bacs1', 'elianto'],
    '67d9a91f56a568412eecda60': ['elianto', 'bacs1'],
    '67dc135e06eee79a0b0324ef': ['elianto', 'bacs1'],
    '67dfa60d9b39b429c33e2d79': ['elianto', 'bacs1'],
    '67e2a5b83621fdee51b6277e': ['bacs1', 'elianto'],
    '67e361c8903b8fdd6e80c176': ['elianto', 'bacs2'],
    '67e5cf90b79d0874e1cf16b0': ['bacs2', 'bacs1'],
    '67e6e73a9a192e805dad3a03': ['bacs1', 'elianto'],
    '67eab317b6f969b3df440160': ['bacs1', 'bacs2'],
    '67efbb40455d7da8f3441f58': ['elianto', 'bacs1'],
    '67f2f4b9769f12d21471a6b9': ['elianto', 'bacs1'],
    '67f3619e16d4ca195fbd1bd0': ['elianto', 'bacs1'],
    '67f4ccddecca204ee42d44dc': ['bacs1', 'bacs2'],
    '67f65a16d76fa76c28091ede': ['bacs2', 'elianto'],
    '67f6a640d2046b13fcf33328': ['bacs1', 'elianto'],
    '67f7c74584da18f7cd5fceeb': ['elianto', 'bacs1'],
    '67f93edfe74b47a1b0baa6d6': ['bacs1', 'elianto'],
    '67faf61829e07433820ec62d': ['elianto', 'bacs1'],
    '67feb525a7759f2034a95f22': ['elianto', 'bacs2'],
    '680cae1ead1322f04555243d': ['bacs2', 'bacs1'],
    '6813da744902baf71269402d': ['bacs2', 'bacs1'],
    '6818d2a7bd23beaf96347daf': ['bacs2', 'elianto'],
  }


  //let previousRuneSet = subjIDToRuneSet[subID];
  let previousRuneSet = subjIDToRuneSet[subID] || [];

  //console.log("previousRuneSet: ", previousRuneSet);
  // Choose the other character set than previously on the first test
  /*   if (previousRuneSet === 'bacs2') { // those who had bacs2
      window.rune_set = (Math.random() < 0.5) ? 'elianto' : 'bacs1';
    } else if (previousRuneSet === 'bacs1') {  // those who had bacs1
      window.rune_set = (Math.random() < 0.5) ? 'elianto' : 'bacs2';
    } else if (previousRuneSet === 'elianto') { // those who had elianto
      window.rune_set = (Math.random() < 0.5) ? 'bacs1' : 'bacs2';
    } else { // if any issue or the participant types in the wrong ID
      window.rune_set = jsPsych.randomization.sampleWithReplacement(rune_sets, 1, rune_prob)[0];
      //window.rune_set = "bacs2"
    } */

  let nextRune;
  if (previousRuneSet.length === 1) {
    // If they had one, give them the other one
    // Randomly pick one of the remaining two runes
    let remainingRunes = rune_sets.filter(rune => !previousRuneSet.includes(rune));
    nextRune = remainingRunes[Math.floor(Math.random() * remainingRunes.length)];
  } else if (previousRuneSet.length === 2) {
    // If they had two, give them the third remaining one
    nextRune = rune_sets.find(rune => !previousRuneSet.includes(rune));
  } else {
    // If they had none, assign randomly (or default to one)
    nextRune = rune_sets[Math.floor(Math.random() * rune_sets.length)];
  }


  window.rune_set = nextRune;
  //console.log(`Assigned rune set for ${subID}: ${window.rune_set}`);

  // Gather rune orders.
  if (window.rune_set == 'elianto') {
    window.runes_a = ['U', 'L', 'A', 'G', 'P', 'S', 'W', 'E', 'K', 'D', 'J', 'V'];
    window.runes_b = ['M', 'R', 'Y', 'H', 'Z', 'C', 'B', 'T', 'X', 'F', 'N', 'Q'];
  } else if (window.rune_set == 'bacs1') {
    window.runes_a = ['B', 'Z', 'J', 'R', 'V', 'E', 'T', 'F', 'A', 'C', 'L', 'Q'];
    window.runes_b = ['Y', 'H', 'P', 'M', 'U', 'S', 'K', 'D', 'O', 'I', 'G', 'N'];
  } else if (window.rune_set == 'bacs2') {
    window.runes_a = ['J', 'W', 'X', 'Z', 'G', 'O', 'C', 'E', 'H', 'Q', 'T', 'Y'];
    window.runes_b = ['M', 'B', 'K', 'V', 'R', 'P', 'L', 'S', 'U', 'A', 'F', 'N'];
  } /* else if (window.rune_set == 'bacs2') {
    window.runes_a = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
    window.runes_b = ['W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X', 'W', 'X'];
  } */

  //console.log(runes_a, "runes_a");

  // Randomize presentation order.
  if (Math.random() < 0.5) { window.runes_a = window.runes_a.reverse(); }
  if (Math.random() < 0.5) { window.runes_b = window.runes_b.reverse(); }
  window.runes = (Math.random() < 0.5) ? [window.runes_a, window.runes_b] : [window.runes_b, window.runes_a];
};

//------------------------------------//
// Define experiment.
//------------------------------------//
// One block of the PGNG task is comprised of 8-12 exposures to 12 robots, or
// 120 total trials. 80% of trials provide correct feedback. There are 2 total
// blocks, or 240 total trials.

// Preallocate space.
var PGNG = [];
// Iteratively define trials.
var n = 0;
for (let i = 0; i < runsheets.length; i++) { // 2 => runsheets = [runsheet_s00, runsheet_s03];

  for (let j = 0; j < runsheets[i]['robots'].length; j++) { // 30 => sets of robots (each set has 4)

    jsPsych.randomization.shuffle([0, 1, 2, 3]).forEach(function (k) {

      // Extract trial information.
      const robot = runsheets[i]['robots'][j][k];
      const stimulus = runsheets[i]['stimuli'][j][k];

      // Define trial metadata.
      const valence = (robot < 2) ? 'win' : 'lose';
      const action = (robot % 2 == 0) ? 'go' : 'no-go';

      // Define trial outcomes.
      const sham = (Math.random() < 0.8) ? 0 : 1;
      if (valence == 'win' && sham == 0) {
        var outcome_correct = '+10';
        var outcome_incorrect = '+1';
      } else if (valence == 'win') {
        var outcome_correct = '+1';
        var outcome_incorrect = '+10';
      } else if (valence == 'lose' && sham == 0) {
        var outcome_correct = '-1';
        var outcome_incorrect = '-10';
      } else {
        var outcome_correct = '-10';
        var outcome_incorrect = '-1';
      }

      // Define screen check.
      const screen_check = {
        timeline: [{
          type: jsPsychScreenCheck,
          min_width: min_width,
          min_height: min_height
        }],
        conditional_function: function () {
          if (window.innerWidth >= min_width && window.innerHeight >= min_height) {
            return false;
          } else {
            return true;
          }
        }
      }

      // Define trial.
      const trial = {
        type: jsPsychPgngTrial,
        robot_rune: function () { return runes[i][stimulus] },
        scanner_color: valence == 'win' ? scanner_color_win : scanner_color_lose,
        outcome_color: valence == 'win' ? outcome_color_win : outcome_color_lose,
        outcome_correct: outcome_correct,
        outcome_incorrect: outcome_incorrect,
        correct: robot % 2 == 0 ? key_go : -1,
        rune_set: function () { return rune_set },
        valid_responses: [key_go],
        trial_duration: trial_duration,
        feedback_duration: feedback_duration,
        data: {
          block: i + 1,
          trial: n + 1,
          stimulus: stimulus,
          robot: robot + 1,
          valence: valence,
          action: action,
          sham: sham
        },
        on_finish: function (data) {

          // Store number of browser interactions
          data.browser_interactions = jsPsych.data.getInteractionData().filter({ trial: data.trial_index }).count();
        }
      };

      const blank_trial = {
        type: jsPsychHtmlKeyboardResponse,
        trial_duration: function (data) {
          trial_data_rt = jsPsych.data.get().last(2).trials[1].rt; //allData.trials[2];
          //console.log("trial_data: ", trial_data_rt);
          if (trial_data_rt == -1) {//no response
            break_time = 0;
            //console.log("break time no reponse: ", break_time);
          } else {
            break_time = trial_duration - trial_data_rt; //faster response leads to longer feedback, keeping trial length equal
            //console.log("break time after response: ", break_time);
          }
          return break_time;

        },
        stimulus: function () {
          return new_html;
        }
      }

      // Define trial node.
      const trial_node = {
        timeline: [screen_check, trial, blank_trial]
      }

      // Replace the runes with re-rest ones
      /*       if (n == 0) {
        PGNG.push(set_runes_var);
      } */

      // Append.
      PGNG.push(trial_node)

      //console.log(PGNG, "PGNG");

      n++;

    })

  }

}

//------------------------------------//
// Define transition screens.
//------------------------------------//

/* // Define ready screen.
var READY = {
  type: jsPsychPgngInstructions,
  pages: [
    "Great job! You've passed the comprehension check.",
    "Get ready to begin the task demo.<br>Press next when you're ready to start.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
} */

var set_runes_var = {
  type: jsPsychHtmlKeyboardResponse,
  trial_duration: 1,
  stimulus: "",
  on_finish: function () {
    //console.log('setting runes now');
    set_runes();
  }
}

// Define ready screen 1
var READY_01 = {
  type: jsPsychPgngInstructions,
  pages: [
    "Great job! You've passed the comprehension check.",
    "<b>One final thing</b>: we will check if you are paying attention at specific times during the experiment by having you press a specific button.",
    "If you fail these attention checks, the experiment will end, and you will not be compensated for participating.",
    "Get ready to begin <b>Block 1 of 2</b>. Each block will take ~6 minutes.<br>Press next when you're ready to start.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
}

// Define ready screen 2
var READY_02 = {
  type: jsPsychPgngInstructions,
  pages: [
    "Take a break for a few moments and press next when you are ready to continue.",
    "Get ready to begin <b>Block 2 of 2</b>. Each block will take ~8 minutes.<br>Press next when you're ready to start.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
}

// Define finish screen.
var FINISHED = {
  type: jsPsychPgngInstructions,
  pages: [
    "Great job! You've finished the task.",
  ],
  show_clickable_nav: true,
  button_label_previous: "Prev",
  button_label_next: "Next",
}

/* prompt the user for their Prolific (participant) ID and loop if they give no answer*/
let resp = 0;
let participantID = {
  type: jsPsychSurveyText,
  preamble:
    `<p style="margin: auto;width: 50%; font-size: 1.5vw; line-height: 4vmin;">In order to be able to reward you for participating in this experiment, we need your Prolific ID.
    It is very important that this is entered correctly. If it isn't entered correctly, we will 
            not be able to compensate you for participating in this experiment. 
    </p>`,
  questions: [
    { prompt: `Please enter your Prolific ID here:`, name: `ID` },
  ],
  data: {
    task: `initial_instructions`,
  },
  on_finish: function (data) {
    //let subject = data.response.ID;
    jsPsych.data.addProperties({ subjID: data.response.ID }); //remove nrMissedTrials?

    //record if they responded anything
    var subj_response = jsPsych.data.get().last(1).values()[0].response;
    //console.log('response: ', subj_response.ID);
    if (subj_response.ID == '') {
      //console.log('EMPTY RESPONSE');
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
}

// Define feedback screen.
var FEEDBACK = {
  stimulus: '',
  type: jsPsychHtmlKeyboardResponse,
  on_start: function (trial) {

    // Compute overall accuracy.
    var accuracy = jsPsych.data.get().filter([{ block: 1 }, { block: 2 }]).select('accuracy');
    var accuracy = accuracy.mean();

    // Compute payment.
    var bonus = completion_bonus + Math.ceil(performance_bonus * accuracy * 100) / 100;
    var total = completion_bonus + performance_bonus;
    //console.log('completion_bonus: ', completion_bonus);

    //add to global
    bonus_gonogo = bonus;

    //Update global variables to be passed on to next task
    taskNumber++
    performanceBonus += bonus;

    //console.log('bonus: ', bonus, 'total: ', total, 'taskNumber: ', taskNumber, 'bonus_gonogo: ', bonus_gonogo, 'performanceBonus: ', performanceBonus);

    // Report accuracy to subject.
    trial.stimulus = `<h2>Great job!</h2>You earned a performance bonus of ${bonus}&pound out of ${total}&pound in this game.
    <br>You have earned a total performance bonus of ${performanceBonus}&pound.
    <br><br>Press the <b>space bar</b> to continue.`

    /* `You earned a bonus of ${bonus}&pound out of ${total}&pound.<br><br>Press the <b>space bar</b> to continue.` */

    //save bonus to data
    jsPsych.data.addProperties({
      bonus_gonogo: bonus_gonogo
    });

  },
  on_finish: function (trial) {

    // Compute overall accuracy.
    var accuracy = jsPsych.data.get().filter([{ block: 1 }, { block: 2 }]).select('accuracy');
    var accuracy = accuracy.mean();
    trial.accuracy = accuracy;

    // Compute payment.
    var bonus = completion_bonus + Math.ceil(performance_bonus * accuracy * 100) / 100;
    var total = completion_bonus + performance_bonus;
    trial.bonus = bonus;

  },
  choices: " "
}

// Define catch trial (attention check)
var CATCH = {
  timeline: [
    {
      type: jsPsychHtmlKeyboardResponse,
      stimulus:
        `<div>This is an attention check, please respond by pressing the <b>${CB}</b> button within 10 seconds</div>` + '<div style="background-color: #ccc; margin-top: 1em;">' +
        '<div style="width: 0%; height: 20px; background-color: #333; animation-name: progress-bar; animation-duration: 10s; animation-timing-function: linear;">' +
        '</div>' +
        '<style> @keyframes progress-bar { 0% { width:0%;} 100% { width:100%} } </style>',
      choices: [`${CB}`],
      trial_duration: CATCH_TRIAL_DURATION,
      data: {
        task: `catch_trial`,
        correct_response: `${CB}`
      },
      on_finish: function (data) {
        data.correct = jsPsych.pluginAPI.compareKeys(data.response, data.correct_response);

        if (data.correct !== true) {
          nrMissedAttenChecks++;
        }
        //console.log('nrMissedAttenChecks: ', nrMissedAttenChecks);
      }
    },
    { //feedback catch trial
      type: jsPsychHtmlKeyboardResponse,
      stimulus: function () {
        var tmp1 = jsPsych.data.get().last(1).values()[0].correct;

        if (tmp1 == true) {
          return '<p style="color: #015001; font-size: 3.5vw;">Correct!</p>';
        } else {
          return '<p style="color: #a10000; font-size: 3.5vw;">You failed the attention check!</p>'
        }
      },
      trial_duration: CATCH_TRIAL_FEEDBACK_DURATION,
      data: {
        task: 'catch_feedback'
      },
      choices: ["NO_KEYS"]
    },
    { //Redirect if too many checks have been failed
      type: jsPsychHtmlKeyboardResponse,
      stimulus: function () {
        if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
          return `<div>
          <p> You have failed to respond in time for ${MAX_MISSED_ATTEN_CHECKS} attention checks. As you have not been paying attention, we will not be able to use your data.</p> <p><b><u>The experiment will now be terminated.</u></b></p>
              If you have any questions regarding this please contact the researchers through the messaging system on prolific. </p>
              <p> When you press the space bar, you will be redirected back to Prolific.</p>
              </div>`
        } else {
          return '<div class="gng-fixation">+</div>'
        }
      },
      trial_duration: function () {
        if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
          return 300000
        } else {
          return 1
        }
      },
      data: {
        task: 'post_catch_feedback_screen'
      },
      on_finish: function () {
        if (nrMissedAttenChecks >= MAX_MISSED_ATTEN_CHECKS) {
          return window.location = FAURL;
        }

      },
      choices: " "
    }
  ]
};

// Debriefing questionnaire
var DEBRIEF_01 = {
  type: jsPsychSurveyMultiChoice,
  preamble: '<h1>Debriefing</h1><p>Please answer the questions below.</p><p><font color="#c87606">Your answers do not affect your payment or bonus.</font></p>',
  button_label: 'Submit',
  questions: [
    {
      prompt: "How difficult was the task?",
      name: 'difficultyRate',
      options: ['Very easy', 'Somewhat easy', 'Neither easy nor hard', 'Somewhat hard', 'Very hard'],
      required: true
    },
    {
      prompt: "How fun was the task?",
      name: 'funRate',
      options: ['Very fun', 'Somewhat fun', 'Neither fun nor boring', 'Somewhat boring', 'Very boring'],
      required: true
    },
    {
      prompt: "How clear were the instructions?",
      name: 'clarityRate',
      options: ['Very clear', 'Somewhat clear', 'Neither clear nor confusing', 'Somewhat confusing', 'Very confusing'],
      required: true
    }
  ],
  on_finish: function () {
    removeStyles();
  },
  data: {
    parsing: 'end_gonogo',
    task: 'debrief_gonogo'
  }
}

/* var DEBRIEF_02 = {
      type: jsPsychSurveyText,
      preamble: '<h1>Debriefing</h1><p>Please answer the questions below.</p><p><font color="#c87606">Your answers do not affect your payment or bonus.</font></p>',
      button_label: 'Submit',
      questions: [
        {prompt: '<p style="padding: 0 0;">Did you use any strategies during the task (e.g. write things down)?</p>', placeholder: 'Optional...', rows:3, columns: 55},
        {prompt: 'Do you have any other comments?', placeholder: 'Optional...', rows:1, columns: 55}
      ]
    }; */