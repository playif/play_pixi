part of PIXI;

class ChartData {
  String font;
  num size;
  num lineHeight;
  Map chars = {};
}

class Char {
  Texture texture;
  int line;
  int charCode;
  Point position;

  int xOffset;
  int yOffset;
  int xAdvance;
  Map kernings = {};
}


/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A Text Object will create a line(s) of text using bitmap font. To split a line you can use '\n', '\r' or '\r\n'
 * You can generate the fnt files using
 * http://www.angelcode.com/products/bmfont/ for windows or
 * http://www.bmglyph.com/ for mac.
*/
class BitmapText extends DisplayObjectContainer {
  static Map fonts = {};
  static RegExp _charCodeReg = new RegExp("(?:\r\n|\r|\n)");
  static RegExp _numReg = new RegExp("[a-zA-Z]");
  
  String text;
  TextStyle _style;
  TextStyle get style => _style;

  List _pool;
  bool _dirty;
  int tint = 0xFFFFFF;
  String fontName;
  num fontSize;


  num _textWidth;
  num get textWidth => _textWidth;

  num _textHeight;
  num get textHeight => _textHeight;


  BitmapText(String text, [TextStyle style]) {

    this.text = text;

    if (style == null) {
      style = new TextStyle();
    }
    this._style = style;

    this._pool = [];

    this.setText(text);
    this.setStyle(style);
    this.updateText();
    this._dirty = false;
  }

  /// Set the copy for the text object
  setText(text) {
    this.text = text;
    this._dirty = true;
  }

  /// Set the [style] of the text
  setStyle(TextStyle style) {
    //style = style || {};
    //style.align = style.align || 'left';

    this._style = style;

    var font = style.font.split(' ');
    this.fontName = font[font.length - 1];
    this.fontSize = font.length >= 2 ? int.parse(font[font.length - 2].replaceAll(_numReg, "")) : BitmapText.fonts[this.fontName].size;

    this._dirty = true;

    this.tint = style.tint;
  }

  /// Renders text and updates it when needed
  updateText() {
    //if(this.fontName == null) return;
    ChartData data = fonts[this.fontName];
    var pos = new Point();
    int prevCharCode = null;
    List<Char> chars = [];
    int maxLineWidth = 0;
    List lineWidths = [];
    int line = 0;
    num scale = this.fontSize / data.size;


    for (int i = 0; i < this.text.length; i++) {
      int charCode = this.text.codeUnitAt(i);
      if (text[i] == '\n' || text[i] == '\r' || text[i] == '\r\n') {
        lineWidths.add(pos.x);
        maxLineWidth = max(maxLineWidth, pos.x);
        line++;

        pos.x = 0;
        pos.y += data.lineHeight;
        prevCharCode = null;
        continue;
      }

      Char charData = data.chars[charCode];
      if (charData == null) continue;

      if (prevCharCode != null && charData.kernings.containsKey(prevCharCode)) {
        pos.x += charData.kernings[prevCharCode];
      }
      chars.add(new Char()
          ..texture = charData.texture
          ..line = line
          ..charCode = charCode
          ..position = new Point(pos.x + charData.xOffset, pos.y + charData.yOffset));
      pos.x += charData.xAdvance;

      prevCharCode = charCode;
    }

    lineWidths.add(pos.x);
    maxLineWidth = max(maxLineWidth, pos.x);

    List lineAlignOffsets = [];
    for (int i = 0; i <= line; i++) {
      var alignOffset = 0;
      if (this._style.align == 'right') {
        alignOffset = maxLineWidth - lineWidths[i];
      } else if (this._style.align == 'center') {
        alignOffset = (maxLineWidth - lineWidths[i]) / 2;
      }
      lineAlignOffsets.add(alignOffset);
    }

    int lenChildren = this.children.length;
    int lenChars = chars.length;
    int tint = this.tint;
    for (int i = 0; i < lenChars; i++) {
      //print(lenChildren);
      Sprite c = i < lenChildren ? this.children[i] : null; // get old child if have. if not - take from pool.

      if (c == null && this._pool.length > 0) {
        c = this._pool.removeLast();
      }

      if (c != null) c.setTexture(chars[i].texture); // check if got one before.
      else c = new Sprite(chars[i].texture);
      // if no create new one.

      c.position.x = (chars[i].position.x + lineAlignOffsets[chars[i].line]) * scale;
      c.position.y = chars[i].position.y * scale;
      c.scale.x = c.scale.y = scale;
      c.tint = tint;
      if (c._parent == null) this.addChild(c);
    }

    // remove unnecessary children.
    // and put their into the pool.
    while (this.children.length > lenChars) {
      var child = this.getChildAt(this.children.length - 1);
      this._pool.add(child);
      this.removeChild(child);
    }


    /**
     * [read-only] The width of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textWidth
     * @type Number
     */
    this._textWidth = maxLineWidth * scale;

    /**
     * [read-only] The height of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textHeight
     * @type Number
     */
    this._textHeight = (pos.y + data.lineHeight) * scale;
  }

  /// Updates the transform of this object
  updateTransform() {
    if (this._dirty) {
      this.updateText();
      this._dirty = false;
    }
    super.updateTransform();
  }
}
