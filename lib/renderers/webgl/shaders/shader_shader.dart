part of PIXI;

abstract class Shader {

  UniformLocation uSampler;
  UniformLocation projectionVector;
  UniformLocation offsetVector;
  UniformLocation dimensions;
  UniformLocation uMatrix;
  UniformLocation tintColor;
  UniformLocation color;
  UniformLocation translationMatrix;
  UniformLocation alpha;

  int aVertexPosition;
  int aPositionCoord;
  int aScale;
  int aRotation;
  int aTextureCoord;
  int colorAttribute;

  List attributes;

  int _UID;

  init();
  destroy();
}
