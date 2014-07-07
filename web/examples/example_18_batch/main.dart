import "dart:html";
import "dart:math";
import "package:pixi_dart/pixi.dart" as PIXI;


class Dude extends PIXI.Sprite {
  Dude(PIXI.Texture texture):super(texture);

  PIXI.InteractionData data;
  bool dragging = false;

  num direction;
  num turningSpeed;

  num speed;
  num offset;

}

main() {

  var viewWidth = 800;
  var viewHeight = 600;

  // Create a pixi renderer
  var renderer = PIXI.autoDetectRenderer(viewWidth, viewHeight);
  //var renderer =  new PIXI.CanvasRenderer(viewWidth, viewHeight);
  renderer.view.className = "rendererView";

  // add render view to DOM
  document.body.append(renderer.view);

  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF);

  var sprites = new PIXI.SpriteBatch();
  stage.addChild(sprites);

  var tints = [0xFFFFFF, 0xFFFBEE, 0xFFEEEE, 0xFADEED, 0xE8D4CD];

  // create an array to store a refference to the fish in the pond
  List<Dude> dudeArray = [];

  Random random = new Random();

  var totalDudes = renderer is PIXI.WebGLRenderer ? 5000 : 500;
  PIXI.Texture texture = PIXI.Texture.fromImage("tinyMaggot.png");
  for (var i = 0; i < totalDudes; i++) {
// create a new Sprite that uses the image name that we just generated as its source
    Dude dude = new Dude(texture);

    dude.tint = random.nextInt(0xE8D4CD);

// set the anchor point so the the dude texture is centerd on the sprite
    dude.anchor.x = dude.anchor.y = 0.5;

// set a random scale for the dude - no point them all being the same size!
    dude.scale.x = dude.scale.y = 0.8 + random.nextDouble() * 0.3;

// finally lets set the dude to be a random position..
    dude.x = random.nextDouble() * viewWidth;
    dude.y = random.nextDouble() * viewHeight;

// create some extra properties that will control movement
    dude.tint = random.nextInt(0x808080);

// create a random direction in radians. This is a number between 0 and PI*2 which is the equivalent of 0 - 360 degrees
    dude.direction = random.nextDouble() * PI * 2;

// this number will be used to modify the direction of the dude over time
    dude.turningSpeed = random.nextDouble() - 0.8;

// create a random speed for the dude between 0 - 2
    dude.speed = (2 + random.nextDouble() * 2) * 0.2;

    dude.offset = random.nextDouble() * 100;

// finally we push the dude into the dudeArray so it it can be easily accessed later
    dudeArray.add(dude);

    sprites.addChild(dude);
  }

// create a bounding box box for the little dudes
  var dudeBoundsPadding = 100;
  var dudeBounds = new PIXI.Rectangle(-dudeBoundsPadding,
  -dudeBoundsPadding,
  viewWidth + dudeBoundsPadding * 2,
  viewHeight + dudeBoundsPadding * 2);

  var tick = 0;

  animate(dt) {
    // iterate through the dude and update the position
    for (var i = 0; i < dudeArray.length; i++) {
      var dude = dudeArray[i];
      dude.scale.y = 0.95 + sin(tick + dude.offset) * 0.05;
      dude.direction += dude.turningSpeed * 0.01;
      dude.position.x += sin(dude.direction) * (dude.speed * dude.scale.y);
      dude.position.y += cos(dude.direction) * (dude.speed * dude.scale.y);
      dude.rotation = -dude.direction + PI;

      // wrap the dudes by testing their bounds..
      if (dude.position.x < dudeBounds.x)
        dude.position.x += dudeBounds.width;
      else if (dude.position.x > dudeBounds.x + dudeBounds.width)
        dude.position.x -= dudeBounds.width;

      if (dude.position.y < dudeBounds.y)
        dude.position.y += dudeBounds.height;
      else if (dude.position.y > dudeBounds.y + dudeBounds.height)
        dude.position.y -= dudeBounds.height;
    }

    // increment the ticker
    tick += 0.1;

    // time to render the stage !
    renderer.render(stage);

    // request another animation frame..
    PIXI.requestAnimFrame(animate);
  }

  PIXI.requestAnimFrame(animate);

}