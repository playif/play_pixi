part of PIXI;

class FilterBlock {
  FilterBlock() {
  }

  bool visible = true;
  bool renderable = true;
  DisplayObject target;
  Rectangle _filterArea;
  Rectangle filterArea;
  List<AbstractFilter> filterPasses=[];
  Texture _glFilterTexture;
}
