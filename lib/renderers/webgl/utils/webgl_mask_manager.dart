part of PIXI;

class WebGLMaskManager extends MaskManager {
  List maskStack = [];
  int maskPosition = 0;
  RenderingContext gl;

  bool reverse;
  int count;

  WebGLMaskManager(gl) {
    this.setContext(gl);

    this.reverse = false;
    this.count = 0;

  }

  setContext(gl) {
    this.gl = gl;
  }

  pushMask(maskData, [RenderSession renderSession]) {
    var gl = renderSession.gl;

    if (maskData._dirty) {
      //gl.enable(STENCIL_TEST);
      //gl.stencilFunc(ALWAYS, 1, 1);
      WebGLGraphics.updateGraphics(maskData, gl);
    }

    //  maskData.visible = false;

//    this.maskStack.add(maskData);
//
//    gl.colorMask(false, false, false, false);
//    gl.stencilOp(KEEP, KEEP, INCR);
//
//    WebGLGraphics.renderGraphics(maskData, renderSession);
    if(maskData._webGL[gl].data.length ==0)return;

//    gl.colorMask(true, true, true, true);
//    gl.stencilFunc(NOTEQUAL, 0, this.maskStack.length);
//    gl.stencilOp(KEEP, KEEP, KEEP);
    renderSession.stencilManager.pushStencil(maskData, maskData._webGL[gl].data[0], renderSession);
  }


  popMask(Graphics maskData, [RenderSession renderSession]) {
    var gl = this.gl;

//    var maskData = this.maskStack.removeLast();
//
//    if (maskData != null) {
//      gl.colorMask(false, false, false, false);
//
//      //gl.stencilFunc(gl.ALWAYS,1,1);
//      gl.stencilOp(KEEP, KEEP, DECR);
//
//      WebGLGraphics.renderGraphics(maskData, renderSession);
//
//      gl.colorMask(true, true, true, true);
//      gl.stencilFunc(NOTEQUAL, 0, this.maskStack.length);
//      gl.stencilOp(KEEP, KEEP, KEEP);
//    }
//
//    if (this.maskStack.length == 0)gl.disable(STENCIL_TEST);
    if(maskData._webGL[gl].data.length ==0)return;
    renderSession.stencilManager.popStencil(maskData, maskData._webGL[gl].data[0], renderSession);
  }

  destroy() {
    this.maskStack = null;
    this.gl = null;
  }
}
