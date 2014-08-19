part of PIXI;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A Stage represents the root of the display tree. Everything connected to the stage is rendered
 *
 *      like: 0xFFFFFF for white
 * 
 *      Creating a stage is a mandatory process when you use Pixi, which is as simple as this : 
 *      var stage = new PIXI.Stage(0xFFFFFF);
 *      where the parameter given is the background colour of the stage, in hex
 *      you will use this stage instance to add your sprites to it and therefore to the renderer
 *      Here is how to add a sprite to the stage : 
 *      stage.addChild(sprite);
 */
class Stage extends DisplayObjectContainer {
  /// Whether the stage is dirty and needs to have interactions updated
  bool _dirty;
  bool _interactiveEventsAdded = false;

  Rectangle hitArea = new Rectangle(0, 0, 100000, 100000);
  int backgroundColor = 0;
  List<num> backgroundColorSplit = [];
  String backgroundColorString;

  Matrix _worldTransform = new Matrix();
  
  /// [read-only] Current transform of the object based on world (parent) factors
  Matrix get worldTransform => _worldTransform; 

  /// The interaction manage for this stage, manages all interactive activity on the stage
  InteractionManager interactionManager;


  Stage([int backgroundColor = 0, bool interactive = true]) {
    _dirty = true;
    this._stage = this;
    if (backgroundColor != null) {
      this.backgroundColor = backgroundColor;
    }
    this.interactive = interactive;
    interactionManager = new InteractionManager(this);
    setBackgroundColor(backgroundColor);

  }

  /**
   * Sets another DOM element which can receive mouse/touch interactions instead of the default Canvas element.
   * This is useful for when you have other DOM elements on top of the Canvas element.
   */
  void setInteractionDelegate(domElement) {
    this.interactionManager.setTargetDomElement(domElement);
  }

  /// Updates the object transform for rendering
  void updateTransform() {
    this._worldAlpha = 1.0;

    for (var i = 0,
        j = this.children.length; i < j; i++) {
      this.children[i].updateTransform();
    }

    if (this._dirty) {
      this._dirty = false;
      // update interactive!
      this.interactionManager.dirty = true;
    }

    if (this.interactive) {

      this.interactionManager.update();
    }
  }

  /// Sets the background color for the stage
  void setBackgroundColor(int backgroundColor) {
    this.backgroundColor = backgroundColor;
    //window.console.log(backgroundColor);
    this.backgroundColorSplit = hex2rgb(this.backgroundColor);
    //window.console.log(backgroundColorSplit);
    var hex = this.backgroundColor.toRadixString(16);
    hex = '000000'.substring(0, 6 - hex.length) + hex;
    this.backgroundColorString = '#' + hex;
  }

  /// This will return the point containing global coords of the mouse.
  Point getMousePosition() {
    return this.interactionManager.mouse.global;
  }




}
