import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;


main(){

  // create an array of assets to load




  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF, true);

  // create a renderer instance
//	var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);
  var renderer = new PIXI.CanvasRenderer(window.innerWidth, window.innerHeight);


  // set the canvas width and height to fill the screen
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);

  onAssetsLoaded()
  {
    var dragon = new PIXI.Spine("data/dragonBonesData.json");

    var scale = 1;//window.innerHeight / 700;

    dragon.position.x = window.innerWidth/2;
    dragon.position.y =	window.innerHeight/2 + (450 * scale);

    dragon.scale.x = dragon.scale.y = scale;


    dragon.state.setAnimationByName("flying", true);

    stage.addChild(dragon);

//		var logo = PIXI.Sprite.fromImage("../../logo_small.png")
//		stage.addChild(logo);
//
//
//		logo.anchor.x = 1;
//		logo.position.x = window.innerWidth
//		logo.scale.x = logo.scale.y = 0.5;
//		logo.position.y = window.innerHeight - 70;
//		logo.setInteractive(true);
//		logo.buttonMode = true;
//		logo.click = logo.tap = function()
//		{
//			window.open("https://github.com/GoodBoyDigital/pixi.js", "_blank")
//		}

  }

  var assetsToLoader = ["data/dragonBones.json", "data/dragonBonesData.json"];

  // create a new loader
  var loader = new PIXI.AssetLoader(assetsToLoader);

  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();



  animate(dt) {

    PIXI.requestAnimFrame( animate );
    renderer.render(stage);
  }

  PIXI.requestAnimFrame(animate);

}