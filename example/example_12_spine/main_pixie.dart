import "dart:html";

import "../../lib/pixi.dart" as PIXI;


main() {


  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF, true);

  // create a renderer instance
  var renderer = PIXI.autoDetectRenderer(1024, 640);

  // set the canvas width and height to fill the screen
  renderer.view.style.display = "block";
  renderer.view.style.width = "100%";
  renderer.view.style.height = "100%";

  // add render view to DOM
  document.body.append(renderer.view);

  var postition = 0;
  var background;
  var background2;
  var foreground;
  var foreground2;


  animate(dt) {

    postition += 10;

    background.position.x = -(postition * 0.6);
    background.position.x %= 1286 * 2;
    if (background.position.x < 0)background.position.x += 1286 * 2;
    background.position.x -= 1286;

    background2.position.x = -(postition * 0.6) + 1286;
    background2.position.x %= 1286 * 2;
    if (background2.position.x < 0)background2.position.x += 1286 * 2;
    background2.position.x -= 1286;

    foreground.position.x = -postition;
    foreground.position.x %= 1286 * 2;
    if (foreground.position.x < 0)foreground.position.x += 1286 * 2;
    foreground.position.x -= 1286;

    foreground2.position.x = -postition + 1286;
    foreground2.position.x %= 1286 * 2;
    if (foreground2.position.x < 0)foreground2.position.x += 1286 * 2;
    foreground2.position.x -= 1286;

    PIXI.requestAnimFrame(animate);


    renderer.render(stage);
  }

  onAssetsLoaded() {
    background = PIXI.Sprite.fromImage("data/iP4_BGtile.jpg");
    background2 = PIXI.Sprite.fromImage("data/iP4_BGtile.jpg");
    stage.addChild(background);
    stage.addChild(background2);

    foreground = PIXI.Sprite.fromImage("data/iP4_ground.png");
    foreground2 = PIXI.Sprite.fromImage("data/iP4_ground.png");
    stage.addChild(foreground);
    stage.addChild(foreground2);
    foreground.position.y = foreground2.position.y = 640 - foreground2.height;

    var pixie = new PIXI.Spine("data/PixieSpineData.json");

    var scale = 0.3;//window.innerHeight / 700;

    pixie.position.x = 1024 / 3;
    pixie.position.y = 500;

    pixie.scale.x = pixie.scale.y = scale;


    //dragon.state.setAnimationByName("running", true);

    stage.addChild(pixie);

    //pixie.stateData.setMixByName("running", "jump", 0.2);
    //pixie.stateData.setMixByName("jump", "running", 0.4);
    //pixie.stateData.setMixByName("jump", "jump", 0.1);

    pixie.state.addAnimationByName("running", true);


    stage.mousedown = (e) {
      pixie.state.setAnimationByName("jump", false);
      pixie.state.addAnimationByName("running", true);
    };


    PIXI.requestAnimFrame(animate);
  }


  // create an array of assets to load

  var assetsToLoader = ["data/PixieSpineData.json", "data/Pixie.json", "data/iP4_BGtile.jpg", "data/iP4_ground.png"];

  // create a new loader
  var loader = new PIXI.AssetLoader(assetsToLoader);

  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();
}