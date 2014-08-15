part of PIXI;

Rectangle EmptyRectangle = new Rectangle(0, 0, 0, 0);


/**
 * @author Mat Groves http://matgroves.com/
 */

/**
 * the Rectangle object is an area defined by its position, as indicated by its top-left corner point (x, y) and by its width and its height.
 *
 * @class Rectangle
 * @constructor
 * @param x {Number} The X coord of the upper-left corner of the rectangle
 * @param y {Number} The Y coord of the upper-left corner of the rectangle
 * @param width {Number} The overall width of this rectangle
 * @param height {Number} The overall height of this rectangle
 */
class Rectangle extends Shape {
  num x, y, width, height;

  Rectangle([this.x=0, this.y=0, this.width=0, this.height=0]);

  /**
   * Creates a clone of this Rectangle
   *
   */
  Rectangle clone() {
    return new Rectangle(this.x, this.y, this.width, this.height);
  }

  /**
   * Checks whether the [x] and [y] coordinates passed to this function are contained within this Rectangle
   *
   * @return [bool] Whether the x/y coords are within this Rectangle
   */
  bool contains(num x, num y) {
    if (this.width <= 0 || this.height <= 0)
      return false;

    var x1 = this.x;
    if (x >= x1 && x <= x1 + this.width) {
      var y1 = this.y;

      if (y >= y1 && y <= y1 + this.height) {
        return true;
      }
    }
    return false;
  }


}
