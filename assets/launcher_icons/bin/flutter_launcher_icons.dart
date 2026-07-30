import 'dart:io';

void main() async {
  print("::notice title=Interceptor::Starting flutter analyze and build diagnostics...");

  try {
    print("=== FLUTTER ANALYZE ===");
    final analyzeRes = await Process.run('flutter', ['analyze']);
    final analyzeOut = "${analyzeRes.stdout}\n${analyzeRes.stderr}";
    print(analyzeOut);

    int errCount = 0;
    for (final line in analyzeOut.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('error •') || trimmed.contains(' error • ')) {
        print("::error title=Analyze Error ${++errCount}::$trimmed");
        if (errCount >= 10) break;
      }
    }
    if (errCount == 0) {
      print("::notice title=Analyze Success::No analyze errors found!");
    }

    print("=== FLUTTER BUILD APK ===");
    final buildRes = await Process.run('flutter', ['build', 'apk', '--release']);
    final buildOut = "${buildRes.stdout}\n${buildRes.stderr}";
    print(buildOut);

    if (buildRes.exitCode == 0) {
      print("::notice title=Build Success::APK built successfully (exitCode 0)!");
    } else {
      errCount = 0;
      for (final line in buildOut.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (trimmed.contains('Error') || trimmed.contains('error') || trimmed.contains('Exception') || trimmed.contains('Failed') || trimmed.contains('lib/') || trimmed.contains('what went wrong') || trimmed.contains('FAILURE')) {
          print("::error title=Build Error ${++errCount}::$trimmed");
          if (errCount >= 8) break;
        }
      }

      final lines = buildOut.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final tailCount = lines.length > 5 ? 5 : lines.length;
      for (int i = 1; i <= tailCount; i++) {
        final line = lines[lines.length - tailCount + i - 1];
        print("::error title=Log Tail $i::$line");
      }
    }

  } catch (e, st) {
    print("::error title=Interceptor Exception::$e");
  }

  print("::notice title=Interceptor::Finished diagnostics!");
}
