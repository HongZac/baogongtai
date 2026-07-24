import 'package:basement/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'dart:io';


///应用程序重启
class RestartApplicationUtil {

  static const String fileName = 'restart_app.bat';

  static Future<String> _writeToBatchFile(String currentDirectory, String executableName) async {
    try {
      //final currentScriptPath = Platform.script.toFilePath();
      //final appDirectory = path.dirname(currentScriptPath);
      final appExecutablePath = path.join(currentDirectory, fileName);
      final batchFilePath = appExecutablePath; // Replace with the path to your batch file
      final file = File(batchFilePath);
      if (!await file.exists()) {
        await file.create();
      }
      final batchFile = file.openSync(mode: FileMode.write);
      //final appPath = path.join(appDirectory, executableName);
      batchFile.writeStringSync(
        '@echo off\n'
            'taskkill /F /IM $executableName\n'
            //'start /wait "$executableName" "$appPath"', ///绝对路径
            'start /wait "$executableName" "%~dp0$executableName"', ///相对路径
      );
      // Close the batch file
      batchFile.closeSync();
      return batchFilePath;
    }catch(e){
      PrintUtil.printDebug('Error occurred:');
      PrintUtil.printDebug(e.toString());
    }
    return '';
  }


  static Future<void> restartApp() async {
    if (!kIsWeb && Platform.isWindows){
      final currentScriptPath = Platform.script.toFilePath();
      final appDirectory = path.dirname(currentScriptPath);
      String executablePath = Platform.executable;
      String executableName = File(executablePath).uri.pathSegments.last;
      String appPath = await _writeToBatchFile(appDirectory, executableName);
      Process.run(fileName, ['$executableName', appPath]);
    }
  }
}

