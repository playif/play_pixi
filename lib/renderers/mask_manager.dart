part of PIXI;

abstract class MaskManager {
//  MaskManager() {
//  }

  pushMask(maskData, [context]);

  popMask(maskData, [RenderSession  renderSession]);

  setContext(RenderingContext gl);

  destroy();
}
