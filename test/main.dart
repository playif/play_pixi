library model_map_test;

import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:play_pixi/pixi.dart';


main() {

  print('Running unit tests for play_pixi library.');
  useHtmlEnhancedConfiguration();

  group('circle', () {
    Circle circle = new Circle();

    test('instance', () {
      expect(circle.x, equals(0));
      expect(circle.y, equals(0));
      expect(circle.radius, equals(0));
    });

    Circle circle2 = new Circle();
    circle2.x=10;
    circle2.y=20;
    circle2.radius=20;

    Circle cloneCircle=circle2.clone();

    test('clone', () {

      expect(cloneCircle.x, equals(10));
      expect(cloneCircle.y, equals(20));
      expect(cloneCircle.radius, equals(20));
    });

    test('contains', () {

      expect(cloneCircle.contains(10,20), equals(true));
      expect(cloneCircle.contains(100,20), equals(false));

    });

//    test('Extract collections to map', () {
//      var model = new CollectionsModel()
//        ..map	= { 'first': 42, 'second': 123 }
//        ..list	= [ 'list', 'of', 'strings' ];
//
//      expect(model.toMap(), equals(map));
//    });
  });

}