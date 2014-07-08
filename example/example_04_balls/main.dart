import "dart:html";
import "dart:math";
import "../../lib/pixi.dart" as PIXI;

main() {
  Random random = new Random();

  num w = 1024;
  num h = 768;
  num starCount = 2500;
  num sx = 1.0 + (random.nextDouble() / 20);
  num sy = 1.0 + (random.nextDouble() / 20);
  num slideX = w / 2;
  num slideY = h / 2;
  List stars = [];
  var renderer;
  PIXI.Stage stage;


  newWave(e) {
    sx = 1.0 + (random.nextDouble() / 20);
    sy = 1.0 + (random.nextDouble() / 20);
    document.getElementById('sx').innerHtml = 'SX: $sx<br />SY: $sy';
  }

  resize([e]) {

    w = window.innerWidth - 16;
    h = window.innerHeight - 16;

    slideX = w / 2;
    slideY = h / 2;

    renderer.resize(w, h);
  }

  update([dt]) {
    for (var i = 0; i < starCount; i++) {
      stars[i]['sprite'].position.x = stars[i]['x'] + slideX;
      stars[i]['sprite'].position.y = stars[i]['y'] + slideY;
      stars[i]['x'] = stars[i]['x'] * sx;
      stars[i]['y'] = stars[i]['y'] * sy;

      if (stars[i]['x'] > w) {
        stars[i]['x'] = stars[i]['x'] - w;
      }
      else if (stars[i]['x'] < -w) {
        stars[i]['x'] = stars[i]['x'] + w;
      }

      if (stars[i]['y'] > h) {
        stars[i]['y'] = stars[i]['y'] - h;
      }
      else if (stars[i]['y'] < -h) {
        stars[i]['y'] = stars[i]['y'] + h;
      }
    }

    renderer.render(stage);

    PIXI.requestAnimFrame(update);
  }


  start() {
    //print(w);
    PIXI.Texture ballTexture = PIXI.Texture.fromImage("assets/bubble_32x32.png");
    renderer = PIXI.autoDetectRenderer(w, h);
    stage = new PIXI.Stage();

    document.body.append(renderer.view);

    for (var i = 0; i < starCount; i++) {
      var tempBall = new PIXI.Sprite(ballTexture);

      tempBall.position.x = random.nextInt(w) - slideX;
      tempBall.position.y = random.nextInt(h) - slideY;
      tempBall.anchor.x = 0.5;
      tempBall.anchor.y = 0.5;

      stars.add({
          'sprite': tempBall, 'x': tempBall.position.x, 'y': tempBall.position.y
      });

      stage.addChild(tempBall);
    }

    document.getElementById('rnd').onClick.listen(newWave);
    document.getElementById('sx').innerHtml = 'SX:  $sx <br />SY: $sy';

    resize();

    PIXI.requestAnimFrame(update);
  }


  window.onResize.listen(resize);

  start();
}

