part of PIXI;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The Sprite object is the base for all textured objects that are rendered to the screen
 *
 *     A sprite can be created directly from an image like this : 
 *     var sprite = new PIXI.Sprite.fromImage('assets/image.png');
 *     yourStage.addChild(sprite);
 *     then obviously don't forget to add it to the stage you have already created
 */
class Sprite extends DisplayObjectContainer {
  /**
   * The anchor sets the origin point of the texture.
   *     The default is 0,0 this means the texture's origin is the top left
   *     Setting than anchor to 0.5,0.5 means the textures origin is centred
   *     Setting the anchor to 1,1 would mean the textures origin points will be the bottom right corner
   */
  Point anchor = new Point();

  /// The texture that the sprite is using
  Texture texture;

  /// The width of the sprite (this is initially set by the texture)
  bool updateFrame = false;


  /// The width of the sprite (this is initially set by the texture)
  num _width = 0;

  /// The height of the sprite (this is initially set by the texture)
  num _height = 0;


  TextureUvs _uvs = null;
  CanvasImageSource tintedTexture;
  CanvasBuffer buffer = null;

  /// The width of the sprite, setting this will actually modify the scale to achieve the value set
  num get width => scale.x * texture.frame.width;

  set width(num value) {
    this.scale.x = value / this.texture.frame.width;
    this._width = value;
  }

  /// The height of the sprite, setting this will actually modify the scale to achieve the value set
  num get height => scale.y * texture.frame.height;

  set height(num value) {
    this.scale.y = value / this.texture.frame.height;
    this._height = value;
  }

  /// The tint applied to the sprite. This is a hex value
  int tint = 0xFFFFFF;


  int cachedTint;

  //  bool renderable = true;

  /// The blend mode to be applied to the sprite
  BlendModes blendMode = BlendModes.NORMAL;


  Sprite._() {
    renderable = true;
  }

  Sprite(Texture texture) {
    this.texture = texture;
    _setupTexture();
  }

  void _setupTexture() {
    if (texture.baseTexture.hasLoaded) {
      this._onTextureUpdate(null);
    } else {
      this.texture.addEventListener('update', this._onTextureUpdate);
    }
  }

  /// Sets the texture of the sprite
  void setTexture(Texture texture) {
    // stop current texture;
    //    if (this.texture.baseTexture != texture.baseTexture) {
    //      this.textureChange = true;
    //      this.texture = texture;
    //    }
    //    else {
    //      this.texture = texture;
    //    }
    this.texture = texture;
    this.cachedTint = 0xFFFFFF;
    //this.updateFrame = true;
  }

  /// When the texture is updated, this event will fire to update the scale and frame
  _onTextureUpdate(PixiEvent e) {
    //print('update');
    // so if _width is 0 then width was not set..
    if (this._width != 0) this.scale.x = this._width / this.texture.frame.width;
    if (this._height != 0) this.scale.y = this._height / this.texture.frame.height;


    //this.updateFrame = true;
  }

  /// Returns the framing rectangle of the sprite as a [Rectangle] object
  Rectangle getBounds([Matrix matrix]) {

    num width = this.texture.frame.width;
    num height = this.texture.frame.height;

    num w0 = width * (1 - this.anchor.x);
    num w1 = width * -this.anchor.x;

    num h0 = height * (1 - this.anchor.y);
    num h1 = height * -this.anchor.y;

    Matrix worldTransform = (matrix == null) ? this._worldTransform : matrix;

    double a = worldTransform.a;
    double b = worldTransform.c;
    double c = worldTransform.b;
    double d = worldTransform.d;
    double tx = worldTransform.tx;
    double ty = worldTransform.ty;

    double x1 = a * w1 + c * h1 + tx;
    double y1 = d * h1 + b * w1 + ty;

    double x2 = a * w0 + c * h1 + tx;
    double y2 = d * h1 + b * w0 + ty;

    double x3 = a * w0 + c * h0 + tx;
    double y3 = d * h0 + b * w0 + ty;

    double x4 = a * w1 + c * h0 + tx;
    double y4 = d * h0 + b * w1 + ty;

    double maxX = double.NEGATIVE_INFINITY;
    double maxY = double.NEGATIVE_INFINITY;

    double minX = double.INFINITY;
    double minY = double.INFINITY;

    minX = x1 < minX ? x1 : minX;
    minX = x2 < minX ? x2 : minX;
    minX = x3 < minX ? x3 : minX;
    minX = x4 < minX ? x4 : minX;

    minY = y1 < minY ? y1 : minY;
    minY = y2 < minY ? y2 : minY;
    minY = y3 < minY ? y3 : minY;
    minY = y4 < minY ? y4 : minY;

    maxX = x1 > maxX ? x1 : maxX;
    maxX = x2 > maxX ? x2 : maxX;
    maxX = x3 > maxX ? x3 : maxX;
    maxX = x4 > maxX ? x4 : maxX;

    maxY = y1 > maxY ? y1 : maxY;
    maxY = y2 > maxY ? y2 : maxY;
    maxY = y3 > maxY ? y3 : maxY;
    maxY = y4 > maxY ? y4 : maxY;


    Rectangle bounds = this._bounds;

    bounds.x = minX;
    bounds.width = maxX - minX;

    bounds.y = minY;
    bounds.height = maxY - minY;

    // store a reference so that if this function gets called again in the render cycle we do not have to recalculate
    this._currentBounds = bounds;

    return bounds;
  }


  /// Renders the object using the WebGL renderer
  void _renderWebGL(RenderSession renderSession) {

    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (!this.visible || this.alpha <= 0) return;

    int i, j;

    // do a quick check to see if this element has a mask or a filter.
    if (this._mask != null || this._filters != null) {
      WebGLSpriteBatch spriteBatch = renderSession.spriteBatch;

      if (this._filters != null) {
        //print("cool");
        spriteBatch.flush();
        renderSession.filterManager.pushFilter(this._filterBlock);
      }

      if (this._mask != null) {
        spriteBatch.stop();
        renderSession.maskManager.pushMask(this._mask, renderSession);
        spriteBatch.start();
      }


      // add this sprite to the batch
      spriteBatch.render(this);

      // now loop through the children and make sure they get rendered
      for (int i = 0,
          j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }

      // time to stop the sprite batch as either a mask element or a filter draw will happen next
      spriteBatch.stop();


      if (this._mask != null) renderSession.maskManager.popMask(this._mask, renderSession);
      if (this._filters != null) renderSession.filterManager.popFilter();

      spriteBatch.start();
    } else {

      renderSession.spriteBatch.render(this);

      // simple render children!
      for (int i = 0,
          j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }
    }


    //TODO check culling
  }


  /// Renders the object using the Canvas renderer
  void _renderCanvas(RenderSession renderSession) {
    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (this.visible == false || this.alpha == 0) return;


    //    Rectangle frame = this.texture.frame;
    //    CanvasRenderingContext2D context = renderSession.context;
    //    Texture texture = this.texture;

    if (this.blendMode != renderSession.currentBlendMode) {
      renderSession.currentBlendMode = this.blendMode;
      //context.globalCompositeOperation = blendModesCanvas[renderSession.currentBlendMode];
      renderSession.context.globalCompositeOperation = blendModesCanvas[renderSession.currentBlendMode];
    }

    if (this._mask != null) {
      renderSession.maskManager.pushMask(this._mask, renderSession.context);
    }


    //ignore null sources
    //    if (frame != null && frame.width != 0 && frame.height != 0 && texture.baseTexture.source != null) {
    if (this.texture.valid) {
      renderSession.context.globalAlpha = this._worldAlpha;

      //Matrix transform = this.worldTransform;

      // allow for trimming
      if (renderSession.roundPixels != null) {
        //context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx.floor(), transform.ty.floor());
        renderSession.context.setTransform(this._worldTransform.a, this._worldTransform.c, this._worldTransform.b, this._worldTransform.d, this._worldTransform.tx.floor(), this._worldTransform.ty.floor());
      } else {
        //context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
        renderSession.context.setTransform(this._worldTransform.a, this._worldTransform.c, this._worldTransform.b, this._worldTransform.d, this._worldTransform.tx == null ? 0 : this._worldTransform.tx, this._worldTransform.ty == null ? 0 : this._worldTransform.ty);
      }


      //if smoothingEnabled is supported and we need to change the smoothing property for this texture
      if (renderSession.scaleMode != this.texture.baseTexture.scaleMode) {
        renderSession.scaleMode = this.texture.baseTexture.scaleMode;
        renderSession.context.imageSmoothingEnabled = (renderSession.scaleMode == scaleModes.LINEAR);
      }

      num dx = (this.texture.trim != null) ? this.texture.trim.x - this.anchor.x * this.texture.trim.width : this.anchor.x * -this.texture.frame.width;
      num dy = (this.texture.trim != null) ? this.texture.trim.y - this.anchor.y * this.texture.trim.height : this.anchor.y * -this.texture.frame.height;


      if (this.tint != 0xFFFFFF) {

        if (this.cachedTint != this.tint) {
          this.cachedTint = this.tint;

          //TODO clean up caching - how to clean up the caches?
          this.tintedTexture = CanvasTinter.getTintedTexture(this, this.tint);

        }

        renderSession.context.drawImageScaledFromSource(this.tintedTexture, 0, 0, this.texture.crop.width, this.texture.crop.height, dx, dy, this.texture.crop.width, this.texture.crop.height);
      } else {


        //        if (texture.trim != null) {
        //          Rectangle trim = texture.trim;
        //
        //          context.drawImageScaledFromSource(this.texture.baseTexture.source,
        //          frame.x,
        //          frame.y,
        //          frame.width,
        //          frame.height,
        //          trim.x - this.anchor.x * trim.width,
        //          trim.y - this.anchor.y * trim.height,
        //          frame.width,
        //          frame.height);
        //        }
        //        else {
        //          //window.console.log(this.texture.baseTexture.source);
        //          context.drawImageScaledFromSource(this.texture.baseTexture.source,
        //          frame.x,
        //          frame.y,
        //          frame.width,
        //          frame.height,
        //          (this.anchor.x) * -frame.width,
        //          (this.anchor.y) * -frame.height,
        //          frame.width,
        //          frame.height);
        //        }
        renderSession.context.drawImageScaledFromSource(this.texture.baseTexture.source, this.texture.crop.x, this.texture.crop.y, this.texture.crop.width, this.texture.crop.height, dx, dy, this.texture.crop.width, this.texture.crop.height);

      }
    }

    // OVERWRITE
    for (int i = 0,
        j = this.children.length; i < j; i++) {
      this.children[i]._renderCanvas(renderSession);
    }

    if (this._mask != null) {
      renderSession.maskManager.popMask(renderSession.context);
    }
  }

  /**
   * Helper function that creates a sprite that will contain a texture from the TextureCache based on the frameId
   * The frame ids are created when a Texture packer file has been loaded
   */
  static Sprite fromFrame(String frameId) {
    var texture = TextureCache[frameId];
    if (texture == null) throw new Exception('The frameId "$frameId" does not exist in the texture cache.');
    return new Sprite(texture);
  }

  /**
   * Helper function that creates a sprite that will contain a texture based on an image url
   * If the image is not in the texture cache it will be loaded
   */
  static Sprite fromImage(String imageId, [bool crossorigin, scaleModes scaleMode]) {
    Texture texture = Texture.fromImage(imageId, crossorigin, scaleMode);
    return new Sprite(texture);
  }

}
