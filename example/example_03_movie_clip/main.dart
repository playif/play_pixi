import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;

main() {
  // create an array of assets to load
  var assetsToLoader = [ "SpriteSheet.json" ];

  // holder to store aliens
  // holder to store aliens
  var explosions = [];

  int explosionsCount = 100;
  num count = 0;

  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF);

  // create a renderer instance.
  var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);
  //var renderer = new PIXI.CanvasRenderer(window.innerWidth, window.innerHeight);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);
  renderer.view.style.display = "block";
  // create an empty container
  var alienContainer = new PIXI.DisplayObjectContainer();
  alienContainer.position.x = 400;
  alienContainer.position.y = 300;

  stage.addChild(alienContainer);

  Random random = new Random();


  animate(num delta) {
//            // just for fun, lets rotate mr rabbit a little
//            for (var i = 0; i < aliensCount; i++) {
//                var alien = aliens[i];
//                alien.rotation += 0.1;
//            }
//
//            count += 0.01;
//            alienContainer.scale.x = sin(count);
//            alienContainer.scale.y = sin(count);
//
//            alienContainer.rotation += 0.01;

    // render the stage
    renderer.render(stage);

    PIXI.requestAnimFrame(animate);
  }

  onAssetsLoaded() {
    // create an array to store the textures
    var explosionTextures = [];

    for (var i = 0; i < 26; i++) {
      var texture = PIXI.Texture.fromFrame("Explosion_Sequence_A ${i + 1}.png");
      explosionTextures.add(texture);
    }


    for (var i = 0; i < 50; i++) {
      // create an explosion MovieClip
      var explosion = new PIXI.MovieClip(explosionTextures);

      explosion.position.x = random.nextInt(800) ;
      explosion.position.y = random.nextInt(600) ;
      explosion.anchor.x = 0.5;
      explosion.anchor.y = 0.5;

      explosion.rotation = random.nextDouble() * PI;
      explosion.scale.x = explosion.scale.y = 0.75 + random.nextDouble() * 0.5;

      explosion.gotoAndPlay(random.nextInt(27));

      stage.addChild(explosion);
    }

    // start animating
    PIXI.requestAnimFrame(animate);
  }

  // create a new loader
  var loader = new PIXI.AssetLoader(assetsToLoader);

  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();
}
