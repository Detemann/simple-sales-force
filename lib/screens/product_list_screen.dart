import 'package:flutter/material.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    ProductController().loadProducts().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produtos')),
      body: ListView.builder(
        itemCount: ProductController().products.length,
        itemBuilder: (context, index) {
          final product = ProductController().products[index];
          return ListTile(
            title: Text(product.nome),
            subtitle: Text('Estoque: ${product.qtdEstoque} ${product.unidade}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => _editProduct(context, product)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteProduct(product.id)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () => _addProduct(context)),
    );
  }

  void _addProduct(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductFormScreen())).then((_) => setState(() {}));
  }

  void _editProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
    ).then((_) => setState(() {}));
  }

  void _deleteProduct(String id) {
    ProductController().deleteProduct(id);
    setState(() {});
  }
}
