part of PIXI;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A MovieClip is a simple way to display an animation depicted by a list of textures.
 */
class MovieClip extends Sprite {
  /// The array of textures that make up the animation
  List<Texture> textures;

  /// The speed that the MovieClip will play at. Higher is faster, lower is slower, default=1.
  num animationSpeed = 1;

  /// Whether or not the movie clip repeats after playing, default = true.
  bool loop = true;

  /// Function to call when a MovieClip finishes playing
  Function onComplete = null;


  num _currentFrame = 0;
  /// [read-only] The MovieClips current frame index (this may not have to be a whole number)
  num get currentFrame => _currentFrame;

  bool _playing = false;

  /// [read-only] Indicates if the MovieClip is currently playing
  bool get playing => _playing;

  /**
  * [read-only] totalFrames is the total number of frames in the MovieClip. This is the same as number of textures
  * assigned to the MovieClip.
  */
  int get totalFrames => textures.length;

  /// A MovieClip is a simple way to display an animation depicted by a list of [textures].
  MovieClip(List<Texture> textures) : super(textures[0]) {
    this.textures = textures;
  }

  /// Stops the MovieClip
  stop() {
    this._playing = false;
  }

  /// Plays the MovieClip
  play() {
    this._playing = true;
  }

  /// Stops the MovieClip and goes to a specific [frameNumber]
  gotoAndStop(int frameNumber) {
    this._playing = false;
    this._currentFrame = frameNumber;
    var round = this._currentFrame.ceil();
    this.setTexture(this.textures[round % this.textures.length]);
  }

  /// Goes to a specific [frameNumber] and begins playing the MovieClip
  gotoAndPlay(int frameNumber) {
    this._currentFrame = frameNumber;
    this._playing = true;
  }

  /// Updates the object transform for rendering
  updateTransform() {
    super.updateTransform();

    if (!this._playing) return;

    this._currentFrame += this.animationSpeed;

    int round = this._currentFrame.ceil();
    this._currentFrame = this._currentFrame % this.textures.length;

    if (this.loop || round < this.textures.length) {
      this.setTexture(this.textures[round % this.textures.length]);
    } else if (round >= this.textures.length) {
      this.gotoAndStop(this.textures.length - 1);
      if (this.onComplete != null) {
        this.onComplete();
      }
    }
  }

  /// A short hand way of creating a movieclip from an array of [frames] ids
  static MovieClip fromFrames(List<String> frames) {
    List<Texture> textures = [];

    for (var i = 0; i < frames.length; i++) {
      textures.add(Texture.fromFrame(frames[i]));
    }

    return new MovieClip(textures);
  }

  /// A short hand way of creating a movieclip from an array of [images] ids
  static MovieClip fromImages(List<String> images) {
    List<Texture> textures = [];

    for (var i = 0; i < images.length; i++) {
      textures.add(Texture.fromImage(images[i]));
    }

    return new MovieClip(textures);
  }

}
