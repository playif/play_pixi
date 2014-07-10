import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;


main() {


  // create a renderer instance
  var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);
  //var renderer = new PIXI.CanvasRenderer(window.innerWidth, window.innerHeight);


  // set the canvas width and height to fill the screen
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);

  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF, true);

  animate(dt) {
    for(var spine in stage.children){
      spine.position.x += 3;
      //spine.tint
      if(spine.position.x>=window.innerWidth+110){
        spine.position.x=-110;
      }
    }


    renderer.render(stage);


    PIXI.requestAnimFrame(animate);
  }

  onAssetsLoaded() {
    for (int i = 0;i < 10;i++) {


      // create a spine boy
      var spineBoy = new PIXI.Spine("data/spineboySpineData.json");

      // set the position
      spineBoy.position.x = i*45;
      spineBoy.position.y = window.innerHeight;

      spineBoy.scale.x = spineBoy.scale.y = window.innerHeight / 400;

      // set up the mixes!
      spineBoy.stateData.setMixByName("walk", "jump", 0.2);
      spineBoy.stateData.setMixByName("jump", "walk", 0.4);

      // play animation
      spineBoy.state.setAnimationByName("walk", true);


      stage.addChild(spineBoy);

      stage.click = (e) {
        spineBoy.state.setAnimationByName("jump", false);
        spineBoy.state.addAnimationByName("walk", true);
      };
    }
//    var logo = PIXI.Sprite.fromImage("../../logo_small.png")
//    stage.addChild(logo);
//
//
//    logo.anchor.x = 1;
//    logo.position.x = window.innerWidth
//    logo.scale.x = logo.scale.y = 0.5;
//    logo.position.y = window.innerHeight - 70;
//    logo.setInteractive(true);
//    logo.buttonMode = true;
//    logo.click = logo.tap = function()
//    {
//      window.open("https://github.com/GoodBoyDigital/pixi.js", "_blank")
//    }
    PIXI.requestAnimFrame(animate);
  }


  // create an array of assets to load

  var assetsToLoader = ["data/spineboy.json", "data/spineboySpineData.json"];

  // create a new loader
  var loader = new PIXI.AssetLoader(assetsToLoader);

  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();


}