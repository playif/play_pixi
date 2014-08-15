part of PIXI;

class CanvasMaskManager extends MaskManager {
  CanvasMaskManager() {
  }

  pushMask(maskData, [context]) {
    context.save();

    var cacheAlpha = maskData.alpha;
    var transform = maskData._worldTransform;

    context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);

    CanvasGraphics.renderGraphicsMask(maskData, context);

    context.clip();

    maskData._worldAlpha = cacheAlpha;
  }


  popMask(context, [RenderSession renderSession]) {
    context.restore();
  }

  destroy() {

  }

  setContext(RenderingContext a) {

  }
}
