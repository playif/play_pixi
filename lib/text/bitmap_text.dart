part of PIXI;

class BitmapText extends DisplayObjectContainer {
  static Map fonts = {
  };
  String text;
  Map style;
  static RegExp charCodeReg = new RegExp("(?:\r\n|\r|\n)");

  BitmapText(this.text, this.style) {

    this._pool = [];

    this.setText(text);
    this.setStyle(style);
    this.updateText();
    this.dirty = false;
  }

  setText(text) {
    this.text = text;
    this.dirty = true;
  }

  setStyle(style) {
    //style = style || {};
    style.align = style.align || 'left';
    this.style = style;

    var font = style.font.split(' ');
    this.fontName = font[font.length - 1];
    this.fontSize = font.length >= 2 ? parseInt(font[font.length - 2], 10) : PIXI.BitmapText.fonts[this.fontName].size;

    this.dirty = true;
    this.tint = style.tint;
  }

  updateText() {
    var data = fonts[this.fontName];
    var pos = new Point();
    var prevCharCode = null;
    var chars = [];
    var maxLineWidth = 0;
    List lineWidths = [];
    var line = 0;
    var scale = this.fontSize / data.size;


    for (var i = 0; i < this.text.length; i++) {
      var charCode = this.text.charCodeAt(i);
      if ((this.text.charAt(i))) {
        lineWidths.add(pos.x);
        maxLineWidth = Math.max(maxLineWidth, pos.x);
        line++;

        pos.x = 0;
        pos.y += data.lineHeight;
        prevCharCode = null;
        continue;
      }

      var charData = data.chars[charCode];
      if (charData ==null) continue;

      if (prevCharCode && charData[prevCharCode]) {
        pos.x += charData.kerning[prevCharCode];
      }
      chars.push({
          texture:charData.texture, line: line, charCode: charCode, position: new PIXI.Point(pos.x + charData.xOffset, pos.y + charData.yOffset)
      });
      pos.x += charData.xAdvance;

      prevCharCode = charCode;
    }

    lineWidths.push(pos.x);
    maxLineWidth = Math.max(maxLineWidth, pos.x);

    var lineAlignOffsets = [];
    for (i = 0; i <= line; i++) {
      var alignOffset = 0;
      if (this.style.align == 'right') {
        alignOffset = maxLineWidth - lineWidths[i];
      }
      else if (this.style.align == 'center') {
        alignOffset = (maxLineWidth - lineWidths[i]) / 2;
      }
      lineAlignOffsets.push(alignOffset);
    }

    var lenChildren = this.children.length;
    var lenChars = chars.length;
    var tint = this.tint || 0xFFFFFF;
    for (i = 0; i < lenChars; i++) {
      var c = i < lenChildren ? this.children[i] : this._pool.pop(); // get old child if have. if not - take from pool.

      if (c) c.setTexture(chars[i].texture); // check if got one before.
      else c = new PIXI.Sprite(chars[i].texture);
      // if no create new one.

      c.position.x = (chars[i].position.x + lineAlignOffsets[chars[i].line]) * scale;
      c.position.y = chars[i].position.y * scale;
      c.scale.x = c.scale.y = scale;
      c.tint = tint;
      if (!c.parent) this.addChild(c);
    }

// remove unnecessary children.
// and put their into the pool.
    while (this.children.length > lenChars) {
      var child = this.getChildAt(this.children.length - 1);
      this._pool.push(child);
      this.removeChild(child);
    }


    /**
     * [read-only] The width of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textWidth
     * @type Number
     */
    this.textWidth = maxLineWidth * scale;

    /**
     * [read-only] The height of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textHeight
     * @type Number
     */
    this.textHeight = (pos.y + data.lineHeight) * scale;
  }

  updateTransform() {
    if (this.dirty) {
      this.updateText();
      this.dirty = false;
    }
    super.updateTransform(this);
  }
}
