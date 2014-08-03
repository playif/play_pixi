part of PIXI;

class Point {
  num x, y;

  Point([num x=0, num y=0]) {
    this.x = x;
    this.y = y;
  }

  clone() {
    return new Point(x, y);
  }

  set([num x=0, num y]) {
    this.x = x;
    this.y = y == null ? this.x : y;
  }
}
