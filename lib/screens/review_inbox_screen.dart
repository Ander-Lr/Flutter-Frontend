import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';

class ReviewInboxScreen extends StatefulWidget {
  const ReviewInboxScreen({Key? key}) : super(key: key);

  @override
  _ReviewInboxScreenState createState() => _ReviewInboxScreenState();
}

class _ReviewInboxScreenState extends State<ReviewInboxScreen> {
  final DashboardService _service = DashboardService();
  bool _isLoading = true;
  String? _error;
  List<ReviewInboxItem> _items = [];
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchInbox();
  }

  Future<void> _fetchInbox({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _items.clear();
    }
    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getReviewInbox(_currentPage, 20);
      setState(() {
        _items.addAll(result['items'] as List<ReviewInboxItem>);
        _hasMore = !(result['last'] as bool);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ocurrió un error: $e';
        _isLoading = false;
      });
    }
  }

  void _handleSwipe(DismissDirection direction, ReviewInboxItem item) {
    setState(() {
      _items.removeWhere((e) => e.idComentario == item.idComentario);
    });
    
    if (direction == DismissDirection.startToEnd) {
      // Swipe Derecha = Aprobar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comentario aprobado'), backgroundColor: Colors.green),
      );
      // Aquí llamarías a un endpoint como _service.approveComment(item.idComentario)
    } else {
      // Swipe Izquierda = Eliminar/Rechazar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comentario eliminado'), backgroundColor: Colors.red),
      );
      // Aquí llamarías a un endpoint como _service.deleteComment(item.idComentario)
    }
  }

  void _showItemDetails(ReviewInboxItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))
              ),
              child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white12,
                        backgroundImage: item.imgAutor != null ? NetworkImage(item.imgAutor!) : null,
                        child: item.imgAutor == null ? const Icon(Icons.person, color: Colors.white70) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.autor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            if (item.fechaAnalisis != null)
                              Text(timeago.format(item.fechaAnalisis!), style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Contenido", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(item.contenido, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 24),
                  const Text("Análisis de IA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 16),
                  
                  // Barras de detalle
                  _buildDetailBar('Toxicidad', item.toxicidadScore, Colors.red),
                  const SizedBox(height: 12),
                  _buildDetailBar('Sentimiento (${item.sentimiento})', item.sentimientoScore, item.sentimiento == 'positivo' ? Colors.green : item.sentimiento == 'negativo' ? Colors.red : Colors.grey),
                  
                  if (item.analisisJson != null && item.analisisJson!['confianza_general'] != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailBar('Confianza del Modelo', (item.analisisJson!['confianza_general'] as num).toDouble(), Colors.blue),
                  ],

                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleSwipe(DismissDirection.endToStart, item);
                          },
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleSwipe(DismissDirection.startToEnd, item);
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Aprobar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
            Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 8, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11111B),
      appBar: AppBar(
        title: const Text('Bandeja de Revisión'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchInbox(refresh: true),
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('No hay elementos pendientes por revisar', style: TextStyle(color: Colors.white70, fontSize: 16))),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _items.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _items.length) {
                          _fetchInbox();
                          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                        }

                        final item = _items[index];
                        return Dismissible(
                          key: Key(item.idComentario),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Icon(Icons.check, color: Colors.white, size: 32),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Icon(Icons.delete, color: Colors.white, size: 32),
                          ),
                          onDismissed: (direction) => _handleSwipe(direction, item),
                          child: InkWell(
                            onTap: () => _showItemDetails(item),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white12,
                                        backgroundImage: item.imgAutor != null ? NetworkImage(item.imgAutor!) : null,
                                        child: item.imgAutor == null ? const Icon(Icons.person, size: 16, color: Colors.white70) : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(item.autor, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                      const Spacer(),
                                      if (item.fechaAnalisis != null)
                                        Text(timeago.format(item.fechaAnalisis!), style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(item.contenido, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: item.sentimiento == 'negativo' ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: item.sentimiento == 'negativo' ? Colors.red.shade400 : Colors.green.shade400),
                                        ),
                                        child: Text(
                                          '${item.sentimiento.toUpperCase()} ${(item.sentimientoScore * 100).toInt()}%',
                                          style: TextStyle(fontSize: 10, color: item.sentimiento == 'negativo' ? Colors.red.shade300 : Colors.green.shade300, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.orange.shade400),
                                        ),
                                        child: Text(
                                          'TÓXICO ${(item.toxicidadScore * 100).toInt()}%',
                                          style: TextStyle(fontSize: 10, color: Colors.orange.shade300, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (item.esSpam) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.warning, color: Colors.red, size: 16),
                                      ]
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
