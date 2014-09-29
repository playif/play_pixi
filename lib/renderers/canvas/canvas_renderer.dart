part of PIXI;

class CanvasRenderer extends Renderer {

  bool clearBeforeRender = true;
  bool roundPixels = false;
  CanvasRenderingContext2D context;
  bool refresh = true;
  int count = 0;

  CanvasRenderer([num width=800, num height=600, CanvasElement view, bool transparent=false, bool antialias=false]) {
    defaultRenderer = this;
//    this.width=width;
//    this.height=height;
    type = CANVAS_RENDERER;
    this.width = width.toInt();
    this.height = height.toInt();
    this.transparent = transparent;
    this.antialias = antialias;

    if (view == null) {
      view = new CanvasElement();
    }
    //print(view);

    this.view = view;
    this.view.width = this.width.toInt();
    this.view.height = this.height.toInt();

    if (blendModesCanvas == null) {
      //TODO improve the performance
      blendModesCanvas = {
      };

      if (canUseNewCanvasBlendModes()) {
        blendModesCanvas[BlendModes.NORMAL] = "source-over";
        blendModesCanvas[BlendModes.ADD] = "lighter"; //IS THIS OK???
        blendModesCanvas[BlendModes.MULTIPLY] = "multiply";
        blendModesCanvas[BlendModes.SCREEN] = "screen";
        blendModesCanvas[BlendModes.OVERLAY] = "overlay";
        blendModesCanvas[BlendModes.DARKEN] = "darken";
        blendModesCanvas[BlendModes.LIGHTEN] = "lighten";
        blendModesCanvas[BlendModes.COLOR_DODGE] = "color-dodge";
        blendModesCanvas[BlendModes.COLOR_BURN] = "color-burn";
        blendModesCanvas[BlendModes.HARD_LIGHT] = "hard-light";
        blendModesCanvas[BlendModes.SOFT_LIGHT] = "soft-light";
        blendModesCanvas[BlendModes.DIFFERENCE] = "difference";
        blendModesCanvas[BlendModes.EXCLUSION] = "exclusion";
        blendModesCanvas[BlendModes.HUE] = "hue";
        blendModesCanvas[BlendModes.SATURATION] = "saturation";
        blendModesCanvas[BlendModes.COLOR] = "color";
        blendModesCanvas[BlendModes.LUMINOSITY] = "luminosity";
      }
      else {
        // this means that the browser does not support the cool new blend modes in canvas "cough" ie "cough"
        blendModesCanvas[BlendModes.NORMAL] = "source-over";
        blendModesCanvas[BlendModes.ADD] = "lighter"; //IS THIS OK???
        blendModesCanvas[BlendModes.MULTIPLY] = "source-over";
        blendModesCanvas[BlendModes.SCREEN] = "source-over";
        blendModesCanvas[BlendModes.OVERLAY] = "source-over";
        blendModesCanvas[BlendModes.DARKEN] = "source-over";
        blendModesCanvas[BlendModes.LIGHTEN] = "source-over";
        blendModesCanvas[BlendModes.COLOR_DODGE] = "source-over";
        blendModesCanvas[BlendModes.COLOR_BURN] = "source-over";
        blendModesCanvas[BlendModes.HARD_LIGHT] = "source-over";
        blendModesCanvas[BlendModes.SOFT_LIGHT] = "source-over";
        blendModesCanvas[BlendModes.DIFFERENCE] = "source-over";
        blendModesCanvas[BlendModes.EXCLUSION] = "source-over";
        blendModesCanvas[BlendModes.HUE] = "source-over";
        blendModesCanvas[BlendModes.SATURATION] = "source-over";
        blendModesCanvas[BlendModes.COLOR] = "source-over";
        blendModesCanvas[BlendModes.LUMINOSITY] = "source-over";
      }
    }


    this.context = this.view.getContext("2d", {
        'alpha': this.transparent
    });


    // hack to enable some hardware acceleration!
    //this.view.style["transform"] = "translatez(0)";


    /**
     * Instance of a PIXI.CanvasMaskManager, handles masking when using the canvas renderer
     * @property CanvasMaskManager
     * @type CanvasMaskManager
     */
    this.maskManager = new CanvasMaskManager();

    /**
     * The render session is just a bunch of parameter used for rendering
     * @property renderSession
     * @type Object
     */
    this.renderSession = new RenderSession()
      ..context = this.context
      ..maskManager = this.maskManager
      ..scaleMode = null
      ..smoothProperty = null;

//    if (context.imageSmoothingEnabled)
//      this.renderSession.smoothProperty = "imageSmoothingEnabled";
//    else if(context.webkitImageSmoothingEnabled)
//      this.renderSession.smoothProperty = "webkitImageSmoothingEnabled";
//    else if("mozImageSmoothingEnabled" in this.context)
//        this.renderSession.smoothProperty = "mozImageSmoothingEnabled";
//      else if("oImageSmoothingEnabled" in this.context)
//          this.renderSession.smoothProperty = "oImageSmoothingEnabled";
  }


  render(Stage stage) {
    // update textures if need be
    texturesToUpdate.length = 0;
    texturesToDestroy.length = 0;

    stage.updateTransform();

    this.context.setTransform(1, 0, 0, 1, 0, 0);
    this.context.globalAlpha = 1;

    //TODO
//    if (navigator.isCocoonJS && this.view.screencanvas) {
//      this.context.fillStyle = "black";
//      this.context.clear();
//    }


    if (!this.transparent && this.clearBeforeRender) {
      this.context.fillStyle = stage.backgroundColorString;
      this.context.fillRect(0, 0, this.width, this.height);
    }
    else if (this.transparent && this.clearBeforeRender) {
      this.context.clearRect(0, 0, this.width, this.height);
    }

    this.renderDisplayObject(stage);

    // run interaction!
    if (stage.interactive) {
      //need to add some events!
      if (!stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = true;
        stage.interactionManager.setTarget(this);
      }
    }

    // remove frame updates..
    if (Texture.frameUpdates.length > 0) {
      Texture.frameUpdates.length = 0;
    }
  }

  resize(num width, num height) {
    this.width = width.toInt();
    this.height = height.toInt();

    this.view.width = width.toInt();
    this.view.height = height.toInt();
  }

  renderDisplayObject(DisplayInterface displayObject, [CanvasRenderingContext2D context, buffer]) {
    // no longer recursive!
    //var transform;
    //var context = this.context;

    this.renderSession.context = context == null ? this.context : context;
    displayObject._renderCanvas(this.renderSession);
  }

  renderStripFlat(strip) {
    CanvasRenderingContext2D context = this.context;
    var verticies = strip.verticies;

    var length = verticies.length / 2;
    this.count++;

    context.beginPath();
    for (var i = 1; i < length - 2; i++) {
      // draw some triangles!
      var index = i * 2;

      var x0 = verticies[index], x1 = verticies[index + 2], x2 = verticies[index + 4];
      var y0 = verticies[index + 1], y1 = verticies[index + 3], y2 = verticies[index + 5];

      context.moveTo(x0, y0);
      context.lineTo(x1, y1);
      context.lineTo(x2, y2);
    }

    context.fillStyle = "#FF0000";
    context.fill();
    context.closePath();
  }

  renderStrip(strip) {
    var context = this.context;

    // draw triangles!!
    var verticies = strip.verticies;
    var uvs = strip.uvs;

    var length = verticies.length / 2;
    this.count++;

    for (var i = 1; i < length - 2; i++) {
      // draw some triangles!
      var index = i * 2;

      var x0 = verticies[index], x1 = verticies[index + 2], x2 = verticies[index + 4];
      var y0 = verticies[index + 1], y1 = verticies[index + 3], y2 = verticies[index + 5];

      var u0 = uvs[index] * strip.texture.width, u1 = uvs[index + 2] * strip.texture.width, u2 = uvs[index + 4] * strip.texture.width;
      var v0 = uvs[index + 1] * strip.texture.height, v1 = uvs[index + 3] * strip.texture.height, v2 = uvs[index + 5] * strip.texture.height;

      context.save();
      context.beginPath();
      context.moveTo(x0, y0);
      context.lineTo(x1, y1);
      context.lineTo(x2, y2);
      context.closePath();

      context.clip();

      // Compute matrix transform
      var delta = u0 * v1 + v0 * u2 + u1 * v2 - v1 * u2 - v0 * u1 - u0 * v2;
      var deltaA = x0 * v1 + v0 * x2 + x1 * v2 - v1 * x2 - v0 * x1 - x0 * v2;
      var deltaB = u0 * x1 + x0 * u2 + u1 * x2 - x1 * u2 - x0 * u1 - u0 * x2;
      var deltaC = u0 * v1 * x2 + v0 * x1 * u2 + x0 * u1 * v2 - x0 * v1 * u2 - v0 * u1 * x2 - u0 * x1 * v2;
      var deltaD = y0 * v1 + v0 * y2 + y1 * v2 - v1 * y2 - v0 * y1 - y0 * v2;
      var deltaE = u0 * y1 + y0 * u2 + u1 * y2 - y1 * u2 - y0 * u1 - u0 * y2;
      var deltaF = u0 * v1 * y2 + v0 * y1 * u2 + y0 * u1 * v2 - y0 * v1 * u2 - v0 * u1 * y2 - u0 * y1 * v2;

      context.transform(deltaA / delta, deltaD / delta,
      deltaB / delta, deltaE / delta,
      deltaC / delta, deltaF / delta);

      context.drawImage(strip.texture.baseTexture.source, 0, 0);
      context.restore();
    }
  }


}

class CanvasBuffer {
  num width, height;
  CanvasElement canvas;
  CanvasRenderingContext2D context;

  CanvasBuffer(this.width, this.height) {

    this.canvas = document.createElement("canvas");
    this.canvas.width = width.toInt();
    this.canvas.height = height.toInt();
    this.context = this.canvas.getContext("2d");

  }

  clear() {
    this.context.clearRect(0, 0, this.width, this.height);
  }

  resize(num width, num height) {
    this.width = this.canvas.width = width;
    this.height = this.canvas.height = height;
  }
}
