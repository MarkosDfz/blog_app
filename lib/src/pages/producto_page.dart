
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/provider.dart';
import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {

  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {

  final formKey          = GlobalKey<FormState>();
  final scaffoldKey      = GlobalKey<ScaffoldState>();

  ProductosBloc productosBloc;
  ProductoModel producto = new ProductoModel();
  bool _guardando        = false;
  File foto;

  @override
  Widget build(BuildContext context) {

    productosBloc = Provider.productosBloc( context );

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;
    if ( prodData != null ) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon( Icons.photo_size_select_actual ),
            onPressed: () => _procesarImagen( ImageSource.gallery )
          ),
          IconButton(
            icon: Icon( Icons.camera_alt ),
            onPressed: () => _procesarImagen( ImageSource.camera )
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all( 15.0 ),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton()
              ],
            )
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {

    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto'
      ),
      onSaved: ( value ) {
        producto.titulo = value;
      },
      validator: ( value ) {
        if ( value.length < 3) {
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );

  }

  Widget _crearPrecio() {

    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions( decimal: true ),
      decoration: InputDecoration(
        labelText: 'Precio'
      ),
      onSaved: ( value ) {
        producto.valor = double.parse( value );
      },
      validator: ( value ) {

        if ( value.isEmpty ) return 'El campo es obligatorio';

        if ( utils.isNumeric( value ) ) {
          return null;
        } else {
          return 'Solo números';
        }

      },
    );

  }

  Widget _crearDisponible() {

    return SwitchListTile(
      value: producto.disponible,
      title: Text( 'Disponible' ),
      activeColor: Colors.deepPurpleAccent,
      onChanged: ( value ) {
        setState(() {
          producto.disponible = value;
        });
      },
    );

  }

  Widget _crearBoton() {

    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular( 20.0 )
      ),
      color: Colors.deepPurpleAccent,
      textColor: Colors.white,
      icon: Icon( Icons.save ),
      label: Text( 'Guardar' ),
      onPressed: ( _guardando ) ? null : _submit,
    );

  }

  void _submit() async {

    if ( !formKey.currentState.validate() ) return;

    formKey.currentState.save();

    setState(() { _guardando = true; });

    if ( foto != null ) {
      producto.fotoUrl = await productosBloc.subirFoto(foto);
    }



    if ( producto.id == null ) {
      productosBloc.agregarProducto(producto);
    } else {
      productosBloc.editarProducto(producto);
    }


    // setState(() {_guardando = false; });
    // mostrarSnackbar('Registro guardado');

    Navigator.pop(context);

  }

  Widget _mostarFoto() {

    if ( producto.fotoUrl != null ) {
      return FadeInImage(
        placeholder: AssetImage( 'assets/load.gif' ),
        image: NetworkImage( producto.fotoUrl ),
      );
    } else {
      return Image(
        image: AssetImage( foto?.path ?? 'assets/noimg.png' ),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }

  }

  _procesarImagen( ImageSource origen ) async {

    foto = await ImagePicker.pickImage(
      source: origen
    );

    if ( foto != null ) {
      //limpieza
      producto.fotoUrl = null;
    }

    setState(() { });

  }

}