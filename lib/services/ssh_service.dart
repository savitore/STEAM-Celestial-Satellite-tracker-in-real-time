import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:dartssh2/dartssh2.dart';

import '../models/ssh_entity.dart';
import 'lg_settings_service.dart';

/// Service that deals with the SSH management.
class SSHService {
  LGSettingsService get _settingsService => GetIt.I<LGSettingsService>();

  /// Property that defines the SSH client instance.
  SSHClient? _client;

  /// Property that defines the SSH client instance.
  SSHClient? get client => _client;

  bool isAuthenticated=false;
  String result='';

  /// Sets a client with the given [ssh] info.
  Future<String?> setClient(SSHEntity ssh) async {
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
        onAuthenticated: (){
            isAuthenticated=true;
        }
      );
      await Future.delayed(const Duration(seconds: 10));
      if(isAuthenticated){
      }else{
        throw Exception('SSH authentication failed');
      }
    }catch(e){
      result = "Failed to connect to the SSH server: $e";
    }
    return result;
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
    String? result = await connect();

    SSHSession? execResult;

    // if (result == '') {
      execResult = await _client?.execute(command);
    // }

    disconnect();
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
    print(result);
    return result;
  }

  /// Disconnects from the a machine using the current client.
  SSHClient? disconnect()  {
    _client?.close();
    return _client;
  }

  /// Connects to the current client through SFTP, uploads a file into it and then disconnects.
  Future<void> upload(File inputFile, String filename) async {
    // await connect();
    double anyKindofProgressBar;
    final sftp = await _client?.sftp();
    // String? result = await _client.connectSFTP();
    final file = await sftp?.open('/var/www/html/$filename',
    mode: SftpFileOpenMode.truncate |
        SftpFileOpenMode.create |
        SftpFileOpenMode.write);
    var fileSize = await inputFile.length();
    await file?.write(inputFile.openRead().cast(), onProgress: (progress){
      anyKindofProgressBar = progress/fileSize;
    });
  }
}
