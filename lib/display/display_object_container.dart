part of PIXI;


/**
 * A DisplayObjectContainer represents a collection of display objects.
 * It is the base class of all display objects that act as a container for other objects.
 */
class DisplayObjectContainer extends DisplayObject {
  final List<DisplayInterface> children = [];

  bool interactiveChildren = false;

  num _width=0;
  /// The width of the displayObjectContainer, setting this will actually modify the scale to achieve the value set
  num get width {
    return this.scale.x * this.getLocalBounds().width;
  }

  set width(num value) {
    //this.scale.x = value / (this.getLocalBounds().width / this.scale.x);

    num width = this.getLocalBounds().width;
    if (width != 0) {
      //this.scale.x = value / (width / this.scale.x);
      this.scale.x = value / (width);
    } else {
      this.scale.x = 1;
    }
    this._width = value;
  }

  num _height=0;
  /// The height of the displayObjectContainer, setting this will actually modify the scale to achieve the value set
  num get height {
    return this.scale.y * this.getLocalBounds().height;
  }

  set height(num value) {
    //this.scale.y = value / (this.getLocalBounds().height / this.scale.y);

    num height = this.getLocalBounds().height;
    if (height != 0) {
      // this.scale.y = value / (height / this.scale.y);
      this.scale.y = value / (height);
    } else {
      this.scale.y = 1;
    }
    this._height = value;
  }

  /// Adds a [child] to the container.
  DisplayInterface addChild(DisplayInterface child) {
    return addChildAt(child, children.length);
  }

  /// Adds a [child] to the container at a specified [index]. If the [index] is out of bounds an error will be thrown
  DisplayInterface addChildAt(DisplayInterface child, int index) {
    DisplayObject _child = child as DisplayObject;
    if (index >= 0 && index <= children.length) {
      if (_child._parent != null) {
        (_child._parent as DisplayObjectContainer).removeChild(child);
      }

      _child._parent = this;

      children.insert(index, child);

      if (_stage != null) _child._setStageReference(_stage);

      return child;
    } else {
      throw new Exception('$child  The index $index supplied is out of bounds ${children.length}');
    }
  }


  /// Swaps the depth of 2 displayObjects
  bool swapChildren(DisplayInterface child, DisplayInterface child2) {
    if (child == child2) {
      return false;
    }

    int index1 = children.indexOf(child);
    int index2 = children.indexOf(child2);

    if (index1 < 0 || index2 < 0) {
      throw new Exception('swapChildren: Both the supplied DisplayObjects must be a child of the caller.');
    }

    children[index1] = child2;
    children[index2] = child;
    return true;
  }

  /// Returns the child at the specified index
  DisplayInterface getChildAt(int index) {
    if (index >= 0 && index < children.length) {
      return children[index];
    } else {
      throw new Exception('Supplied index does not exist in the child list, or the supplied DisplayObject must be a child of the caller');
    }
  }

  /// Removes a child from the container.
  DisplayInterface removeChild(DisplayInterface child) {
    return removeChildAt(children.indexOf(child));
  }


  /// Removes a child from the specified index position in the child list of the container.
  DisplayInterface removeChildAt(int index) {
    DisplayObject child = getChildAt(index);
    if (_stage != null && child is DisplayObjectContainer) child._removeStageReference();

    child._parent = null;
    children.removeAt(index);
    return child;
  }


  /// Removes all child instances from the child list of the container.
  List<DisplayInterface> removeChildren([int begin = 0, int end]) {
    end = end == null ? children.length : end;
    int range = end - begin;

    if (range > 0 && range <= end) {
      var removed = children.getRange(begin, range);
      children.removeRange(begin, range);
      for (DisplayObject child in removed) {
        child._stage = null;
        //if (stage != null)
        //  child.removeStageReference();
        child._parent = null;
      }
      return removed;
    } else {
      throw new Exception('Range Error, numeric values are outside the acceptable range');
    }
  }

  /// Updates the container's childrens transform for rendering
  updateTransform() {
    //this._currentBounds = null;

    if (!this.visible) return;

    super.updateTransform();

    if (this._cacheAsBitmap) return;

    for (int i = 0,
        j = this.children.length; i < j; i++) {
      this.children[i].updateTransform();
    }
  }

  /// Retrieves the bounds of the displayObjectContainer as a rectangle object
  Rectangle getBounds([Matrix matrix]) {
    if (this.children.length == 0) return EmptyRectangle;

    // TODO the bounds have already been calculated this render session so return what we have
    if (matrix != null) {
      Matrix matrixCache = this._worldTransform;
      this._worldTransform = matrix;
      this.updateTransform();
      this._worldTransform = matrixCache;
    }

    num minX = double.INFINITY;
    num minY = double.INFINITY;

    num maxX = double.NEGATIVE_INFINITY;
    num maxY = double.NEGATIVE_INFINITY;

    Rectangle childBounds;
    num childMaxX;
    num childMaxY;

    bool childVisible = false;

    for (int i = 0,
        j = this.children.length; i < j; i++) {
      DisplayObject child = this.children[i];

      if (!child.visible) continue;

      childVisible = true;

      childBounds = child.getBounds(matrix);

      minX = minX < childBounds.x ? minX : childBounds.x;
      minY = minY < childBounds.y ? minY : childBounds.y;

      childMaxX = childBounds.width + childBounds.x;
      childMaxY = childBounds.height + childBounds.y;

      maxX = maxX > childMaxX ? maxX : childMaxX;
      maxY = maxY > childMaxY ? maxY : childMaxY;
    }

    if (!childVisible) return EmptyRectangle;

    Rectangle bounds = this._bounds;

    bounds.x = minX;
    bounds.y = minY;
    bounds.width = maxX - minX;
    bounds.height = maxY - minY;

    // TODO: store a reference so that if this function gets called again in the render cycle we do not have to recalculate
    //this._currentBounds = bounds;

    return bounds;
  }

  ///
  Rectangle getLocalBounds() {
    Matrix matrixCache = this._worldTransform;

    this._worldTransform = IdentityMatrix;

    for (int i = 0,
        j = this.children.length; i < j; i++) {
      this.children[i].updateTransform();
    }

    Rectangle bounds = this.getBounds();

    this._worldTransform = matrixCache;

    return bounds;
  }

  /// Sets the container's stage reference, the stage this object is connected to
  void _setStageReference(Stage stage) {
    this._stage = stage;
    if (this._interactive) this._stage._dirty = true;

    for (int i = 0,
        j = this.children.length; i < j; i++) {
      DisplayObject child = this.children[i];
      child._setStageReference(stage);
    }
  }

  /// removes the current stage reference of the container
  void _removeStageReference() {

    for (int i = 0,
        j = this.children.length; i < j; i++) {
      DisplayObjectContainer child = this.children[i];
      child._removeStageReference();
    }

    if (this._interactive) this._stage._dirty = true;

    this._stage = null;
  }

  /// Renders the object using the WebGL renderer
  void _renderWebGL(RenderSession renderSession) {
    if (!this.visible || this.alpha <= 0) return;

    if (this._cacheAsBitmap) {
      this._renderCachedSprite(renderSession);
      return;
    }

    int i, j;

    if (this._mask != null || this._filters != null) {
      if (this._filters != null) {
        renderSession.spriteBatch.flush();
        renderSession.filterManager.pushFilter(this._filterBlock);
      }

      if (this._mask != null) {
        renderSession.spriteBatch.stop();
        renderSession.maskManager.pushMask(this._mask, renderSession);
        renderSession.spriteBatch.start();
      }


      // simple render children!
      for (int i = 0,
          j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }

      renderSession.spriteBatch.stop();


      if (this._mask != null) renderSession.maskManager.popMask(this._mask, renderSession);
      if (this._filters != null) renderSession.filterManager.popFilter();

      renderSession.spriteBatch.start();
    } else {
      // simple render children!
      for (int i = 0,
          j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }
    }
  }

  /// Renders the object using the Canvas renderer
  void _renderCanvas(RenderSession renderSession) {
    if (this.visible == false || this.alpha == 0) return;

    if (this._cacheAsBitmap) {

      this._renderCachedSprite(renderSession);
      return;
    }

    if (this._mask != null) {
      renderSession.maskManager.pushMask(this._mask, renderSession.context);
    }

    for (int i = 0,
        j = this.children.length; i < j; i++) {
      DisplayInterface child = this.children[i];
      child._renderCanvas(renderSession);
    }

    if (this._mask != null) {
      renderSession.maskManager.popMask(renderSession.context);
    }
  }
}
