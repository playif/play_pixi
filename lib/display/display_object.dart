part of PIXI;

typedef void InteractionHandler(InteractionData data);

abstract class DisplayInterface {
  updateTransform();
  _renderWebGL(RenderSession renderSession);
  _renderCanvas(RenderSession renderSession);
  //getBounds(Matrix matrix);
  //Matrix get _worldTransform;
  //num _worldAlpha;
  //removeChild(DisplayInterface child);
  //DisplayInterface _parent;
  //setStageReference(Stage stage);
  //bool visible;
  //Stage _stage;
  //bool interactiveChildren;
  //bool _dirty;

//  InteractionHandler click;
//  InteractionHandler mousemove;
//  InteractionHandler mousedown;
//  InteractionHandler mouseout;
//  InteractionHandler mouseover;
//  InteractionHandler mouseup;
//  InteractionHandler mouseupoutside;
//
//  InteractionHandler touchmove;
//  InteractionHandler touchstart;
//  InteractionHandler touchend;
//  InteractionHandler tap;
//  InteractionHandler touchendoutside;

  Shape hitArea = null;
  //bool get worldVisible;
}


/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The base class for all objects that are rendered on the screen. 
 * This is an abstract class and should not be used on its own rather it should be extended.
 *
 */
class DisplayObject implements DisplayInterface {
  /// The coordinate of the object relative to the local coordinates of the parent.
  Point position = new Point();

  /// The scale factor of the object, default is (1, 1).
  Point scale = new Point(1, 1);

  /// The pivot point of the [DisplayObject] that it rotates around
  Point pivot = new Point(0, 0);

  /// The rotation of the object in radians.
  num rotation = 0;

  /// The opacity of the object.
  num alpha = 1;

  /// The visibility of the object.
  bool visible = true;

  /**
   * This is the defined area that will pick up mouse / touch events. It is null by default.
   * Setting it is a neat way of optimising the hitTest function that the interactionManager will use (as it will not need to hit test all the children)
   *
   * @The instance of [hitArea] is one of [Rectangle]|[Circle]|[Ellipse]|[Polygon]
   */
  Shape hitArea = null;

  /// This is used to indicate if the displayObject should display a mouse hand cursor on rollover
  bool buttonMode = false;

  /// Can this object be rendered
  bool renderable = false;


  DisplayInterface _parent = null;

  /// [read-only] The display object container that contains this display object.
  DisplayInterface get parent => _parent;

  //DisplayInterface __iParent = null;


  //bool interactiveChildren = false;
  bool __hit = false;
  bool __isOver = false;
  bool __mouseIsDown = false;
  bool __isDown = false;

  bool _dirty = false;

  InteractionHandler click;
  InteractionHandler mousemove;
  InteractionHandler mousedown;
  InteractionHandler mouseout;
  InteractionHandler mouseover;
  InteractionHandler mouseup;
  InteractionHandler mouseupoutside;

  InteractionHandler touchmove;
  InteractionHandler touchstart;
  InteractionHandler touchend;
  InteractionHandler tap;
  InteractionHandler touchendoutside;

  Map<int, InteractionData> __touchData = {};
  //bool buttonMode = false;
  //DisplayObjectContainer get parent => _parent;


  Stage _stage = null;
  /// [read-only] The stage the display object is connected to, or undefined if it is not connected to the stage.
  Stage get stage => _stage;

  num _worldAlpha = 1.0;

  /// [read-only] The multiplied alpha of the displayObject
  num get worldAlpha => _worldAlpha;


  bool _interactive = false;

  /// Indicates if the sprite will have touch and mouse interactivity. It is false by default
  bool get interactive => _interactive;

  set interactive(value) {
    _interactive = value;
    if (this._stage != null) this._stage._dirty = true;
  }

  String defaultCursor = 'pointer';

  Matrix _worldTransform = new Matrix();

  /// [read-only] Current transform of the object based on world (parent) factors
  Matrix get worldTransform => _worldTransform;

  /// TODO
  //List color = [];
  //bool dynamic = true;


  num _sr = 0;
  num _cr = 1;

  /**
   * The area the filter is applied to like the hitArea this is used as more of an optimisation
   * rather than figuring out the dimensions of the displayObject each frame you can set this rectangle
   */
  Rectangle filterArea = null;

  /// The original, cached bounds of the object
  Rectangle _bounds = new Rectangle(0, 0, 1, 1);

  /// The most up-to-date bounds of the object
  Rectangle _currentBounds = null;

  Graphics _mask = null;

  /**
   * Sets a mask for the displayObject. A mask is an object that limits the visibility of an object to the shape of the mask applied to it.
   * In PIXI a regular mask must be a [Graphics] object. This allows for much faster masking in canvas as it utilises shape clipping.
   * To remove a mask, set this property to null.
   */
  Graphics get mask => _mask;

  set mask(Graphics value) {
    if (this._mask != null) this._mask._isMask = false;
    this._mask = value;
    if (this._mask != null) this._mask._isMask = true;
  }

  bool _cacheAsBitmap = false;

  /**
   * Set weather or not a the display objects is cached as a bitmap.
   * This basically takes a snap shot of the display object as it is at that moment. It can provide a performance benefit for complex static displayObjects
   */
  bool get cacheAsBitmap => _cacheAsBitmap;

  Sprite _cachedSprite;

  set cacheAsBitmap(bool value) {
    if (this._cacheAsBitmap == value) return;

    if (value) {
      //this._cacheIsDirty = true;
      this._generateCachedSprite();
    } else {
      this._destroyCachedSprite();
    }

    this._cacheAsBitmap = value;
  }


  bool _cacheIsDirty = false;

  /// [read-only] Indicates if the sprite is globaly visible.
  bool get worldVisible {
    DisplayObject item = this;

    do {
      if (!item.visible) return false;
      item = item._parent;
    } while (item != null);

    return true;
  }

  FilterBlock _filterBlock = new FilterBlock();

  List<AbstractFilter> _filters = null;

  /**
   * Sets the filters for the displayObject.
   * * IMPORTANT: This is a webGL only feature and will be ignored by the canvas renderer.
   * To remove filters simply set this property to 'null'
   * @property filters
   * @type Array An array of filters
   */
  List<AbstractFilter> get filters => _filters;

  set filters(List<AbstractFilter> value) {
    if (value != null) {
      // now put all the passes in one place..
      List<AbstractFilter> passes = [];
      for (int i = 0; i < value.length; i++) {
        List<AbstractFilter> filterPasses = value[i].passes;
        for (int j = 0; j < filterPasses.length; j++) {
          passes.add(filterPasses[j]);
        }
      }

      // TODO change this as it is legacy
      this._filterBlock.target = this;
      this._filterBlock.filterPasses = passes;
      //          'target':this, 'filterPasses':passes
      //      };
    }

    this._filters = value;
  }

  num _rotationCache = 0;

  /// Updates the object transform for rendering
  void updateTransform() {
    // TODO OPTIMIZE THIS!! with dirty
    if (this.rotation != this._rotationCache) {

      this._rotationCache = this.rotation;
      this._sr = sin(this.rotation);
      this._cr = cos(this.rotation);
    }
    //print("updated");

    DisplayObject parent = this._parent;

    Matrix parentTransform = parent._worldTransform;
    Matrix worldTransform = this._worldTransform;

    num px = this.pivot.x;
    num py = this.pivot.y;

    num a00 = this._cr * this.scale.x,
        a01 = -this._sr * this.scale.y,
        a10 = this._sr * this.scale.x,
        a11 = this._cr * this.scale.y,
        a02 = this.position.x - a00 * px - py * a01,
        a12 = this.position.y - a11 * py - px * a10,
        b00 = parentTransform.a,
        b01 = parentTransform.b,
        b10 = parentTransform.c,
        b11 = parentTransform.d;

    worldTransform.a = b00 * a00 + b01 * a10;
    worldTransform.b = b00 * a01 + b01 * a11;
    worldTransform.tx = b00 * a02 + b01 * a12 + parentTransform.tx;

    worldTransform.c = b10 * a00 + b11 * a10;
    worldTransform.d = b10 * a01 + b11 * a11;
    worldTransform.ty = b10 * a02 + b11 * a12 + parentTransform.ty;

    this._worldAlpha = this.alpha * parent._worldAlpha;
  }

  /// Retrieves the bounds of the displayObject as a rectangle object
  Rectangle getBounds([Matrix matrix]) {
    matrix = matrix;//just to get passed js hinting (and preserve inheritance)
    return EmptyRectangle;
  }

  /// Retrieves the local bounds of the displayObject as a rectangle object
  Rectangle getLocalBounds() {
    return this.getBounds(IdentityMatrix);
  }

  /// Sets the object's [stage] reference, the stage this object is connected to
  _setStageReference(Stage stage) {
    this._stage = stage;
    if (this._interactive) this._stage._dirty = true;
  }

  RenderTexture generateTexture(Renderer renderer) {
    Rectangle bounds = this.getLocalBounds();

    RenderTexture renderTexture = new RenderTexture(bounds.width.floor(), bounds.height.floor(), renderer);
    renderTexture.render(this, new Point(-bounds.x, -bounds.y));

    return renderTexture;
  }


  updateCache() {
    this._generateCachedSprite();
  }

  _renderCachedSprite(RenderSession renderSession) {
    this._cachedSprite._worldAlpha = this._worldAlpha;

    if (renderSession.gl != null) {
      this._cachedSprite._renderWebGL(renderSession);
      //PIXI.Sprite.prototype._renderWebGL.call(this._cachedSprite, renderSession);
    } else {
      this._cachedSprite._renderCanvas(renderSession);
      //PIXI.Sprite.prototype._renderCanvas.call(this._cachedSprite, renderSession);
    }
  }


  void _generateCachedSprite() {
    this._cacheAsBitmap = false;
    var bounds = this.getLocalBounds();

    if (this._cachedSprite == null) {
      var renderTexture = new RenderTexture(bounds.width.floor(), bounds.height.floor());//, renderSession.renderer);

      this._cachedSprite = new Sprite(renderTexture);
      this._cachedSprite._worldTransform = this._worldTransform;
    } else {
      RenderTexture texture = _cachedSprite.texture as RenderTexture;
      texture.resize(bounds.width.floor(), bounds.height.floor());
    }

    //REMOVE filter!
    var tempFilters = this._filters;
    this._filters = null;

    this._cachedSprite.filters = tempFilters;

    RenderTexture texture = _cachedSprite.texture as RenderTexture;
    texture.render(this, new Point(-bounds.x, -bounds.y), false);

    this._cachedSprite.anchor.x = -(bounds.x / bounds.width);
    this._cachedSprite.anchor.y = -(bounds.y / bounds.height);

    this._filters = tempFilters;

    this._cacheAsBitmap = true;
  }

  void _destroyCachedSprite() {
    if (this._cachedSprite == null) return;

    this._cachedSprite.texture.destroy(true);
    //  console.log("DESTROY")
    // let the gc collect the unused sprite
    // TODO could be object pooled!
    this._cachedSprite = null;
  }

  /// Renders the object using the [WebGLRenderer]
  void _renderWebGL(RenderSession renderSession) {

    // OVERWRITE;
    // this line is just here to pass jshinting :)
    renderSession = renderSession;
  }

  /// Renders the object using the [CanvasRenderer]
  void _renderCanvas(renderSession) {
    // OVERWRITE;
    // this line is just here to pass jshinting :)
    renderSession = renderSession;
  }

  /// The position of the displayObject on the x axis relative to the local coordinates of the parent.
  num get x => position.x;

  void set x(num value) {
    position.x = value;
  }

  /// The position of the displayObject on the y axis relative to the local coordinates of the parent.
  num get y => position.y;

  void set y(num value) {
    position.y = value;
  }

}
