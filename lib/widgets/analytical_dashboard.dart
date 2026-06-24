import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';
import '../screens/review_inbox_screen.dart';

class AnalyticalDashboard extends StatefulWidget {
  const AnalyticalDashboard({Key? key}) : super(key: key);

  @override
  _AnalyticalDashboardState createState() => _AnalyticalDashboardState();
}

class _AnalyticalDashboardState extends State<AnalyticalDashboard> {
  final DashboardService _service = DashboardService();
  bool _isLoading = true;
  String? _error;

  KpiMetrics? _kpis;
  List<SentimentDistribution> _sentimentDist = [];
  List<ToxicPublication> _toxicPubs = [];
  List<SentimentEvolution> _sentimentEvol = [];
  List<SpamVolume> _spamVol = [];
  double _modelConfidence = 0.0;
  WorkerStatus? _workerStatus;
  List<ReviewInboxItem> _reviewInbox = [];

  @override
  void initState() {
    super.initState();
    // Configurar idioma para timeago si se desea
    // timeago.setLocaleMessages('es', timeago.EsMessages());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final futures = await Future.wait([
        _service.getKpis().catchError((_) => KpiMetrics(totalAnalizado: 0, porcentajeSpam: 0, porcentajeRevision: 0, porcentajeNegativo: 0)),
        _service.getSentimentDistribution().catchError((_) => <SentimentDistribution>[]),
        _service.getToxicPublications().catchError((_) => <ToxicPublication>[]),
        _service.getSentimentEvolution().catchError((_) => <SentimentEvolution>[]),
        _service.getSpamVolume().catchError((_) => <SpamVolume>[]),
        _service.getModelConfidence().catchError((_) => 0.0),
        _service.getWorkerStatus().catchError((_) => WorkerStatus(enCola: 0, conError: 0, modeloActivo: 'N/A')),
        _service.getReviewInbox(0, 5).catchError((_) => {'items': <ReviewInboxItem>[], 'totalPages': 0, 'totalElements': 0, 'last': true}),
      ]);

      setState(() {
        _kpis = futures[0] as KpiMetrics;
        _sentimentDist = futures[1] as List<SentimentDistribution>;
        _toxicPubs = futures[2] as List<ToxicPublication>;
        _sentimentEvol = futures[3] as List<SentimentEvolution>;
        _spamVol = futures[4] as List<SpamVolume>;
        _modelConfidence = futures[5] as double;
        _workerStatus = futures[6] as WorkerStatus;
        final inboxResult = futures[7] as Map<String, dynamic>;
        _reviewInbox = inboxResult['items'] as List<ReviewInboxItem>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Ocurrió un error al cargar el dashboard: $e';
      });
    }
  }

  // --- UI Builders ---

  Widget _buildKpiGrid() {
    if (_kpis == null) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildKpiCard('Total Analizado', _kpis!.totalAnalizado.toString(), Icons.analytics, Colors.blue),
        _buildKpiCard('% Spam/Malicioso', '${_kpis!.porcentajeSpam.toStringAsFixed(1)}%', Icons.warning, Colors.orange),
        _buildKpiCard('% Req. Revisión', '${_kpis!.porcentajeRevision.toStringAsFixed(1)}%', Icons.rule, Colors.purple),
        _buildKpiCard('% Sent. Negativo', '${_kpis!.porcentajeNegativo.toStringAsFixed(1)}%', Icons.sentiment_very_dissatisfied, Colors.red),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentDonut() {
    if (_sentimentDist.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text("Sin datos de sentimiento", style: TextStyle(color: Colors.white70))));
    }

    final positive = _sentimentDist.firstWhere((e) => e.sentimiento == 'positivo', orElse: () => SentimentDistribution(sentimiento: 'positivo', cantidad: 0)).cantidad;
    final negative = _sentimentDist.firstWhere((e) => e.sentimiento == 'negativo', orElse: () => SentimentDistribution(sentimiento: 'negativo', cantidad: 0)).cantidad;
    final neutral = _sentimentDist.firstWhere((e) => e.sentimiento == 'neutro', orElse: () => SentimentDistribution(sentimiento: 'neutro', cantidad: 0)).cantidad;
    final total = positive + negative + neutral;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Text("Distribución de Sentimientos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          Expanded(
            child: total == 0 ? const Center(child: Text("Sin datos", style: TextStyle(color: Colors.white70))) : PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.green.shade400,
                    value: positive.toDouble(),
                    title: '${((positive / total) * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.red.shade400,
                    value: negative.toDouble(),
                    title: '${((negative / total) * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.grey.shade400,
                    value: neutral.toDouble(),
                    title: '${((neutral / total) * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green.shade400, "Positivo ($positive)"),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.grey.shade400, "Neutro ($neutral)"),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.red.shade400, "Negativo ($negative)"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildToxicPublications() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top Publicaciones más Tóxicas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 12),
          if (_toxicPubs.isEmpty) const Text("No hay publicaciones tóxicas recientes.", style: TextStyle(color: Colors.white70)),
          ..._toxicPubs.take(5).map((pub) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(pub.contenido, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white))),
                      Text('@${pub.autor}', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      Container(height: 8, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: pub.toxicidadScore.clamp(0.0, 1.0),
                        child: Container(height: 8, decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(pub.toxicidadScore * 100).toStringAsFixed(1)}% Toxicidad', style: TextStyle(fontSize: 10, color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                      if (pub.fechaPublicacion != null)
                        Text(timeago.format(pub.fechaPublicacion!), style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWorkerStatus() {
    if (_workerStatus == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF512DA8).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Salud del Sistema (Worker)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text("En cola: ${_workerStatus!.enCola} | Errores: ${_workerStatus!.conError}", style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              Text("Modelo: ${_workerStatus!.modeloActivo}", style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
          Column(
            children: [
              const Text("Confianza", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40, height: 40,
                    child: CircularProgressIndicator(
                      value: _modelConfidence,
                      backgroundColor: Colors.white12,
                      color: _modelConfidence > 0.8 ? Colors.green : _modelConfidence > 0.6 ? Colors.orange : Colors.red,
                      strokeWidth: 4,
                    ),
                  ),
                  Text('${(_modelConfidence * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSentimentEvolution() {
    if (_sentimentEvol.isEmpty) return const SizedBox.shrink();

    // Agrupar por fechas únicas y ordenarlas
    final dates = _sentimentEvol.map((e) => e.fecha).toSet().toList()..sort();
    
    // Crear puntos para cada línea
    List<FlSpot> positiveSpots = [];
    List<FlSpot> negativeSpots = [];
    List<FlSpot> neutralSpots = [];

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final pos = _sentimentEvol.where((e) => e.fecha == date && e.sentimiento == 'positivo').fold(0, (sum, item) => sum + item.cantidad);
      final neg = _sentimentEvol.where((e) => e.fecha == date && e.sentimiento == 'negativo').fold(0, (sum, item) => sum + item.cantidad);
      final neu = _sentimentEvol.where((e) => e.fecha == date && e.sentimiento == 'neutro').fold(0, (sum, item) => sum + item.cantidad);

      positiveSpots.add(FlSpot(i.toDouble(), pos.toDouble()));
      negativeSpots.add(FlSpot(i.toDouble(), neg.toDouble()));
      neutralSpots.add(FlSpot(i.toDouble(), neu.toDouble()));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Evolución de Sentimientos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < dates.length) {
                          // Mostrar solo día y mes
                          final dateStr = dates[value.toInt()];
                          final shortDate = dateStr.length >= 10 ? '${dateStr.substring(8,10)}/${dateStr.substring(5,7)}' : dateStr;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(shortDate, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(spots: positiveSpots, isCurved: true, color: Colors.green.shade400, barWidth: 3, dotData: FlDotData(show: false)),
                  LineChartBarData(spots: negativeSpots, isCurved: true, color: Colors.red.shade400, barWidth: 3, dotData: FlDotData(show: false)),
                  LineChartBarData(spots: neutralSpots, isCurved: true, color: Colors.grey.shade400, barWidth: 3, dotData: FlDotData(show: false)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpamVolume() {
    if (_spamVol.isEmpty) return const SizedBox.shrink();

    List<BarChartGroupData> barGroups = _spamVol.map((e) {
      return BarChartGroupData(
        x: e.hora,
        barRods: [
          BarChartRodData(
            toY: e.cantidad.toDouble(),
            color: Colors.orange.shade400,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          )
        ],
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Volumen de Spam por Hora", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${value.toInt()}h', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF512DA8)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reintentar'),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF512DA8),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildWorkerStatus(),
          const SizedBox(height: 16),
          _buildKpiGrid(),
          const SizedBox(height: 16),
          _buildSentimentDonut(),
          const SizedBox(height: 16),
          _buildSentimentEvolution(),
          const SizedBox(height: 16),
          _buildSpamVolume(),
          const SizedBox(height: 16),
          _buildToxicPublications(),
          const SizedBox(height: 24),
          // TODO: Bandeja de Revisión
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReviewInboxScreen()),
              );
            },
            icon: const Icon(Icons.inbox),
            label: const Text('Abrir Bandeja de Revisión Completa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF512DA8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 48), // Padding inferior
        ],
      ),
    );
  }
}
