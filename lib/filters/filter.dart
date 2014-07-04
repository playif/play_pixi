part of PIXI;

class Filter {
  List<Filter> passes = [this];
  List shaders = [];
  bool dirty = true;
  num padding = 0;

  Map uniforms = {
  };

  List fragmentSrc = [];

  Filter() {
    print("Filter");
  }
}
