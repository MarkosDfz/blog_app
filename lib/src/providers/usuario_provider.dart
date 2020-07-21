
import 'dart:convert';

import 'package:formvalidation/src/prefs/preferencias_usuario.dart';
import 'package:http/http.dart' as http;

class UsuarioProvider {

  final String _firebaseToken = 'AIzaSyDnz07mwDHMI6nQwUaXk74vB4JV_goHDQ8';
  final _prefs = new PreferenciasUsuario();

  Future<Map<String, dynamic>> login( String email, String password ) async {

    final authData = {
      'email'    : email,
      'password' : password,
      'returnSecureToken' : true
    };

    final resp = await http.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseToken',
      body: json.encode( authData )
    );

    Map<String, dynamic> decodeResp = json.decode( resp.body );

    if ( decodeResp.containsKey( 'idToken' ) ) {
      // Guardar token en storage
      _prefs.token = decodeResp[ 'idToken' ];
      return { 'ok': true, 'token': decodeResp[ 'idToken' ] };
    } else {
      return { 'ok': false, 'mensaje': decodeResp[ 'error' ][ 'message' ] };
    }
    
  }

  Future<Map<String, dynamic>> nuevoUsuario( String email, String password ) async {

    final authData = {
      'email'    : email,
      'password' : password,
      'returnSecureToken' : true
    };

    final resp = await http.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseToken',
      body: json.encode( authData )
    );

    Map<String, dynamic> decodeResp = json.decode( resp.body );

    if ( decodeResp.containsKey( 'idToken' ) ) {

      _prefs.token = decodeResp[ 'idToken' ];
      return { 'ok': true, 'token': decodeResp[ 'idToken' ] };

    } else {
      
      return { 'ok': false, 'mensaje': decodeResp[ 'error' ][ 'message' ] };

    }
    
  }

}