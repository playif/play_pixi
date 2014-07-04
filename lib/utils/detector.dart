part of PIXI;

Renderer autoDetectRenderer([num width=800, num height=600, view, transparent, antialias]) {
  bool webgl = ( () {
    try {
      var canvas = document.createElement('canvas');
      return !!window.WebGLRenderingContext && ( canvas.getContext('webgl') || canvas.getContext('experimental-webgl') );
    } catch(e) {
      return false;
    }
  } )();

  if (webgl) {
    return new WebGLRenderer(width, height, view, transparent, antialias);
  }

  return new WebGLRenderer(width, height, view, transparent, antialias);

  //return new CanvasRenderer(width, height, view, transparent);
}

autoDetectRecommendedRenderer([num width=800, num height=600, view, transparent, antialias]) {


  bool webgl = ( () {
    try {
      var canvas = document.createElement('canvas');
      return !!window.WebGLRenderingContext && ( canvas.getContext('webgl') || canvas.getContext('experimental-webgl') );
    } catch(e) {
      return false;
    }
  } )();


  var isAndroid = new RegExp("Android", "i").test(navigator.userAgent);

  if (webgl && !isAndroid) {
    return new WebGLRenderer(width, height, view, transparent, antialias);
  }

  return new CanvasRenderer(width, height, view, transparent);
}


class PixiEvent {
  String type;
  dynamic content;
  dynamic loader;

  PixiEvent({this.type, this.content, this.loader});
}

class EventTargetObj {
  Map<String, List<EventFunc>> listeners = {
  };

  //Function on, emit, off;

//  EventTarget() {
//
//  }
//  Function on = addEventListener;
//  Function emit = dispatchEvent;
//  Function off = removeEventListener;

  addEventListener(type, listener) {


    if (listeners[ type ] == null) {

      listeners[ type ] = [];

    }

    if (listeners[ type ].indexOf(listener) == -1) {

      listeners[ type ].add(listener);
    }

  }

  dispatchEvent(PixiEvent event) {

    if (!listeners[ event.type] || !listeners[ event.type ].length) {

      return;

    }

    for (var i = 0, l = listeners[ event.type ].length; i < l; i++) {

      listeners[ event.type ][ i ](event);

    }

  }

  removeEventListener(type, listener) {

    var index = listeners[ type ].indexOf(listener);

    if (index != -1) {

      listeners[ type ].removeAt(index);

    }

  }

  removeAllEventListeners(type) {
    var a = listeners[type];
    if (a)
      a.length = 0;
  }

}
