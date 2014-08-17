part of PIXI;

/**
 * @author Mat Groves http://matgroves.com/
 */

/**
 * The [SpriteBatch] class is a really fast version of the [DisplayObjectContainer]
 * built solely for speed, so use when you need a lot of sprites or particles.
 *     And it's extremely easy to use : 
 *
 *     var container = new PIXI.SpriteBatch();
 *     stage.addChild(container);
 *     for(var i  = 0; i < 100; i++)
 *     {
 *        var sprite = new PIXI.Sprite.fromImage("myImage.png");
 *        container.addChild(sprite);
 *     }
 *
 * And here you have a hundred sprites that will be renderer at the speed of light
 */
class SpriteBatch extends DisplayObjectContainer {
  RenderTexture textureThing;
  bool _ready = false;
  WebGLFastSpriteBatch fastSpriteBatch;

  SpriteBatch([this.textureThing]) {
  }

  /// Initialises the spriteBatch
  _initWebGL(gl) {
    // TODO only one needed for the whole engine really?
    this.fastSpriteBatch = new WebGLFastSpriteBatch(gl);
    this._ready = true;
  }

  /// Updates the object transform for rendering
  updateTransform() {
    // TODO dont need to!
    super.updateTransform();
    //  PIXI.DisplayObjectContainer.prototype.updateTransform.call( this );
  }

  /// Renders the object using the WebGL renderer
  void _renderWebGL(RenderSession renderSession) {
    if (!this.visible || this.alpha <= 0 || this.children.length == 0)return;

    if (!this._ready) this._initWebGL(renderSession.gl);

    renderSession.spriteBatch.stop();

    renderSession.shaderManager.setShader(renderSession.shaderManager.fastShader);

    this.fastSpriteBatch.begin(this, renderSession);
    this.fastSpriteBatch.render(this);

    //renderSession.shaderManager.activateShader(renderSession.shaderManager.defaultShader);

    renderSession.spriteBatch.start();

  }


  /// Renders the object using the Canvas renderer
  void _renderCanvas(renderSession) {
    CanvasRenderingContext2D context = renderSession._context;
    context.globalAlpha = this._worldAlpha;

    super.updateTransform();

    Matrix transform = this._worldTransform;
    // alow for trimming

    bool isRotated = true;

    for (int i = 0; i < this.children.length; i++) {

      Sprite child = this.children[i];

      if (!child.visible)continue;

      Texture texture = child.texture;
      Rectangle frame = texture.frame;

      context.globalAlpha = this._worldAlpha * child.alpha;

      if (child.rotation % (PI * 2) == 0) {
        if (isRotated) {
          context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
          isRotated = false;
        }

        // this is the fastest  way to optimise! - if rotation is 0 then we can avoid any kind of setTransform call
        context.drawImageScaledFromSource(texture.baseTexture.source,
        frame.x,
        frame.y,
        frame.width,
        frame.height,
        ((child.anchor.x) * (-frame.width * child.scale.x) + child.position.x + 0.5).floor(),
        ((child.anchor.y) * (-frame.height * child.scale.y) + child.position.y + 0.5).floor(),
        frame.width * child.scale.x,
        frame.height * child.scale.y);
      }
      else {
        if (!isRotated) isRotated = true;

        child.updateTransform();

        var childTransform = child._worldTransform;

        // allow for trimming

        if (renderSession.roundPixels) {
          context.setTransform(childTransform.a, childTransform.c, childTransform.b, childTransform.d, childTransform.tx.floor(), childTransform.ty.floor());
        }
        else {
          context.setTransform(childTransform.a, childTransform.c, childTransform.b, childTransform.d, childTransform.tx, childTransform.ty);
        }

        context.drawImageScaledFromSource(texture.baseTexture.source,
        frame.x,
        frame.y,
        frame.width,
        frame.height,
        ((child.anchor.x) * (-frame.width) + 0.5),
        ((child.anchor.y) * (-frame.height) + 0.5),
        frame.width,
        frame.height);


      }

      // context.restore();
    }

//    context.restore();
  }
}
