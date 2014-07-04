part of PIXI;

class WebGLMaskManager {
  List maskStack = [];
  int maskPosition = 0;
  RenderingContext gl;

  WebGLMaskManager(gl) {
    this.setContext(gl);
  }

  setContext(gl) {
    this.gl = gl;
  }

  pushMask(maskData, renderSession) {
    var gl = this.gl;

    if (this.maskStack.length == 0) {
      gl.enable(gl.STENCIL_TEST);
      gl.stencilFunc(gl.ALWAYS, 1, 1);
    }

    //  maskData.visible = false;

    this.maskStack.add(maskData);

    gl.colorMask(false, false, false, false);
    gl.stencilOp(gl.KEEP, gl.KEEP, gl.INCR);

    WebGLGraphics.renderGraphics(maskData, renderSession);

    gl.colorMask(true, true, true, true);
    gl.stencilFunc(gl.NOTEQUAL, 0, this.maskStack.length);
    gl.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
  }


  popMask(RenderSession renderSession) {
    var gl = this.gl;

    var maskData = this.maskStack.removeLast();

    if (maskData) {
      gl.colorMask(false, false, false, false);

      //gl.stencilFunc(gl.ALWAYS,1,1);
      gl.stencilOp(gl.KEEP, gl.KEEP, gl.DECR);

      WebGLGraphics.renderGraphics(maskData, renderSession);

      gl.colorMask(true, true, true, true);
      gl.stencilFunc(gl.NOTEQUAL, 0, this.maskStack.length);
      gl.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
    }

    if (this.maskStack.length == 0)gl.disable(gl.STENCIL_TEST);
  }

  destroy() {
    this.maskStack = null;
    this.gl = null;
  }
}
