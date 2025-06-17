import 'package:flutter/material.dart';
import 'dart:math';

class JuegoMemoria extends StatefulWidget {
  const JuegoMemoria({super.key});

  @override
  State<JuegoMemoria> createState() => _JuegoMemoriaState();
}

class _JuegoMemoriaState extends State<JuegoMemoria>
    with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _flipController;
  late AnimationController _matchController;
  late AnimationController _shakeController;
  late Animation<double> _matchAnimation;
  late Animation<double> _shakeAnimation;

  // Estados del juego
  List<Map<String, dynamic>> cartas = [];
  int? primerCartaIndex;
  int? segundoCartaIndex;
  bool procesandoComparacion = false;
  int parejasEncontradas = 0;
  int movimientos = 0;
  int puntuacion = 1000;
  bool juegoTerminado = false;

  // Datos de las primeras 6 letras
  final List<Map<String, String>> letrasYSenias = [
    {'letra': 'A', 'senia': 'a'},
    {'letra': 'B', 'senia': 'b'},
    {'letra': 'C', 'senia': 'c'},
    {'letra': 'D', 'senia': 'd'},
    {'letra': 'E', 'senia': 'e'},
    {'letra': 'F', 'senia': 'f'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _inicializarJuego();
  }

  void _initAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // No necesitamos mantener _flipAnimation si no la usamos
    _matchAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _matchController, curve: Curves.elasticOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  void _inicializarJuego() {
    cartas.clear();

    // Crear cartas de letras
    for (var item in letrasYSenias) {
      cartas.add({
        'contenido': item['letra']!,
        'tipo': 'letra',
        'pareja': item['senia']!,
        'volteada': false,
        'emparejada': false,
        'id': 'letra_${item['letra']}',
      });
    }

    // Crear cartas de señas
    for (var item in letrasYSenias) {
      cartas.add({
        'contenido': item['senia']!,
        'tipo': 'senia',
        'pareja': item['letra']!,
        'volteada': false,
        'emparejada': false,
        'id': 'senia_${item['senia']}',
      });
    }

    // Mezclar las cartas
    cartas.shuffle(Random());

    setState(() {
      parejasEncontradas = 0;
      movimientos = 0;
      puntuacion = 1000;
      juegoTerminado = false;
      primerCartaIndex = null;
      segundoCartaIndex = null;
      procesandoComparacion = false;
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _matchController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildGameInfo(theme),
            Expanded(child: _buildGameGrid(theme)),
            _buildBottomButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.iconTheme.color,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Memoria de Señas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color, size: 28),
            onPressed: _reiniciarJuego,
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              26,
            ), // Reemplazado withOpacity por withAlpha
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            'Parejas',
            '$parejasEncontradas/6',
            Icons.psychology,
            const Color(0xFF58CC02),
            theme,
          ),
          _buildDivider(theme),
          _buildInfoItem(
            'Movimientos',
            '$movimientos',
            Icons.touch_app,
            const Color(0xFF1CB0F6),
            theme,
          ),
          _buildDivider(theme),
          _buildInfoItem(
            'Puntuación',
            '$puntuacion',
            Icons.stars,
            const Color(0xFFFF9500),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(width: 1, height: 40, color: theme.dividerColor);
  }

  Widget _buildGameGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Grid responsivo basado en el ancho disponible
          int crossAxisCount = 3;
          if (constraints.maxWidth > 600) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 400) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 3; // Mínimo 3 columnas para 12 cartas
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: cartas.length,
            itemBuilder: (context, index) {
              return _buildCard(index, theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(int index, ThemeData theme) {
    final carta = cartas[index];
    final bool mostrarContenido = carta['volteada'] || carta['emparejada'];
    final bool esSeleccionada =
        primerCartaIndex == index || segundoCartaIndex == index;

    return GestureDetector(
      onTap: () => _voltearCarta(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_shakeAnimation, _matchAnimation]),
        builder: (context, child) {
          double shake = 0;
          double scale = 1;

          if (esSeleccionada && procesandoComparacion) {
            if (carta['emparejada']) {
              scale = 1 + (_matchAnimation.value - 1) * 0.3;
            } else {
              shake = _shakeAnimation.value * 5 * (1 - _shakeAnimation.value);
            }
          }

          return Transform.translate(
            offset: Offset(shake, 0),
            child: Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _getCardColor(carta, theme),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getBorderColor(carta, esSeleccionada, theme),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(
                        26,
                      ), // Reemplazado withOpacity por withAlpha
                      blurRadius: carta['emparejada'] ? 12 : 6,
                      offset: Offset(0, carta['emparejada'] ? 6 : 3),
                    ),
                  ],
                ),
                child:
                    mostrarContenido
                        ? _buildCardContent(carta, theme)
                        : _buildCardBack(theme),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCardColor(Map<String, dynamic> carta, ThemeData theme) {
    if (carta['emparejada']) {
      return const Color(0xFF58CC02);
    }
    if (carta['volteada']) {
      return carta['tipo'] == 'letra'
          ? const Color(0xFF1CB0F6)
          : const Color(0xFFFF9500);
    }
    return theme.cardColor;
  }

  Color _getBorderColor(
    Map<String, dynamic> carta,
    bool esSeleccionada,
    ThemeData theme,
  ) {
    if (carta['emparejada']) {
      return const Color(0xFF58CC02);
    }
    if (esSeleccionada) {
      return const Color(0xFFFF4B4B);
    }
    if (carta['volteada']) {
      return carta['tipo'] == 'letra'
          ? const Color(0xFF1CB0F6)
          : const Color(0xFFFF9500);
    }
    return theme.dividerColor;
  }

  Widget _buildCardContent(Map<String, dynamic> carta, ThemeData theme) {
    final bool esSenia = carta['tipo'] == 'senia';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (carta['emparejada'])
          const Icon(Icons.check_circle, color: Colors.white, size: 24)
        else ...[
          // Contenido principal
          Expanded(
            child: Center(
              child: Text(
                carta['contenido'],
                style: TextStyle(
                  fontFamily: esSenia ? 'ChileanSignLanguage' : null,
                  fontSize: esSenia ? 32 : 28,
                  fontWeight: esSenia ? FontWeight.normal : FontWeight.bold,
                  color:
                      carta['volteada']
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          // Etiqueta del tipo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(
                51,
              ), // Reemplazado withOpacity por withAlpha
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Text(
              esSenia ? 'SEÑA' : 'LETRA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardBack(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(
              204,
            ), // Reemplazado withOpacity por withAlpha
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.help_outline, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildBottomButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('REINICIAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CB0F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _reiniciarJuego,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('PISTA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: parejasEncontradas < 6 ? _mostrarPista : null,
            ),
          ),
        ],
      ),
    );
  }

  void _voltearCarta(int index) {
    if (procesandoComparacion ||
        cartas[index]['volteada'] ||
        cartas[index]['emparejada'] ||
        juegoTerminado) {
      return;
    }

    setState(() {
      cartas[index]['volteada'] = true;

      if (primerCartaIndex == null) {
        primerCartaIndex = index;
      } else if (segundoCartaIndex == null) {
        segundoCartaIndex = index;
        movimientos++;
        procesandoComparacion = true;

        // Reducir puntuación por movimiento
        if (puntuacion > 50) {
          puntuacion -= 50;
        }
      }
    });

    if (primerCartaIndex != null && segundoCartaIndex != null) {
      _verificarPareja();
    }
  }

  void _verificarPareja() {
    final carta1 = cartas[primerCartaIndex!];
    final carta2 = cartas[segundoCartaIndex!];

    // Verificar si forman pareja
    bool esPareja =
        (carta1['tipo'] == 'letra' &&
            carta2['tipo'] == 'senia' &&
            carta1['contenido'] == carta2['pareja']) ||
        (carta1['tipo'] == 'senia' &&
            carta2['tipo'] == 'letra' &&
            carta1['contenido'] == carta2['pareja']);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (esPareja) {
        // Pareja correcta
        _matchController.forward().then((_) {
          _matchController.reset();
        });

        setState(() {
          cartas[primerCartaIndex!]['emparejada'] = true;
          cartas[segundoCartaIndex!]['emparejada'] = true;
          parejasEncontradas++;

          // Bonus por pareja encontrada
          puntuacion += 100;
        });

        if (parejasEncontradas == 6) {
          _juegoCompletado();
        }
      } else {
        // Pareja incorrecta
        _shakeController.forward().then((_) {
          _shakeController.reset();

          setState(() {
            cartas[primerCartaIndex!]['volteada'] = false;
            cartas[segundoCartaIndex!]['volteada'] = false;
          });
        });
      }

      setState(() {
        primerCartaIndex = null;
        segundoCartaIndex = null;
        procesandoComparacion = false;
      });
    });
  }

  void _juegoCompletado() {
    setState(() {
      juegoTerminado = true;
    });

    // Bonus por completar el juego
    final bonusVelocidad = max(0, 500 - (movimientos * 20));
    puntuacion += bonusVelocidad;

    Future.delayed(const Duration(milliseconds: 1000), () {
      _mostrarDialogoVictoria();
    });
  }

  void _mostrarDialogoVictoria() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de victoria
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF58CC02),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  '¡Felicitaciones!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Has completado el juego de memoria',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Estadísticas del juego
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'Movimientos:',
                        '$movimientos',
                        Icons.touch_app,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        'Puntuación:',
                        '$puntuacion',
                        Icons.stars,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        'Precisión:',
                        '${((6 / movimientos) * 100).toStringAsFixed(1)}%',
                        Icons.gps_fixed,
                        theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1CB0F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _reiniciarJuego();
                        },
                        child: const Text('JUGAR DE NUEVO'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('SALIR'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  void _reiniciarJuego() {
    _flipController.reset();
    _matchController.reset();
    _shakeController.reset();
    _inicializarJuego();
  }

  void _mostrarPista() {
    // Encontrar una carta no emparejada y no volteada
    List<int> cartasDisponibles = [];
    for (int i = 0; i < cartas.length; i++) {
      if (!cartas[i]['emparejada'] && !cartas[i]['volteada']) {
        cartasDisponibles.add(i);
      }
    }

    if (cartasDisponibles.isEmpty) return;

    // Seleccionar una carta al azar
    final random = Random();
    final indexSeleccionado =
        cartasDisponibles[random.nextInt(cartasDisponibles.length)];

    setState(() {
      cartas[indexSeleccionado]['volteada'] = true;
      puntuacion = max(0, puntuacion - 100); // Penalización por usar pista
    });

    // Ocultar la carta después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (!cartas[indexSeleccionado]['emparejada']) {
        setState(() {
          cartas[indexSeleccionado]['volteada'] = false;
        });
      }
    });

    // Mostrar mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.white),
            const SizedBox(width: 8),
            Text('Pista mostrada (-100 puntos)'),
          ],
        ),
        backgroundColor: const Color(0xFFFF9500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
