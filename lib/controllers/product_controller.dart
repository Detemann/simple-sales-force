import 'dart:convert';
import 'dart:io';
import '../models/product.dart';

class ProductController {
  List<Product> _products = [];
  int _nextProductId = 1;
  static const String _fileName = 'products.json';
  static const String _androidDataPath = '/data/data/com.example.appmobile/files';

  static final ProductController _instance = ProductController._internal();

  factory ProductController() => _instance;

  ProductController._internal();

  Future<File> get _localFile async {
    final directory = Directory(_androidDataPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$_fileName');
  }

  Future<void> loadProducts() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        List<dynamic> jsonList = json.decode(contents);
        _products = jsonList.map((json) => Product.fromJson(json)).toList();
        _nextProductId = _products.isNotEmpty ? int.parse(_products.last.id) + 1 : 1;
      }
    } catch (e) {
      print('Erro ao carregar produtos: $e');
      _products = [];
      _nextProductId = 1;
    }
  }

  Future<void> saveProducts() async {
    try {
      final file = await _localFile;
      await file.writeAsString(json.encode(_products));
    } catch (e) {
      print('Erro ao salvar produtos: $e');
      throw Exception('Não foi possível salvar os produtos: $e');
    }
  }

  Future<void> addProduct(Product product) async {
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
    await saveProducts();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      await saveProducts();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await saveProducts();
  }

  List<Product> get products => _products;

  Future<void> clearAll() async {
    _products = [];
    _nextProductId = 1;
    await saveProducts();
  }

  Future<String> getDebugPath() async {
    final file = await _localFile;
    return file.path;
  }
}
