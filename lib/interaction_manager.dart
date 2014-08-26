part of PIXI;

class InteractionManager {
  Stage stage;
  InteractionData mouse = new InteractionData();

  Map<int, InteractionData> touchs = {
  };

  Point tempPoint = new Point();

  bool mouseoverEnabled = true;

  final List<InteractionData> pool = [];
  List<DisplayInterface> interactiveItems = [];
  CanvasElement interactionDOMElement;

  Renderer target = null;
  DateTime last = new DateTime.now();

  bool dirty;

  String currentCursorStyle = 'inherit';

  bool mouseOut = false;

  bool isCocoonJS;

  InteractionManager(this.stage) {
    //TODO check this.
    isCocoonJS = window.navigator.appVersion.contains("CocoonJS");
  }

  void collectInteractiveSprite(DisplayObjectContainer displayObject, DisplayObjectContainer iParent) {


    List<DisplayObjectContainer> children = displayObject.children;
    int length = children.length;

    // make an interaction tree... {item.__interactiveParent}
    for (var i = length - 1; i >= 0; i--) {
      DisplayObjectContainer child = children[i];

      // push all interactive bits
      if (child._interactive) {
        iParent.interactiveChildren = true;
        //child.__iParent = iParent;
        this.interactiveItems.add(child);

        if (child.children.length > 0) {
          this.collectInteractiveSprite(child, child);
        }
      } else {
        //child.__iParent = null;

        if (child.children.length > 0) {
          this.collectInteractiveSprite(child, iParent);
        }
      }

    }
  }

  void setTarget(Renderer target) {
    this.target = target;

    //check if the dom element has been set. If it has don't do anything
    if (this.interactionDOMElement == null) {

      this.setTargetDomElement(target.view);
    }


  }

  void setTargetDomElement(Element domElement) {

    this.removeEvents();


    //    if (window.navigator.msPointerEnabled)
    //    {
    //      // time to remove some of that zoom in ja..
    //      domElement.style['-ms-content-zooming'] = 'none';
    //      domElement.style['-ms-touch-action'] = 'none';
    //
    //      // DO some window specific touch!
    //    }

    this.interactionDOMElement = domElement;

    //print("PIXI interactive");

    domElement.addEventListener('mousemove', this.onMouseMove, true);
    domElement.addEventListener('mousedown', this.onMouseDown, true);
    domElement.addEventListener('mouseout', this.onMouseOut, true);

    // aint no multi touch just yet!
    domElement.addEventListener('touchstart', this.onTouchStart, true);
    domElement.addEventListener('touchend', this.onTouchEnd, true);
    domElement.addEventListener('touchmove', this.onTouchMove, true);

    window.addEventListener('mouseup', this.onMouseUp, true);
  }

  void removeEvents() {
    if (this.interactionDOMElement == null) return;

    //    this.interactionDOMElement.style['-ms-content-zooming'] = '';
    //    this.interactionDOMElement.style['-ms-touch-action'] = '';

    this.interactionDOMElement.removeEventListener('mousemove', this.onMouseMove, true);
    this.interactionDOMElement.removeEventListener('mousedown', this.onMouseDown, true);
    this.interactionDOMElement.removeEventListener('mouseout', this.onMouseOut, true);

    // aint no multi touch just yet!
    this.interactionDOMElement.removeEventListener('touchstart', this.onTouchStart, true);
    this.interactionDOMElement.removeEventListener('touchend', this.onTouchEnd, true);
    this.interactionDOMElement.removeEventListener('touchmove', this.onTouchMove, true);

    this.interactionDOMElement = null;

    window.removeEventListener('mouseup', this.onMouseUp, true);
  }

  void update() {
    if (this.target == null) return;

    // frequency of 30fps??
    DateTime now = new DateTime.now();
    num diff = now.difference(this.last).inMilliseconds;
    diff = (diff * INTERACTION_FREQUENCY) / 1000;
    if (diff < 1) return;
    this.last = now;

    int i = 0;

    // ok.. so mouse events??
    // yes for now :)
    // OPTIMISE - how often to check??
    if (this.dirty) {
      //      this.dirty = false;
      //
      //      int len = this.interactiveItems.length;
      //
      //      for (i = 0; i < len; i++) {
      //        this.interactiveItems[i].interactiveChildren = false;
      //      }
      //
      //      this.interactiveItems.clear();
      //
      //      if (this.stage.interactive)this.interactiveItems.add(this.stage);
      //      // go through and collect all the objects that are interactive..
      //      this.collectInteractiveSprite(this.stage, this.stage);
      this.rebuildInteractiveGraph();
    }

    // loop through interactive objects!
    int length = this.interactiveItems.length;
    String cursor = 'inherit';
    bool over = false;
    //print(length);
    for (i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];
      //print(item);
      // OPTIMISATION - only calculate every time if the mousemove function exists..
      // OK so.. does the object have any other interactive functions?
      // hit-test the clip!
      // if(item.mouseover || item.mouseout || item.buttonMode)
      // {
      // ok so there are some functions so lets hit test it..
      item.__hit = this.hitTest(item, this.mouse);
      this.mouse.target = item;

      // ok so deal with interactions..
      // looks like there was a hit!
      if (item.__hit && !over) {

        if (item.buttonMode) cursor = item.defaultCursor;

        if (item is DisplayObjectContainer && !item.interactiveChildren) over = true;

        if (!item.__isOver) {
          //print(item);
          //print(item.mouseover);
          if (item.mouseover != null) item.mouseover(this.mouse);
          item.__isOver = true;
        }
      } else {
        if (item.__isOver) {
          // roll out!
          if (item.mouseout != null) item.mouseout(this.mouse);
          item.__isOver = false;
        }
      }
    }

    if (this.currentCursorStyle != cursor) {
      this.currentCursorStyle = cursor;
      this.interactionDOMElement.style.cursor = cursor;
    }
  }

  rebuildInteractiveGraph() {
    this.dirty = false;

    int len = this.interactiveItems.length;

    for (int i = 0; i < len; i++) {
      DisplayInterface item = this.interactiveItems[i];
      if (item is DisplayObjectContainer) {
        item.interactiveChildren = false;
      }
    }

    this.interactiveItems = [];

    if (this.stage.interactive) this.interactiveItems.add(this.stage);
    // go through and collect all the objects that are interactive..
    this.collectInteractiveSprite(this.stage, this.stage);
  }


  onMouseMove(MouseEvent event) {
    if (this.dirty) {
      this.rebuildInteractiveGraph();
    }

    this.mouse.originalEvent = event; //IE uses window.event
    // TODO optimize by not check EVERY TIME! maybe half as often? //
    var rect = this.interactionDOMElement.getBoundingClientRect();

    this.mouse.global.x = (event.client.x - rect.left) * (this.target.width / rect.width);
    this.mouse.global.y = (event.client.y - rect.top) * (this.target.height / rect.height);

    var length = this.interactiveItems.length;

    for (var i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];

      if (item.mousemove != null) {
        //call the function!
        item.mousemove(this.mouse);
      }
    }
  }

  void onMouseDown(MouseEvent event) {
    if (this.dirty) {
      this.rebuildInteractiveGraph();
    }

    this.mouse.originalEvent = event; //IE uses window.event

    if (AUTO_PREVENT_DEFAULT) this.mouse.originalEvent.preventDefault();

    // loop through interaction tree...
    // hit test each item! ->
    // get interactive items under point??
    //stage.__i
    int length = this.interactiveItems.length;

    // while
    // hit test
    for (var i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];

      if (item.mousedown != null || item.click != null) {
        item.__mouseIsDown = true;
        item.__hit = this.hitTest(item, this.mouse);

        if (item.__hit) {
          //call the function!
          if (item.mousedown != null) item.mousedown(this.mouse);
          item.__isDown = true;

          // just the one!
          if (item is DisplayObjectContainer && !item.interactiveChildren) break;
        }
      }
    }
  }

  void onMouseOut(MouseEvent event) {
    if (this.dirty) {
      this.rebuildInteractiveGraph();
    }

    int length = this.interactiveItems.length;

    this.interactionDOMElement.style.cursor = 'inherit';

    for (var i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];
      if (item.__isOver) {
        this.mouse.target = item;
        if (item.mouseout != null) item.mouseout(this.mouse);
        item.__isOver = false;
      }
    }

    this.mouseOut = true;

    // move the mouse to an impossible position
    this.mouse.global.x = -10000;
    this.mouse.global.y = -10000;
  }

  onMouseUp(MouseEvent event) {
    if (this.dirty) {
      this.rebuildInteractiveGraph();
    }

    this.mouse.originalEvent = event; //IE uses window.event

    int length = this.interactiveItems.length;
    bool up = false;

    for (int i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];

      item.__hit = this.hitTest(item, this.mouse);

      if (item.__hit && !up) {
        //call the function!
        if (item.mouseup != null) {
          item.mouseup(this.mouse);
        }
        if (item.__isDown) {
          if (item.click != null) item.click(this.mouse);
        }

        if (item is DisplayObjectContainer && !item.interactiveChildren) up = true;
      } else {
        if (item.__isDown) {
          if (item.mouseupoutside != null) item.mouseupoutside(this.mouse);
        }
      }

      item.__isDown = false;
      //}
    }
  }


  bool hitTest(DisplayObjectContainer item, InteractionData interactionData) {
    Point global = interactionData.global;

    if (!item.worldVisible) return false;

    // temp fix for if the element is in a non visible

    bool isSprite = (item is Sprite);
    Matrix worldTransform = item._worldTransform;
    num a00 = worldTransform.a,
    a01 = worldTransform.b,
    a02 = worldTransform.tx,
    a10 = worldTransform.c,
    a11 = worldTransform.d,
    a12 = worldTransform.ty,
    id = 1 / (a00 * a11 + a01 * -a10),
    x = a11 * id * global.x + -a01 * id * global.y + (a12 * a01 - a02 * a11) * id,
    y = a00 * id * global.y + -a10 * id * global.x + (-a12 * a00 + a02 * a10) * id;

    interactionData.target = item;

    //a sprite or display object with a hit area defined
    if (item.hitArea != null && item.hitArea.contains != null) {
      //print("$x $y");
      if (item.hitArea.contains(x, y)) {

        //print(item);
        //if(isSprite)
        interactionData.target = item;

        return true;
      }

      return false;
    }
    // a sprite with no hitarea defined
    else if (isSprite) {

      Sprite sprite = item as Sprite;
      var width = sprite.texture.frame.width,
      height = sprite.texture.frame.height,
      x1 = -width * sprite.anchor.x,
      y1;

      if (x > x1 && x < x1 + width) {
        y1 = -height * sprite.anchor.y;

        if (y > y1 && y < y1 + height) {
          // set the target property if a hit is true!
          interactionData.target = sprite;

          return true;
        }
      }
    }

    int length = item.children.length;

    for (int i = 0; i < length; i++) {
      DisplayObject tempItem = item.children[i];
      bool hit = this.hitTest(tempItem, interactionData);
      if (hit) {
        // hmm.. TODO SET CORRECT TARGET?
        interactionData.target = item;
        return true;
      }
    }

    return false;
  }

  void onTouchMove(event) {
    if (this.dirty) {
      this.rebuildInteractiveGraph();
    }

    var changedTouches;
    InteractionData touchData;
    int i = 0;

    if (isCocoonJS) {
      JsObject ev = new JsObject.fromBrowserObject(event);
      changedTouches = new JsArray.from(ev["changedTouches"]);
    }
    else {
      changedTouches = event.changedTouches;
    }


    for (i = 0; i < changedTouches.length; i++) {
      int identifier = -1;

      if (isCocoonJS) {
        JsObject touchEvent = new JsObject.fromBrowserObject(changedTouches[i]);
        identifier = touchEvent['identifier'];
        touchData = this.touchs[identifier];
        touchData.originalEvent = event;
        touchData.global.x = touchEvent["clientX"];
        touchData.global.y = touchEvent["clientY"];
      } else {

        var rect = this.interactionDOMElement.getBoundingClientRect();
        Touch touchEvent = changedTouches[i];
        identifier = touchEvent.identifier;
        touchData = this.touchs[identifier];

        touchData.originalEvent = event;
        // update the touch position
        touchData.global.x = (touchEvent.client.x - rect.left) * (this.target.width / rect.width);
        touchData.global.y = (touchEvent.client.y - rect.top) * (this.target.height / rect.height);
      }

      for (var j = 0; j < this.interactiveItems.length; j++) {
        DisplayObject item = this.interactiveItems[j];
        if (item.touchmove != null && item.__touchData[identifier] != null) item.touchmove(touchData);
      }
    }
  }

  void onTouchStart(event) {
    if (this.dirty) {
      this.rebuildInteractiveGraph();
    }

    var changedTouches;


    if (isCocoonJS) {
      JsObject ev = new JsObject.fromBrowserObject(event);
      changedTouches = new JsArray.from(ev["changedTouches"]);
      if (AUTO_PREVENT_DEFAULT) {
        JsFunction func = ev['preventDefault'];
        func.apply([], thisArg:ev);
      }
    }
    else {
      changedTouches = event.changedTouches;
      if (AUTO_PREVENT_DEFAULT) event.preventDefault();
    }


    for (var i = 0; i < changedTouches.length; i++) {
      InteractionData touchData;
      int identifier = -1;
      if (this.pool.length > 0) {
        touchData = this.pool.removeLast();
      }
      if (touchData == null) touchData = new InteractionData();
      touchData.originalEvent = event;


      if (isCocoonJS) {
        JsObject touchEvent = new JsObject.fromBrowserObject(changedTouches[i]);
        identifier = touchEvent['identifier'];
        touchData.global.x = touchEvent["clientX"];
        touchData.global.y = touchEvent["clientY"];
      } else {
        Touch touchEvent = changedTouches[i];
        identifier = touchEvent.identifier;
        var rect = this.interactionDOMElement.getBoundingClientRect();
        touchData.global.x = (touchEvent.client.x - rect.left) * (this.target.width / rect.width);
        touchData.global.y = (touchEvent.client.y - rect.top) * (this.target.height / rect.height);
      }

      this.touchs[identifier] = touchData;

      int length = this.interactiveItems.length;

      for (int j = 0; j < length; j++) {
        DisplayObject item = this.interactiveItems[j];

        if (item.touchstart != null || item.tap != null) {
          item.__hit = this.hitTest(item, touchData);

          if (item.__hit) {
            //call the function!
            if (item.touchstart != null) item.touchstart(touchData);
            item.__isDown = true;
            if (item.__touchData == null) {
              item.__touchData = {
              };
            }

            item.__touchData[identifier] = touchData;

            if (item is DisplayObjectContainer && !item.interactiveChildren) break;
          }
        }
      }
    }
  }

  void onTouchEnd(event) {
    if (this.dirty) {
      this.rebuildInteractiveGraph();
    }

    var changedTouches;

    if (isCocoonJS) {
      JsObject ev = new JsObject.fromBrowserObject(event);
      changedTouches = new JsArray.from(ev["changedTouches"]);
    }
    else {
      changedTouches = event.changedTouches;
    }


    for (int i = 0; i < changedTouches.length; i++) {
      InteractionData touchData;
      int identifier = -1;
      bool up = false;

      if (isCocoonJS) {
        JsObject touchEvent = new JsObject.fromBrowserObject(changedTouches[i]);
        identifier = touchEvent['identifier'];
        touchData = this.touchs[identifier];
        touchData.global.x = touchEvent["clientX"];
        touchData.global.y = touchEvent["clientY"];
      } else {
        Touch touchEvent = changedTouches[i];
        identifier = touchEvent.identifier;
        touchData = this.touchs[identifier];
        var rect = this.interactionDOMElement.getBoundingClientRect();
        touchData.global.x = (touchEvent.client.x - rect.left) * (this.target.width / rect.width);
        touchData.global.y = (touchEvent.client.y - rect.top) * (this.target.height / rect.height);
      }

      int length = this.interactiveItems.length;
      for (int j = 0; j < length; j++) {
        DisplayObject item = this.interactiveItems[j];

        if (item.__touchData != null && item.__touchData[identifier] != null) {

          item.__hit = this.hitTest(item, item.__touchData[identifier]);

          // so this one WAS down...
          touchData.originalEvent = event;
          // hitTest??

          if (item.touchend != null || item.tap != null) {
            if (item.__hit && !up) {
              if (item.touchend != null) item.touchend(touchData);
              if (item.__isDown) {
                if (item.tap != null) item.tap(touchData);
              }

              if (item is DisplayObjectContainer && !item.interactiveChildren) up = true;
            } else {
              if (item.__isDown) {
                if (item.touchendoutside != null) item.touchendoutside(touchData);
              }
            }

            item.__isDown = false;
          }

          item.__touchData[identifier] = null;
        }
      }
      // remove the touch..
      this.pool.add(touchData);
      this.touchs[identifier] = null;
    }
  }
}
