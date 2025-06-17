import 'package:OratioLingo/screens/juegos.dart';
import 'package:OratioLingo/screens/levels/nivel1.dart';
import 'package:OratioLingo/screens/levels/nivel2.dart';
import 'package:OratioLingo/screens/progreso.dart';
import 'package:OratioLingo/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/perfil.dart';
import 'package:OratioLingo/screens/videos.dart';
import 'package:OratioLingo/screens/diccionario.dart';
import 'package:OratioLingo/screens/levels/nivel3.dart';
import 'package:OratioLingo/services/niveles_services.dart';

class PantallaNiveles extends StatefulWidget {
  const PantallaNiveles({super.key});

  @override
  State<PantallaNiveles> createState() => _PantallaNivelesState();
}

class _PantallaNivelesState extends State<PantallaNiveles> {
  final NivelesService _nivelesService = NivelesService();
  final FirestoreServices _firestoreServices = FirestoreServices();

  List<Map<String, dynamic>> _progreso = [];
  bool _cargando = true;
  bool _isModalVisible = false;

  // Configuración de niveles disponibles
  final List<Map<String, dynamic>> _nivelesConfig = [
    {
      'numero': 1,
      'titulo': 'Letras A-E',
      'descripcion': 'Aprende las primeras 5 letras',
      'screen': () => const Nivel1Screen(),
    },
    {
      'numero': 2,
      'titulo': 'Letras F-J',
      'descripcion': 'Continúa con más letras',
      'screen': () => const Nivel2Screen(),
    },
    {
      'numero': 3,
      'titulo': 'Letras K-Ñ',
      'descripcion': 'Avanza en tu aprendizaje',
      'screen': () => const Nivel3Screen(),
    },
    {
      'numero': 4,
      'titulo': 'Letras O-S',
      'descripcion': 'Más señas por aprender',
      'screen': () => const Nivel3Screen(),
    },
    {
      'numero': 5,
      'titulo': 'Letras T-Z',
      'descripcion': 'Completa el alfabeto',
      'screen': null,
    },
    {
      'numero': 6,
      'titulo': 'Números 0-9',
      'descripcion': 'Aprende los números',
      'screen': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    try {
      setState(() => _cargando = true);
      final progreso = await _nivelesService.obtenerProgreso();

      if (mounted) {
        setState(() {
          _progreso = progreso;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError('Error al cargar progreso: $e');
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

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: const Color(0xFF58CC02),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Obtener estado del nivel desde el progreso de Firestore
  Map<String, dynamic> _obtenerEstadoNivel(int numeroNivel) {
    try {
      final nivelData = _progreso.firstWhere(
        (nivel) => nivel['numero_nivel'] == numeroNivel,
        orElse:
            () => {
              'numero_nivel': numeroNivel,
              'isUnlocked':
                  numeroNivel == 1, // Solo nivel 1 desbloqueado por defecto
              'isFinished': false,
              'puntuacion_maxima': 0,
            },
      );
      return nivelData;
    } catch (e) {
      return {
        'numero_nivel': numeroNivel,
        'isUnlocked': numeroNivel == 1,
        'isFinished': false,
        'puntuacion_maxima': 0,
      };
    }
  }

  // Verificar estado real desde Firestore
  Future<bool> _verificarEstadoRealNivel(int numeroNivel) async {
    try {
      bool estadoReal = await _nivelesService.estaDesbloqueado(numeroNivel);

      // Si el estado local difiere del real, actualizar silenciosamente
      final estadoLocal = _obtenerEstadoNivel(numeroNivel);
      if (estadoLocal['isUnlocked'] != estadoReal) {
        // Recargar progreso para sincronizar
        await _cargarProgreso();
      }

      return estadoReal;
    } catch (e) {
      print('Error al verificar estado del nivel: $e');
      // En caso de error, usar el estado local como fallback
      final estadoLocal = _obtenerEstadoNivel(numeroNivel);
      return estadoLocal['isUnlocked'] ?? false;
    }
  }

  // Navegar a un nivel específico
  void _navegarANivel(Map<String, dynamic> nivelConfig) {
    final screen = nivelConfig['screen']();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) {
      // Recargar progreso al regresar del nivel
      _cargarProgreso();
    });
  }

  // Intentar abrir nivel anterior disponible
  void _intentarAbrirNivelAnterior(int numeroNivel) async {
    final estadoNivel = _obtenerEstadoNivel(numeroNivel);
    final isUnlocked = estadoNivel['isUnlocked'] ?? false;

    if (isUnlocked) {
      final nivelConfig = _nivelesConfig.firstWhere(
        (config) => config['numero'] == numeroNivel,
        orElse: () => {'numero': numeroNivel, 'screen': null},
      );

      if (nivelConfig['screen'] != null) {
        _navegarANivel(nivelConfig);
      } else {
        _mostrarError('Nivel $numeroNivel no está disponible aún.');
      }
    } else {
      _mostrarError('El Nivel $numeroNivel también está bloqueado.');
    }
  }

  // Mostrar información detallada de un nivel completado (solo info básica)
  void _mostrarInfoNivel(int numeroNivel, Map<String, dynamic> estadoNivel) {
    final theme = Theme.of(context);
    final nivelConfig = _nivelesConfig.firstWhere(
      (config) => config['numero'] == numeroNivel,
      orElse: () => {'titulo': 'Nivel $numeroNivel', 'descripcion': ''},
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF58CC02),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nivelConfig['titulo'] ?? 'Nivel $numeroNivel',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nivelConfig['descripcion'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF58CC02).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFF58CC02),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '¡COMPLETADO!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF58CC02),
                            ),
                          ),
                        ],
                      ),
                      if (estadoNivel['puntuacion_maxima'] != null &&
                          estadoNivel['puntuacion_maxima'] > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Mejor puntuación: ${estadoNivel['puntuacion_maxima']} pts',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _onNivelTapConValidacion(numeroNivel, true, nivelConfig);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Jugar de nuevo'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _cargarProgreso,
                child: Column(
                  children: [
                    _buildTopBar(theme),
                    Expanded(child: _buildLevelsContainer(theme)),
                    _buildBottomNavBar(theme),
                  ],
                ),
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
                    Icons.sign_language,
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

  Widget _buildLevelsContainer(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Título principal
            Text(
              'Niveles de aprendizaje',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Aprende lenguaje de señas paso a paso',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 20),

            // Primera fila de niveles (1, 2, 3)
            _buildLevelRow([1, 2, 3], theme),
            const SizedBox(height: 50),

            // Segunda fila de niveles (4, 5, 6)
            _buildLevelRow([4, 5, 6], theme),
            const SizedBox(height: 50),

            // Sección de examen
            _buildExamSection(theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(List<int> niveles, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLevel(niveles[0], theme),
        _buildPath(theme),
        _buildLevel(niveles[1], theme),
        _buildPath(theme),
        _buildLevel(niveles[2], theme),
      ],
    );
  }

  Widget _buildLevel(int numeroNivel, ThemeData theme) {
    final estadoNivel = _obtenerEstadoNivel(numeroNivel);
    final isUnlocked = estadoNivel['isUnlocked'] ?? false;
    final isFinished = estadoNivel['isFinished'] ?? false;
    final puntuacion = estadoNivel['puntuacion_maxima'] ?? 0;

    // Verificar si el nivel está configurado
    final nivelConfig = _nivelesConfig.firstWhere(
      (config) => config['numero'] == numeroNivel,
      orElse: () => {'numero': numeroNivel, 'screen': null},
    );

    Color colorNivel;
    Widget contenidoNivel;

    if (isFinished) {
      // VERDE con CHECK - Nivel completado
      colorNivel = const Color(0xFF58CC02);
      contenidoNivel = const Icon(Icons.check, color: Colors.white, size: 32);
    } else if (isUnlocked) {
      // MORADO con NÚMERO - Nivel desbloqueado
      colorNivel = const Color(0xFF9C27B0); // Color morado
      contenidoNivel = Text(
        '$numeroNivel',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      // GRIS con CANDADO - Nivel bloqueado
      colorNivel = Colors.grey[400]!;
      contenidoNivel = const Icon(Icons.lock, color: Colors.white, size: 28);
    }

    return GestureDetector(
      onTap:
          () => _onNivelTapConValidacion(numeroNivel, isUnlocked, nivelConfig),
      onLongPress:
          isFinished ? () => _mostrarInfoNivel(numeroNivel, estadoNivel) : null,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorNivel,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (isUnlocked || isFinished)
                  BoxShadow(
                    color: colorNivel.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
              ],
              border:
                  isFinished
                      ? Border.all(color: const Color(0xFF58CC02), width: 3)
                      : isUnlocked
                      ? Border.all(color: const Color(0xFF9C27B0), width: 2)
                      : null,
            ),
            child: Center(child: contenidoNivel),
          ),

          const SizedBox(height: 12),

          // Título del nivel
          Text(
            nivelConfig['titulo'] ?? 'Nivel $numeroNivel',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  isUnlocked || isFinished
                      ? theme.textTheme.bodyLarge?.color
                      : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),

          // Mostrar puntuación si está completado
          if (isFinished && puntuacion > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF58CC02).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${puntuacion}pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          // Indicador de estado
          if (!isUnlocked && !isFinished) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Bloqueado',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else if (isUnlocked && !isFinished) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Disponible',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9C27B0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Método mejorado con validación completa
  void _onNivelTapConValidacion(
    int numeroNivel,
    bool isUnlockedLocal,
    Map<String, dynamic> nivelConfig,
  ) async {
    // Primera validación: estado local
    if (!isUnlockedLocal) {
      _mostrarNivelBloqueado(numeroNivel);
      return;
    }

    // Segunda validación: estado real desde Firestore
    bool estadoRealDesbloqueado = await _verificarEstadoRealNivel(numeroNivel);

    if (!estadoRealDesbloqueado) {
      _mostrarNivelBloqueado(numeroNivel);
      return;
    }

    // Tercera validación: verificar que la pantalla existe
    if (nivelConfig['screen'] == null) {
      _mostrarNivelNoDisponible(numeroNivel);
      return;
    }

    // Todo OK, navegar al nivel
    _navegarANivel(nivelConfig);
  }

  void _mostrarNivelBloqueado(int numeroNivel) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nivel Bloqueado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'El Nivel $numeroNivel está bloqueado.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Completa el nivel anterior para desbloquearlo automáticamente.',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),

                // Información sobre el sistema de desbloqueo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF9C27B0).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: const Color(0xFF9C27B0),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Sistema de Progreso',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Los niveles se desbloquean automáticamente\n'
                        '• Aparecen en morado cuando están disponibles\n'
                        '• Se vuelven verdes cuando los completas',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
              if (numeroNivel > 1)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _intentarAbrirNivelAnterior(numeroNivel - 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Ir a Nivel ${numeroNivel - 1}'),
                ),
            ],
          ),
    );
  }

  void _mostrarNivelNoDisponible(int numeroNivel) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.construction,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Próximamente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'El Nivel $numeroNivel estará disponible pronto.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Mantente atento a las actualizaciones!',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.timeline, color: Colors.blue[600], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Mientras tanto, completa los niveles disponibles para seguir aprendiendo.',
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  Widget _buildPath(ThemeData theme) {
    return Container(
      width: 50,
      height: 4,
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildExamSection(ThemeData theme) {
    // Determinar si el examen está desbloqueado (si completó al menos 3 niveles)
    int nivelesCompletados =
        _progreso.where((nivel) => nivel['isFinished'] == true).length;
    bool examenDesbloqueado = nivelesCompletados >= 3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Examen de Evaluación",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            examenDesbloqueado
                ? "¡Pon a prueba todos tus conocimientos!"
                : "Completa 3 niveles para desbloquear el examen",
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap:
                examenDesbloqueado
                    ? () => _mostrarError('Examen próximamente disponible')
                    : () =>
                        _mostrarError('Completa más niveles para desbloquear'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color:
                    examenDesbloqueado ? Colors.amber[700] : Colors.grey[400],
                shape: BoxShape.circle,
                boxShadow:
                    examenDesbloqueado
                        ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                        : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 50),
                  if (!examenDesbloqueado)
                    Icon(Icons.lock, color: Colors.white, size: 30),
                ],
              ),
            ),
          ),
          if (examenDesbloqueado) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '¡Disponible!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ),
          ],
        ],
      ),
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
          _buildNavItem(Icons.layers, "Niveles", true, theme),
          _buildNavItem(Icons.book, "Diccionario", false, theme),
          _buildNavItem(Icons.play_circle_outline, "Videos", false, theme),
          _buildNavItem(Icons.games, "Juegos", false, theme),
          _buildNavItem(Icons.trending_up, "Progreso", false, theme),
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
        break; // Ya estamos en niveles
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PantallaProgreso()),
        );
        break;
    }
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

  void _abrirPantallaDiccionario() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaDiccionario()),
    );
  }
}
