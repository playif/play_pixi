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
    final allPassedRegExp = new RegExp('All \\d+ tests passed');
    tcontext.info("Running Unit Tests....");
    var result = Process.run('./content_shell',
    ['--dump-render-tree','test/test.html'])
    .then((ProcessResult process) {
      tcontext.info(process.stdout);
      return allPassedRegExp.hasMatch(process.stdout);
    });
    return result;
  });
}