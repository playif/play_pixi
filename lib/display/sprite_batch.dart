part of PIXI;

class SpriteBatch extends DisplayObjectContainer {
  RenderTexture textureThing;
  bool ready=false;
  WebGLFastSpriteBatch fastSpriteBatch;
  SpriteBatch(this.textureThing) {
  }

  initWebGL(gl)
  {
    // TODO only one needed for the whole engine really?
    this.fastSpriteBatch = new WebGLFastSpriteBatch(gl);

    this.ready = true;
  }

  updateTransform()
  {
    // TODO dont need to!
    DisplayObject.updateTransform.call( this );
    //  PIXI.DisplayObjectContainer.prototype.updateTransform.call( this );
  }

  void _renderWebGL(renderSession)
  {
    if(!this.visible || this.alpha <= 0 || !this.children.length)return;

    if(!this.ready)this.initWebGL( renderSession.gl );

    renderSession.spriteBatch.stop();

    renderSession.shaderManager.activateShader(renderSession.shaderManager.fastShader);

    this.fastSpriteBatch.begin(this, renderSession);
    this.fastSpriteBatch.render(this);

    renderSession.shaderManager.activateShader(renderSession.shaderManager.defaultShader);

    renderSession.spriteBatch.start();

  }


  void _renderCanvas (renderSession)
  {
    var context = renderSession.context;
    context.globalAlpha = this.worldAlpha;

    DisplayObject.updateTransform.call(this);

    var transform = this.worldTransform;
    // alow for trimming

    var isRotated = true;

    for (var i = 0; i < this.children.length; i++) {

      var child = this.children[i];

      if(!child.visible)continue;

      var texture = child.texture;
      var frame = texture.frame;

      context.globalAlpha = this.worldAlpha * child.alpha;

      if(child.rotation % (PI * 2) == 0)
      {
        if(isRotated)
        {
          context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
          isRotated = false;
        }

        // this is the fastest  way to optimise! - if rotation is 0 then we can avoid any kind of setTransform call
        context.drawImage(texture.baseTexture.source,
        frame.x,
        frame.y,
        frame.width,
        frame.height,
        ((child.anchor.x) * (-frame.width * child.scale.x) + child.position.x  + 0.5) | 0,
        ((child.anchor.y) * (-frame.height * child.scale.y) + child.position.y  + 0.5) | 0,
        frame.width * child.scale.x,
        frame.height * child.scale.y);
      }
      else
      {
        if(!isRotated)isRotated = true;

        DisplayObject.updateTransform.call(child);

        var childTransform = child.worldTransform;

        // allow for trimming

        if (renderSession.roundPixels)
        {
          context.setTransform(childTransform.a, childTransform.c, childTransform.b, childTransform.d, childTransform.tx | 0, childTransform.ty | 0);
        }
        else
        {
          context.setTransform(childTransform.a, childTransform.c, childTransform.b, childTransform.d, childTransform.tx, childTransform.ty);
        }

        context.drawImage(texture.baseTexture.source,
        frame.x,
        frame.y,
        frame.width,
        frame.height,
        ((child.anchor.x) * (-frame.width) + 0.5) | 0,
        ((child.anchor.y) * (-frame.height) + 0.5) | 0,
        frame.width,
        frame.height);


      }

      // context.restore();
    }

//    context.restore();
  }
}
