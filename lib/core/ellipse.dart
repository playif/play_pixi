part of PIXI;

/**
 * The [Ellipse] object can be used to specify a hit area for [DisplayObject]s.
 *
 */
class Ellipse extends Shape{
  ///property x
  num x;

  ///property y
  num y;

  ///property width
  num width;

  ///property height
  num height;

  /**
   * The [Ellipse] object can be used to specify a hit area for [DisplayObject]s.
   *
   * The [x] coordinate of the center of the ellipse
   * 
   * The [y] coordinate of the center of the ellipse
   * 
   * The half [width] of this ellipse
   * 
   * The half [height] of this ellipse
   * 
   */
  Ellipse([this.x = 0, this.y = 0, this.width = 0, this.height = 0]) {


  }

  /**
   * Creates a clone of this [Ellipse] instance
   * 
   * [Ellipse] a copy of the ellipse
   */
  Ellipse clone() {
    return new Ellipse(this.x, this.y, this.width, this.height);
  }

  /**
   * Checks whether the x and y coordinates passed to this function are contained within this ellipse
   *
   * return [bool] Whether the x/y coords are within this ellipse
   */
  bool contains(num x, num y) {
    if (this.width <= 0 || this.height <= 0) return false;


    //normalize the coords to an ellipse with center 0,0
    var normx = ((x - this.x) / this.width),
        normy = ((y - this.y) / this.height);

    normx *= normx;
    normy *= normy;

    return (normx + normy <= 1);
  }

  /**
  * Returns the framing rectangle of the ellipse as a [Rectangle] object
  *
  * return rectangle the framing rectangle
  */
  Rectangle getBounds() {
    return new Rectangle(this.x - this.width, this.y - this.height, this.width, this.height);
  }


}
