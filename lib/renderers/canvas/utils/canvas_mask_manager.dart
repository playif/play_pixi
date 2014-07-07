part of PIXI;

class CanvasMaskManager {
  CanvasMaskManager() {
  }

  pushMask(maskData, context) {
    context.save();

    var cacheAlpha = maskData.alpha;
    var transform = maskData.worldTransform;

    context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);

    PIXI.CanvasGraphics.renderGraphicsMask(maskData, context);

    context.clip();

    maskData.worldAlpha = cacheAlpha;
  }


  popMask(context) {
    context.restore();
  }
}
