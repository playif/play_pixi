part of PIXI;
class WebGLStencilManager {
  RenderingContext gl;
  List stencilStack;
  bool reverse;
  int count;

  List maskStack;

  Graphics _currentGraphics;

  WebGLStencilManager(this.gl) {
    this.stencilStack = [];
    this.setContext(gl);
    this.reverse = true;
    this.count = 0;
  }

  setContext(gl)
  {
    this.gl = gl;
  }


  pushStencil( Graphics graphics, WebGLGraphicsData webGLData, RenderSession renderSession)
  {
    var gl = this.gl;
    this.bindGraphics(graphics, webGLData, renderSession);


    if(this.stencilStack.length == 0)
    {
      gl.enable(STENCIL_TEST);
      gl.clear(STENCIL_BUFFER_BIT);
      this.reverse = true;
      this.count = 0;
    }


    this.stencilStack.add(webGLData);


    int level = this.count;


    gl.colorMask(false, false, false, false);


    gl.stencilFunc(ALWAYS,0,0xFF);
    gl.stencilOp(KEEP,KEEP,INVERT);


    // draw the triangle strip!


    if(webGLData.mode == 1)
    {


      gl.drawElements(TRIANGLE_FAN,  webGLData.indices.length - 4, UNSIGNED_SHORT, 0 );

      if(this.reverse)
      {
        gl.stencilFunc(EQUAL, 0xFF - level, 0xFF);
        gl.stencilOp(KEEP,KEEP,DECR);
      }
      else
      {
        gl.stencilFunc(EQUAL,level, 0xFF);
        gl.stencilOp(KEEP,KEEP,INCR);
      }


      // draw a quad to increment..
      gl.drawElements(TRIANGLE_FAN, 4, UNSIGNED_SHORT, ( webGLData.indices.length - 4 ) * 2 );

      if(this.reverse)
      {
        gl.stencilFunc(EQUAL,0xFF-(level+1), 0xFF);
      }
      else
      {
        gl.stencilFunc(EQUAL,level+1, 0xFF);
      }


      this.reverse = !this.reverse;
    }
    else
    {
      if(!this.reverse)
      {
        gl.stencilFunc(EQUAL, 0xFF - level, 0xFF);
        gl.stencilOp(KEEP,KEEP,DECR);
      }
      else
      {
        gl.stencilFunc(EQUAL,level, 0xFF);
        gl.stencilOp(KEEP,KEEP,INCR);
      }


      gl.drawElements(TRIANGLE_STRIP,  webGLData.indices.length, UNSIGNED_SHORT, 0 );


      if(!this.reverse)
      {
        gl.stencilFunc(EQUAL,0xFF-(level+1), 0xFF);
      }
      else
      {
        gl.stencilFunc(EQUAL,level+1, 0xFF);
      }
    }


    gl.colorMask(true, true, true, true);
    gl.stencilOp(KEEP,KEEP,KEEP);


    this.count++;
  }


//TODO this does not belong here!
  bindGraphics (Graphics graphics, WebGLGraphicsData webGLData, RenderSession renderSession)
  {
    //if(this._currentGraphics === graphics)return;
    this._currentGraphics = graphics;


    //var gl = this.gl;


    // bind the graphics object..
    Point projection = renderSession.projection,
    offset = renderSession.offset;
    Shader shader;// = renderSession.shaderManager.primitiveShader;


    if(webGLData.mode == 1)
    {
      shader = renderSession.shaderManager.complexPrimativeShader;


      renderSession.shaderManager.setShader( shader );


      gl.uniformMatrix3fv(shader.translationMatrix, false, graphics._worldTransform.toArray(true));


      gl.uniform2f(shader.projectionVector, projection.x, -projection.y);
      gl.uniform2f(shader.offsetVector, -offset.x, -offset.y);


      gl.uniform3fv(shader.tintColor, new Float32List.fromList(hex2rgb(graphics.tint)));
      gl.uniform3fv(shader.color, new Float32List.fromList(webGLData.color));


      gl.uniform1f(shader.alpha, graphics._worldAlpha * webGLData.alpha);


      gl.bindBuffer(ARRAY_BUFFER, webGLData.buffer);


      gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 4 * 2, 0);




      // now do the rest..
      // set the index buffer!
      gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGLData.indexBuffer);
    }
    else
    {
      //renderSession.shaderManager.activatePrimitiveShader();
      shader = renderSession.shaderManager.primitiveShader;
      renderSession.shaderManager.setShader( shader );


      gl.uniformMatrix3fv(shader.translationMatrix, false, graphics._worldTransform.toArray(true));


      gl.uniform2f(shader.projectionVector, projection.x, -projection.y);
      gl.uniform2f(shader.offsetVector, -offset.x, -offset.y);

//TODO
      gl.uniform3fv(shader.tintColor, new Float32List.fromList(hex2rgb(graphics.tint)));


      gl.uniform1f(shader.alpha, graphics._worldAlpha);

      gl.bindBuffer(ARRAY_BUFFER, webGLData.buffer);


      gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 4 * 6, 0);
      gl.vertexAttribPointer(shader.colorAttribute, 4, FLOAT, false,4 * 6, 2 * 4);


      // set the index buffer!
      gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGLData.indexBuffer);
    }
  }


  popStencil (graphics, webGLData, renderSession)
  {
    var gl = this.gl;
    this.stencilStack.removeLast();

    this.count--;


    if(this.stencilStack.length == 0)
    {
      // the stack is empty!
      gl.disable(STENCIL_TEST);


    }
    else
    {


      var level = this.count;


      this.bindGraphics(graphics, webGLData, renderSession);


      gl.colorMask(false, false, false, false);

      if(webGLData.mode == 1)
      {
        this.reverse = !this.reverse;


        if(this.reverse)
        {
          gl.stencilFunc(EQUAL, 0xFF - (level+1), 0xFF);
          gl.stencilOp(KEEP,KEEP,INCR);
        }
        else
        {
          gl.stencilFunc(EQUAL,level+1, 0xFF);
          gl.stencilOp(KEEP,KEEP,DECR);
        }


        // draw a quad to increment..
        gl.drawElements(TRIANGLE_FAN, 4, UNSIGNED_SHORT, ( webGLData.indices.length - 4 ) * 2 );

        gl.stencilFunc(ALWAYS,0,0xFF);
        gl.stencilOp(KEEP,KEEP,INVERT);


        // draw the triangle strip!
        gl.drawElements(TRIANGLE_FAN,  webGLData.indices.length - 4, UNSIGNED_SHORT, 0 );

        if(!this.reverse)
        {
          gl.stencilFunc(EQUAL,0xFF-(level), 0xFF);
        }
        else
        {
          gl.stencilFunc(EQUAL,level, 0xFF);
        }


      }
      else
      {
        //  console.log("<<>>")
        if(!this.reverse)
        {
          gl.stencilFunc(EQUAL, 0xFF - (level+1), 0xFF);
          gl.stencilOp(KEEP,KEEP,INCR);
        }
        else
        {
          gl.stencilFunc(EQUAL,level+1, 0xFF);
          gl.stencilOp(KEEP,KEEP,DECR);
        }


        gl.drawElements(TRIANGLE_STRIP,  webGLData.indices.length, UNSIGNED_SHORT, 0 );


        if(!this.reverse)
        {
          gl.stencilFunc(EQUAL,0xFF-(level), 0xFF);
        }
        else
        {
          gl.stencilFunc(EQUAL,level, 0xFF);
        }
      }


      gl.colorMask(true, true, true, true);
      gl.stencilOp(KEEP,KEEP,KEEP);




    }


    //renderSession.shaderManager.deactivatePrimitiveShader();
  }


  /**
   * Destroys the mask stack
   * @method destroy
   */
  destroy()
  {
    this.maskStack = null;
    this.gl = null;
  }


}
