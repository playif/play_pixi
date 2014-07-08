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
  var viewWidth = 630;
  var viewHeight = 410;

  // Create a pixi renderer
  var renderer = PIXI.autoDetectRenderer(viewWidth, viewHeight);
  renderer.view.className = "rendererView";

  // add render view to DOM
  document.body.append(renderer.view);
  Random random = new Random();

  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF);

  // create a background texture
  var pondFloorTexture = PIXI.Texture.fromImage("BGrotate.jpg");

  // create an array to store a reference to the fish in the pond
  List dudeArray = [];

  var totalDudes = 20;
  for (var i = 0; i < totalDudes; i++) {
    // create a new Sprite that uses the image name that we just generated as its source
    var texture = PIXI.Texture.fromImage("eggHead.png");
    Dude dude = new Dude(texture);

    // set the anchor point so the the dude texture is centerd on the sprite
    dude.anchor.x = dude.anchor.y = 0.5;

    // set a random scale for the dude - no point them all being the same size!
    dude.scale.x = dude.scale.y = 0.8 + random.nextDouble() * 0.3;

    // finally lets set the dude to be a random position..
    dude.position.x = random.nextInt(viewWidth);
    dude.position.y = random.nextInt(viewHeight);

    // time to add the dude to the pond container !
    stage.addChild(dude);

    dude.tint = random.nextInt(0xFFFFFF);

    // create some extra properties that will control movement
    // create a random direction in radians. This is a number between 0 and PI*2 which is the equivalent of 0 - 360 degrees
    dude.direction = random.nextDouble() * PI * 2;

    // this number will be used to modify the direction of the dude over time
    dude.turningSpeed = random.nextDouble() - 0.8;

    // create a random speed for the dude between 0 - 2
    dude.speed = 2 + random.nextDouble() * 2;

    // finally we push the dude into the dudeArray so it it can be easily accessed later
    dudeArray.add(dude);
  }

  // create a bounding box box for the little dudes
  var dudeBoundsPadding = 100;
  var dudeBounds = new PIXI.Rectangle(-dudeBoundsPadding,
  -dudeBoundsPadding,
  viewWidth + dudeBoundsPadding * 2,
  viewHeight + dudeBoundsPadding * 2);

  var tick = 0;


  animate(dt) {
    // iterate through the dude and update the positiond
    for (var i = 0; i < dudeArray.length; i++) {
      var dude = dudeArray[i];
      dude.direction += dude.turningSpeed * 0.01;
      dude.position.x += sin(dude.direction) * dude.speed;
      dude.position.y += cos(dude.direction) * dude.speed;
      dude.rotation = -dude.direction - PI / 2;

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

    // time to render the state!
    renderer.render(stage);

    // request another animation frame..
    PIXI.requestAnimFrame(animate);
  }

  PIXI.requestAnimFrame(animate);
}