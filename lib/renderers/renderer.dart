part of PIXI;

abstract class Renderer {
  int type = 0;
  bool transparent = false;
  bool antialias = false;
  bool preserveDrawingBuffer=false;
  num width = 100, height = 100;
  CanvasElement view = null;

  Point projection;
  Point offset;

  bool contextLost = false;


  Map options;

  RenderingContext gl;

  WebGLShaderManager shaderManager;
  WebGLSpriteBatch spriteBatch;
  MaskManager maskManager;
  WebGLFilterManager filterManager;
  WebGLStencilManager stencilManager;
  WebGLBlendModeManager blendModeManager;
 // PrimitiveShader primitiveBatch;

  RenderSession renderSession;
  Stage __stage;

  Renderer() {
  }

  render(Stage stage);

  renderDisplayObject(displayObject, [projection, buffer]);

  resize(int width,int height);
}
