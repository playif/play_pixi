part of PIXI;

class Strip extends DisplayObjectContainer {
  Texture texture;

  BlendModes blendMode = BlendModes.NORMAL;
  Float32List uvs;
  Float32List verticies;
  Float32List colors;
  Uint16List indices;

  bool updateFrame = false;

  Buffer _vertexBuffer;
  Buffer _indexBuffer;
  Buffer _uvBuffer;
  Buffer _colorBuffer;

  int count = 0;

//  num tint=0xFFFFFF;

  Strip(Texture texture) {
    this.texture = texture;
    this.uvs = new Float32List.fromList([0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0]);
    this.verticies = new Float32List.fromList([0.0, 0.0, 100.0, 0.0, 100.0, 100.0, 0.0, 100.0]);
    this.colors = new Float32List.fromList([1.0, 1.0, 1.0, 1.0]);
    this.indices = new Uint16List.fromList([0, 1, 2, 3]);
    this._dirty = true;
//    // load the texture!
//    if (texture.baseTexture.hasLoaded) {
//      this.width = this.texture.frame.width;
//      this.height = this.texture.frame.height;
//      this.updateFrame = true;
//    }
//    else {
//      //this.onTextureUpdateBind = this.onTextureUpdate.bind(this);
//      this.texture.addEventListener('update', onTextureUpdate);
//    }
//
//    this.renderable = true;
  }

//  setTexture(Texture texture) {
//    //TODO SET THE TEXTURES
//    //TODO VISIBILITY
//    this.texture = texture;
//    this.width = texture.frame.width;
//    this.height = texture.frame.height;
//    this.updateFrame = true;
//  }

  onTextureUpdate(e) {
    this.updateFrame = true;
  }

  _renderWebGL(RenderSession renderSession) {

    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (!this.visible || this.alpha <= 0)return;
    // render triangle strip..

    renderSession.spriteBatch.stop();

    // init! init!
    if (this._vertexBuffer == null)this._initWebGL(renderSession);

    renderSession.shaderManager.setShader(renderSession.shaderManager.stripShader);
    //renderSession.spriteBatch.render(this);
    this._renderStrip(renderSession);

    ///renderSession.shaderManager.activateDefaultShader();

    renderSession.spriteBatch.start();

    //TODO check culling
  }

  _initWebGL(RenderSession renderSession) {
    // build the strip!
    var gl = renderSession.gl;

    this._vertexBuffer = gl.createBuffer();
    this._indexBuffer = gl.createBuffer();
    this._uvBuffer = gl.createBuffer();
    this._colorBuffer = gl.createBuffer();


    gl.bindBuffer(ARRAY_BUFFER, this._vertexBuffer);
    gl.bufferData(ARRAY_BUFFER, this.verticies, DYNAMIC_DRAW);

    gl.bindBuffer(ARRAY_BUFFER, this._uvBuffer);
    gl.bufferData(ARRAY_BUFFER, this.uvs, STATIC_DRAW);

    gl.bindBuffer(ARRAY_BUFFER, this._colorBuffer);
    gl.bufferData(ARRAY_BUFFER, this.colors, STATIC_DRAW);

    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this._indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, this.indices, STATIC_DRAW);
  }

  _renderStrip(RenderSession renderSession) {
    var gl = renderSession.gl;
    Point projection = renderSession.projection,
    offset = renderSession.offset;
    Shader shader = renderSession.shaderManager.stripShader;


    // gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mat4Real);
    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);
    // set uniforms
    gl.uniformMatrix3fv(shader.translationMatrix, false, this._worldTransform.toArray(true));
    gl.uniform2f(shader.projectionVector, projection.x, -projection.y);
    gl.uniform2f(shader.offsetVector, -offset.x, -offset.y);
    gl.uniform1f(shader.alpha, 1.0);

    if (!this._dirty) {
      gl.bindBuffer(ARRAY_BUFFER, this._vertexBuffer);
      gl.bufferSubData(ARRAY_BUFFER, 0, this.verticies);
      gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 0, 0);

      // update the uvs
      gl.bindBuffer(ARRAY_BUFFER, this._uvBuffer);
      gl.vertexAttribPointer(shader.aTextureCoord, 2, FLOAT, false, 0, 0);

      gl.activeTexture(TEXTURE0);
      // bind the current texture
      gl.bindTexture(TEXTURE_2D, this.texture.baseTexture._glTextures[gl] == null ?
      createWebGLTexture(this.texture.baseTexture, gl) :
      this.texture.baseTexture._glTextures[gl]);

      // dont need to upload!
      gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this._indexBuffer);


    }
    else {
      this._dirty = false;
      gl.bindBuffer(ARRAY_BUFFER, this._vertexBuffer);
      gl.bufferData(ARRAY_BUFFER, this.verticies, STATIC_DRAW);
      gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 0, 0);

      // update the uvs
      gl.bindBuffer(ARRAY_BUFFER, this._uvBuffer);
      gl.bufferData(ARRAY_BUFFER, this.uvs, STATIC_DRAW);
      gl.vertexAttribPointer(shader.aTextureCoord, 2, FLOAT, false, 0, 0);

      gl.activeTexture(TEXTURE0);
      gl.bindTexture(TEXTURE_2D,
      this.texture.baseTexture._glTextures[gl] == null ?
      createWebGLTexture(this.texture.baseTexture, gl) :
      this.texture.baseTexture._glTextures[gl]);

      // dont need to upload!
      gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this._indexBuffer);
      gl.bufferData(ELEMENT_ARRAY_BUFFER, this.indices, STATIC_DRAW);

    }
    //console.log(gl.TRIANGLE_STRIP)
    //
    //
    gl.drawElements(TRIANGLE_STRIP, this.indices.length, UNSIGNED_SHORT, 0);


  }


  _renderCanvas(RenderSession renderSession) {
    var context = renderSession.context;

    var transform = this._worldTransform;

    if (renderSession.roundPixels) {
      context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx.floor(), transform.ty.floor());
    }
    else {
      context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
    }

    var strip = this;
    // draw triangles!!
    var verticies = strip.verticies;
    var uvs = strip.uvs;

    var length = verticies.length / 2;
    this.count++;

    for (var i = 0; i < length - 2; i++) {
      // draw some triangles!
      var index = i * 2;

      var x0 = verticies[index], x1 = verticies[index + 2], x2 = verticies[index + 4];
      var y0 = verticies[index + 1], y1 = verticies[index + 3], y2 = verticies[index + 5];

      if (true) {

        //expand();
        var centerX = (x0 + x1 + x2) / 3;
        var centerY = (y0 + y1 + y2) / 3;

        var normX = x0 - centerX;
        var normY = y0 - centerY;

        var dist = sqrt(normX * normX + normY * normY);
        x0 = centerX + (normX / dist) * (dist + 3);
        y0 = centerY + (normY / dist) * (dist + 3);

        //

        normX = x1 - centerX;
        normY = y1 - centerY;

        dist = sqrt(normX * normX + normY * normY);
        x1 = centerX + (normX / dist) * (dist + 3);
        y1 = centerY + (normY / dist) * (dist + 3);

        normX = x2 - centerX;
        normY = y2 - centerY;

        dist = sqrt(normX * normX + normY * normY);
        x2 = centerX + (normX / dist) * (dist + 3);
        y2 = centerY + (normY / dist) * (dist + 3);

      }

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