import "dart:html";
import "dart:math";
import "package:pixi_dart/pixi.dart" as PIXI;
import "dart:async";

main() {


  //window.omo = resize;

  //document.addEventListener('DOMContentLoaded', start, false);

  var w = 1024;
  var h = 768;

  var n = 2000;
  var d = 1;
  var current = 1;
  var objs = 17;
  var vx = 0;
  var vy = 0;
  var vz = 0;
  var points1 = new List<num>(n);
  var points2 = new List<num>(n);
  var points3 = new List<num>(n);
  var tpoint1 = new List<num>(n);
  var tpoint2 = new List<num>(n);
  var tpoint3 = new List<num>(n);
  var balls = new List<num>(n);
  var renderer;
  var stage;

  Random random = new Random();
  var ballTexture = PIXI.Texture.fromImage("assets/pixel.png");
  renderer = PIXI.autoDetectRenderer(w, h);
  stage = new PIXI.Stage();

  makeObject(t) {
    var xd;

    switch (t) {
      case 0:
        for (var i = 0; i < n; i++) {
          points1[i] = -50 + random.nextInt(100);
          points2[i] = 0;
          points3[i] = 0;
        }
        break;
      case 1:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(t * 360 / n) * 10);
          points2[i] = (cos(xd) * 10) * (sin(t * 360 / n) * 10);
          points3[i] = sin(xd) * 100;
        }
        break;
      case 2:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(t * 360 / n) * 10);
          points2[i] = (cos(xd) * 10) * (sin(t * 360 / n) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 3:

        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(xd) * 10);
          points2[i] = (cos(xd) * 10) * (sin(xd) * 10);
          points3[i] = sin(xd) * 100;
        }
        break;
      case 4:

        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(xd) * 10);
          points2[i] = (cos(xd) * 10) * (sin(xd) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 5:

        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(xd) * 10);
          points2[i] = (cos(i * 360 / n) * 10) * (sin(xd) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 6:

        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(i * 360 / n) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (cos(i * 360 / n) * 10) * (sin(xd) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 7:

        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(i * 360 / n) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (cos(i * 360 / n) * 10) * (sin(i * 360 / n) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 8:

        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (cos(i * 360 / n) * 10) * (sin(i * 360 / n) * 10);
          points3[i] = sin(xd) * 100;
        }
        break;
      case 9:

        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (cos(i * 360 / n) * 10) * (sin(xd) * 10);
          points3[i] = sin(xd) * 100;
        }
        break;
      case 10:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(i * 360 / n) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (cos(xd) * 10) * (sin(xd) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 11:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (sin(xd) * 10) * (sin(i * 360 / n) * 10);
          points3[i] = sin(xd) * 100;
        }
        break;
      case 12:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(xd) * 10);
          points2[i] = (sin(xd) * 10) * (sin(xd) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 13:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (sin(i * 360 / n) * 10) * (sin(xd) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 14:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (sin(xd) * 10) * (cos(xd) * 10);
          points2[i] = (sin(xd) * 10) * (sin(i * 360 / n) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 15:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(i * 360 / n) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (sin(i * 360 / n) * 10) * (sin(xd) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
      case 16:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(i * 360 / n) * 10);
          points2[i] = (sin(i * 360 / n) * 10) * (sin(xd) * 10);
          points3[i] = sin(xd) * 100;
        }
        break;
      case 17:
        for (var i = 0; i < n; i++) {
          xd = -90 + random.nextInt(180);
          points1[i] = (cos(xd) * 10) * (cos(xd) * 10);
          points2[i] = (cos(i * 360 / n) * 10) * (sin(i * 360 / n) * 10);
          points3[i] = sin(i * 360 / n) * 100;
        }
        break;
    }
  }

  nextObject() {
    current++;
    if (current > objs) {
      current = 0;
    }

    makeObject(current);
    new Timer(const Duration(seconds:8), nextObject);
  }

  resize(e) {
    w = window.innerWidth - 16;
    h = window.innerHeight - 16;

    renderer.resize(w, h);
  }
  window.onResize.listen(resize);

  update(dt) {
    var x3d, y3d, z3d, tx, ty, tz, ox;

    if (d < 250) {
      d++;
    }

    vx += 0.0075;
    vy += 0.0075;
    vz += 0.0075;

    for (var i = 0; i < n; i++) {
      if (points1[i] > tpoint1[i]) {
        tpoint1[i] = tpoint1[i] + 1;
      }
      if (points1[i] < tpoint1[i]) {
        tpoint1[i] = tpoint1[i] - 1;
      }
      if (points2[i] > tpoint2[i]) {
        tpoint2[i] = tpoint2[i] + 1;
      }
      if (points2[i] < tpoint2[i]) {
        tpoint2[i] = tpoint2[i] - 1;
      }
      if (points3[i] > tpoint3[i]) {
        tpoint3[i] = tpoint3[i] + 1;
      }
      if (points3[i] < tpoint3[i]) {
        tpoint3[i] = tpoint3[i] - 1;
      }

      x3d = tpoint1[i];
      y3d = tpoint2[i];
      z3d = tpoint3[i];

      ty = (y3d * cos(vx)) - (z3d * sin(vx));
      tz = (y3d * sin(vx)) + (z3d * cos(vx));
      tx = (x3d * cos(vy)) - (tz * sin(vy));
      tz = (x3d * sin(vy)) + (tz * cos(vy));
      ox = tx;
      tx = (tx * cos(vz)) - (ty * sin(vz));
      ty = (ox * sin(vz)) + (ty * cos(vz));

      balls[i].position.x = (512 * tx) / (d - tz) + w / 2;
      balls[i].position.y = (h / 2) - (512 * ty) / (d - tz);
    }

    renderer.render(stage);

    PIXI.requestAnimFrame(update);
  }


  start() {


    document.body.append(renderer.view);

    makeObject(0);

    for (var i = 0; i < n; i++) {
      tpoint1[i] = points1[i];
      tpoint2[i] = points2[i];
      tpoint3[i] = points3[i];

      var tempBall = new PIXI.Sprite(ballTexture);
      tempBall.anchor.x = 0.5;
      tempBall.anchor.y = 0.5;
      tempBall.alpha = 0.5;
      balls[i] = tempBall;

      stage.addChild(tempBall);
    }

    resize(null);

    new Timer(const Duration(seconds:8), nextObject);

    PIXI.requestAnimFrame(update);
  }
  start();
}