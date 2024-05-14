import 'dart:async';
import 'dart:js_interop';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'package:web/helpers.dart';
import 'package:web/web.dart' as web;
import 'package:file_saver/src/models/file.model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the FileSaver plugin.
class FileSaverWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'file_saver',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = FileSaverWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'saveFile':
        String args = call.arguments;

        return downloadFile(FileModel.fromJson(args));
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'file_saver for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  static Future<bool> downloadFile(FileModel fileModel) async {
    bool success = false;

    try {
      final anchor = web.document.createElement('a') as HTMLAnchorElement;
      anchor.setAttribute('href', web.URL.createObjectURL(web.Blob([fileModel.bytes.toJS].toJS)));
      anchor.setAttribute('download', fileModel.name + fileModel.ext);
      anchor.style.display = 'none';
      document.body!.append(anchor);
      anchor.click();
      anchor.remove();      
      success = true;
    } catch (e) {
      rethrow;
    }
    return success;
  }
}
