part of PIXI;

class WebGLShaderManager {
  RenderingContext gl;
  int maxAttibs = 10;
  int _currentId;
  Map<int, bool> attribState = {
  };
  Map<int, bool> tempAttribState = {
  };
  Map shaderMap = {};

  PrimitiveShader primitiveShader;
  PixiShader defaultShader;
  PixiFastShader fastShader;
  Shader currentShader;

  ComplexPrimitiveShader complexPrimativeShader;
  StripShader stripShader;


  WebGLShaderManager(gl) {
    for (var i = 0; i < this.maxAttibs; i++) {
      this.attribState[i] = false;
    }
//    if(gl == null) return;
    this.setContext(gl);
  }

  setContext(gl) {
    this.gl = gl;

    // the next one is used for rendering primatives
    this.primitiveShader = new PrimitiveShader(gl);

    // the next one is used for rendering triangle strips
    this.complexPrimativeShader = new ComplexPrimitiveShader(gl);


    // this shader is used for the default sprite rendering
    this.defaultShader = new PixiShader(gl);

    // this shader is used for the fast sprite rendering
    this.fastShader = new PixiFastShader(gl);


    //this.activateShader(this.defaultShader);
    this.stripShader = new StripShader(gl);

    this.setShader(this.defaultShader);
  }

  setAttribs(List<int> attribs) {
    // reset temp state

    int i;

    for (var key in this.tempAttribState.keys) {
      this.tempAttribState[key] = false;
    }

    // set the new attribs
    for (i = 0; i < attribs.length; i++) {
      int attribId = attribs[i];
      this.tempAttribState[attribId] = true;
    }

    for (i = 0; i < this.attribState.length; i++) {

      if (this.attribState[i] != this.tempAttribState[i]) {
        this.attribState[i] = this.tempAttribState[i];

        if (this.tempAttribState[i] == true) {
          gl.enableVertexAttribArray(i);
        }
        else {
          gl.disableVertexAttribArray(i);
        }
      }
    }
  }

  setShader( shader) {
    //if(this.currentShader == shader)return;
    if (this._currentId == shader._UID) return false;
    this._currentId = shader._UID;

    this.currentShader = shader;

    this.gl.useProgram(shader.program);
    this.setAttribs(shader.attributes);
//
//  }
//
//  activatePrimitiveShader() {
//    var gl = this.gl;
//
//    gl.useProgram(this.primitiveShader.program);
//
//    this.setAttribs(this.primitiveShader.attributes);
//
//  }
//
//
//  deactivatePrimitiveShader() {
//    var gl = this.gl;
//
//    gl.useProgram(this.defaultShader.program);
//
//    this.setAttribs(this.defaultShader.attributes);
    return true;
  }

  destroy() {
    this.attribState = null;

    this.tempAttribState = null;

    this.primitiveShader.destroy();

    this.defaultShader.destroy();

    this.fastShader.destroy();

    this.stripShader.destroy();

    this.gl = null;
  }
}
