part of PIXI;

class RenderSession {
  RenderingContext gl;
  Point projection;
  Point offset;
  int drawCount = 0;
  WebGLShaderManager shaderManager;
  WebGLMaskManager maskManager;
  WebGLFilterManager filterManager;
  WebGLSpriteBatch spriteBatch;
  Renderer renderer;

  blendModes currentBlendMode;

}
