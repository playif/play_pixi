import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;

main() {
  // create an new instance of a pixi stage
  // the second parameter is interactivity...
  var interactive = true;
  var stage = new PIXI.Stage(0x000000, interactive);

  // create a renderer instance.
  var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);
  renderer.view.style.display = "block";

  // create a background..
  var background = PIXI.Sprite.fromImage("button_test_BG.jpg");

  // add background to stage...
  stage.addChild(background);

  // create some textures from an image path
  var textureButton = PIXI.Texture.fromImage("button.png");
  var textureButtonDown = PIXI.Texture.fromImage("buttonDown.png");
  var textureButtonOver = PIXI.Texture.fromImage("buttonOver.png");

  List buttons = [];

  var buttonPositions = [175, 75,
  600 - 145, 75,
  600 / 2 - 20, 400 / 2 + 10,
  175, 400 - 75,
  600 - 115, 400 - 95];


  for (var i = 0; i < 5; i++) {
    PIXI.Sprite button = new PIXI.Sprite(textureButton);
    button.buttonMode = true;

    button.anchor.x = 0.5;
    button.anchor.y = 0.5;

    button.position.x = buttonPositions[i * 2];
    button.position.y = buttonPositions[i * 2 + 1];

    // make the button interactive..
    button.interactive = true;

    // set the mousedown and touchstart callback..
    button.mousedown = button.touchstart = (data) {
      print("mousedown");
      //button.isdown = true;
      button.setTexture(textureButtonDown);
      button.alpha = 1;
    };

    // set the mouseup and touchend callback..
    button.mouseup = button.mouseupoutside = button.touchend = button.touchendoutside = (data) {
      print("mouseup");
      //button.isdown = false;

      //if (button.isOver) {
      button.setTexture(textureButtonOver);
      //}
      //else {
      //    button.setTexture(textureButton);
      //}
    };

    // set the mouseover callback..
    button.mouseover = button.touchmove = (data) {
      print("over");
      //button.isOver = true;

      //if (button.isdown)
      //    return;

      button.setTexture(textureButtonOver);
    };

    // set the mouseout callback..
    button.mouseout = button.touchend = (data) {
      print("mouseout");
      //button.isOver = false;
      //if (button.isdown)
      //    return
      button.setTexture(textureButton);
    };


    button.click = (data) {
      print("click");
      window.console.log("CLICK!");
    };


//            button.tap = (data) {
//                window. console.log("TAP!!");
//            };


    // add it to the stage
    stage.addChild(button);

    // add button to array
    buttons.add(button);
  }


  // set some silly values...
  buttons[0].scale.x = 1.2;
  buttons[1].scale.y = 1.2;
  buttons[2].rotation = PI / 10;
  buttons[3].scale.x = 0.8;
  buttons[3].scale.y = 0.8;
  buttons[4].scale.x = 0.8;
  buttons[4].scale.y = 1.2;
  buttons[4].rotation = PI;

  animate(dt) {
    // render the stage
    renderer.render(stage);

    PIXI.requestAnimFrame(animate);
  }

  // add a logo!
  var pixiLogo = PIXI.Sprite.fromImage("pixi.png");
  stage.addChild(pixiLogo);

  pixiLogo.buttonMode = true;

  pixiLogo.position.x = 620 - 56;
  pixiLogo.position.y = 400 - 32;

  pixiLogo.click = (e) {
    window.open("http://www.pixijs.com", '_blank');
  };


  PIXI.requestAnimFrame(animate);
}

