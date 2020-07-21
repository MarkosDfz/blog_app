
import 'dart:async';

import 'package:formvalidation/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc with Validators {

  final _emailController    = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  // Recuper los datos del Stream
  Stream<String> get emailSream    => _emailController.stream.transform( validarEmail );
  Stream<String> get passwordSream => _passwordController.stream.transform( validarPassword );

  // Insertar valores al Stream
  Function(String) get changeEmail    => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  Stream<bool> get formValidStream => 
      CombineLatestStream.combine2( emailSream, passwordSream, ( e, p ) => true );

  // Obtener último valor ingresado a los streams
  String get email     => _emailController.value;
  String get password  => _passwordController.value;

  dispose() {
    _emailController?.close();
    _passwordController?.close();
  }

}