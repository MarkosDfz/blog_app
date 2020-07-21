
import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/provider.dart';
import 'package:formvalidation/src/models/producto_model.dart';

class HomePage extends StatelessWidget {

  final scaffoldKey      = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    final productosBloc = Provider.productosBloc(context);
    productosBloc.caragarProductos();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text( 'Home' ),
      ),
      body: _crearListado( productosBloc ),
      floatingActionButton: _crearBoton( context ),
    );
  }

  Widget _crearListado( ProductosBloc productosBloc ) {

    return StreamBuilder(
      stream: productosBloc.productosStream ,
      builder: (BuildContext context, AsyncSnapshot<List<ProductoModel>> snapshot){
        
        if ( snapshot.hasData ) {

          final productos = snapshot.data;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: ( BuildContext context, int i ) {
              return _crearItem( context, productos[i], productosBloc );
            },
          );

        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        
      },
    );

  }

  Widget _crearItem( BuildContext context, ProductoModel producto, ProductosBloc productosBloc ) {

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        padding: EdgeInsets.only( left: 10.0 ),
        color: Colors.red,
        child: Row(
          children: <Widget>[
            Icon( Icons.delete, color: Colors.white ),
            SizedBox( width: 15.0 ),
            Text( 'Eliminar', style: TextStyle( color: Colors.white, fontSize: 17.0 ) )
          ],
        ),
      ),
      confirmDismiss: ( direction ) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return _crearAlerta( context, producto, productosBloc );
          },
        );
      },
      child: Card(
        child: Column(
          children: <Widget>[
            ( producto.fotoUrl == null )
              ? Image( image: AssetImage( 'assets/noimg.png' ) )
              : FadeInImage(
                  placeholder: AssetImage( 'assets/load.gif' ),
                  image: NetworkImage( producto.fotoUrl ),
                  height: 300.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
            ListTile(
              title: Text( '${ producto.titulo } - ${ producto.valor }' ),
              subtitle: Text( '${ producto.id }' ),
              onTap: () {
                Navigator.pushNamed( context, 'producto', arguments: producto );
              },
            ),
          ],
        ),
      )
    );

  }

  Widget _crearAlerta( BuildContext context, ProductoModel producto, ProductosBloc productosBloc ) {

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text('Confirmar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('¿Desea Eliminar este Producto?')
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text( 'Cancelar' ),
          onPressed: () => Navigator.of(context).pop( false )
        ),
        FlatButton(
          child: Text( 'Aceptar' ),
          onPressed: () {
            productosBloc.borrarProducto( producto.id );
            Navigator.of(context).pop( true );
            mostrarSnackBar( '${ producto.titulo } Eliminado', Icons.delete );
          }
        )
      ],
    );
  }

  _crearBoton( BuildContext context ) {

    return FloatingActionButton(
      child: Icon( Icons.add ),
      backgroundColor: Colors.deepPurpleAccent,
      onPressed: () {
        Navigator.pushNamed( context, 'producto' );
      }
    );
    
  }

  void mostrarSnackBar( String mensaje, IconData icono ) {

    final snackbar = SnackBar(
      duration: Duration( milliseconds: 1500 ),
      content: Container(
        child: Row(
          children: <Widget>[
            Icon( icono, color: Colors.white ),
            SizedBox( width: 15.0 ),
            Text( mensaje, style: TextStyle( color: Colors.white, fontSize: 17.0 ) )
          ],
        ),
      )
    );

    scaffoldKey.currentState.showSnackBar( snackbar );

  }

}