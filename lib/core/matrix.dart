part of PIXI;



Matrix IdentityMatrix = new Matrix();

Type determineMatrixArrayType() {
    return Float32List;
}

/**
    88   + * The Matrix2 class will choose the best type of array to use between
    89   + * a regular javascript Array and a Float32Array if the latter is available
    90   + *
    91   + * @class Matrix2
    92   + * @constructor
    93   + */
Type Matrix2 = determineMatrixArrayType();



class Matrix {
  num a = 1.0, b = 0.0, c = 0.0, d = 1.0, tx = 0.0, ty = 0.0;

  Float32List array =null;

  Matrix() {
  }

  fromArray(array) {
    this.a = array[0];
    this.b = array[1];
    this.c = array[3];
    this.d = array[4];
    this.tx = array[2];
    this.ty = array[5];
  }

  Float32List toArray(bool transpose) {
    if(this.array == null) this.array = new Float32List(9);
    Float32List array =this.array;

    if (transpose) {
      array[0] = this.a;
      array[1] = this.c;
      array[2] = .0;
      array[3] = this.b;
      array[4] = this.d;
      array[5] = .0;
      array[6] = this.tx;
      array[7] = this.ty;
      array[8] = 1.0;
    }
    else {
      array[0] = this.a;
      array[1] = this.b;
      array[2] = this.tx;
      array[3] = this.c;
      array[4] = this.d;
      array[5] = this.ty;
      array[6] = .0;
      array[7] = .0;
      array[8] = 1.0;
    }

    return array;
  }

}
