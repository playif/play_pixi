part of PIXI;

class InteractionData {
  Point global = new Point();
  DisplayObjectContainer target = null;
  Event originalEvent = null;

  //bool interactiveChildren = false;


  Point getLocalPosition(DisplayObject displayObject, Point point) {
    Matrix worldTransform = displayObject._worldTransform;

    // do a cheeky transform to get the mouse coords;
    num a00 = worldTransform.a, a01 = worldTransform.c, a02 = worldTransform.tx,
    a10 = worldTransform.b, a11 = worldTransform.d, a12 = worldTransform.ty,
    id = 1 / (a00 * a11 + a01 * -a10);

    if(point == null) point  = new Point();
    point.x = a11 * id * global.x + -a01 * id * global.y + (a12 * a01 - a02 * a11) * id;
    point.y = a00 * id * global.y + -a10 * id * global.x + (-a12 * a00 + a02 * a10) * id;

    // set the mouse coords...
    //return new Point(a11 * id * global.x + -a01 * id * global.y + (a12 * a01 - a02 * a11) * id,
    //a00 * id * global.y + -a10 * id * global.x + (-a12 * a00 + a02 * a10) * id);
    return point;
  }
}
