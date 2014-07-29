part of PIXI;

class WebGLBlendModeManager {
  RenderingContext gl;
  BlendModes currentBlendMode;

  WebGLBlendModeManager(this.gl) {
    this.currentBlendMode = BlendModes.NONE;
  }

  bool setBlendMode(BlendModes blendMode) {
    if (this.currentBlendMode == blendMode)return false;
    //   console.log("SWAP!")
    this.currentBlendMode = blendMode;

    var blendModeWebGL = blendModesWebGL[this.currentBlendMode];
    this.gl.blendFunc(blendModeWebGL[0], blendModeWebGL[1]);

    return true;
  }

  destroy() {
    this.gl = null;
  }


}
