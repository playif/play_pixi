part of PIXI;


class DisplayObjectContainer extends DisplayObject {

//  Stage stage = null;
//  bool visible = true;

  DisplayObjectContainer() {
  }

  void addChild(child) {
    addChildAt(child, children.length);
  }

  void addChildAt(DisplayObject child, index) {
    if (index >= 0 && index <= children.length) {
      if (child.parent) {
        child.parent.removeChild(child);
      }

      child.parent = this;

      children.insert(index, child);

      if (stage != null)child.setStageReference(stage);
    }
    else {
      throw new Exception('$child  The index $index supplied is out of bounds ${children.length}');
    }
  }


  void swapChildren(child, child2) {
    if (child == child2) {
      return;
    }

    var index1 = children.indexOf(child);
    var index2 = children.indexOf(child2);

    if (index1 < 0 || index2 < 0) {
      throw new Exception('swapChildren: Both the supplied DisplayObjects must be a child of the caller.');
    }

    children[index1] = child2;
    children[index2] = child;

  }

  getChildAt(index) {
    if (index >= 0 && index < children.length) {
      return children[index];
    }
    else {
      throw new Exception('Supplied index does not exist in the child list, or the supplied DisplayObject must be a child of the caller');
    }
  }

  removeChild(child) {
    return removeChildAt(children.indexOf(child));
  }

  removeChildAt(index) {
    var child = getChildAt(index);
    if (stage != null)
      child.removeStageReference();

    child.parent = null;
    children.removeAt(index);
    return child;
  }


  removeChildren([int begin=0, int end]) {
    end = end == null ? children.length : end;
    var range = end - begin;

    if (range > 0 && range <= end) {
      var removed = children.removeRange(begin, range);
      for (var i = 0; i < removed.length; i++) {
        var child = removed[i];
        if (stage != null)
          child.removeStageReference();
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

    if (!this.visible)return;

    super.updateTransform();

    if (this._cacheAsBitmap)return;

    for (var i = 0, j = this.children.length; i < j; i++) {
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

    num maxX = -double.INFINITY;
    num maxY = -double.INFINITY;

    Rectangle childBounds;
    num childMaxX;
    num childMaxY;

    bool childVisible = false;

    for (int i = 0, j = this.children.length; i < j; i++) {
      DisplayObject child = this.children[i];

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

    Matrix bounds = this.getBounds();

    this.worldTransform = matrixCache;

    return bounds;
  }

  void setStageReference(stage) {
    this.stage = stage;
    if (this._interactive)this.stage.dirty = true;

    for (var i = 0, j = this.children.length; i < j; i++) {
      DisplayObject child = this.children[i];
      child.setStageReference(stage);
    }
  }

  void removeStageReference() {

    for (int i = 0, j = this.children.length; i < j; i++) {
      DisplayObjectContainer child = this.children[i];
      child.removeStageReference();
    }

    if (this._interactive)this.stage.dirty = true;

    this.stage = null;
  }

  void _renderWebGL(renderSession) {
    if (!this.visible || this.alpha <= 0)return;

    if (this._cacheAsBitmap) {
      this._renderCachedSprite(renderSession);
      return;
    }

    var i, j;

    if (this._mask || this._filters) {
      if (this._mask) {
        renderSession.spriteBatch.stop();
        renderSession.maskManager.pushMask(this.mask, renderSession);
        renderSession.spriteBatch.start();
      }

      if (this._filters) {
        renderSession.spriteBatch.flush();
        renderSession.filterManager.pushFilter(this._filterBlock);
      }

      // simple render children!
      for (int i = 0, j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }

      renderSession.spriteBatch.stop();

      if (this._filters)renderSession.filterManager.popFilter();
      if (this._mask)renderSession.maskManager.popMask(renderSession);

      renderSession.spriteBatch.start();
    }
    else {
      // simple render children!
      for (int i = 0, j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }
    }
  }

  void _renderCanvas(renderSession) {
    if (this.visible == false || this.alpha == 0)return;

    if (this._cacheAsBitmap) {

      this._renderCachedSprite(renderSession);
      return;
    }

    if (this._mask) {
      renderSession.maskManager.pushMask(this._mask, renderSession.context);
    }

    for (var i = 0, j = this.children.length; i < j; i++) {
      var child = this.children[i];
      child._renderCanvas(renderSession);
    }

    if (this._mask) {
      renderSession.maskManager.popMask(renderSession.context);
    }
  }
}
