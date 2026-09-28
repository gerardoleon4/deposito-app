import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final app = Router()..get('/salud', (Request r) => Response.ok('ok'));
  final server = await io.serve(app.call, InternetAddress.anyIPv4, 8080);
  print('Servidor en http://${server.address.host}:${server.port}');
}
