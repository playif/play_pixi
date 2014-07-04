part of PIXI;

abstract class Renderer {
  int type;
  bool transparent;
  bool antialias;
  num width, height;
  CanvasElement view;

  Point projection;
  Point offset;

  bool contextLost = false;

  Map options;

  RenderingContext gl;

  WebGLShaderManager shaderManager;
  WebGLSpriteBatch spriteBatch;
  WebGLMaskManager maskManager;
  WebGLFilterManager filterManager;

  RenderSession renderSession = [];
  Stage __stage;

  Renderer() {
  }

  render(Stage stage);
}
