import "dart:html";
import "dart:math";
import "package:pixi_dart/pixi.dart" as PIXI;

class Bunny extends PIXI.Sprite {
  Bunny(PIXI.Texture texture):super(texture);

  PIXI.InteractionData data;
  bool dragging = false;
}

main() {
  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0x97C56E, true);

  // create a renderer instance
  var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight, null);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);
  renderer.view.style.position = "absolute";
  renderer.view.style.top = "0px";
  renderer.view.style.left = "0px";


  // create a texture from an image path
  var texture = PIXI.Texture.fromImage("bunny.png");
  Random random = new Random();


  createBunny(x, y) {
    // create our little bunny friend..
    Bunny bunny = new Bunny(texture);

    // enable the bunny to be interactive.. this will allow it to respond to mouse and touch events
    bunny.interactive = true;
    // this button mode will mean the hand cursor appears when you rollover the bunny with your mouse
    bunny.buttonMode = true;

    // center the bunnys anchor point
    bunny.anchor.x = 0.5;
    bunny.anchor.y = 0.5;
    // make it a bit bigger, so its easier to touch
    bunny.scale.x = bunny.scale.y = 3;


    // use the mousedown and touchstart
    bunny.mousedown = (PIXI.InteractionData data) {
      // stop the default event...
      data.originalEvent.preventDefault();

      // store a reference to the data
      // The reason for this is because of multitouch
      // we want to track the movement of this particular touch
      bunny.data = data;
      bunny.alpha = 0.9;
      bunny.dragging = true;
    };

    // set the events for when the mouse is released or a touch is released
    bunny.mouseup = bunny.mouseupoutside = (PIXI.InteractionData data) {
      bunny.alpha = 1;
      bunny.dragging = false;
      // set the interaction data to null
      bunny.data = null;
    } ;

    // set the callbacks for when the mouse or a touch moves
    bunny.mousemove = (PIXI.InteractionData data) {
      //print(bunny.dragging);
      if (bunny.dragging) {
        var newPosition = bunny.data.getLocalPosition(bunny.parent);
        bunny.position.x = newPosition.x;
        bunny.position.y = newPosition.y;
      }
    };

    // move the sprite to its designated position
    bunny.position.x = x;
    bunny.position.y = y;

    // add it to the stage
    stage.addChild(bunny);
  }

  for (var i = 0; i < 10; i++) {
    createBunny(random.nextInt(window.innerWidth), random.nextInt(window.innerHeight));
  }



  animate(dt) {

    PIXI.requestAnimFrame(animate);

    // render the stage
    renderer.render(stage);
  }

  PIXI.requestAnimFrame(animate);
}
