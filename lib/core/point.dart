part of PIXI;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The Point object represents a location in a two-dimensional coordinate system, where x represents the horizontal axis and y represents the vertical axis.
 *
 */
class Point {
  ///property x
  num x;

  ///property y
  num y;

  
  Point([num x = 0, num y = 0]) {
    this.x = x;
    this.y = y;
  }

  /**
   * Creates a clone of this point
   *
   * return [Point] a copy of the point
   */
  clone() {
    return new Point(x, y);
  }

  /**
   * Sets the point to a new [x] and [y] position.
   * If [y] is ommited, both [x] and [y] will be set to [x].
   * 
   */
  set([num x = 0, num y]) {
    this.x = x;
    this.y = y == null ? this.x : y;
  }
}
