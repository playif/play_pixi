part of PIXI;

class WebGLBlendModeManager {
  RenderingContext gl;
  blendModes currentBlendMode;

  WebGLBlendModeManager(this.gl) {
    this.currentBlendMode = blendModes.NONE;
  }

  bool setBlendMode(blendModes blendMode) {
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
