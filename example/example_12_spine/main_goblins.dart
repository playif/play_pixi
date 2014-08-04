import "dart:html";

import "../../lib/pixi.dart" as PIXI;


main() {


  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF, true);

  // create a renderer instance
  var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);

  // set the canvas width and height to fill the screen
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);

  onAssetsLoaded() {
    var goblin = new PIXI.Spine("data/goblinsSpineData.json");

    // set current skin
    goblin.skeleton.setSkinByName('goblin');
    goblin.skeleton.setSlotsToSetupPose();

    // set the position
    goblin.position.x = window.innerWidth / 2;
    goblin.position.y = window.innerHeight;

    goblin.scale.x = goblin.scale.y = window.innerHeight / 400;

    // play animation
    goblin.state.setAnimationByName("walk", true);


    stage.addChild(goblin);

    stage.click = (e) {
      // change current skin
      var currentSkinName = goblin.skeleton.skin.name;
      var newSkinName = (currentSkinName == 'goblin' ? 'goblingirl' : 'goblin');
      goblin.skeleton.setSkinByName(newSkinName);
      goblin.skeleton.setSlotsToSetupPose();
    };

  }

  // create an array of assets to load

  var assetsToLoader = ["data/goblins.json", "data/goblinsSpineData.json"];

  // create a new loader
  var loader = new PIXI.AssetLoader(assetsToLoader);

  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();


  animate(dt) {

    PIXI.requestAnimFrame(animate);
    renderer.render(stage);
  }
  PIXI.requestAnimFrame(animate);
}