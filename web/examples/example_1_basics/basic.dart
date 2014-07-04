import "dart:html";
import "package:pixi_dart/pixi.dart" as PIXI;


main(){
  // create an new instance of a pixi stage
  PIXI.Stage stage = new PIXI.Stage(0x66FF99);

  // create a renderer instance
  PIXI.Renderer renderer =  new PIXI.WebGLRenderer(500, 300);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);



  // create a texture from an image path
  var texture = PIXI.Texture.fromImage("bunny.png");
  window.console.log(texture.baseTexture);
  // create a new Sprite using the texture
  var bunny = new PIXI.Sprite(texture);

  // center the sprites anchor point
  bunny.anchor.x = 0.5;
  bunny.anchor.y = 0.5;

  // move the sprite t the center of the screen
  bunny.position.x = 200;
  bunny.position.y = 150;

  stage.addChild(bunny);

  animate(num delta) {
    window.requestAnimationFrame(animate);

    // just for fun, let's rotate mr rabbit a little
    bunny.rotation += 0.1;

    // render the stage
    renderer.render(stage);
  }
  window.requestAnimationFrame(animate);

}