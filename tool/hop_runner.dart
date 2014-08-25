library dumprendertree;

import 'package:hop/hop.dart';
import 'dart:io';
import 'dart:async';

main(List<String> args) {
  addTask('test', createUnitTestTask());
  runHop(args);
}

Task createUnitTestTask() {
  return new Task((TaskContext tcontext) {
    tcontext.info("Running Unit Tests....");
    var result = Process.run('./content_shell',
    ['--dump-render-tree','test/test.html'])
    .then((ProcessResult process) {
      tcontext.info(process.stdout);
      tcontext.fail(process.stderr);
    }, onError:(e){
      print("here");
      print(e);
    });
    return result;
  });
}