library dumprendertree;

import 'package:hop/hop.dart';
import 'dart:io';


main(List<String> args) {
  addTask('test', createUnitTestTask());
  runHop(args);
}

Task createUnitTestTask() {
  final allPassedRegExp = new RegExp('All \\d+ tests passed');
  return new Task((TaskContext tcontext) {
    tcontext.info("Running Unit Tests....");
    var result = Process.run('./content_shell',
    ['--dump-render-tree','test/test.html'])
    .then((ProcessResult process) {
      tcontext.info(process.stdout);
      bool match= allPassedRegExp.hasMatch(process.stdout);
      if(!match)throw new Exception("Failed!");
    });
    return result;
  });
}