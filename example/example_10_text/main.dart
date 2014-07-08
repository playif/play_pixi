
import "dart:html";
import "dart:math";
import "package:pixi_dart/pixi.dart" as PIXI;

main() {
  // Load them google fonts before starting...!


  runList(item) {
    window.console.log("_");
    var safe = 0;
    var tmp = item;
    while (tmp._iNext) {
      safe++;
      tmp = tmp._iNext;
      window.console.log(tmp);

      if (safe > 100) {
        window.console.log("BREAK");
        break;
      }
    }
  }

  init() {
    var assetsToLoader = ["desyrel.xml"];

    // create an new instance of a pixi stage
    var stage = new PIXI.Stage(0x66FF99);



    onAssetsLoaded() {
      var bitmapFontText = new PIXI.BitmapText("bitmap fonts are\n now supported!", new PIXI.TextStyle()
        ..font = "35px Desyrel"
        ..align = "right"
      );
      bitmapFontText.position.x = 620 - bitmapFontText.textWidth - 20;
      bitmapFontText.position.y = 20;

      //runList(bitmapFontText);

      stage.addChild(bitmapFontText);
    }

    // create a new loader
    var loader = new PIXI.AssetLoader(assetsToLoader);

    // use callback
    loader.onComplete = onAssetsLoaded;

    // begin load
    loader.load();

    // add a shiny background...
    var background = PIXI.Sprite.fromImage("textDemoBG.jpg");
    stage.addChild(background);

    // create a renderer instance
    var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);
    //var renderer =  new PIXI.CanvasRenderer(window.innerWidth, window.innerHeight);

    // add the renderer view element to the DOM
    document.body.append(renderer.view);

    // create some white text using the Snippet webfont
    var textSample = new PIXI.Text("Pixi.js can has\nmultiline text!", new PIXI.TextStyle()
      ..font = "35px Snippet"
      ..fill = "white"
      ..align = "left"
    );
    textSample.position.x = 20;
    textSample.position.y = 20;

    // create a text object with a nice stroke
    var spinningText = new PIXI.Text("I'm fun!", new PIXI.TextStyle()
      ..font = "bold 60px Podkova"
      ..fill = "#cc00ff"
      ..align = "center"
      ..stroke = "#FFFFFF"
      ..strokeThickness = 6
    );

    // setting the anchor point to 0.5 will center align the text... great for spinning!
    spinningText.anchor.x = spinningText.anchor.y = 0.5;
    spinningText.position.x = 620 / 2;
    spinningText.position.y = 400 / 2;

    // create a text object that will be updated..
    var countingText = new PIXI.Text("COUNT 4EVAR: 0", new PIXI.TextStyle()
      ..font = "bold italic 60px Arvo"
      ..fill = "#3e1707"
      ..align = "center"
      ..stroke = "#a4410e"
      ..strokeThickness = 7
    );
    countingText.position.x = 620 / 2;
    countingText.position.y = 320;
    countingText.anchor.x = 0.5;

    stage.addChild(textSample);
    stage.addChild(spinningText);
    stage.addChild(countingText);

    var count = 0;
    var score = 0;
    var remaining = 10;

    //stage.removeChildren();

    animate(dt) {
      renderer.render(stage);
      PIXI.requestAnimFrame(animate);
    }

    PIXI.requestAnimFrame(animate);

  }

  init();

//        Map WebFontConfig = {
//                'google': {
//                        'families': [ 'Snippet', 'Arvo:700italic', 'Podkova:700' ]
//                },
//
//                'active': () {
//                    // do something
//                    init();
//                }
//        };
//
//
//        start() {
//            ScriptElement wf = document.createElement('script');
//            wf.src = ('https:' == window.location.protocol ? 'https' : 'http') +
//            '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
//            wf.type = 'text/javascript';
//            wf.async = true;
//            var s = document.getElementsByTagName('script')[0];
//            s.parentNode.insertBefore(wf, s);
//        }
//        start();
}