part of PIXI;

Map glContexts = {};

class WebGLRenderer extends Renderer {
  static int glContextId = 0;
  int glId = 0;
  //num width, height;
  bool transparent;
  bool antialias;

  WebGLRenderer([int width=800, int height=600, CanvasElement view, this.transparent=false, this.antialias=false]) {
    if (defaultRenderer == null) defaultRenderer = this;
    type = WEBGL_RENDERER;
    this.width = width;
    this.height = height;

    if (view == null) {
      view = new CanvasElement();
    }
    //print(view);

    this.view=view;
    this.view.width = this.width;
    this.view.height = this.height;


    // deal with losing context..
    //this.contextLost = this.handleContextLost.bind(this);
    //this.contextRestoredLost = this.handleContextRestored.bind(this);

    this.view.addEventListener('webglcontextlost', this.handleContextLost, false);
    this.view.addEventListener('webglcontextrestored', this.handleContextRestored, false);

    this.options = {
        'alpha': this.transparent,
        'antialias':this.antialias, // SPEED UP??
        'premultipliedAlpha':transparent,
        'stencil':true
    };

    //try 'experimental-webgl'
    try {
      this.gl = this.view.getContext('experimental-webgl', this.options);
      //window.console.log(this.view.getContext('experimental-webgl', this.options));
    } catch (e) {
      //try 'webgl'
      try {
        this.gl = this.view.getContext('webgl', this.options);
      } catch (e2) {
        // fail, not able to get a context
        throw new Exception(' This browser does not support webGL. Try using the canvas renderer $this');
      }
    }

    var gl = this.gl;
    this.glId  = WebGLRenderer.glContextId ++;

    glContexts[this.glId] = gl;
    //window.console.log(gl);

    if (blendModesWebGL == null) {
      blendModesWebGL = {};

      blendModesWebGL[blendModes.NORMAL] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.ADD] = [RenderingContext.SRC_ALPHA, RenderingContext.DST_ALPHA];
      blendModesWebGL[blendModes.MULTIPLY] = [RenderingContext.DST_COLOR, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.SCREEN] = [RenderingContext.SRC_ALPHA, RenderingContext.ONE];
      blendModesWebGL[blendModes.OVERLAY] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.DARKEN] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.LIGHTEN] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.COLOR_DODGE] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.COLOR_BURN] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.HARD_LIGHT] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.SOFT_LIGHT] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.DIFFERENCE] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.EXCLUSION] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.HUE] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.SATURATION] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.COLOR] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.LUMINOSITY] = [RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA];
    }


    this.projection = new Point();
    this.projection.x = this.width / 2;
    this.projection.y = -this.height / 2;

    this.offset = new Point(0, 0);

    this.resize(this.width, this.height);
    this.contextLost = false;

    // time to create the render managers! each one focuses on managine a state in webGL
    this.shaderManager = new WebGLShaderManager(gl); // deals with managing the shader programs and their attribs
    this.spriteBatch = new WebGLSpriteBatch(gl); // manages the rendering of sprites
    this.maskManager = new WebGLMaskManager(gl); // manages the masks using the stencil buffer
    this.filterManager = new WebGLFilterManager(gl, this.transparent); // manages the filters

    this.renderSession = new RenderSession();
    this.renderSession.gl = this.gl;
    this.renderSession.drawCount = 0;
    this.renderSession.shaderManager = this.shaderManager;
    this.renderSession.maskManager = this.maskManager;
    this.renderSession.filterManager = this.filterManager;
    this.renderSession.spriteBatch = this.spriteBatch;
    this.renderSession.renderer = this;

    gl.useProgram(this.shaderManager.defaultShader.program);

    gl.disable(RenderingContext.DEPTH_TEST);
    gl.disable(RenderingContext.CULL_FACE);

    gl.enable(RenderingContext.BLEND);
    gl.colorMask(true, true, true, this.transparent);
  }

  render(Stage stage) {
    if (this.contextLost) return;
    //window.console.log(stage.children[0]);

    // if rendering a new stage clear the batches..
    if (this.__stage != stage) {
      if (stage.interactive)stage.interactionManager.removeEvents();

      // TODO make this work
      // dont think this is needed any more?
      this.__stage = stage;
    }

    // update any textures this includes uvs and uploading them to the gpu
    WebGLRenderer.updateTextures();

    // update the scene graph
    stage.updateTransform();


    // interaction
    if (stage._interactive) {
      //need to add some events!
      if (!stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = true;
        stage.interactionManager.setTarget(this);
      }
    }

    var gl = this.gl;

    // -- Does this need to be set every frame? -- //
    //gl.colorMask(true, true, true, this.transparent);
    gl.viewport(0, 0, this.width, this.height);

    // make sure we are bound to the main frame buffer
    gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, null);

    if (this.transparent) {
      gl.clearColor(0, 0, 0, 0);
    }
    else {
      gl.clearColor(stage.backgroundColorSplit[0], stage.backgroundColorSplit[1], stage.backgroundColorSplit[2], 1);
    }


    gl.clear(RenderingContext.COLOR_BUFFER_BIT);

    this.renderDisplayObject(stage, this.projection);

    // interaction
    if (stage.interactive) {
      //need to add some events!
      if (!stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = true;
        stage.interactionManager.setTarget(this);
      }
    }
    else {
      if (stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = false;
        stage.interactionManager.setTarget(this);
      }
    }

    /*
    //can simulate context loss in Chrome like so:
     this.view.onmousedown = function(ev) {
     console.dir(this.gl.getSupportedExtensions());
        var ext = (
            gl.getExtension("WEBGL_scompressed_texture_s3tc")
       // gl.getExtension("WEBGL_compressed_texture_s3tc") ||
       // gl.getExtension("MOZ_WEBGL_compressed_texture_s3tc") ||
       // gl.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc")
     );
     console.dir(ext);
     var loseCtx = this.gl.getExtension("WEBGL_lose_context");
      console.log("killing context");
      loseCtx.loseContext();
     setTimeout(function() {
          console.log("restoring context...");
          loseCtx.restoreContext();
      }.bind(this), 1000);
     }.bind(this);
     */
  }


  renderDisplayObject(DisplayObject displayObject, Point projection, [buffer]) {
    // reset the render session data..
    this.renderSession.drawCount = 0;
    this.renderSession.currentBlendMode = 9999;

    this.renderSession.projection = projection;
    this.renderSession.offset = this.offset;



    // start the sprite batch
    this.spriteBatch.begin(this.renderSession);

    // start the filter manager
    this.filterManager.begin(this.renderSession, buffer);

    // render the scene!
    displayObject._renderWebGL(this.renderSession);

    // finish the sprite batch
    this.spriteBatch.end();
  }


  static void updateTextures() {
    var i = 0;

    //TODO break this out into a texture manager...
    //for (i = 0; i < PIXI.texturesToUpdate.length; i++)
    //    PIXI.WebGLRenderer.updateTexture(PIXI.texturesToUpdate[i]);


    for (i = 0; i < Texture.frameUpdates.length; i++)
      WebGLRenderer.updateTextureFrame(Texture.frameUpdates[i]);

    for (i = 0; i < texturesToDestroy.length; i++)
      WebGLRenderer.destroyTexture(texturesToDestroy[i]);

    texturesToUpdate.length = 0;
    texturesToDestroy.length = 0;
    Texture.frameUpdates.length = 0;
  }


  static destroyTexture(Texture texture) {
    //TODO break this out into a texture manager...

    for (int i = texture._glTextures.length - 1; i >= 0; i--) {
      var glTexture = texture._glTextures[i];
      var gl = glContexts[i];

      if (gl && glTexture) {
        gl.deleteTexture(glTexture);
      }
    }

    texture._glTextures.length = 0;
  }

  static updateTextureFrame(Texture texture) {
    texture.updateFrame = false;

    // now set the uvs. Figured that the uv data sits with a texture rather than a sprite.
    // so uv data is stored on the texture itself
    texture._updateWebGLuvs();
  }

  resize(width, height) {
    this.width = width;
    this.height = height;

    this.view.width = width;
    this.view.height = height;

    this.gl.viewport(0, 0, this.width, this.height);

    this.projection.x = this.width / 2;
    this.projection.y = -this.height / 2;
  }

  handleContextLost(event) {
    event.preventDefault();
    this.contextLost = true;
  }

  handleContextRestored() {

    //try 'experimental-webgl'
    try {
      this.gl = this.view.getContext('experimental-webgl', this.options);
    } catch (e) {
      //try 'webgl'
      try {
        this.gl = this.view.getContext('webgl', this.options);
      } catch (e2) {
        // fail, not able to get a context
        throw new Exception(' This browser does not support webGL. Try using the canvas renderer this');
      }
    }

    var gl = this.gl;
    gl.id = WebGLRenderer.glContextId ++;


    // need to set the context...
    this.shaderManager.setContext(gl);
    this.spriteBatch.setContext(gl);
    this.maskManager.setContext(gl);
    this.filterManager.setContext(gl);


    this.renderSession.gl = this.gl;

    gl.disable(gl.DEPTH_TEST);
    gl.disable(gl.CULL_FACE);

    gl.enable(gl.BLEND);
    gl.colorMask(true, true, true, this.transparent);

    this.gl.viewport(0, 0, this.width, this.height);

    for (var key in TextureCache) {
      var texture = TextureCache[key].baseTexture;
      texture._glTextures = [];
    }

    /**
     * Whether the context was lost
     * @property contextLost
     * @type Boolean
     */
    this.contextLost = false;

  }

  void destroy() {

    // deal with losing context..

    // remove listeners
    this.view.removeEventListener('webglcontextlost', this.handleContextLost);
    this.view.removeEventListener('webglcontextrestored', this.handleContextRestored);

    glContexts[this.glContextId] = null;

    this.projection = null;
    this.offset = null;

    // time to create the render managers! each one focuses on managine a state in webGL
    this.shaderManager.destroy();
    this.spriteBatch.destroy();
    this.maskManager.destroy();
    this.filterManager.destroy();

    this.shaderManager = null;
    this.spriteBatch = null;
    this.maskManager = null;
    this.filterManager = null;

    this.gl = null;
    //
    this.renderSession = null;
  }

}

createWebGLTexture(texture, gl) {


  if (texture.hasLoaded) {
    texture._glTextures[gl.id] = gl.createTexture();

    gl.bindTexture(gl.TEXTURE_2D, texture._glTextures[gl.id]);
    gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);

    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.source);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, texture.scaleMode == scaleModes.LINEAR ? gl.LINEAR : gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, texture.scaleMode == scaleModes.LINEAR ? gl.LINEAR : gl.NEAREST);

    // reguler...

    if (!texture._powerOf2) {
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    }
    else {
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    }

    gl.bindTexture(gl.TEXTURE_2D, null);
  }

  return texture._glTextures[gl.id];
}

updateWebGLTexture(texture, gl) {
  if (texture._glTextures[gl.id]) {
    gl.bindTexture(gl.TEXTURE_2D, texture._glTextures[gl.id]);
    gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);

    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.source);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, texture.scaleMode == scaleModes.LINEAR ? gl.LINEAR : gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, texture.scaleMode == scaleModes.LINEAR ? gl.LINEAR : gl.NEAREST);

    // reguler...

    if (!texture._powerOf2) {
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    }
    else {
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    }

    gl.bindTexture(gl.TEXTURE_2D, null);
  }

}