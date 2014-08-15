part of PIXI;

/**
 * The [Circle] object can be used to specify a hit area for [DisplayObject]s.
 * 
 * The [radius] of the circle
 */
class Circle extends Shape{
  ///property x
  num x;


  /// property y
  num y;

  
  /// property radius
  num radius;



  Circle([this.x = 0, this.y = 0, this.radius = 0]) {

  }


  /**
   * Creates a clone of this [Circle] instance
   *
   * return [Circle] a copy of the polygon
   */
  Circle clone() {
    return new Circle(x, y, radius);
  }


  /**
   * Checks whether the [x], and [y] coordinates passed to this function are contained within this circle
   *
   * return [bool] Whether the [x]/[y] coordinates are within this polygon
   */
  bool contains(num x, num y) {
    if (this.radius <= 0) return false;

    num dx = (this.x - x),
        dy = (this.y - y),
        r2 = this.radius * this.radius;

    dx *= dx;
    dy *= dy;

    return (dx + dy <= r2);
  }

  /**
  * Returns the framing rectangle of the circle as a [Rectangle] object
  *
  * Return rectangle the framing rectangle
  */
  Rectangle getBounds() {
    return new Rectangle(this.x - this.radius, this.y - this.radius, 2 * this.radius, 2 * this.radius);
  }

}
