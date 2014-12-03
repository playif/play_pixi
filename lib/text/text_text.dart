part of PIXI;

class TextStyle {
  String fill = 'black';
  String font = 'bold 20pt Arial';
  String align = 'left';
  String stroke = 'black';
  num strokeThickness = 0;
  bool wordWrap = false;
  num wordWrapWidth = 100;
  bool dropShadow = false;
  num dropShadowAngle = PI / 6;
  num dropShadowDistance = 4;
  String dropShadowColor = 'black';

  TextStyle({String fill : 'black',
            String font : 'bold 20pt Arial',
            String align : 'left',
            String stroke : 'black',
            num strokeThickness : 0,
            num tint : 0xFFFFFF
            }) {
    this.fill = fill;
    this.font = font;
    this.align = align;
    this.stroke = stroke;
    this.strokeThickness = strokeThickness;
    this.tint = tint;
  }

  num tint = 0xFFFFFF;

}


/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 * - Modified by Tom Slezakowski http://www.tomslezakowski.com @TomSlezakowski (24/03/2014) - Added dropShadowColor.
 */

/**
 * A Text Object will create a line(s) of text. To split a line you can use '\n' 
 * or add a wordWrap property set to true and and wordWrapWidth property with a value
 * in the style object
 *
 * @class Text
 * @extends Sprite
 * @constructor
 * @param text {String} The copy that you would like the text to display
 * @param [style] {Object} The style parameters
 * @param [style.font] {String} default 'bold 20px Arial' The style and size of the font
 * @param [style.fill='black'] {String|Number} A canvas fillstyle that will be used on the text e.g 'red', '#00FF00'
 * @param [style.align='left'] {String} Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text
 * @param [style.stroke] {String|Number} A canvas fillstyle that will be used on the text stroke e.g 'blue', '#FCFF00'
 * @param [style.strokeThickness=0] {Number} A number that represents the thickness of the stroke. Default is 0 (no stroke)
 * @param [style.wordWrap=false] {Boolean} Indicates if word wrap should be used
 * @param [style.wordWrapWidth=100] {Number} The width at which text will wrap, it needs wordWrap to be set to true
 * @param [style.dropShadow=false] {Boolean} Set a drop shadow for the text
 * @param [style.dropShadowColor='#000000'] {String} A fill style to be used on the dropshadow e.g 'red', '#00FF00'
 * @param [style.dropShadowAngle=Math.PI/4] {Number} Set a angle of the drop shadow
 * @param [style.dropShadowDistance=5] {Number} Set a distance of the drop shadow
 */
class Text extends Sprite {
  static RegExp splitReg = new RegExp("(?:\r\n|\r|\n)");
  static Map<String, int> heightCache = {
  };
  String _text;
  TextStyle _style;
  TextStyle get style => _style;
  
  /// The canvas element that everything is drawn to
  CanvasElement _canvas;
  CanvasElement get canvas => _canvas;
  CanvasRenderingContext2D _context;
  CanvasRenderingContext2D get context => _context;
  
  bool _dirty = false;
  bool _requiresUpdate;

  String get text=>_text;
  set text(String value){
    setText(value);
  }

  Text(String text, TextStyle style) :super._() {
    this._text=text;
    this._style=style;

    this._canvas = new CanvasElement(); //document.createElement('canvas');

    this._context = this._canvas.getContext('2d');

    this.texture = Texture.fromCanvas(this._canvas);
    _setupTexture();

    this.setText(text);
    this.setStyle(style);

    //this.updateText();
    //this.dirty = false;
  }

  /// Set the style of the text
  setStyle(TextStyle style) {
    this._style = style;
    this._dirty = true;
  }

  /// Set the copy for the text object. To split a line you can use '\n'
  setText(Object text) {
    this._text = text.toString();
    this._dirty = true;
  }

  /// The width of the sprite, setting this will actually modify the scale to achieve the value set
  num get width {

    if (this._dirty) {
      this.updateText();
      this._dirty = false;
    }
    return this.scale.x * this.texture.frame.width;
  }

  set width(num value) {
    this.scale.x = value / this.texture.frame.width;
    this._width = value;
  }


  /// The height of the Text, setting this will actually modify the scale to achieve the value set
  num get height {

    if (this._dirty) {
      this.updateText();
      this._dirty = false;
    }
    return this.scale.y * this.texture.frame.height;
  }

  set height(num value) {
    this.scale.y = value / this.texture.frame.height;
    this._height = value;
  }

  /// Renders text and updates it when needed
  updateText() {
    this._context.font = this.style.font;

    var outputText = this.text;

    // word wrap
    // preserve original text
    if (this.style.wordWrap) outputText = this.wordWrap(this.text);

    //split text into lines
    var lines = outputText.split(splitReg);

    //calculate text width
    List<num> lineWidths = new List<num>(lines.length);
    var maxLineWidth = 0;
    for (int i = 0; i < lines.length; i++) {
      num lineWidth = this._context.measureText(lines[i]).width;
      lineWidths[i] = lineWidth;
      maxLineWidth = max(maxLineWidth, lineWidth);
    }

    var width = maxLineWidth + this.style.strokeThickness;
    if (this.style.dropShadow)width += this.style.dropShadowDistance;

    this._canvas.width = (width + this._context.lineWidth).floor();
    //calculate text height
    var lineHeight = this.determineFontHeight('font: ' + this.style.font + ';') + this.style.strokeThickness;

    var height = lineHeight * lines.length;
    if (this.style.dropShadow)height += this.style.dropShadowDistance;

    this._canvas.height = height;

    //if(navigator.isCocoonJS) this.context.clearRect(0,0,this.canvas.width,this.canvas.height);

    this._context.font = this.style.font;
    this._context.strokeStyle = this.style.stroke;
    this._context.lineWidth = this.style.strokeThickness;
    this._context.textBaseline = 'top';

    var linePositionX;
    var linePositionY;

    if (this.style.dropShadow) {
      this._context.fillStyle = this.style.dropShadowColor;

      var xShadowOffset = sin(this.style.dropShadowAngle) * this.style.dropShadowDistance;
      var yShadowOffset = cos(this.style.dropShadowAngle) * this.style.dropShadowDistance;

      for (int i = 0; i < lines.length; i++) {
        linePositionX = this.style.strokeThickness / 2;
        linePositionY = this.style.strokeThickness / 2 + i * lineHeight;

        if (this.style.align == 'right') {
          linePositionX += maxLineWidth - lineWidths[i];
        }
        else if (this.style.align == 'center') {
          linePositionX += (maxLineWidth - lineWidths[i]) / 2;
        }

        if (this.style.fill != null) {
          this._context.fillText(lines[i], linePositionX + xShadowOffset, linePositionY + yShadowOffset);
        }

        //  if(dropShadow)
      }
    }

    //set canvas text styles
    this._context.fillStyle = this.style.fill;

    //draw lines line by line
    for (int i = 0; i < lines.length; i++) {
      linePositionX = this.style.strokeThickness / 2;
      linePositionY = this.style.strokeThickness / 2 + i * lineHeight;

      if (this.style.align == 'right') {
        linePositionX += maxLineWidth - lineWidths[i];
      }
      else if (this.style.align == 'center') {
        linePositionX += (maxLineWidth - lineWidths[i]) / 2;
      }

      if (this.style.stroke != null && this.style.strokeThickness != 0) {
        this._context.strokeText(lines[i], linePositionX, linePositionY);
      }

      if (this.style.fill != null) {
        this._context.fillText(lines[i], linePositionX, linePositionY);
      }

      //  if(dropShadow)
    }


    this.updateTexture();
  }

  /// Updates texture size based on canvas size
  updateTexture() {
    this.texture.baseTexture.width = this._canvas.width;
    this.texture.baseTexture.height = this._canvas.height;
    this.texture.crop.width = this.texture.frame.width = this._canvas.width;
    this.texture.crop.height = this.texture.frame.height = this._canvas.height;

    this._width = this._canvas.width;
    this._height = this._canvas.height;

    this._requiresUpdate = true;
  }

  /// Renders the object using the WebGL renderer
  _renderWebGL(RenderSession renderSession) {
    if (this._requiresUpdate) {
      this._requiresUpdate = false;
      updateWebGLTexture(this.texture.baseTexture, renderSession.gl);
    }

    super._renderWebGL(renderSession);
  }

  /// Updates the transform of this object
  updateTransform() {
    if (this._dirty) {
      this.updateText();
      this._dirty = false;
    }
    super.updateTransform();
  }

  /*
   * http://stackoverflow.com/users/34441/ellisbben
   * great solution to the problem!
   * returns the height of the given font
   */
  num determineFontHeight(String fontStyle) {
    // build a little reference dictionary so if the font style has been used return a
    // cached version...
    var result = Text.heightCache[fontStyle];

    if (result == null) {
      BodyElement body = document.getElementsByTagName('body')[0];
      DivElement dummy = new DivElement();
      //var dummyText = document.cre.createTextNode('M');
      dummy.text = 'M';
      dummy.setAttribute('style', fontStyle + ';position:absolute;top:0;left:0');
      body.append(dummy);

      result = dummy.offsetHeight;
      Text.heightCache[fontStyle] = result;

      dummy.remove();
    }

    return result;
  }

  /**
   * Applies newlines to a [text] to have it optimally fit into the horizontal
   * bounds set by the Text object's wordWrapWidth property.
   */
  String wordWrap(String text) {
    // Greedy wrapping algorithm that will wrap words as the line grows longer
    // than its horizontal bounds.
    String result = '';
    List<String> lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      var spaceLeft = this.style.wordWrapWidth;
      var words = lines[i].split(' ');
      for (int j = 0; j < words.length; j++) {
        var wordWidth = this._context.measureText(words[j]).width;
        var wordWidthWithSpace = wordWidth + this._context.measureText(' ').width;
        if (j == 0 || wordWidthWithSpace > spaceLeft) {
          // Skip printing the newline if it's the first word of the line that is
          // greater than the word wrap width.
          if (j > 0) {
            result += '\n';
          }
          result += words[j];
          spaceLeft = this.style.wordWrapWidth - wordWidth;
        }
        else {
          spaceLeft -= wordWidthWithSpace;
          result += ' ' + words[j];
        }
      }

      if (i < lines.length - 1) {
        result += '\n';
      }
    }
    return result;
  }

  /// Destroys this text object
  destroy([destroyBaseTexture]) {
    this._context = null;
    this._canvas = null;

    this.texture.destroy(destroyBaseTexture == null ? true : destroyBaseTexture);
  }


}
