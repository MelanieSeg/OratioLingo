import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _cargando = true;
  Map<String, dynamic> _estadisticas = {};
  List<Map<String, dynamic>> _usuariosActivos = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      setState(() {
        _cargando = true;
        _errorMessage = null;
      });

      // Verificar permisos con una operación de lectura simple
      try {
        print("Verificando permisos de Firestore...");
        final testRead = await _firestore.collection('usuarios').limit(1).get();
        print(
          "Permiso de lectura OK. Documentos encontrados: ${testRead.docs.length}",
        );
      } catch (e) {
        print("Error de permisos en Firestore: $e");
        if (mounted) {
          setState(() {
            _cargando = false;
            _errorMessage = 'Error de permisos: $e';
          });
        }
        return;
      }

      // Obtener estadísticas generales
      await Future.wait([
        _obtenerEstadisticasGenerales(),
        _obtenerUsuariosActivos(),
      ]);

      if (mounted) {
        setState(() => _cargando = false);
      }
    } catch (e) {
      print('Error general al cargar estadísticas: $e');
      if (mounted) {
        setState(() {
          _cargando = false;
          _errorMessage = 'Error al cargar estadísticas: $e';
        });
      }
    }
  }

  Future<void> _obtenerEstadisticasGenerales() async {
    try {
      // 1. Total de usuarios desde Firestore
      int totalUsuarios = 0;
      try {
        final usuariosSnapshot = await _firestore.collection('usuarios').get();
        totalUsuarios = usuariosSnapshot.docs.length;
        print('Total de usuarios: $totalUsuarios');
      } catch (e) {
        print('Error al contar usuarios: $e');
      }

      // 2. Total de videos
      int totalVideos = 0;
      try {
        final videosSnapshot = await _firestore.collection('videos').get();
        totalVideos = videosSnapshot.docs.length;
        print('Total de videos: $totalVideos');
      } catch (e) {
        print('Error al contar videos: $e');
      }

      // 3. Niveles completados
      int nivelesCompletados = 0;
      try {
        final usuariosSnapshot = await _firestore.collection('usuarios').get();

        for (var doc in usuariosSnapshot.docs) {
          try {
            final nivelesSnapshot =
                await _firestore
                    .collection('usuarios')
                    .doc(doc.id)
                    .collection('niveles')
                    .where('isFinished', isEqualTo: true)
                    .get();

            nivelesCompletados += nivelesSnapshot.docs.length;
          } catch (e) {
            print('Error al contar niveles para usuario ${doc.id}: $e');
          }
        }

        print('Niveles completados: $nivelesCompletados');
      } catch (e) {
        print('Error al contar niveles completados: $e');
      }

      // 4. Administradores activos
      int adminsActivos = 0;
      try {
        final adminsSnapshot =
            await _firestore
                .collection('administradores')
                .where('activo', isEqualTo: true)
                .get();
        adminsActivos = adminsSnapshot.docs.length;
        print('Administradores activos: $adminsActivos');
      } catch (e) {
        print('Error al contar administradores activos: $e');
      }

      // Guardar los datos
      if (mounted) {
        setState(() {
          _estadisticas = {
            'total_usuarios': totalUsuarios,
            'total_videos': totalVideos,
            'niveles_completados': nivelesCompletados,
            'admins_activos': adminsActivos,
          };
        });
      }
    } catch (e) {
      print('Error al obtener estadísticas generales: $e');
    }
  }

  Future<void> _obtenerUsuariosActivos() async {
    try {
      List<Map<String, dynamic>> usuarios = [];

      // Intentar obtener usuarios ordenados por última actividad desde Firestore
      try {
        final usuariosSnapshot =
            await _firestore
                .collection('usuarios')
                .orderBy('ultima_actividad', descending: true)
                .limit(5)
                .get();

        for (var doc in usuariosSnapshot.docs) {
          final data = doc.data();

          String actividadFormatada = 'No disponible';
          DateTime? ultimaActividad;

          // Usar ultima_actividad de Firestore
          if (data.containsKey('ultima_actividad')) {
            try {
              final timestamp = data['ultima_actividad'] as Timestamp;
              ultimaActividad = timestamp.toDate();
              actividadFormatada = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(ultimaActividad);
            } catch (e) {
              print('Error al formatear fecha de actividad: $e');
            }
          }

          usuarios.add({
            'id': doc.id,
            'nombre': data['nombre'] ?? 'Usuario',
            'correo': data['correo'] ?? 'No disponible',
            'ultima_actividad': ultimaActividad,
            'ultima_actividad_formatted': actividadFormatada,
          });
        }
      } catch (e) {
        print('Error con query ordenada, usando método alternativo: $e');

        // Fallback: obtener todos y ordenar manualmente
        final usuariosSnapshot = await _firestore.collection('usuarios').get();
        List<Map<String, dynamic>> usuariosConFecha = [];

        for (var doc in usuariosSnapshot.docs) {
          try {
            final data = doc.data();

            DateTime? ultimaActividad;
            String actividadFormatada = 'No disponible';

            // Priorizar ultima_actividad de Firestore
            if (data.containsKey('ultima_actividad')) {
              try {
                final timestamp = data['ultima_actividad'] as Timestamp;
                ultimaActividad = timestamp.toDate();
                actividadFormatada = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(ultimaActividad);
              } catch (e) {
                print('Error al procesar ultima_actividad: $e');
              }
            }

            // Si no hay ultima_actividad, usar fechaCreacion como fallback
            if (ultimaActividad == null && data.containsKey('fechaCreacion')) {
              try {
                final timestamp = data['fechaCreacion'] as Timestamp;
                ultimaActividad = timestamp.toDate();
                actividadFormatada = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(ultimaActividad);
              } catch (e) {
                print('Error al procesar fechaCreacion: $e');
              }
            }

            usuariosConFecha.add({
              'id': doc.id,
              'nombre': data['nombre'] ?? 'Usuario',
              'correo': data['correo'] ?? 'No disponible',
              'ultima_actividad': ultimaActividad,
              'ultima_actividad_formatted': actividadFormatada,
            });
          } catch (e) {
            print('Error al procesar usuario ${doc.id}: $e');
          }
        }

        // Ordenar por fecha de última actividad (más reciente primero)
        usuariosConFecha.sort((a, b) {
          final fechaA = a['ultima_actividad'] as DateTime?;
          final fechaB = b['ultima_actividad'] as DateTime?;

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaB.compareTo(fechaA);
        });

        // Tomar solo los 5 más recientes
        usuarios = usuariosConFecha.take(5).toList();
      }

      print('Usuarios activos encontrados: ${usuarios.length}');

      if (mounted) {
        setState(() {
          _usuariosActivos = usuarios;
        });
      }
    } catch (e) {
      print('Error al obtener usuarios activos: $e');
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
                    : _errorMessage != null
                    ? _buildErrorView(theme, size)
                    : _buildEstadisticasContent(theme, size),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, Size size) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar estadísticas',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarEstadisticas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: (size.height * 0.07) + topPadding,
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
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: theme.cardColor,
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
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              Text(
                'Resumen General',
                style: TextStyle(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              _buildEstadisticasGrid(theme, size),
              SizedBox(height: size.height * 0.03),
              Text(
                'Usuarios activos recientes',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              _buildUsuariosActivos(theme, size),
              SizedBox(height: size.height * 0.05),
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
      {
        'titulo': 'Administradores',
        'valor': _estadisticas['admins_activos'] ?? 0,
        'icono': Icons.admin_panel_settings,
        'color': const Color(0xFF795548),
      },
    ];

    int crossAxisCount = size.width > 600 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.9,
        crossAxisSpacing: size.width * 0.04,
        mainAxisSpacing: size.width * 0.04,
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
        borderRadius: BorderRadius.circular(size.width * 0.04),
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
        padding: EdgeInsets.all(size.width * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.12,
              height: size.width * 0.12,
              decoration: BoxDecoration(
                color: (stat['color'] as Color).withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(size.width * 0.03),
              ),
              child: Icon(
                stat['icono'] as IconData,
                color: stat['color'] as Color,
                size: size.width * 0.07,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              '${stat['valor']}',
              style: TextStyle(
                fontSize: size.width * 0.08,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              stat['titulo'] as String,
              style: TextStyle(
                fontSize: size.width * 0.035,
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
              'No hay datos de usuarios activos',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _usuariosActivos.length,
      itemBuilder: (context, index) {
        final usuario = _usuariosActivos[index];
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
              // Avatar del usuario (primera letra del nombre)
              Container(
                width: size.width * 0.12,
                height: size.width * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withAlpha(
                    (0.1 * 255).round(),
                  ),
                ),
                child: Center(
                  child: Text(
                    (usuario['nombre'] as String).isNotEmpty
                        ? (usuario['nombre'] as String)[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.03),
              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario['nombre'] as String,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      usuario['correo'] as String,
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Última actividad
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Última actividad',
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    usuario['ultima_actividad_formatted'] as String,
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
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
}
