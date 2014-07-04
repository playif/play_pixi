library PIXI;

import "dart:html";
import "dart:math";
import "dart:async";
import "dart:convert";
import "dart:web_gl";

import "dart:typed_data";

//part "utils/myeve.dart";


part "core/circle.dart";
part "core/matrix.dart";
part "core/point.dart";
part "core/rectangle.dart";

part "display/display_object.dart";
part "display/display_object_container.dart";
part "display/sprite.dart";
part "display/sprite_batch.dart";
part "display/stage.dart";

part "filters/filter.dart";
part "filters/filter_block.dart";

part "primitives/graphics.dart";

part "renderers/canvas/utils/canvas_mask_manager.dart";
part "renderers/canvas/utils/canvas_tinter.dart";
part "renderers/canvas/canvas_graphics.dart";
part "renderers/canvas/canvas_renderer.dart";

part "renderers/webgl/shaders/pixi_fast_shader.dart";
part "renderers/webgl/shaders/pixi_shader.dart";
part "renderers/webgl/shaders/primitive_shader.dart";
part "renderers/webgl/shaders/strip_shader.dart";

part "renderers/webgl/utils/filter_texture.dart";
part "renderers/webgl/utils/webgl_fast_sprite_batch.dart";
part "renderers/webgl/utils/webgl_filter_manager.dart";
part "renderers/webgl/utils/webgl_graphics.dart";
part "renderers/webgl/utils/webgl_mask_manager.dart";
part "renderers/webgl/utils/webgl_shader_manager.dart";
part "renderers/webgl/utils/webgl_shader_utils.dart";
part "renderers/webgl/utils/webgl_sprite_batch.dart";

part "renderers/webgl/webgl_renderer.dart";
part "renderers/renderer.dart";

part "textures/base_texture.dart";
part "textures/render_texture.dart";
part "textures/texture.dart";

part "utils/detector.dart";

part "utils/polyk.dart";
part "utils/utils.dart";

part "interaction_data.dart";
part "interaction_manager.dart";

part "render_session.dart";

typedef void EventFunc(Event e);

class blendModes {
  static const NORMAL = const blendModes._(0);
  static const ADD = const blendModes._(1);
  static const MULTIPLY = const blendModes._(2);
  static const SCREEN = const blendModes._(3);
  static const OVERLAY = const blendModes._(4);
  static const DARKEN = const blendModes._(5);
  static const LIGHTEN = const blendModes._(6);
  static const COLOR_DODGE = const blendModes._(7);
  static const COLOR_BURN = const blendModes._(8);
  static const HARD_LIGHT = const blendModes._(9);
  static const SOFT_LIGHT = const blendModes._(10);
  static const DIFFERENCE = const blendModes._(11);
  static const EXCLUSION = const blendModes._(12);
  static const HUE = const blendModes._(13);
  static const SATURATION = const blendModes._(14);
  static const COLOR = const blendModes._(15);
  static const LUMINOSITY = const blendModes._(16);


//  static get values => [NORMAL, ADD];

  final int value;

  const blendModes._(this.value);
}

class scaleModes {
  static const DEFAULT = const scaleModes._(0);
  static const LINEAR = const scaleModes._(1);
  static const NEAREST = const scaleModes._(2);

//  static get values => [NORMAL, ADD];

  final int value;

  const scaleModes._(this.value);
}

Renderer defaultRenderer;
List blendModesWebGL = null;

const int WEBGL_RENDERER = 0;
const int CANVAS_RENDERER = 0;
const String VERSION = "v1.5.3";

const int INTERACTION_FREQUENCY = 30;
const bool AUTO_PREVENT_DEFAULT = true;

const num RAD_TO_DEG = 180 / PI;
const num DEG_TO_RAD = PI / 180;

