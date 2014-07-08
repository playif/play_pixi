import "dart:html";
import "dart:math";
import "package:pixi_dart/pixi.dart" as PIXI;

main(){
  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0x66FF99);

  // create a renderer instance
  var renderer = PIXI.autoDetectRenderer(400, 300, null, true, true);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);
  renderer.view.style.position = "absolute";
  renderer.view.style.top = "0px";
  renderer.view.style.left = "0px";

  // create a texture from an image path
  var texture = PIXI.Texture.fromImage("bunny.png");

  // create a new Sprite using the texture
  var bunny = new PIXI.Sprite(texture);

  // center the sprite's anchor point
  bunny.anchor.x = 0.5;
  bunny.anchor.y = 0.5;

  // move the sprite to the center of the screen
  bunny.position.x = 200;
  bunny.position.y = 150;

  stage.addChild(bunny);

  animate(dt) {
    PIXI.requestAnimFrame(animate);

    // just for fun, lets rotate mr rabbit a little
    bunny.rotation += 0.1;

    // render the stage
    renderer.render(stage);
  }


  PIXI.requestAnimFrame(animate);
}


