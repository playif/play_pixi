import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;

main() {
  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0x660099);

  // create a renderer instance
  var renderer =  new PIXI.CanvasRenderer(400, 300);
  //var renderer = new PIXI.WebGLRenderer(400, 300);
  //var renderer = PIXI.autoDetectRenderer(400, 300);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);


  // create a texture from an image path
  var texture = PIXI.Texture.fromImage("bunny.png");
  //window.console.log(texture.baseTexture);
  // create a new Sprite using the texture
  List<PIXI.Point> points = new List<PIXI.Point>();
  points.add(new PIXI.Point(0, 0));
  points.add(new PIXI.Point(0, 20));
  points.add(new PIXI.Point(20, 0));
  points.add(new PIXI.Point(20, 20));

  var bunny = new PIXI.Sprite(texture);

  Random random = new Random();
  //bunny.tint = random.nextInt(0xFFFFFF);

  // center the sprites anchor point
  //bunny.anchor.x = 0.5;
  //bunny.anchor.y = 0.5;

  // move the sprite t the center of the screen
  bunny.position.x = 200;
  bunny.position.y = 150;

  stage.addChild(bunny);

  animate(num delta) {
    PIXI.requestAnimFrame(animate);

    // just for fun, let's rotate mr rabbit a little
    bunny.rotation += 0.1;

    // render the stage
    renderer.render(stage);
  }
  PIXI.requestAnimFrame(animate);

}