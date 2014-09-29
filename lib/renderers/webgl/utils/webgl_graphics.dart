part of PIXI;


class WebGLGraphicsData {
  RenderingContext gl;
  List<num> color;
  List<num> points;
  List<num> indices;
  int lastIndex;
  Buffer buffer;
  Buffer indexBuffer;
  int mode;
  num alpha;
  bool dirty;

  Float32List glPoints;
  Uint16List glIndicies;
  List<WebGLGraphicsData> data;

  WebGLGraphicsData(this.gl) {
    //TODO does this need to be split before uploding??
    this.color = [0, 0, 0]; // color split!
    this.points = [];
    this.indices = [];
    this.lastIndex = 0;
    this.buffer = gl.createBuffer();
    this.indexBuffer = gl.createBuffer();
    this.mode = 1;
    this.alpha = 1;
    this.dirty = true;
  }


  reset() {
    this.points = [];
    this.indices = [];
    this.lastIndex = 0;
  }

  upload() {
    var gl = this.gl;


//    this.lastIndex = graphics.graphicsData.length;
    this.glPoints = new Float32List.fromList(this.points.map((s) => s.toDouble()).toList());


    gl.bindBuffer(ARRAY_BUFFER, this.buffer);
    gl.bufferData(ARRAY_BUFFER, this.glPoints, STATIC_DRAW);


    this.glIndicies = new Uint16List.fromList(this.indices.map((num s) => s.toInt()).toList());


    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, this.glIndicies, STATIC_DRAW);


    this.dirty = false;
  }


}

//class WebGLData {
//  List<num> points = [];
//  List<num> indices = [];
//  int lastIndex = 0;
//  Buffer buffer;
//  Buffer indexBuffer;
//
//  num alpha;
//  List<num> color;
//
//  List<WebGLGraphicsData> data;
//  RenderingContext gl;
//
//  Float32List glPoints;
//  Uint16List glIndicies;
//}

class WebGLGraphics {
  static List<WebGLGraphicsData> graphicsDataPool = [];
  static int last;

  WebGLGraphics() {
  }

  static renderGraphics(Graphics graphics, RenderSession renderSession) {
    var gl = renderSession.gl;
    var projection = renderSession.projection,
    offset = renderSession.offset,
//    shader = renderSession.shaderManager.primitiveShader;
//
//    if (graphics._webGL[gl] == null)graphics._webGL[gl] = new WebGLData()
//      ..points = []
//      ..indices = []
//      ..lastIndex = 0
//      ..buffer = gl.createBuffer()
//      ..indexBuffer = gl.createBuffer();
//
//    WebGLData webGL = graphics._webGL[gl];
    shader = renderSession.shaderManager.primitiveShader,
    webGLData;

    if (graphics._dirty) {
//      graphics.dirty = false;
//
//      if (graphics.clearDirty) {
//        graphics.clearDirty = false;
//
//        webGL.lastIndex = 0;
//        webGL.points = [];
//        webGL.indices = [];
//
//      }

      WebGLGraphics.updateGraphics(graphics, gl);
      //window.console.log(webGL);
    }

    //renderSession.shaderManager.activatePrimitiveShader();
    WebGLGraphicsData webGL = graphics._webGL[gl];
    // This  could be speeded up for sure!


    // set the matrix transform
    //gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);
    for (var i = 0; i < webGL.data.length; i++) {
      if (webGL.data[i].mode == 1) {
        WebGLGraphicsData webGLData = webGL.data[i];

        // gl.uniformMatrix3fv(shader.translationMatrix, false, graphics.worldTransform.toArray(true));
        renderSession.stencilManager.pushStencil(graphics, webGLData, renderSession);

        //gl.uniform2f(shader.projectionVector, projection.x, -projection.y);
        //gl.uniform2f(shader.offsetVector, -offset.x, -offset.y);
        gl.drawElements(TRIANGLE_FAN, 4, UNSIGNED_SHORT, ( webGLData.indices.length - 4 ) * 2);

        renderSession.stencilManager.popStencil(graphics, webGLData, renderSession);

        last = webGLData.mode;
      }
      else {
        WebGLGraphicsData webGLData = webGL.data[i];


//print(shader.translationMatrix);
        List<num> colorList = hex2rgb(graphics.tint);
        Float32List tintColor = new Float32List(3);
        tintColor[0] = colorList[0];
        tintColor[1] = colorList[1];
        tintColor[2] = colorList[2];
        //gl.uniform3fv(shader.tintColor, tintColor);
        renderSession.shaderManager.setShader(shader);//activatePrimitiveShader();
        shader = renderSession.shaderManager.primitiveShader;
        gl.uniformMatrix3fv(shader.translationMatrix, false, graphics._worldTransform.toArray(true));


        //gl.uniform1f(shader.alpha, graphics.worldAlpha);
        //gl.bindBuffer(ARRAY_BUFFER, webGL.buffer);
        gl.uniform2f(shader.projectionVector, projection.x, -projection.y);
        gl.uniform2f(shader.offsetVector, -offset.x, -offset.y);


        //gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 4 * 6, 0);
        //gl.vertexAttribPointer(shader.colorAttribute, 4, FLOAT, false, 4 * 6, 2 * 4);
        gl.uniform3fv(shader.tintColor, tintColor);

        // set the index buffer!
        //gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGL.indexBuffer);
        gl.uniform1f(shader.alpha, graphics._worldAlpha);

        //gl.drawElements(TRIANGLE_STRIP, webGL.indices.length, UNSIGNED_SHORT, 0);
        gl.bindBuffer(ARRAY_BUFFER, webGLData.buffer);

        //renderSession.shaderManager.deactivatePrimitiveShader();
        gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 4 * 6, 0);
        gl.vertexAttribPointer(shader.colorAttribute, 4, FLOAT, false, 4 * 6, 2 * 4);
// set the index buffer!
        gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGLData.indexBuffer);
        gl.drawElements(TRIANGLE_STRIP, webGLData.indices.length, UNSIGNED_SHORT, 0);
      }
    }


// return to default shader...
//  PIXI.activateShader(PIXI.defaultShader);
  }

  static updateGraphics(Graphics graphics, RenderingContext gl) {
    WebGLGraphicsData webGL = graphics._webGL[gl];
    if (webGL == null)webGL = graphics._webGL[gl] = new WebGLGraphicsData(gl)
      ..lastIndex = 0
      ..data = []
      ..gl = gl;


    // flag the graphics as not dirty as we are about to update it...
    graphics._dirty = false;


    var i;


    // if the user cleared the graphics object we will need to clear every object
    if (graphics.clearDirty) {
      graphics.clearDirty = false;


      // lop through and return all the webGLDatas to the object pool so than can be reused later on
      for (i = 0; i < webGL.data.length; i++) {
        WebGLGraphicsData graphicsData = webGL.data[i];
        graphicsData.reset();
        WebGLGraphics.graphicsDataPool.add(graphicsData);
      }


      // clear the array and reset the index..
      webGL.data = [];
      webGL.lastIndex = 0;
    }


    WebGLGraphicsData webGLData;


    for (int i = webGL.lastIndex; i < graphics._graphicsData.length; i++) {
      GraphicsData data = graphics._graphicsData[i];

      if (data.type == Graphics.POLY) {

        if (data.fill) {
          if (data.points.length > 6) {
            if (data.points.length > 5 * 2) {
              webGLData = WebGLGraphics.switchMode(webGL, 1);
              WebGLGraphics.buildComplexPoly(data, webGLData);
            }
            else {
              webGLData = WebGLGraphics.switchMode(webGL, 0);
              WebGLGraphics.buildPoly(data, webGLData);
            }
          }
        }

        if (data.lineWidth > 0) {
          webGLData = WebGLGraphics.switchMode(webGL, 0);
          WebGLGraphics.buildLine(data, webGLData);

          //WebGLGraphics.buildLine(data, webGL);
        }
      }
//      else if (data.type == Graphics.RECT) {
//        WebGLGraphics.buildRectangle(data, webGL);
//      }
//      else if (data.type == Graphics.CIRC || data.type == Graphics.ELIP) {
//          WebGLGraphics.buildCircle(data, webGL);
//        }
      else {
        webGLData = WebGLGraphics.switchMode(webGL, 0);

        if (data.type == Graphics.RECT) {
          WebGLGraphics.buildRectangle(data, webGLData);
        }
        else if (data.type == Graphics.CIRC || data.type == Graphics.ELIP) {
          WebGLGraphics.buildCircle(data, webGLData);
        }
        else if (data.type == Graphics.RREC) {
            WebGLGraphics.buildRoundedRectangle(data, webGLData);
          }

      }


      webGL.lastIndex++;
      // upload all the dirty data...

    }

    for (i = 0; i < webGL.data.length; i++) {
      webGLData = webGL.data[i];
      if (webGLData.dirty) webGLData.upload();
    }
//    webGL.glPoints = new Float32List(webGL.points.length);
//    for (int i = 0;i < webGL.points.length;i++) {
//      webGL.glPoints[i] = webGL.points[i].toDouble();
//    }
//
//    gl.bindBuffer(ARRAY_BUFFER, webGL.buffer);
//    gl.bufferData(ARRAY_BUFFER, webGL.glPoints, STATIC_DRAW);
//
//    webGL.glIndicies = new Uint16List(webGL.indices.length);
//    for (int i = 0;i < webGL.indices.length;i++) {
//      webGL.glIndicies[i] = webGL.indices[i].toInt();
//    }
//
//    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGL.indexBuffer);
//    gl.bufferData(ELEMENT_ARRAY_BUFFER, webGL.glIndicies, STATIC_DRAW);
  }

  static WebGLGraphicsData switchMode(WebGLGraphicsData webGL, int type) {
    WebGLGraphicsData webGLData;


    if (webGL.data.length == 0) {
      if (WebGLGraphics.graphicsDataPool.length > 0) {
        webGLData = WebGLGraphics.graphicsDataPool.removeLast();
      }
      if (webGLData == null) {
        webGLData = new WebGLGraphicsData(webGL.gl);
      }
      //webGLData = WebGLGraphics.graphicsDataPool.pop() || new PIXI.WebGLGraphicsData(webGL.gl);
      webGLData.mode = type;
      webGL.data.add(webGLData);
    }
    else {
      webGLData = webGL.data[webGL.data.length - 1];


      if (webGLData.mode != type || type == 1) {
        if (WebGLGraphics.graphicsDataPool.length > 0) {
          webGLData = WebGLGraphics.graphicsDataPool.removeLast();
        }
        else {
          webGLData = new WebGLGraphicsData(webGL.gl);
        }
        //webGLData = WebGLGraphics.graphicsDataPool.pop() || new PIXI.WebGLGraphicsData(webGL.gl);
        webGLData.mode = type;
        webGL.data.add(webGLData);
      }
    }


    webGLData.dirty = true;


    return webGLData;
  }


  static buildRectangle(GraphicsData graphicsData, WebGLGraphicsData webGLData) {

    // --- //
    // need to convert points to a nice regular data
    //
    var rectData = graphicsData.points;
    var x = rectData[0];
    var y = rectData[1];
    var width = rectData[2];
    var height = rectData[3];


    if (graphicsData.fill) {
      List<num> color = hex2rgb(graphicsData.fillColor);
      num alpha = graphicsData.fillAlpha;

      num r = color[0] * alpha;
      num g = color[1] * alpha;
      num b = color[2] * alpha;

      List verts = webGLData.points;
      List indices = webGLData.indices;

      var vertPos = verts.length / 6;

      // start
      verts.addAll([x, y]);
      verts.addAll([r, g, b, alpha]);

      verts.addAll([x + width, y]);
      verts.addAll([r, g, b, alpha]);

      verts.addAll([x, y + height]);
      verts.addAll([r, g, b, alpha]);

      verts.addAll([x + width, y + height]);
      verts.addAll([r, g, b, alpha]);

      // insert 2 dead triangles..
      indices.addAll([vertPos, vertPos, vertPos + 1, vertPos + 2, vertPos + 3, vertPos + 3]);
    }

    if (graphicsData.lineWidth != 0) {
      var tempPoints = graphicsData.points;

      graphicsData.points = [x, y,
      x + width, y,
      x + width, y + height,
      x, y + height,
      x, y];


      WebGLGraphics.buildLine(graphicsData, webGLData);

      graphicsData.points = tempPoints;
    }
  }


  /**
   * Calcul the points for a quadratic bezier curve.
   * Based on : https://stackoverflow.com/questions/785097/how-do-i-implement-a-bezier-curve-in-c
   *
   * @param  {number}   fromX Origin point x
   * @param  {number}   fromY Origin point x
   * @param  {number}   cpX   Control point x
   * @param  {number}   cpY   Control point y
   * @param  {number}   toX   Destination point x
   * @param  {number}   toY   Destination point y
   * @return {number[]}
   */
  static List<num> quadraticBezierCurve(num fromX, num fromY, num cpX, num cpY, num toX, num toY) {
    num xa,
    ya,
    xb,
    yb,
    x,
    y,
    n = 20;
    List<num> points = [];


    num getPt(num n1, num n2, num perc) {
      num diff = n2 - n1;
      return n1 + ( diff * perc );
    }


    num j = 0;
    for (int i = 0; i <= n; i++) {
      j = i / n;


      // The Green Line
      xa = getPt(fromX, cpX, j);
      ya = getPt(fromY, cpY, j);
      xb = getPt(cpX, toX, j);
      yb = getPt(cpY, toY, j);


      // The Black Dot
      x = getPt(xa, xb, j);
      y = getPt(ya, yb, j);


      points.addAll([x, y]);
    }
    return points;
  }

  static buildRoundedRectangle(GraphicsData graphicsData, WebGLGraphicsData webGLData) {



    List<num> points = graphicsData.points;
    num x = points[0];
    num y = points[1];
    num width = points[2];
    num height = points[3];
    num radius = points[4];


    List recPoints = [];
    recPoints.addAll([x, y + radius]);
    recPoints.addAll(quadraticBezierCurve(x, y + height - radius, x, y + height, x + radius, y + height));
    recPoints.addAll(quadraticBezierCurve(x + width - radius, y + height, x + width, y + height, x + width, y + height - radius));
    recPoints.addAll(quadraticBezierCurve(x + width, y + radius, x + width, y, x + width - radius, y));
    recPoints.addAll(quadraticBezierCurve(x + radius, y, x, y, x, y + radius));


    if (graphicsData.fill) {
      List<num> color = hex2rgb(graphicsData.fillColor);
      num alpha = graphicsData.fillAlpha;


      num r = color[0] * alpha;
      num g = color[1] * alpha;
      num b = color[2] * alpha;


      List<num> verts = webGLData.points;
      List<num> indices = webGLData.indices;


      var vecPos = verts.length / 6;


      List<num> triangles = PolyK.Triangulate(recPoints);


      int i = 0;
      for (i = 0; i < triangles.length; i += 3) {
        indices.add(triangles[i] + vecPos);
        indices.add(triangles[i] + vecPos);
        indices.add(triangles[i + 1] + vecPos);
        indices.add(triangles[i + 2] + vecPos);
        indices.add(triangles[i + 2] + vecPos);
      }


      for (i = 0; i < recPoints.length; i++) {
        verts.addAll([recPoints[i], recPoints[++i], r, g, b, alpha]);
      }
    }


    if (graphicsData.lineWidth != 0) {
      List<num> tempPoints = graphicsData.points;


      graphicsData.points = recPoints;


      WebGLGraphics.buildLine(graphicsData, webGLData);


      graphicsData.points = tempPoints;
    }
  }


  static buildCircle(GraphicsData graphicsData, WebGLGraphicsData webGLData) {

    // need to convert points to a nice regular data
    var rectData = graphicsData.points;
    var x = rectData[0];
    var y = rectData[1];
    var width = rectData[2];
    var height = rectData[3];

    var totalSegs = 40;
    var seg = (PI * 2) / totalSegs ;

    var i = 0;

    if (graphicsData.fill) {
      List<num> color = hex2rgb(graphicsData.fillColor);
      num alpha = graphicsData.fillAlpha;

      num r = color[0] * alpha;
      num g = color[1] * alpha;
      num b = color[2] * alpha;

      List verts = webGLData.points;
      List indices = webGLData.indices;

      var vecPos = verts.length / 6;

      indices.add(vecPos);

      for (i = 0; i < totalSegs + 1 ; i++) {
        verts.addAll([x, y, r, g, b, alpha]);

        verts.addAll([x + sin(seg * i) * width,
        y + cos(seg * i) * height,
        r, g, b, alpha]);

        indices.addAll([vecPos++, vecPos++]);
      }

      indices.add(vecPos - 1);
    }

    if (graphicsData.lineWidth != 0) {
      var tempPoints = graphicsData.points;

      graphicsData.points = [];

      for (i = 0; i < totalSegs + 1; i++) {
        graphicsData.points.addAll([
            x + sin(seg * i) * width,
            y + cos(seg * i) * height
        ]);
      }

      WebGLGraphics.buildLine(graphicsData, webGLData);

      graphicsData.points = tempPoints;
    }
  }

  static buildLine(GraphicsData graphicsData, WebGLGraphicsData webGLData) {
    // TODO OPTIMISE!
    int i = 0;

    List points = graphicsData.points;
    if (points.length < 4) return;


    // if the line width is an odd number add 0.5 to align to a whole pixel
//    if (graphicsData.lineWidth>1 && graphicsData.lineWidth % 2 != 0) {
//      for (i = 0; i < points.length; i++) {
//        points[i] += 0.5;
//      }
//    }


    // get first and last point.. figure out the middle!
    Point firstPoint = new Point(points[0], points[1]);
    Point lastPoint = new Point(points[points.length - 2], points[points.length - 1]);

    // if the first point is the last point - gonna have issues :)
    if (firstPoint.x == lastPoint.x && firstPoint.y == lastPoint.y) {
      points = new List.from(points);
      points.removeLast();
      points.removeLast();

      lastPoint = new Point(points[points.length - 2], points[points.length - 1]);

      num midPointX = lastPoint.x + (firstPoint.x - lastPoint.x) * 0.5;
      num midPointY = lastPoint.y + (firstPoint.y - lastPoint.y) * 0.5;

      points.insertAll(0, [midPointX, midPointY]);
      points.addAll([midPointX, midPointY]);
    }

    List verts = webGLData.points;
    List indices = webGLData.indices;
    int length = points.length ~/ 2;
    int indexCount = points.length;
    int indexStart = verts.length ~/ 6;

    // DRAW the Line
    num width = graphicsData.lineWidth / 2;

    // sort color
    List<num> color = hex2rgb(graphicsData.lineColor);
    num alpha = graphicsData.lineAlpha;
    num r = color[0] * alpha;
    num g = color[1] * alpha;
    num b = color[2] * alpha;

    num px, py, p1x, p1y, p2x, p2y, p3x, p3y;
    num perpx, perpy, perp2x, perp2y, perp3x, perp3y;
    num a1, b1, c1, a2, b2, c2;
    num denom, pdist, dist;

    p1x = points[0];
    p1y = points[1];

    p2x = points[2];
    p2y = points[3];

    perpx = -(p1y - p2y);
    perpy = p1x - p2x;

    dist = sqrt(perpx * perpx + perpy * perpy);

    perpx /= dist;
    perpy /= dist;
    perpx *= width;
    perpy *= width;

    // start
    verts.addAll([p1x - perpx, p1y - perpy,
    r, g, b, alpha]);


    verts.addAll([p1x + perpx, p1y + perpy,
    r, g, b, alpha]);

    for (i = 1; i < length - 1; i++) {
      p1x = points[(i - 1) * 2];
      p1y = points[(i - 1) * 2 + 1];

      p2x = points[(i) * 2];
      p2y = points[(i) * 2 + 1];

      p3x = points[(i + 1) * 2];
      p3y = points[(i + 1) * 2 + 1];

      perpx = -(p1y - p2y);
      perpy = p1x - p2x;

      dist = sqrt(perpx * perpx + perpy * perpy);
      perpx /= dist;
      perpy /= dist;
      perpx *= width;
      perpy *= width;

      perp2x = -(p2y - p3y);
      perp2y = p2x - p3x;

      dist = sqrt(perp2x * perp2x + perp2y * perp2y);
      perp2x /= dist;
      perp2y /= dist;
      perp2x *= width;
      perp2y *= width;

      a1 = (-perpy + p1y) - (-perpy + p2y);
      b1 = (-perpx + p2x) - (-perpx + p1x);
      c1 = (-perpx + p1x) * (-perpy + p2y) - (-perpx + p2x) * (-perpy + p1y);
      a2 = (-perp2y + p3y) - (-perp2y + p2y);
      b2 = (-perp2x + p2x) - (-perp2x + p3x);
      c2 = (-perp2x + p3x) * (-perp2y + p2y) - (-perp2x + p2x) * (-perp2y + p3y);

      denom = a1 * b2 - a2 * b1;

      if ((denom < 0 ? -denom : denom) < 0.1) {

        denom += 10.1;
        verts.addAll([p2x - perpx, p2y - perpy,
        r, g, b, alpha]);

        verts.addAll([p2x + perpx, p2y + perpy,
        r, g, b, alpha]);

        continue;
      }

      px = (b1 * c2 - b2 * c1) / denom;
      py = (a2 * c1 - a1 * c2) / denom;


      pdist = (px - p2x) * (px - p2x) + (py - p2y) + (py - p2y);


      if (pdist > 140 * 140) {
        perp3x = perpx - perp2x;
        perp3y = perpy - perp2y;

        dist = sqrt(perp3x * perp3x + perp3y * perp3y);
        perp3x /= dist;
        perp3y /= dist;
        perp3x *= width;
        perp3y *= width;

        verts.addAll([p2x - perp3x, p2y - perp3y]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x + perp3x, p2y + perp3y]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x - perp3x, p2y - perp3y]);
        verts.addAll([r, g, b, alpha]);

        indexCount++;
      }
      else {

        verts.addAll([px, py]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x - (px - p2x), p2y - (py - p2y)]);
        verts.addAll([r, g, b, alpha]);
      }
    }

    //print((length - 2) * 2);
    p1x = points[(length - 2) * 2];
    p1y = points[(length - 2) * 2 + 1];

    p2x = points[(length - 1) * 2];
    p2y = points[(length - 1) * 2 + 1];

    perpx = -(p1y - p2y);
    perpy = p1x - p2x;

    dist = sqrt(perpx * perpx + perpy * perpy);
    perpx /= dist;
    perpy /= dist;
    perpx *= width;
    perpy *= width;

    verts.addAll([p2x - perpx, p2y - perpy]);
    verts.addAll([r, g, b, alpha]);

    verts.addAll([p2x + perpx, p2y + perpy]);
    verts.addAll([r, g, b, alpha]);
//    print(verts);
    indices.add(indexStart);

    for (i = 0; i < indexCount; i++) {
      indices.add(indexStart++);
    }

    indices.add(indexStart - 1);
  }

  static buildComplexPoly(GraphicsData graphicsData, WebGLGraphicsData webGLData) {


    //TODO - no need to copy this as it gets turned into a FLoat32Array anyways..
    List<num> points = new List.from(graphicsData.points);
    if (points.length < 6)return;


    // get first and last point.. figure out the middle!
    List<num> indices = webGLData.indices;
    webGLData.points = points;
    webGLData.alpha = graphicsData.fillAlpha;
    webGLData.color = hex2rgb(graphicsData.fillColor);


    /*
        calclate the bounds..
    */
    var minX = double.INFINITY;
    var maxX = double.NEGATIVE_INFINITY;


    var minY = double.INFINITY;
    var maxY = double.NEGATIVE_INFINITY;


    num x, y;


    // get size..
    for (int i = 0; i < points.length; i += 2) {
      x = points[i];
      y = points[i + 1];


      minX = x < minX ? x : minX;
      maxX = x > maxX ? x : maxX;


      minY = y < minY ? y : minY;
      maxY = y > maxY ? y : maxY;
    }


    // add a quad to the end cos there is no point making another buffer!
    points.addAll([minX, minY,
    maxX, minY,
    maxX, maxY,
    minX, maxY]);


    // push a quad onto the end..

    //TODO - this aint needed!
    int length = points.length ~/ 2;
    for (int i = 0; i < length; i++) {
      indices.add(i);
    }


  }


  static buildPoly(GraphicsData graphicsData, WebGLGraphicsData webGLData) {
    var points = graphicsData.points;

    if (points.length < 6) return;

    // get first and last point.. figure out the middle!
    List verts = webGLData.points;
    List indices = webGLData.indices;

    var length = points.length / 2;

    // sort color
    List<num> color = hex2rgb(graphicsData.fillColor);
    num alpha = graphicsData.fillAlpha;
    num r = color[0] * alpha;
    num g = color[1] * alpha;
    num b = color[2] * alpha;

    var triangles = PolyK.Triangulate(points);

    var vertPos = verts.length / 6;

    var i = 0;

    for (i = 0; i < triangles.length; i += 3) {
      indices.add(triangles[i] + vertPos);
      indices.add(triangles[i] + vertPos);
      indices.add(triangles[i + 1] + vertPos);
      indices.add(triangles[i + 2] + vertPos);
      indices.add(triangles[i + 2] + vertPos);
    }

    for (i = 0; i < length; i++) {
      verts.addAll([
          points[i * 2],
          points[i * 2 + 1],
          r, g, b, alpha
      ]);
    }
  }
}
