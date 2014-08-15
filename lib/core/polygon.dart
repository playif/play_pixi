part of PIXI;

/**
 * @author Adrien Brault <adrien.brault@gmail.com>
 */

/**
 * @class Polygon
 * @constructor
 * @param points* {Array<Point>|Array<Number>|Point...|Number...} This can be an array of Points that form the polygon,
 *      a flat array of numbers that will be interpreted as [x,y, x,y, ...], or the arguments passed can be
 *      all the points of the polygon e.g. `new PIXI.Polygon(new PIXI.Point(), new PIXI.Point(), ...)`, or the
 *      arguments passed can be flat x,y values e.g. `new PIXI.Polygon(x,y, x,y, x,y, ...)` where `x` and `y` are
 *      Numbers.
 */
class Polygon extends Shape {
  List<Point> points;

  Polygon(List points) {
    //if points isn't an array, use arguments as the array
    //    if(!(points is List))
    //      points = Array.prototype.slice.call(arguments);

    //if this is a flat array of numbers, convert it to points
    if (points[0] is num) {
      List<Point> p = [];
      for (var i = 0,
          il = points.length; i < il; i += 2) {
        p.add(new Point(points[i], points[i + 1]));
      }

      points = p;
    }

    this.points = points;
  }

  /**
   * Creates a clone of this polygon
   *
   * @method clone
   * @return [Polygon] a copy of the polygon
   */

  clone() {
    List points = [];
    for (int i = 0; i < this.points.length; i++) {
      points.add(this.points[i].clone());
    }
    return new Polygon(points);
  }

  /**
   * Checks whether the x and y coordinates passed to this function are contained within this polygon
   *
   * @method contains
   * @param x {Number} The X coordinate of the point to test
   * @param y {Number} The Y coordinate of the point to test
   * @return {Boolean} Whether the x/y coordinates are within this polygon
   */

  contains(num x, num y) {
    bool inside = false;

    // use some raycasting to test hits
    // https://github.com/substack/point-in-polygon/blob/master/index.js
    for (int i = 0,
        j = this.points.length - 1; i < this.points.length; j = i++) {
      num xi = this.points[i].x,
          yi = this.points[i].y,
          xj = this.points[j].x,
          yj = this.points[j].y;
      bool intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

      if (intersect) inside = !inside;
    }

    return inside;
  }

}
