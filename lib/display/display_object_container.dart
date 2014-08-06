part of PIXI;



class DisplayObjectContainer extends DisplayObject {
  List<DisplayInterface> children = [];

//  Stage stage = null;
//  bool visible = true;

  num _width; 

  num get width {
    return this.scale.x * this.getLocalBounds().width;
  }

  set width(num value) {
    //this.scale.x = value / (this.getLocalBounds().width / this.scale.x);

    num width = this.getLocalBounds().width;
    if (width != 0) {
      this.scale.x = value / ( width / this.scale.x );
    }
    else {
      this.scale.x = 1;
    }
    this._width = value;
  }

  num _height;

  num get height {
    return this.scale.y * this.getLocalBounds().height;
  }

  set height(num value) {
    //this.scale.y = value / (this.getLocalBounds().height / this.scale.y);

    num height = this.getLocalBounds().height;
    if (height != 0) {
      this.scale.y = value / ( height / this.scale.y );
    }
    else {
      this.scale.y = 1;
    }
    this._height = value;
  }


  DisplayObjectContainer() {
  }

  DisplayInterface addChild(DisplayInterface child) {
    return addChildAt(child, children.length);
  }

  DisplayInterface addChildAt(DisplayInterface child, int index) {
    if (index >= 0 && index <= children.length) {
      if (child.parent != null) {
        (child.parent as DisplayObjectContainer).removeChild(child);
      }

      child.parent = this;

      children.insert(index, child);

      if (stage != null) child.setStageReference(stage);

      return child;
    }
    else {
      throw new Exception('$child  The index $index supplied is out of bounds ${children.length}');
    }
  }


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

  DisplayInterface getChildAt(int index) {
    if (index >= 0 && index < children.length) {
      return children[index];
    }
    else {
      throw new Exception('Supplied index does not exist in the child list, or the supplied DisplayObject must be a child of the caller');
    }
  }

  DisplayInterface removeChild(DisplayInterface child) {
    return removeChildAt(children.indexOf(child));
  }

  DisplayInterface removeChildAt(int index) {
    DisplayInterface child = getChildAt(index);
    if (stage != null && child is DisplayObjectContainer)
      child.removeStageReference();

    child.parent = null;
    children.removeAt(index);
    return child;
  }


  List<DisplayInterface> removeChildren([int begin=0, int end]) {
    end = end == null ? children.length : end;
    int range = end - begin;

    if (range > 0 && range <= end) {
      var removed = children.getRange(begin, range);
      children.removeRange(begin, range);
      for (DisplayInterface child in removed) {
        child.stage = null;
        //if (stage != null)
        //  child.removeStageReference();
        child.parent = null;
      }
      return removed;
    }
    else {
      throw new Exception('Range Error, numeric values are outside the acceptable range');
    }
  }

  updateTransform() {
    //this._currentBounds = null;

    if (!this.visible) return;

    super.updateTransform();

    if (this._cacheAsBitmap) return;

    for (int i = 0, j = this.children.length; i < j; i++) {
      this.children[i].updateTransform();
    }
  }

  Rectangle getBounds([Matrix matrix]) {
    if (this.children.length == 0)return EmptyRectangle;

    // TODO the bounds have already been calculated this render session so return what we have
    if (matrix != null) {
      Matrix matrixCache = this.worldTransform;
      this.worldTransform = matrix;
      this.updateTransform();
      this.worldTransform = matrixCache;
    }

    num minX = double.INFINITY;
    num minY = double.INFINITY;

    num maxX = double.NEGATIVE_INFINITY;
    num maxY = double.NEGATIVE_INFINITY;

    Rectangle childBounds;
    num childMaxX;
    num childMaxY;

    bool childVisible = false;

    for (int i = 0, j = this.children.length; i < j; i++) {
      DisplayInterface child = this.children[i];

      if (!child.visible)continue;

      childVisible = true;

      childBounds = this.children[i].getBounds(matrix);

      minX = minX < childBounds.x ? minX : childBounds.x;
      minY = minY < childBounds.y ? minY : childBounds.y;

      childMaxX = childBounds.width + childBounds.x;
      childMaxY = childBounds.height + childBounds.y;

      maxX = maxX > childMaxX ? maxX : childMaxX;
      maxY = maxY > childMaxY ? maxY : childMaxY;
    }

    if (!childVisible)
      return EmptyRectangle;

    Rectangle bounds = this._bounds;

    bounds.x = minX;
    bounds.y = minY;
    bounds.width = maxX - minX;
    bounds.height = maxY - minY;

    // TODO: store a reference so that if this function gets called again in the render cycle we do not have to recalculate
    //this._currentBounds = bounds;

    return bounds;
  }

  Rectangle getLocalBounds() {
    Matrix matrixCache = this.worldTransform;

    this.worldTransform = IdentityMatrix;

    for (int i = 0, j = this.children.length; i < j; i++) {
      this.children[i].updateTransform();
    }

    Rectangle bounds = this.getBounds();

    this.worldTransform = matrixCache;

    return bounds;
  }

  void setStageReference(Stage stage) {
    this.stage = stage;
    if (this._interactive)this.stage.dirty = true;

    for (int i = 0, j = this.children.length; i < j; i++) {
      DisplayInterface child = this.children[i];
      child.setStageReference(stage);
    }
  }

  void removeStageReference() {

    for (int i = 0, j = this.children.length; i < j; i++) {
      DisplayObjectContainer child = this.children[i];
      child.removeStageReference();
    }

    if (this._interactive) this.stage.dirty = true;

    this.stage = null;
  }

  void _renderWebGL(RenderSession renderSession) {
    if (!this.visible || this.alpha <= 0)return;

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
        renderSession.maskManager.pushMask(this.mask, renderSession);
        renderSession.spriteBatch.start();
      }


      // simple render children!
      for (int i = 0, j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }

      renderSession.spriteBatch.stop();


      if (this._mask != null)renderSession.maskManager.popMask(this._mask, renderSession);
      if (this._filters != null)renderSession.filterManager.popFilter();

      renderSession.spriteBatch.start();
    }
    else {
      // simple render children!
      for (int i = 0, j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }
    }
  }

  void _renderCanvas(RenderSession renderSession) {
    if (this.visible == false || this.alpha == 0)return;

    if (this._cacheAsBitmap) {

      this._renderCachedSprite(renderSession);
      return;
    }

    if (this._mask != null) {
      renderSession.maskManager.pushMask(this._mask, renderSession.context);
    }

    for (int i = 0, j = this.children.length; i < j; i++) {
      DisplayObject child = this.children[i];
      child._renderCanvas(renderSession);
    }

    if (this._mask != null) {
      renderSession.maskManager.popMask(renderSession.context);
    }
  }
}
