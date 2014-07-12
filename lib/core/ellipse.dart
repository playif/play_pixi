part of PIXI;

class Ellipse {
  num x, y, width, height;

  Ellipse([this.x=0, this.y=0, this.width=0, this.height=0]) {


  }

  clone() {
    return new Ellipse(this.x, this.y, this.width, this.height);
  }

  bool contains(num x, num y) {
    if (this.width <= 0 || this.height <= 0)
      return false;


    //normalize the coords to an ellipse with center 0,0
    var normx = ((x - this.x) / this.width),
    normy = ((y - this.y) / this.height);


    normx *= normx;
    normy *= normy;


    return (normx + normy <= 1);
  }


  getBounds() {
    return new Rectangle(this.x - this.width, this.y - this.height, this.width, this.height);
  }


}
