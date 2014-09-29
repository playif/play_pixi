part of PIXI;

class CanvasGraphics {
  CanvasGraphics() {
  }

  static renderGraphics(Graphics graphics, CanvasRenderingContext2D context) {
    num worldAlpha = graphics._worldAlpha;
    String color = '';

    for (var i = 0; i < graphics._graphicsData.length; i++) {
      GraphicsData data = graphics._graphicsData[i];
      List points = data.points;
      if(points.isEmpty){
        continue;
      }

      context.strokeStyle = color = '#' + "${data.lineColor.floor().toRadixString(16)}".padLeft(6, '0');
      //print(color);
      context.lineWidth = data.lineWidth;

      if (data.type == Graphics.POLY) {
        context.beginPath();

        context.moveTo(points[0], points[1]);
 
        for (var j = 1; j < points.length / 2; j++) {
          context.lineTo(points[j * 2], points[j * 2 + 1]);
        }

        // if the first and last point are the same close the path - much neater :)
        if (points[0] == points[points.length - 2] && points[1] == points[points.length - 1]) {
          context.closePath();
        }

        if (data.fill) {
          context.globalAlpha = data.fillAlpha * worldAlpha;
          context.fillStyle = color = '#' + "${data.fillColor.floor().toRadixString(16)}".padLeft(6, '0');
          context.fill();
        }
        if (data.lineWidth != 0) {
          context.globalAlpha = data.lineAlpha * worldAlpha;
          context.stroke();
        }
      }
      else if (data.type == Graphics.RECT) {

        if (data.fill) {
          context.globalAlpha = data.fillAlpha * worldAlpha;
          context.fillStyle = color = '#' + "${data.fillColor.floor().toRadixString(16)}".padLeft(6, '0');
          context.fillRect(points[0], points[1], points[2], points[3]);

        }
        if (data.lineWidth != 0) {
          context.globalAlpha = data.lineAlpha * worldAlpha;
          context.strokeRect(points[0], points[1], points[2], points[3]);
        }

      }
      else if (data.type == Graphics.CIRC) {
          // TODO - need to be Undefined!
          context.beginPath();
          context.arc(points[0], points[1], points[2], 0, 2 * PI);
          context.closePath();

          if (data.fill) {
            context.globalAlpha = data.fillAlpha * worldAlpha;
            context.fillStyle = color = '#' + "${data.fillColor.floor().toRadixString(16)}".padLeft(6, '0');
            context.fill();
          }
          if (data.lineWidth != 0) {
            context.globalAlpha = data.lineAlpha * worldAlpha;
            context.stroke();
          }
        }
        else if (data.type == Graphics.ELIP) {

            var ellipseData = data.points;

            var w = ellipseData[2] * 2;
            var h = ellipseData[3] * 2;

            var x = ellipseData[0] - w / 2;
            var y = ellipseData[1] - h / 2;

            context.beginPath();

            var kappa = 0.5522848,
            ox = (w / 2) * kappa, // control point offset horizontal
            oy = (h / 2) * kappa, // control point offset vertical
            xe = x + w, // x-end
            ye = y + h, // y-end
            xm = x + w / 2, // x-middle
            ym = y + h / 2; // y-middle

            context.moveTo(x, ym);
            context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
            context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
            context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
            context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);

            context.closePath();

            if (data.fill) {
              context.globalAlpha = data.fillAlpha * worldAlpha;
              context.fillStyle = color = '#' + "${data.fillColor.floor().toRadixString(16)}".padLeft(6, '0');
              context.fill();
            }
            if (data.lineWidth != 0) {
              context.globalAlpha = data.lineAlpha * worldAlpha;
              context.stroke();
            }
          }
          else if (data.type == Graphics.RREC) {
              num rx = points[0];
              num ry = points[1];
              num width = points[2];
              num height = points[3];
              num radius = points[4];


              num maxRadius = (min(width, height) / 2).floor();
              radius = radius > maxRadius ? maxRadius : radius;


              context.beginPath();
              context.moveTo(rx, ry + radius);
              context.lineTo(rx, ry + height - radius);
              context.quadraticCurveTo(rx, ry + height, rx + radius, ry + height);
              context.lineTo(rx + width - radius, ry + height);
              context.quadraticCurveTo(rx + width, ry + height, rx + width, ry + height - radius);
              context.lineTo(rx + width, ry + radius);
              context.quadraticCurveTo(rx + width, ry, rx + width - radius, ry);
              context.lineTo(rx + radius, ry);
              context.quadraticCurveTo(rx, ry, rx, ry + radius);
              context.closePath();


              if (data.fill) {
                context.globalAlpha = data.fillAlpha * worldAlpha;
                context.fillStyle = color = '#' + "${data.fillColor.floor().toRadixString(16)}".padLeft(6, '0');
                context.fill();


              }
              if (data.lineWidth != 0) {
                context.globalAlpha = data.lineAlpha * worldAlpha;
                context.stroke();
              }
            }

    }
  }


  static renderGraphicsMask(Graphics graphics, CanvasRenderingContext2D context) {
    var len = graphics._graphicsData.length;

    if (len == 0) return;

    if (len > 1) {
      len = 1;
      window.console.log('Pixi.js warning: masks in canvas can only mask using the first path in the graphics object');
    }

    for (var i = 0; i < 1; i++) {
      var data = graphics._graphicsData[i];
      var points = data.points;

      if (data.type == Graphics.POLY) {
        context.beginPath();
        context.moveTo(points[0], points[1]);

        for (var j = 1; j < points.length / 2; j++) {
          context.lineTo(points[j * 2], points[j * 2 + 1]);
        }

        // if the first and last point are the same close the path - much neater :)
        if (points[0] == points[points.length - 2] && points[1] == points[points.length - 1]) {
          context.closePath();
        }

      }
      else if (data.type == Graphics.RECT) {
        context.beginPath();
        context.rect(points[0], points[1], points[2], points[3]);
        context.closePath();
      }
      else if (data.type == Graphics.CIRC) {
          // TODO - need to be Undefined!
          context.beginPath();
          context.arc(points[0], points[1], points[2], 0, 2 * PI);
          context.closePath();
        }
        else if (data.type == Graphics.ELIP) {

            // ellipse code taken from: http://stackoverflow.com/questions/2172798/how-to-draw-an-oval-in-html5-canvas
            var ellipseData = data.points;

            var w = ellipseData[2] * 2;
            var h = ellipseData[3] * 2;

            var x = ellipseData[0] - w / 2;
            var y = ellipseData[1] - h / 2;

            context.beginPath();

            var kappa = 0.5522848,
            ox = (w / 2) * kappa, // control point offset horizontal
            oy = (h / 2) * kappa, // control point offset vertical
            xe = x + w, // x-end
            ye = y + h, // y-end
            xm = x + w / 2, // x-middle
            ym = y + h / 2; // y-middle

            context.moveTo(x, ym);
            context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
            context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
            context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
            context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
            context.closePath();
          }
          else if (data.type == Graphics.RREC) {
              num rx = points[0];
              num ry = points[1];
              num width = points[2];
              num height = points[3];
              num radius = points[4];


              num maxRadius = (min(width, height) / 2 ).floor();
              radius = radius > maxRadius ? maxRadius : radius;


              context.beginPath();
              context.moveTo(rx, ry + radius);
              context.lineTo(rx, ry + height - radius);
              context.quadraticCurveTo(rx, ry + height, rx + radius, ry + height);
              context.lineTo(rx + width - radius, ry + height);
              context.quadraticCurveTo(rx + width, ry + height, rx + width, ry + height - radius);
              context.lineTo(rx + width, ry + radius);
              context.quadraticCurveTo(rx + width, ry, rx + width - radius, ry);
              context.lineTo(rx + radius, ry);
              context.quadraticCurveTo(rx, ry, rx, ry + radius);
              context.closePath();
            }

    }
  }

}
