import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;


main() {

  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0xFFFFFF, true);

  stage.interactive = true;

  var bg = PIXI.Sprite.fromImage("BGrotate.jpg");
  bg.anchor.x = 0.5;
  bg.anchor.y = 0.5;

  bg.position.x = 620 / 2;
  bg.position.y = 380 / 2;

  stage.addChild(bg);

  var container = new PIXI.DisplayObjectContainer();
  container.position.x = 620 / 2;
  container.position.y = 380 / 2;

  var bgFront = PIXI.Sprite.fromImage("SceneRotate.jpg");
  bgFront.anchor.x = 0.5;
  bgFront.anchor.y = 0.5;

  container.addChild(bgFront);

  var light2 = PIXI.Sprite.fromImage("LightRotate2.png");
  light2.anchor.x = 0.5;
  light2.anchor.y = 0.5;
  container.addChild(light2);

  var light1 = PIXI.Sprite.fromImage("LightRotate1.png");
  light1.anchor.x = 0.5;
  light1.anchor.y = 0.5;
  container.addChild(light1);

  var panda = PIXI.Sprite.fromImage("panda.png");
  panda.anchor.x = 0.5;
  panda.anchor.y = 0.5;

  container.addChild(panda);

  stage.addChild(container);

  // create a renderer instance
  var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);

  renderer.view.style.position = "absolute";
  renderer.view.style.marginLeft = "-310px";
  renderer.view.style.marginTop = "-190px";
  renderer.view.style.top = "50%";
  renderer.view.style.left = "50%";
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);

  // lets create moving shape
  var thing = new PIXI.Graphics();
  stage.addChild(thing);
  thing.position.x = 620 / 2;
  thing.position.y = 380 / 2;
  thing.lineStyle(0);

  container.mask = thing;

  var count = 0;

  stage.click = stage.tap = (e) {
    print("cool");
    if (container.mask == null) {
      container.mask = thing;
      //PIXI.runList(stage);
    }
    else {
      print("cool");
      container.mask = null;
    }
  };

  /*
	 * Add a pixi Logo!
	 */
//  var logo = PIXI.Sprite.fromImage("../../logo_small.png");
//  stage.addChild(logo);

//  logo.anchor.x = 1;
//  logo.position.x = 620;
//  logo.scale.x = logo.scale.y = 0.5;
//  logo.position.y = 320;
//  logo.interactive = true;
//  logo.buttonMode = true;
//
//  logo.click = () {
//    window.open("https://github.com/GoodBoyDigital/pixi.js", "_blank");
//  };

  var help = new PIXI.Text("Click to turn masking on / off.", new PIXI.TextStyle()
    ..font = "bold 12pt Arial"
    ..fill = "white"
  );
  help.position.y = 350;
  help.position.x = 10;
  stage.addChild(help);


  animate(dt) {
    bg.rotation += 0.01;
    bgFront.rotation -= 0.01;

    light1.rotation += 0.02;
    light2.rotation += 0.01;

    panda.scale.x = 1 + sin(count) * 0.04;
    panda.scale.y = 1 + cos(count) * 0.04;

    count += 0.1;

    thing.clear();

    thing.beginFill(0x8bc5ff, 0.4);
    thing.moveTo(-120 + sin(count) * 20, -100 + cos(count) * 20);
    thing.lineTo(120 + cos(count) * 20, -100 + sin(count) * 20);
    thing.lineTo(120 + sin(count) * 20, 100 + cos(count) * 20);
    thing.lineTo(-120 + cos(count) * 20, 100 + sin(count) * 20);
    thing.lineTo(-120 + sin(count) * 20, -100 + cos(count) * 20);
    thing.rotation = count * 0.1;


    renderer.render(stage);
    PIXI.requestAnimFrame(animate);
  }
  PIXI.requestAnimFrame(animate);
}
