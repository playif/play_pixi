part of PIXI;

typedef void Render(DisplayInterface displayObject, Point position, [bool clear]);

class RenderTexture extends Texture {
  Renderer renderer;
  int width, height;
  Rectangle frame;
  scaleModes scaleMode;

  BaseTexture baseTexture = new BaseTexture();

  var textureBuffer;
  Point projection;

  Render render;

  static Matrix tempMatrix = new Matrix();

  bool valid;

  RenderTexture([num this.width = 100, num this.height = 100, this.renderer, scaleModes this.scaleMode = scaleModes.DEFAULT]) : super._() {
    if (renderer == null) {
      renderer = defaultRenderer;
    }
    frame = new Rectangle(0, 0, this.width, this.height);
    crop = new Rectangle(0, 0, this.width, this.height);

    baseTexture.width = width;
    baseTexture.height = height;
    baseTexture.scaleMode = scaleMode;
    baseTexture.hasLoaded = true;
    //baseTexture._glTextures = {};

    //print(this.renderer.type);
    if (this.renderer.type == WEBGL_RENDERER) {
//print("here");
      var gl = this.renderer.gl;

      this.textureBuffer = new FilterTexture(gl, this.width, this.height, this.baseTexture.scaleMode);
      this.baseTexture._glTextures[gl] = this.textureBuffer.texture;

      this.render = this.renderWebGL;
      this.projection = new Point(this.width / 2, -this.height / 2);
    } else {
      this.render = this.renderCanvas;
      this.textureBuffer = new CanvasBuffer(this.width, this.height);
      this.baseTexture.source = this.textureBuffer._canvas;
    }


    this.valid = true;
    Texture.frameUpdates.add(this);


  }

  clear() {
    if (this.renderer.type == WEBGL_RENDERER) {
      this.renderer.gl.bindFramebuffer(FRAMEBUFFER, this.textureBuffer.frameBuffer);
    }

    this.textureBuffer.clear();
  }

  resize(num width, num height, [bool updateBase = false]) {
    width = width.toInt();
    height = height.toInt();
    
    if (width == this.width && height == this.height) {
      return;
    }
    //print("here");
    this.width = this.frame.width = width;
    this.height = this.frame.height = height;

    if (updateBase) {
      this.baseTexture.width = this.width;
      this.baseTexture.height = this.height;
    }

    if (this.renderer.type == WEBGL_RENDERER) {
      this.projection.x = this.width / 2;
      this.projection.y = -this.height / 2;

//      var gl = this.renderer.gl;
//      gl.bindTexture(TEXTURE_2D, this.baseTexture._glTextures[gl]);
//      gl.texImage2D(TEXTURE_2D, 0, RGBA, this.width, this.height, 0, RGBA, UNSIGNED_BYTE, null);
    }
//    else {
//
//    }
    this.textureBuffer.resize(this.width, this.height);
    //Texture.frameUpdates.add(this);
  }

  renderWebGL(DisplayObjectContainer displayObject, Point position, [bool clear = false]) {
    //TOOD replace position with matrix..
    var gl = this.renderer.gl;

    gl.colorMask(true, true, true, true);

    gl.viewport(0, 0, this.width, this.height);

    gl.bindFramebuffer(FRAMEBUFFER, this.textureBuffer.frameBuffer);

    if (clear) this.textureBuffer.clear();

    // THIS WILL MESS WITH HIT TESTING!
    List<DisplayInterface> children = displayObject.children;

    //TODO -? create a new one??? dont think so!
    Matrix originalWorldTransform = displayObject._worldTransform;
    displayObject._worldTransform = RenderTexture.tempMatrix;
    // modify to flip...
    displayObject._worldTransform.d = -1.0;
    displayObject._worldTransform.ty = this.projection.y * -2.0;

    if (position != null) {
      displayObject._worldTransform.tx = position.x.toDouble();
      displayObject._worldTransform.ty -= position.y.toDouble();
    }

    for (int i = 0,
        j = children.length; i < j; i++) {
      children[i].updateTransform();
    }

    // update the textures!
    WebGLRenderer.updateTextures(gl);

    this.renderer.spriteBatch.dirty = true;
    //
    this.renderer.renderDisplayObject(displayObject, this.projection, this.textureBuffer.frameBuffer);

    displayObject._worldTransform = originalWorldTransform;

    this.renderer.spriteBatch.dirty = true;
  }

  void renderCanvas(DisplayObjectContainer displayObject, Point position, [bool clear = false]) {
    var children = displayObject.children;

    var originalWorldTransform = displayObject._worldTransform;

    displayObject._worldTransform = RenderTexture.tempMatrix;

    if (position != null) {
      displayObject._worldTransform.tx = position.x;
      displayObject._worldTransform.ty = position.y;
    } else {
      displayObject._worldTransform.tx = 0.0;
      displayObject._worldTransform.ty = 0.0;
    }


    for (var i = 0,
        j = children.length; i < j; i++) {
      children[i].updateTransform();
    }

    if (clear) this.textureBuffer.clear();

    var context = this.textureBuffer._context;

    this.renderer.renderDisplayObject(displayObject, context);

    context.setTransform(1, 0, 0, 1, 0, 0);

    displayObject._worldTransform = originalWorldTransform;
  }

}
