import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:dartssh2/dartssh2.dart';

import '../models/ssh_entity.dart';
import 'lg_settings_service.dart';
import 'local_storage_service.dart';

/// Service that deals with the SSH management.
class SSHService {
  LGSettingsService get _settingsService => GetIt.I<LGSettingsService>();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();

  /// Property that defines the SSH client instance.
  SSHClient? _client;

  /// Property that defines the SSH client instance.
  SSHClient? get client => _client;

  bool isAuthenticated=false;

  /// Sets a client with the given [ssh] info.
  void setClient(SSHEntity ssh) async {
    try{
      final socket = await SSHSocket.connect(ssh.host, ssh.port);
      String? password;
      _client = SSHClient(
          socket,
          username: ssh.username,
          onPasswordRequest: (){
            password = ssh.passwordOrKey;
            return password;
          },
        keepAliveInterval: const Duration(seconds: 3600),
        onAuthenticated: () async {
            isAuthenticated=true;
            _localStorageService.setItem('lgConnected', "connected");
        }
      );
      // await Future.delayed(const Duration(seconds: 10));
    }catch(e){
      print(e);
    }
  }

  void init() {
    final settings = _settingsService.getSettings();
    setClient(SSHEntity(
      username: settings.username,
      host: settings.ip,
      passwordOrKey: settings.password,
      port: settings.port,
    ));
  }

  /// Connects to the current client, executes a command into it and then disconnects.
  Future<SSHSession?> execute(String command) async {
    SSHSession? execResult;

    execResult = await _client?.execute(command);

    return execResult;
  }

  /// Connects to a machine using the current client.
  Future<String?> connect() async {
    final settings = _settingsService.getSettings();
    setClient(SSHEntity(
      username: settings.username,
      host: settings.ip,
      passwordOrKey: settings.password,
      port: settings.port,
    ));
    return '';
  }

  /// Disconnects from the a machine using the current client.
  SSHClient? disconnect()  {
    _client?.close();
    return _client;
  }

  /// Connects to the current client through SFTP, uploads a file into it and then disconnects.
  upload(File inputFile, String filename) async {
    final settings = _settingsService.getSettings();
    setClient(SSHEntity(
      username: settings.username,
      host: settings.ip,
      passwordOrKey: settings.password,
      port: settings.port,
    ));
    Future.delayed(const Duration(seconds: 3));
    print(isAuthenticated);
    try{
      bool uploading =true;
      final sftp = await _client?.sftp();
      final file = await sftp?.open('/var/www/html/$filename',
          mode: SftpFileOpenMode.truncate |
          SftpFileOpenMode.create |
          SftpFileOpenMode.write);
      var fileSize = await inputFile.length();
      file?.write(inputFile.openRead().cast(), onProgress: (progress){
        // if(fileSize == progress){
          uploading=true;
        // }
      });
      // print(file);
      // if(file==null){
      //   print('null');
      //   return;
      // }
      // await waitWhile(() => uploading);
    } catch(error){
      print(error);
    }
  }

  Future waitWhile(bool Function() test, [Duration pollInterval = Duration.zero]){
    var completer = Completer();
    print('inside');
    check(){
      if(!test()){
        completer.complete();
      } else{
        Timer(pollInterval,check);
      }
    }
    check();
    return completer.future;
  }

}
