part of PIXI;

class RenderSession {

//  RenderingContext glID;
  RenderingContext gl;
  Point projection;
  Point offset;
  int drawCount = 0;
  WebGLShaderManager shaderManager;
  MaskManager maskManager;
  WebGLFilterManager filterManager;
  WebGLSpriteBatch spriteBatch;
  WebGLBlendModeManager blendModeManager;
  WebGLStencilManager stencilManager;

  Renderer renderer;

  BlendModes currentBlendMode;
  scaleModes scaleMode;

  String smoothProperty;
  //String smoothProperty;

  CanvasRenderingContext2D context;

  bool roundPixels = false;
}
