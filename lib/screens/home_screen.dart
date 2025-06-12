import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/utils/utils.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Administrador';
  DateTime? _lastSync;
  int _clientCount = 0;
  int _productCount = 0;
  int _pendingOrders = 0;
  double _monthlySales = 0.0;
  List<Activity> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStatistics();
    _loadRecentActivities();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    final lastSyncMs = prefs.getInt('lastSync');
    setState(() {
      _userName = name ?? 'Administrador';
      _lastSync = lastSyncMs != null ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs) : null;
    });
  }

  Future<void> _loadStatistics() async {
    final db = await DatabaseHelper.instance.database;
    final clientRes = await db.rawQuery('SELECT COUNT(*) AS count FROM clients WHERE deleted = 0');
    _clientCount = firstIntValue(clientRes) ?? 0;

    final productRes = await db.rawQuery('SELECT COUNT(*) AS count FROM products WHERE deleted = 0');
    _productCount = firstIntValue(productRes) ?? 0;

    final pendingRows = await db.rawQuery('''
      SELECT o.id
      FROM orders o
      LEFT JOIN order_payments p ON o.id = p.orderId
      WHERE o.deleted = 0
      GROUP BY o.id
      HAVING SUM(p.amount) IS NULL
  ''');
    _pendingOrders = pendingRows.length;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1).millisecondsSinceEpoch;
    final salesRes = await db.rawQuery(
      'SELECT SUM(total) AS total FROM orders WHERE deleted = 0 AND createdAt BETWEEN ? AND ?',
      [startOfMonth, startOfNextMonth],
    );
    _monthlySales = (salesRes.first['total'] as num?)?.toDouble() ?? 0.0;

    setState(() {});
  }

  Future<void> _loadRecentActivities() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
    SELECT id, clientId, total, createdAt
    FROM orders
    WHERE deleted = 0
    ORDER BY createdAt DESC
    LIMIT 5
''');
    _recentActivities = rows.map((row) {
      final created = DateTime.fromMillisecondsSinceEpoch(int.parse(row['createdAt'] as String));
      return Activity(
        title: 'Pedido #${row['id']} realizado',
        description: 'Cliente: ${row['clientId']} - Valor: R${(row['total'] as num).toStringAsFixed(2)}',
        time: _formatTimeAgo(created),
        icon: Icons.shopping_cart,
        color: Colors.green,
      );
    }).toList();
    setState(() {});
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} minutos';
    if (diff.inHours < 24) return 'Há ${diff.inHours} horas';
    if (diff.inDays == 1) return 'Ontem';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Força de Vendas'),
        actions: [
          IconButton(icon: const Icon(Icons.sync), tooltip: 'Sincronizar', onPressed: _onSyncPressed),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Future<void> _onSyncPressed() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSync', now.millisecondsSinceEpoch);
    setState(() => _lastSync = now);
    Navigator.pushReplacementNamed(context, '/home');
  }

  Widget _buildDrawer() => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                _userName,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              if (_lastSync != null)
                Text(
                  'Última sincronização: ${DateFormat('dd/MM/yyyy HH:mm').format(_lastSync!)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
            ],
          ),
        ),
        _drawerItem(Icons.people, 'Clientes', '/clients'),
        _drawerItem(Icons.shopping_bag, 'Produtos', '/products'),
        _drawerItem(Icons.shopping_cart, 'Pedidos', '/orders'),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sincronizar'),
          onTap: () {
            Navigator.pop(context);
            _onSyncPressed();
          },
        ),
        _drawerItem(Icons.settings, 'Configurações', '/settings'),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Sair'),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('userId');
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    ),
  );

  ListTile _drawerItem(IconData icon, String label, String route) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    },
  );

  Widget _buildWelcomeCard() => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo(a)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text('Olá, $_userName! Aqui está o resumo do seu dia.', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(DateFormat('EEEE, d MMMM y').format(DateTime.now()), style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildStatsGrid() => GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      _buildStatCard('Clientes', '$_clientCount', Icons.people, Colors.blue),
      _buildStatCard('Produtos', '$_productCount', Icons.shopping_bag, Colors.green),
      _buildStatCard('Pedidos', '$_pendingOrders', Icons.pending_actions, Colors.orange),
      _buildStatCard('Vendas', 'R\$${_monthlySales.toStringAsFixed(2)}', Icons.attach_money, Colors.purple),
    ],
  );

  Widget _buildStatCard(String title, String value, IconData icon, Color color) => Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    ),
  );

  Widget _buildQuickActions() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Ações Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionButton(Icons.person_add, 'Novo Cliente', '/register_client'),
          _actionButton(Icons.add_box, 'Novo Produto', '/register_product'),
          _actionButton(Icons.shopping_cart, 'Novo Pedido', '/register_order'),
        ],
      ),
    ],
  );

  Widget _actionButton(IconData icon, String label, String route) => InkWell(
    onTap: () => Navigator.pushNamed(context, route),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue),
          ),
        ],
      ),
    ),
  );

  Widget _buildRecentActivity() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Atividade Recente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ..._recentActivities.map((act) => _buildActivityItem(act)).toList(),
    ],
  );

  Widget _buildActivityItem(Activity activity) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: activity.color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(activity.icon, color: activity.color),
      ),
      title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(activity.description),
      trailing: Text(activity.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ),
  );
}

class Activity {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;

  Activity({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
  });
}
