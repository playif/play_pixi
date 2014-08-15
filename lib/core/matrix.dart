part of PIXI;
/**
 * @author Mat Groves [http://matgroves.com/] @Doormat23
 */


Matrix IdentityMatrix = new Matrix();

Type determineMatrixArrayType() {
  return Float32List;
}


/**
 * The [Matrix2] class will choose the best type of array to use between
 * a regular javascript Array and a Float32Array if the latter is available
 */
Type Matrix2 = determineMatrixArrayType();




/**
 * The Matrix class is now an object, which makes it a lot faster.
 * 
 *     here is a representation of it : 
 *     | a | b | tx|
 *     | c | d | ty|
 *     | 0 | 0 | 1 |
 * 
 */
class Matrix {
  double a = 1.0,
      b = 0.0,
      c = 0.0,
      d = 1.0,
      tx = 0.0,
      ty = 0.0;

  Float32List array = new Float32List(9);

  
  double operator [](int i) {
    return array[i];
  }



  Matrix() {
  }

  
  /**
   * Creates a pixi matrix object based on the [array] given as a parameter
   *
   * [array] The array that the matrix will be filled with
   */
  Matrix.fromArray(List array) {
    this.a = array[0];
    this.b = array[1];
    this.c = array[3];
    this.d = array[4];
    this.tx = array[2];
    this.ty = array[5];
  }

  
  /**
   * Creates an array from the current Matrix object
   * 
   * [transpose] Whether we need to transpose the matrix or not
   * 
   * Return [Float32List] the newly created array which contains the matrix
   */
  Float32List toArray(bool transpose) {
    Float32List array = this.array;

    if (transpose) {
      array[0] = this.a;
      array[1] = this.c;
      array[2] = 0.0;
      array[3] = this.b;
      array[4] = this.d;
      array[5] = 0.0;
      array[6] = this.tx;
      array[7] = this.ty;
      array[8] = 1.0;
    } else {
      array[0] = this.a;
      array[1] = this.b;
      array[2] = this.tx;
      array[3] = this.c;
      array[4] = this.d;
      array[5] = this.ty;
      array[6] = 0.0;
      array[7] = 0.0;
      array[8] = 1.0;
    }

    return array;
  }

}
