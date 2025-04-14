import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class ProductController {
  List<Product> _products = [];
  int _nextProductId = 1;

  static final ProductController _instance = ProductController._internal();

  factory ProductController() => _instance;

  ProductController._internal();

  Future<void> loadProducts() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      List<dynamic> jsonList = json.decode(contents);
      _products = jsonList.map((json) => Product.fromJson(json)).toList();
      _nextProductId = _products.isNotEmpty ? int.parse(_products.last.id) + 1 : 1;
    } else {
      _products = [];
      _nextProductId = 1;
    }
  }

  Future<void> saveProducts() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products.json');
    await file.writeAsString(json.encode(_products));
  }

  void addProduct(Product product) {
    _products.add(
      Product(
        id: _nextProductId.toString(),
        nome: product.nome,
        unidade: product.unidade,
        qtdEstoque: product.qtdEstoque,
        precoVenda: product.precoVenda,
        status: product.status,
        custo: product.custo,
        codigoBarra: product.codigoBarra,
      ),
    );
    _nextProductId++;
    saveProducts();
  }

  void updateProduct(Product updatedProduct) {
    int index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      saveProducts();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    saveProducts();
  }

  List<Product> get products => _products;
}
