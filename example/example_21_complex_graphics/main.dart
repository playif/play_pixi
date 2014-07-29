import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;

main() {


  // holder to store aliens
//  List aliens = [];
//  var alienFrames = ["eggHead.png", "flowerTop.png", "helmlok.png", "skully.png"];

  var count = 0;

  // create an new instance of a pixi stage
  var stage = new PIXI.Stage(0x3da8bb);


  // create a renderer instance.
  var renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);
  //var renderer = new PIXI.CanvasRenderer(window.innerWidth, window.innerHeight);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);

  // create an empty container
  var alienContainer = new PIXI.DisplayObjectContainer();
  alienContainer.position.x = 400;
  alienContainer.position.y = 300;


  stage.addChild(alienContainer);

  count = 0;

  // start animating

  Random random = new Random();
  var graphics = new PIXI.Graphics().beginFill(0xFF0000);//.moveTo(-200, -300).lineTo(200, -300).lineTo(220,100).lineTo(200,300).lineTo(-200,300).endFill();

  var liveGraphics = new PIXI.Graphics().beginFill(0xFF0000);

  var path = [];


  stage.interactive = true;

  var isDown = false;
  var color = 0;

  var colors = [0x5D0776, 0xEC8A49, 0xAF3666, 0xF6C84C, 0x4C779A];
  var colorCount = 0;

  var label = new PIXI.Text("Click and drag anywhere do draw complex geometry in pixi / do an art attack",
  new PIXI.TextStyle()
    ..fill = "white"
    ..font = "16px Arial");
  label.x = 10;
  label.y = 10;

//  for (var i = 0; i < 100; i++) {
//    var frameName = alienFrames[i % 4];
//
//    // create an alien using the frame name..
//    PIXI.Sprite alien = PIXI.Sprite.fromImage(frameName);
//    alien.tint = random.nextInt(0xFFFFFF) ;
//
//    /*
//			 * fun fact for the day :)
//			 * another way of doing the above would be
//			 * var texture = PIXI.Texture.fromFrame(frameName);
//			 * var alien = new PIXI.Sprite(texture);
//			 */
//
//    alien.position.x = random.nextInt(800) - 400;
//    alien.position.y = random.nextInt(600) - 300;
//    alien.anchor.x = 0.5;
//    alien.anchor.y = 0.5;
//    aliens.add(alien);
//    alienContainer.addChild(alien);
//  }

  stage.mousedown = stage.touchstart = (data) {
    isDown = true;
    path = [];


    color = colors[colorCount++ % colors.length];
    //	liveGraphics.clear().beginFill(color);
//		liveGraphics.drawCircle(data.global.x, data.global.y, 030);


  };

  stage.mousemove = stage.touchmove = (data) {
    if (!isDown)return;


    path.add(data.global.x);
    path.add(data.global.y);


    liveGraphics.clear();

    if (path.length <= 12)return;

    liveGraphics.beginFill(color);
    if (path.length > 12)liveGraphics.drawPath(path);
    liveGraphics.endFill();

    //console.log(">>>>")
  };

  stage.mouseup = stage.touchend = (e) {
    isDown = false;
    if (path.length <= 12)return;
    graphics.beginFill(color);
    graphics.lineStyle(20, color, 0.5);
    graphics.drawPath(path);
    graphics.endFill();
    path = [];
  };

  //graphics.mask = liveGraphics;
//	graphics.drawPath(path);

  stage.addChild(graphics);
  stage.addChild(liveGraphics);
  stage.addChild(label);


  animate(dt) {


    count += 0.1;

    // render the stage
    renderer.render(stage);
    //    graphics.x = 300;
    //   graphics.y = 399

    PIXI.requestAnimFrame(animate);
  }


  PIXI.requestAnimFrame(animate);
}