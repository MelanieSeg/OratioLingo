import 'package:flutter/material.dart';
import 'package:OratioLingo/services/niveles_services.dart';
import 'package:OratioLingo/screens/niveles.dart';
import 'package:OratioLingo/screens/videos.dart';
import 'package:OratioLingo/screens/juegos.dart';
import 'package:OratioLingo/screens/perfil.dart';
import 'package:OratioLingo/screens/diccionario.dart';
import 'package:OratioLingo/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class PantallaProgreso extends StatefulWidget {
  const PantallaProgreso({super.key});

  @override
  State<PantallaProgreso> createState() => _PantallaProgresoState();
}

class _PantallaProgresoState extends State<PantallaProgreso>
    with TickerProviderStateMixin {
  final NivelesService _nivelesService = NivelesService();
  final FirestoreServices _firestoreServices = FirestoreServices();

  List<Map<String, dynamic>> _progreso = [];
  Map<String, dynamic> _estadisticasGenerales = {};
  bool _cargando = true;
  bool _isModalVisible = false;

  late AnimationController _progressController;
  late AnimationController _chartController;
  late Animation<double> _progressAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _cargarDatos();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _chartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() => _cargando = true);

      // Cargar progreso de niveles
      final progreso = await _nivelesService.obtenerProgreso();

      // Cargar estadísticas generales
      final estadisticas = await _obtenerEstadisticasGenerales();

      if (mounted) {
        setState(() {
          _progreso = progreso;
          _estadisticasGenerales = estadisticas;
          _cargando = false;
        });

        // Iniciar animaciones después de cargar datos
        _progressController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _chartController.forward();
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError('Error al cargar datos de progreso');
      }
    }
  }

  Future<Map<String, dynamic>> _obtenerEstadisticasGenerales() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return _estadisticasPorDefecto();
      }

      // Obtener estadísticas de Firestore
      final estadisticasDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('estadisticas')
              .doc('general')
              .get();

      if (estadisticasDoc.exists) {
        final data = estadisticasDoc.data()!;
        return {
          'tiempo_total': data['tiempo_total'] ?? 0,
          'sesion_promedio': data['sesion_promedio'] ?? 15,
          'racha_actual': data['racha_actual'] ?? 1,
          'racha_maxima': data['racha_maxima'] ?? 1,
          'total_aciertos': data['total_aciertos'] ?? 0,
          'total_fallos': data['total_fallos'] ?? 0,
          'precision':
              data['total_aciertos'] != null && data['total_fallos'] != null
                  ? data['total_aciertos'] /
                      (data['total_aciertos'] + data['total_fallos'])
                  : 0.0,
          'niveles_completados': data['niveles_completados'] ?? 0,
          'nivel_maximo_alcanzado': data['nivel_maximo_alcanzado'] ?? 1,
          'fecha_registro': data['fecha_creacion']?.toDate() ?? DateTime.now(),
        };
      } else {
        return _estadisticasPorDefecto();
      }
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return _estadisticasPorDefecto();
    }
  }

  Map<String, dynamic> _estadisticasPorDefecto() {
    return {
      'tiempo_total': 0,
      'sesion_promedio': 15,
      'racha_actual': 1,
      'racha_maxima': 1,
      'total_aciertos': 0,
      'total_fallos': 0,
      'precision': 0.0,
      'niveles_completados': 0,
      'nivel_maximo_alcanzado': 1,
      'fecha_registro': DateTime.now(),
    };
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(theme),
          Expanded(
            child:
                _cargando
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando tu progreso...'),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _cargarDatos,
                      child: _buildContent(theme),
                    ),
          ),
          _buildBottomNavBar(theme),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _toggleModal,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Título
            Text(
              'Mi Progreso',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),

            Text(
              'Tu evolución en el aprendizaje',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 24),

            // Resumen general
            _buildResumenGeneral(theme),
            const SizedBox(height: 24),

            // Gráfico circular de progreso
            _buildGraficoProgreso(theme),
            const SizedBox(height: 24),

            // Estadísticas detalladas
            _buildEstadisticasDetalladas(theme),
            const SizedBox(height: 24),

            // Progreso por nivel
            _buildProgresoNiveles(theme),
            const SizedBox(height: 24),

            // Racha y motivación
            _buildRachayMotivacion(theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenGeneral(ThemeData theme) {
    // Calcular estadísticas desde los datos reales
    int nivelesCompletados =
        _progreso.where((n) => n['isFinished'] == true).length;
    int totalNiveles = math.max(
      _progreso.length,
      6,
    ); // Asegurar al menos 6 niveles
    double porcentajeProgreso =
        totalNiveles > 0 ? (nivelesCompletados / totalNiveles) : 0;
    int puntuacionTotal = _progreso.fold(
      0,
      (sum, n) => sum + ((n['puntuacion_maxima'] ?? 0) as int),
    );

    // Obtener precisión de estadísticas generales
    double precision = (_estadisticasGenerales['precision'] ?? 0.0).toDouble();
    if (precision == 0.0) {
      int totalAciertos = _estadisticasGenerales['total_aciertos'] ?? 0;
      int totalFallos = _estadisticasGenerales['total_fallos'] ?? 0;
      if (totalAciertos + totalFallos > 0) {
        precision = totalAciertos / (totalAciertos + totalFallos);
      }
    }

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _progressAnimation.value),
          child: Opacity(
            opacity: _progressAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progreso General',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${(porcentajeProgreso * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Barra de progreso animada
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor:
                          porcentajeProgreso * _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Estadísticas rápidas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickStat(
                        'Niveles\nCompletados',
                        '$nivelesCompletados/$totalNiveles',
                      ),
                      _buildQuickStat('Puntuación\nTotal', '$puntuacionTotal'),
                      _buildQuickStat(
                        'Precisión',
                        '${(precision * 100).round()}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGraficoProgreso(ThemeData theme) {
    int nivelesCompletados =
        _progreso.where((n) => n['isFinished'] == true).length;
    int totalNiveles = math.max(_progreso.length, 6);
    double porcentaje = nivelesCompletados / totalNiveles;

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Progreso Visual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),

              // Gráfico circular personalizado
              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: CircularProgressIndicator(
                        value: porcentaje * _chartAnimation.value,
                        strokeWidth: 12,
                        backgroundColor: theme.dividerColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$nivelesCompletados',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'de $totalNiveles',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Leyenda
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Completados', theme.colorScheme.primary),
                  const SizedBox(width: 20),
                  _buildLegendItem('Pendientes', theme.dividerColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEstadisticasDetalladas(ThemeData theme) {
    int tiempoTotal = _estadisticasGenerales['tiempo_total'] ?? 0;
    int sesionPromedio = _estadisticasGenerales['sesion_promedio'] ?? 15;
    int totalAciertos = _estadisticasGenerales['total_aciertos'] ?? 0;
    int totalFallos = _estadisticasGenerales['total_fallos'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Estadísticas Detalladas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),

          // Primera fila
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  title: 'Tiempo Total',
                  value:
                      tiempoTotal >= 60
                          ? '${(tiempoTotal / 60).floor()}h ${tiempoTotal % 60}m'
                          : '${tiempoTotal}m',
                  color: Colors.blue,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  title: 'Sesión Promedio',
                  value: '${sesionPromedio}m',
                  color: Colors.green,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segunda fila
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  title: 'Aciertos',
                  value: '$totalAciertos',
                  color: const Color(0xFF58CC02),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cancel,
                  title: 'Fallos',
                  value: '$totalFallos',
                  color: Colors.red,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoNiveles(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso por Nivel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de niveles con su progreso
          if (_progreso.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.school, size: 48, color: theme.dividerColor),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no has comenzado ningún nivel',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaNiveles(),
                        ),
                      );
                    },
                    child: const Text('Comenzar Aprendizaje'),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...List.generate(math.min(_progreso.length, 6), (index) {
              final nivel = _progreso[index];
              return _buildNivelProgressItem(nivel, theme);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildNivelProgressItem(Map<String, dynamic> nivel, ThemeData theme) {
    final numeroNivel = nivel['numero_nivel'] ?? 0;
    final isUnlocked = nivel['isUnlocked'] ?? false;
    final isFinished = nivel['isFinished'] ?? false;
    final puntuacion = nivel['puntuacion_maxima'] ?? 0;
    final intentos = nivel['intentos'] ?? 0;

    String titulo = _obtenerTituloNivel(numeroNivel);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icono del nivel
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isFinished
                      ? const Color(0xFF58CC02)
                      : isUnlocked
                      ? theme.colorScheme.primary
                      : Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child:
                  isFinished
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : isUnlocked
                      ? Text(
                        '$numeroNivel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : const Icon(Icons.lock, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),

          // Información del nivel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (isFinished) ...[
                  Text(
                    'Puntuación: $puntuacion pts | Intentos: $intentos',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ] else if (isUnlocked) ...[
                  Text(
                    'Nivel disponible - ¡Comienza ahora!',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Nivel bloqueado',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),

          // Indicador de estado
          if (isFinished)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Completado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Disponible',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _obtenerTituloNivel(int numeroNivel) {
    const titulos = {
      1: 'Letras A-E',
      2: 'Letras F-J',
      3: 'Letras K-Ñ',
      4: 'Letras O-S',
      5: 'Letras T-Z',
      6: 'Números 0-9',
    };
    return titulos[numeroNivel] ?? 'Nivel $numeroNivel';
  }

  Widget _buildRachayMotivacion(ThemeData theme) {
    int rachaActual = _estadisticasGenerales['racha_actual'] ?? 1;
    int rachaMaxima = _estadisticasGenerales['racha_maxima'] ?? 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),

          const Text(
            '¡Racha de Estudio!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            rachaActual > 1
                ? 'Llevas $rachaActual días consecutivos estudiando'
                : '¡Comienza tu racha de estudio!',
            style: const TextStyle(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRachaItem(
                'Racha Actual',
                '$rachaActual día${rachaActual != 1 ? 's' : ''}',
              ),
              _buildRachaItem(
                'Racha Máxima',
                '$rachaMaxima día${rachaMaxima != 1 ? 's' : ''}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            rachaActual >= 7
                ? '¡Excelente! Mantén esta constancia para dominar el lenguaje de señas.'
                : '¡Sigue así! Cada día cuenta para dominar el lenguaje de señas.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRachaItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
      ],
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.layers, "Niveles", false, theme),
          _buildNavItem(Icons.book, "Diccionario", false, theme),
          _buildNavItem(Icons.play_circle_outline, "Videos", false, theme),
          _buildNavItem(Icons.games, "Juegos", false, theme),
          _buildNavItem(Icons.trending_up, "Progreso", true, theme),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    ThemeData theme,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTap(label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isSelected ? theme.colorScheme.primary : theme.disabledColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleModal() {
    setState(() => _isModalVisible = !_isModalVisible);
    if (_isModalVisible) _showProfileModal();
  }

  void _showProfileModal() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _abrirEditarPerfil();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Editar Perfil"),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _cerrarSesion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Cerrar Sesión"),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => setState(() => _isModalVisible = false));
  }

  void _onNavItemTap(String label) {
    switch (label) {
      case "Niveles":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaNiveles()),
        );
        break;
      case "Diccionario":
        _abrirPantallaDiccionario();
        break;
      case "Videos":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PantallaVideos()),
        );
        break;
      case "Juegos":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PantallaJuegos()),
        );
        break;
      case "Progreso":
        break; // Ya estamos aquí
    }
  }

  void _abrirPantallaDiccionario() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PantallaDiccionario()),
    );
  }

  void _cerrarSesion() {
    _firestoreServices.cerrarSesion();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _abrirEditarPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaPerfil()),
    );
  }
}

// Clase para pintar el gráfico circular personalizado
class ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  ProgressCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Círculo de fondo
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Círculo de progreso
    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
