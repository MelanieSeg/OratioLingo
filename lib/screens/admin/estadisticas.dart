import 'package:flutter/material.dart';
import 'package:OratioLingo/services/estadisticas_service.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final EstadisticasService _estadisticasService = EstadisticasService();

  Map<String, dynamic> _estadisticas = {};
  List<Map<String, dynamic>> _usuariosActivos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      setState(() => _cargando = true);

      final estadisticas =
          await _estadisticasService.obtenerEstadisticasGenerales();
      final usuariosActivos =
          await _estadisticasService.obtenerUsuariosActivos();

      if (mounted) {
        setState(() {
          _estadisticas = estadisticas;
          _usuariosActivos = usuariosActivos;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError('Error al cargar estadísticas: $e');
      }
    }
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(theme),
          Expanded(
            child:
                _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _buildEstadisticasContent(theme, size),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height:
          (size.height * 0.07) +
          topPadding, // Altura adaptable + padding superior
      color: theme.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: theme.cardColor),
            ),
            Container(
              width: size.width * 0.1,
              height: size.width * 0.1,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics,
                color: theme.colorScheme.primary,
                size: size.width * 0.06,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Text(
                'Estadísticas',
                style: TextStyle(
                  color: theme.cardColor,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: _cargarEstadisticas,
              icon: Icon(Icons.refresh, color: theme.cardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasContent(ThemeData theme, Size size) {
    return RefreshIndicator(
      onRefresh: _cargarEstadisticas,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04), // Padding adaptable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),

              Text(
                'Resumen General',
                style: TextStyle(
                  fontSize: size.width * 0.06, // Tamaño de fuente adaptable
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

              SizedBox(height: size.height * 0.01),

              _buildEstadisticasGrid(theme, size),

              SizedBox(height: size.height * 0.03),

              Text(
                'Usuarios Más Activos',
                style: TextStyle(
                  fontSize: size.width * 0.05, // Tamaño de fuente adaptable
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              _buildUsuariosActivos(theme, size),

              SizedBox(height: size.height * 0.03),

              _buildProgresoNiveles(theme, size),

              // Espacio al final para evitar que el contenido quede pegado al borde
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticasGrid(ThemeData theme, Size size) {
    final List<Map<String, dynamic>> stats = [
      {
        'titulo': 'Total Usuarios',
        'valor': _estadisticas['total_usuarios'] ?? 0,
        'icono': Icons.people,
        'color': const Color(0xFF58CC02),
      },
      {
        'titulo': 'Usuarios Activos Hoy',
        'valor': _estadisticas['usuarios_activos_hoy'] ?? 0,
        'icono': Icons.person_outline,
        'color': const Color(0xFF2196F3),
      },
      {
        'titulo': 'Videos Disponibles',
        'valor': _estadisticas['total_videos'] ?? 0,
        'icono': Icons.video_library,
        'color': const Color(0xFF9C27B0),
      },
      {
        'titulo': 'Niveles Completados',
        'valor': _estadisticas['niveles_completados'] ?? 0,
        'icono': Icons.emoji_events,
        'color': const Color(0xFFFF9800),
      },
    ];

    // Calcula el número de columnas según el ancho de la pantalla
    int crossAxisCount = size.width > 600 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.9,
        crossAxisSpacing: size.width * 0.04, // Espaciado adaptable
        mainAxisSpacing: size.width * 0.04, // Espaciado adaptable
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(stat, theme, size);
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, ThemeData theme, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(
          size.width * 0.04,
        ), // Border radius adaptable
        boxShadow: [
          BoxShadow(
            color: (stat['color'] as Color).withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: (stat['color'] as Color).withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.03), // Padding adaptable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.12, // Ancho adaptable
              height: size.width * 0.12, // Altura adaptable
              decoration: BoxDecoration(
                color: (stat['color'] as Color).withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(size.width * 0.03),
              ),
              child: Icon(
                stat['icono'] as IconData,
                color: stat['color'] as Color,
                size: size.width * 0.07, // Tamaño del icono adaptable
              ),
            ),

            SizedBox(height: size.height * 0.015),

            Text(
              '${stat['valor']}',
              style: TextStyle(
                fontSize: size.width * 0.06, // Tamaño de fuente adaptable
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),

            SizedBox(height: size.height * 0.005),

            Text(
              stat['titulo'] as String,
              style: TextStyle(
                fontSize: size.width * 0.03, // Tamaño de fuente adaptable
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsuariosActivos(ThemeData theme, Size size) {
    if (_usuariosActivos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: size.width * 0.12,
              color: Colors.grey[400],
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              'No hay usuarios activos',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Limita a 4 usuarios para evitar problemas de espacio en pantallas pequeñas
    final usuariosAMostrar = _usuariosActivos.take(4).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: usuariosAMostrar.length,
      itemBuilder: (context, index) {
        final usuario = usuariosAMostrar[index];
        return Container(
          margin: EdgeInsets.only(bottom: size.height * 0.015),
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(size.width * 0.03),
            border: Border.all(
              color: Colors.grey.withAlpha((0.2 * 255).round()),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: size.width * 0.12,
                height: size.width * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02).withAlpha((0.1 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF58CC02),
                  size: size.width * 0.06,
                ),
              ),

              SizedBox(width: size.width * 0.04),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario['nombre'] ?? 'Usuario',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      usuario['email'] ?? '',
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF58CC02,
                      ).withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                    ),
                    child: Text(
                      'Nivel ${usuario['nivel_actual'] ?? 1}',
                      style: TextStyle(
                        color: const Color(0xFF58CC02),
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    '${usuario['puntos_totales'] ?? 0} pts',
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgresoNiveles(ThemeData theme, Size size) {
    final nivelesData = _estadisticas['progreso_niveles'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso por Niveles',
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),

        SizedBox(height: size.height * 0.02),

        Container(
          padding: EdgeInsets.all(size.width * 0.05),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(size.width * 0.04),
          ),
          child: Column(
            children: [
              for (int i = 1; i <= 6; i++) ...[
                _buildNivelProgreso(
                  i,
                  nivelesData['nivel_$i'] ?? 0,
                  theme,
                  size,
                ),
                if (i < 6) SizedBox(height: size.height * 0.02),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNivelProgreso(
    int numeroNivel,
    int usuariosCompletados,
    ThemeData theme,
    Size size,
  ) {
    final totalUsuarios = _estadisticas['total_usuarios'] ?? 1;
    final porcentaje =
        totalUsuarios > 0 ? (usuariosCompletados / totalUsuarios) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nivel $numeroNivel',
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              '$usuariosCompletados usuarios (${(porcentaje * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),

        SizedBox(height: size.height * 0.01),

        LinearProgressIndicator(
          value: porcentaje,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getColorForNivel(numeroNivel),
          ),
          minHeight: size.height * 0.01, // Altura adaptable
        ),
      ],
    );
  }

  Color _getColorForNivel(int nivel) {
    switch (nivel) {
      case 1:
        return const Color(0xFF58CC02);
      case 2:
        return const Color(0xFF2196F3);
      case 3:
        return const Color(0xFF9C27B0);
      case 4:
        return const Color(0xFFFF9800);
      case 5:
        return const Color(0xFFF44336);
      case 6:
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
  }
}
