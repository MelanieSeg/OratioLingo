import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/niveles.dart';
import 'package:OratioLingo/services/niveles_services.dart';
import 'dart:async';
import 'dart:math';

class Nivel5Screen extends StatefulWidget {
  const Nivel5Screen({super.key});

  @override
  State<Nivel5Screen> createState() => _Nivel5ScreenState();
}

class _Nivel5ScreenState extends State<Nivel5Screen>
    with TickerProviderStateMixin {
  int ejercicioActual = 0;
  int aciertos = 0;
  int vidas = 3; // Sistema de vidas
  int totalFallos = 0; // Contador total de fallos
  final totalEjercicios = 7; // T, U, V, W, X, Y, Z + 2 actividades nuevas

  // Controladores para animaciones
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late AnimationController _shakeController;
  late AnimationController _hintController;
  late Animation<double> _progressAnimation;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _hintAnimation;

  // Estados para cada ejercicio
  Map<String, dynamic> estadoEmparejamiento = {
    'parejas': [
      {'senia': 't', 'letra': 'T', 'emparejada': false, 'error': false},
      {'senia': 'u', 'letra': 'U', 'emparejada': false, 'error': false},
      {'senia': 'v', 'letra': 'V', 'emparejada': false, 'error': false},
      {'senia': 'w', 'letra': 'W', 'emparejada': false, 'error': false},
      {'senia': 'x', 'letra': 'X', 'emparejada': false, 'error': false},
      {'senia': 'y', 'letra': 'Y', 'emparejada': false, 'error': false},
      {'senia': 'z', 'letra': 'Z', 'emparejada': false, 'error': false},
    ],
    'parejasBarajadas': <Map<String, dynamic>>[],
    'seleccionado': null,
    'parejasCorrectas': 0,
  };

  Map<String, dynamic> estadoOrdenar = {
    'senias': ['z', 'x', 'v', 'y', 'w', 'u', 't'],
    'orden': ['T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
    'ordenActual': <String>[],
    'completado': false,
    'slots': <Map<String, String>?>[
      null, null, null, null, null, null, null,
    ],
    'error': false,
  };

  // Estados para actividades nuevas
  Map<String, dynamic> estadoReconocimiento = {
    'seniasMostradas': ['t', 'u', 'v'],
    'opcionesDisponibles': ['T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
    'respuestasCorrectas': ['T', 'U', 'V'],
    'seleccionadas': <String>[],
    'completado': false,
  };

  Map<String, dynamic> estadoPalabra = {
    'palabra': 'COMER',
    'letrasDisponibles': ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
    'slots': <String?>[null, null, null, null, null],
    'error': false,
  };


  Map<String, dynamic> estadoSenasPalabra = {
    'palabra': 'MUNDO',
    'senias': ['m', 'u', 'n', 'd', 'o'],
    'letrasDisponibles': ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
    'slots': <String?>[null, null, null, null, null],
    'error': false,
  };

  final TextEditingController _escribirController = TextEditingController();
  String? _opcionSeleccionada;
  bool _mostrandoFeedback = false;
  bool _respuestaCorrecta = false;
  
  // Sistema de hints
  bool _mostrandoHint = false;
  String _hintActual = '';
  Timer? _hintTimer;

  final List<Map<String, dynamic>> ejercicios = [
    {
      'tipo': 'emparejar',
      'titulo': 'Empareja las señas con sus letras',
      'completado': false,
    },
    {
      'tipo': 'seleccionMultiple',
      'titulo': '¿Qué letra representa esta seña?',
      'senia': 'w',
      'opciones': ['V', 'W', 'X'],
      'correcta': 'W',
      'hint': 'Tres dedos extendidos hacia arriba formando "W"',
      'completado': false,
    },
    {
      'tipo': 'reconocimiento',
      'titulo': 'Selecciona las letras que representan estas señas',
      'completado': false,
    },
    {
      'tipo': 'ordenar',
      'titulo': 'Organiza las señas en orden alfabético',
      'senias': ['z', 'x', 'v', 'y', 'w', 'u', 't'],
      'orden': ['T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
      'completado': false,
    },
    {
      'tipo': 'escribir',
      'titulo': 'Escribe la letra que representa esta seña',
      'senia': 'z',
      'respuesta': 'Z',
      'hint': 'El dedo índice traza una "Z" en el aire',
      'completado': false,
    },
    {
      'tipo': 'construirPalabra',
      'titulo': 'Arrastra las letras para formar esta palabra',
      'palabra': 'COMER',
      'completado': false,
    },
    {
      'tipo': 'interpretarSeñas',
      'titulo': 'Lee las señas y forma la palabra',
      'senias': ['m', 'u', 'n', 'd', 'o'],
      'palabra': 'MUNDO',
      'completado': false,
    },
  ];

  // Mapas de hints para las señas
  final Map<String, String> hints = {
    't': 'El puño cerrado con el pulgar entre los dedos',
    'u': 'Los dedos índice y medio juntos hacia arriba',
    'v': 'Los dedos índice y medio separados formando "V"',
    'w': 'Tres dedos extendidos hacia arriba',
    'x': 'El dedo índice doblado formando gancho',
    'y': 'El pulgar y meñique extendidos',
    'z': 'El dedo índice traza una "Z" en el aire',
  };

  final NivelesService _nivelesService = NivelesService();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _hintAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    _barajarCartasEmparejamiento();
    _barajarLetrasDisponibles();
  }

  void _barajarCartasEmparejamiento() {
    List<Map<String, dynamic>> parejas = List.from(
      estadoEmparejamiento['parejas'],
    );

    List<Map<String, dynamic>> senias = [];
    List<Map<String, dynamic>> letras = [];

    for (var pareja in parejas) {
      senias.add({
        'tipo': 'senia',
        'contenido': pareja['senia'],
        'id': 'senia_${pareja['senia']}',
        'emparejada': false,
        'error': false,
        'letraCorrespondiente': pareja['letra'],
      });
      letras.add({
        'tipo': 'letra',
        'contenido': pareja['letra'],
        'id': 'letra_${pareja['letra']}',
        'emparejada': false,
        'error': false,
        'seniaCorrespondiente': pareja['senia'],
      });
    }

    senias.shuffle();
    letras.shuffle();

    setState(() {
      estadoEmparejamiento['senias'] = senias;
      estadoEmparejamiento['letras'] = letras;
    });
  }

  void _barajarLetrasDisponibles() {
    List<String> letras = List.from(estadoPalabra['letrasDisponibles']);
    letras.shuffle();
    estadoPalabra['letrasDisponibles'] = letras;
    
    List<String> letrasSenas = List.from(estadoSenasPalabra['letrasDisponibles']);
    letrasSenas.shuffle();
    estadoSenasPalabra['letrasDisponibles'] = letrasSenas;
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    _shakeController.dispose();
    _hintController.dispose();
    _escribirController.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  // Función para mostrar hint
  void _mostrarHint(String senia) {
    setState(() {
      _hintActual = hints[senia] ?? 'Hint no disponible';
      _mostrandoHint = true;
    });
    _hintController.forward();
    
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _ocultarHint();
      }
    });
  }

  void _ocultarHint() {
    _hintController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _mostrandoHint = false;
        });
      }
    });
  }

  // Función para perder vida
  void _perderVida() {
    setState(() {
      vidas--;
      totalFallos++;
    });

    if (vidas <= 0) {
      _mostrarDialogoGameOver();
    }
  }

  void _mostrarDialogoGameOver() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de derrota
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4B4B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              '¡Se acabaron las vidas!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Descripción
            Text(
              'No te preocupes, puedes intentarlo de nuevo. ¡La práctica hace al maestro!',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // Estadísticas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '$totalFallos',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4B4B),
                        ),
                      ),
                      Text(
                        'Fallos',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.dividerColor,
                  ),
                  Column(
                    children: [
                      Text(
                        '$aciertos',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF58CC02),
                        ),
                      ),
                      Text(
                        'Aciertos',
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
            const SizedBox(height: 25),

            // Botón volver
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CB0F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const PantallaNiveles(),
                  )); // Vuelve a la pantalla de niveles
                },
                child: const Text(
                  'VOLVER A NIVELES',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Barra de progreso mejorada estilo Duolingo
                _buildProgressBar(theme),

                // Contenido principal
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Cabecera con botón cerrar y vidas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 28,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            // Contador de vidas estilo Duolingo con animación
                            Row(
                              children: List.generate(3, (index) {
                                bool tieneVida = index < vidas;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.favorite,
                                      color: tieneVida ? Colors.red : Colors.grey[400],
                                      size: 30,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Título del ejercicio actual
                        Text(
                          ejercicios[ejercicioActual]['titulo'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // Contenido del ejercicio
                        Expanded(
                          child: _buildEjercicio(
                            ejercicios[ejercicioActual],
                            theme,
                          ),
                        ),

                        // Feedback y botón continuar
                        _buildFeedbackYBoton(theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Overlay de hint
            if (_mostrandoHint)
              AnimatedBuilder(
                animation: _hintAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: 100 + (50 * (1 - _hintAnimation.value)),
                    left: 20,
                    right: 20,
                    child: Opacity(
                      opacity: _hintAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CB0F6),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _hintActual,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Container(
      height: 10,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEjercicio(Map<String, dynamic> ejercicio, ThemeData theme) {
    switch (ejercicio['tipo']) {
      case 'emparejar':
        return _buildEmparejamiento(theme);
      case 'seleccionMultiple':
        return _buildSeleccionMultiple(ejercicio, theme);
      case 'reconocimiento':
        return _buildReconocimiento(theme);
      case 'ordenar':
        return _buildOrdenar(ejercicio, theme);
      case 'escribir':
        return _buildEscribir(ejercicio, theme);
      case 'construirPalabra':
        return _buildConstruirPalabra(ejercicio, theme);
      case 'interpretarSenias':
        return _buildInterpretarSenas(ejercicio, theme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildEmparejamiento(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Título informativo
        Text(
          'Mantén presionado las señas para ver pistas',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        
        // Señas
        Text(
          'Señas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: estadoEmparejamiento['senias'].map<Widget>((senia) {
            return _buildCartaEmparejamiento(
              senia['id'],
              senia['contenido'],
              senia['emparejada'],
              senia['error'],
              true,
              theme,
            );
          }).toList(),
        ),
        
        const SizedBox(height: 30),
        
        // Letras
        Text(
          'Letras',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: estadoEmparejamiento['letras'].map<Widget>((letra) {
            return _buildCartaEmparejamiento(
              letra['id'],
              letra['contenido'],
              letra['emparejada'],
              letra['error'],
              false,
              theme,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCartaEmparejamiento(
    String id,
    String contenido,
    bool emparejada,
    bool error,
    bool esSenia,
    ThemeData theme,
  ) {
    bool seleccionado = estadoEmparejamiento['seleccionado'] == id;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (emparejada) {
      backgroundColor = const Color(0xFF58CC02);
      borderColor = const Color(0xFF58CC02);
      textColor = Colors.white;
    } else if (error) {
      backgroundColor = const Color(0xFFFF4B4B);
      borderColor = const Color(0xFFFF4B4B);
      textColor = Colors.white;
    } else if (seleccionado) {
      backgroundColor = const Color(0xFF1CB0F6);
      borderColor = const Color(0xFF1CB0F6);
      textColor = Colors.white;
    } else {
      backgroundColor = theme.cardColor;
      borderColor = theme.dividerColor;
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    }

    return GestureDetector(
      onTap: (emparejada || error) ? null : () => _seleccionarCarta(id),
      onLongPress: esSenia ? () => _mostrarHint(contenido) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 55,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: emparejada
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : error
              ? const Icon(Icons.close, color: Colors.white, size: 24)
              : Text(
                contenido,
                style: TextStyle(
                  fontFamily: esSenia ? 'ChileanSignLanguage' : null,
                  fontSize: esSenia ? 28 : 20,
                  fontWeight: esSenia ? FontWeight.normal : FontWeight.bold,
                  color: textColor,
                ),
              ),
        ),
      ),
    );
  }

  void _seleccionarCarta(String carta) {
    setState(() {
      if (estadoEmparejamiento['seleccionado'] == null) {
        estadoEmparejamiento['seleccionado'] = carta;
      } else {
        String primeraCarta = estadoEmparejamiento['seleccionado'];
        estadoEmparejamiento['seleccionado'] = null;

        if (_esParejaCorrecto(primeraCarta, carta)) {
          _marcarParejaCorrecta(primeraCarta, carta);
          estadoEmparejamiento['parejasCorrectas']++;

          if (estadoEmparejamiento['parejasCorrectas'] == 7) {
            _verificarRespuesta(true);
          }
        } else {
          _marcarError(primeraCarta, carta);
          _perderVida(); // Perder vida por error
          _shakeController.forward().then((_) {
            _shakeController.reset();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  _limpiarErrores();
                });
              }
            });
          });
        }
      }
    });
  }

  void _marcarError(String carta1, String carta2) {
    // Marcar error en las señas
    for (var senia in estadoEmparejamiento['senias']) {
      if (senia['id'] == carta1 || senia['id'] == carta2) {
        senia['error'] = true;
      }
    }

    // Marcar error en las letras
    for (var letra in estadoEmparejamiento['letras']) {
      if (letra['id'] == carta1 || letra['id'] == carta2) {
        letra['error'] = true;
      }
    }

    // Activar animación de shake
    _shakeController.forward();
  }

  void _limpiarErrores() {
    // Limpiar error en señas
    for (var senia in estadoEmparejamiento['senias']) {
      senia['error'] = false;
    }

    // Limpiar error en letras
    for (var letra in estadoEmparejamiento['letras']) {
      letra['error'] = false;
    }
  }

  bool _esParejaCorrecto(String carta1, String carta2) {
    // Encuentra las cartas por id
    Map<String, dynamic>? carta1Data;
    Map<String, dynamic>? carta2Data;

    // Busca en señas
    for (var senia in estadoEmparejamiento['senias']) {
      if (senia['id'] == carta1) carta1Data = senia;
      if (senia['id'] == carta2) carta2Data = senia;
    }

    // Busca en letras
    for (var letra in estadoEmparejamiento['letras']) {
      if (letra['id'] == carta1) carta1Data = letra;
      if (letra['id'] == carta2) carta2Data = letra;
    }

    // Si ambas cartas son del mismo tipo, no pueden ser pareja
    if (carta1Data == null || carta2Data == null) return false;
    if (carta1Data['tipo'] == carta2Data['tipo']) return false;

    // Verifica si forman pareja (seña con su letra correspondiente)
    if (carta1Data['tipo'] == 'senia' && carta2Data['tipo'] == 'letra') {
      return carta1Data['letraCorrespondiente'] == carta2Data['contenido'];
    } else if (carta1Data['tipo'] == 'letra' && carta2Data['tipo'] == 'senia') {
      return carta1Data['seniaCorrespondiente'] == carta2Data['contenido'];
    }

    return false;
  }

  void _marcarParejaCorrecta(String carta1, String carta2) {
    // Marca las cartas como emparejadas tanto en senias como en letras
    for (var senia in estadoEmparejamiento['senias']) {
      if (senia['id'] == carta1 || senia['id'] == carta2) {
        senia['emparejada'] = true;
      }
    }

    for (var letra in estadoEmparejamiento['letras']) {
      if (letra['id'] == carta1 || letra['id'] == carta2) {
        letra['emparejada'] = true;
      }
    }
  }

  Widget _buildSeleccionMultiple(
    Map<String, dynamic> ejercicio,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Seña grande con hint al mantener presionado
          GestureDetector(
            onLongPress: () => _mostrarHint(ejercicio['senia']),
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      ejercicio['senia'],
                      style: const TextStyle(
                        fontFamily: 'ChileanSignLanguage',
                        fontSize: 100,
                      ),
                    ),
                  ),
                  // Indicador de hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1CB0F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          
          // Instrucción para hint
          Text(
            'Mantén presionado para ver una pista',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),

          // Opciones
          ...ejercicio['opciones'].map<Widget>((opcion) {
            bool seleccionada = _opcionSeleccionada == opcion;
            Color backgroundColor;
            Color borderColor;
            Color textColor;

            if (seleccionada && _mostrandoFeedback) {
              if (_respuestaCorrecta) {
                backgroundColor = const Color(0xFF58CC02);
                borderColor = const Color(0xFF58CC02);
                textColor = Colors.white;
              } else {
                backgroundColor = const Color(0xFFFF4B4B);
                borderColor = const Color(0xFFFF4B4B);
                textColor = Colors.white;
              }
            } else if (seleccionada) {
              backgroundColor = const Color(0xFF1CB0F6);
              borderColor = const Color(0xFF1CB0F6);
              textColor = Colors.white;
            } else {
              backgroundColor = theme.cardColor;
              borderColor = theme.dividerColor;
              textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                    backgroundColor: backgroundColor,
                    foregroundColor: textColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor, width: 2),
                    ),
                  ),
                  onPressed: _mostrandoFeedback
                      ? null
                      : () {
                        setState(() {
                          _opcionSeleccionada = opcion;
                        });
                        bool esCorrecta = opcion == ejercicio['correcta'];
                        if (!esCorrecta) {
                          _perderVida();
                        }
                        _verificarRespuesta(esCorrecta);
                      },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        opcion,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (seleccionada && _mostrandoFeedback)
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Icon(
                            _respuestaCorrecta ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReconocimiento(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Señas a reconocer
          Text(
            'Reconoce estas señas:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: estadoReconocimiento['seniasMostradas'].map<Widget>((senia) {
              return GestureDetector(
                onLongPress: () => _mostrarHint(senia),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      senia,
                      style: const TextStyle(
                        fontFamily: 'ChileanSignLanguage',
                        fontSize: 50,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Mantén presionado para ver pistas',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Opciones de letras
          Text(
            'Selecciona las letras correspondientes:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: estadoReconocimiento['opcionesDisponibles'].map<Widget>((letra) {
              bool seleccionada = estadoReconocimiento['seleccionadas'].contains(letra);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (seleccionada) {
                      estadoReconocimiento['seleccionadas'].remove(letra);
                    } else {
                      if (estadoReconocimiento['seleccionadas'].length < 3) {
                        estadoReconocimiento['seleccionadas'].add(letra);
                      }
                    }
                    
                    // Verificar si se completó
                    if (estadoReconocimiento['seleccionadas'].length == 3) {
                      _verificarReconocimiento();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: seleccionada ? const Color(0xFF1CB0F6) : theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: seleccionada ? const Color(0xFF1CB0F6) : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letra,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: seleccionada ? Colors.white : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _verificarReconocimiento() {
    List<String> seleccionadas = List.from(estadoReconocimiento['seleccionadas']);
    List<String> correctas = List.from(estadoReconocimiento['respuestasCorrectas']);
    
    seleccionadas.sort();
    correctas.sort();
    
    bool esCorrecto = seleccionadas.length == correctas.length &&
        seleccionadas.every((elemento) => correctas.contains(elemento));
    
    if (!esCorrecto) {
      _perderVida();
      setState(() {
        estadoReconocimiento['seleccionadas'].clear();
      });
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
    } else {
      _verificarRespuesta(true);
    }
  }

  Widget _buildOrdenar(Map<String, dynamic> ejercicio, ThemeData theme) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        double shake = estadoOrdenar['error']
            ? _shakeAnimation.value * 10 * (1 - _shakeAnimation.value)
            : 0;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Área de slots específicos
                Container(
                  height: 100,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: estadoOrdenar['error']
                        ? const Color(0xFFFFEBEE)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: estadoOrdenar['error']
                          ? const Color(0xFFFF4B4B)
                          : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: DragTarget<Map<String, String>>(
                            onAcceptWithDetails: (details) {
                              final data = details.data;
                              setState(() {
                                if (estadoOrdenar['slots'][index] != null) {
                                  return;
                                }

                                int oldIndex = -1;
                                for (int i = 0; i < estadoOrdenar['slots'].length; i++) {
                                  var slot = estadoOrdenar['slots'][i];
                                  if (slot != null && slot['senia'] == data['senia']) {
                                    oldIndex = i;
                                    break;
                                  }
                                }

                                if (oldIndex != -1) {
                                  estadoOrdenar['slots'][oldIndex] = null;
                                }

                                estadoOrdenar['slots'][index] = data;
                                estadoOrdenar['error'] = false;

                                bool allFilled = estadoOrdenar['slots'].every(
                                  (slot) => slot != null,
                                );

                                if (allFilled) {
                                  _verificarOrden();
                                }
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              bool hasContent = estadoOrdenar['slots'][index] != null;
                              bool isHovering = candidateData.isNotEmpty;

                              return Container(
                                width: 45,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: hasContent
                                      ? theme.cardColor
                                      : isHovering
                                      ? const Color(0xFF1CB0F6).withOpacity(0.2)
                                      : theme.cardColor,
                                  border: Border.all(
                                    color: isHovering
                                        ? const Color(0xFF1CB0F6)
                                        : theme.dividerColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: hasContent
                                    ? GestureDetector(
                                      onLongPress: () => _mostrarHint(estadoOrdenar['slots'][index]!['senia']!),
                                      child: Center(
                                        child: Text(
                                          estadoOrdenar['slots'][index]!['senia']!,
                                          style: const TextStyle(
                                            fontFamily: 'ChileanSignLanguage',
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                if (estadoOrdenar['slots'].any((slot) => slot != null))
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        estadoOrdenar['slots'] = <Map<String, String>?>[
                          null, null, null, null, null, null, null,
                        ];
                        estadoOrdenar['error'] = false;
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF1CB0F6)),
                    label: const Text(
                      'Reiniciar',
                      style: TextStyle(
                        color: Color(0xFF1CB0F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Señas para arrastrar
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: ejercicio['senias'].map<Widget>((senia) {
                    Map<String, String> seniaData = {
                      'senia': senia,
                      'letra': _seniaALetra(senia),
                    };
                    bool yaUsada = estadoOrdenar['slots'].any(
                      (slot) => slot != null && slot['senia'] == senia,
                    );

                    return Draggable<Map<String, String>>(
                      data: seniaData,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1CB0F6),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              senia,
                              style: const TextStyle(
                                fontFamily: 'ChileanSignLanguage',
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        width: 60,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.disabledColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: GestureDetector(
                        onLongPress: () => _mostrarHint(senia),
                        child: AnimatedOpacity(
                          opacity: yaUsada ? 0.3 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 60,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                senia,
                                style: const TextStyle(
                                  fontFamily: 'ChileanSignLanguage',
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verificarOrden() {
    bool ordenCorrecto = true;
    for (int i = 0; i < estadoOrdenar['slots'].length; i++) {
      if (estadoOrdenar['slots'][i] == null ||
          estadoOrdenar['slots'][i]!['letra'] !=
              ejercicios[ejercicioActual]['orden'][i]) {
        ordenCorrecto = false;
        break;
      }
    }

    if (ordenCorrecto) {
      _verificarRespuesta(true);
    } else {
      _perderVida(); // Perder vida por orden incorrecto
      setState(() {
        estadoOrdenar['error'] = true;
      });
      _shakeController.forward().then((_) {
        _shakeController.reset();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              estadoOrdenar['error'] = false;
            });
          }
        });
      });
    }
  }

  String _seniaALetra(String senia) {
    const Map<String, String> conversion = {
      't': 'T',
      'u': 'U',
      'v': 'V',
      'w': 'W',
      'x': 'X',
      'y': 'Y',
      'z': 'Z',
    };
    return conversion[senia] ?? senia.toUpperCase();
  }

  Widget _buildEscribir(Map<String, dynamic> ejercicio, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Seña grande con hint
          GestureDetector(
            onLongPress: () => _mostrarHint(ejercicio['senia']),
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      ejercicio['senia'],
                      style: const TextStyle(
                        fontFamily: 'ChileanSignLanguage',
                        fontSize: 100,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1CB0F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          
          Text(
            'Mantén presionado para ver una pista',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 30),

          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _escribirController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.dividerColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF1CB0F6),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.cardColor,
                hintText: 'Escribe aquí...',
                hintStyle: TextStyle(
                  fontSize: 20,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
              onSubmitted: (valor) {
                bool esCorrecta = valor.toUpperCase() == ejercicio['respuesta'];
                if (!esCorrecta) {
                  _perderVida();
                }
                _verificarRespuesta(esCorrecta);
              },
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _escribirController.text.isEmpty
                  ? null
                  : () {
                    bool esCorrecta = _escribirController.text.toUpperCase() == ejercicio['respuesta'];
                    if (!esCorrecta) {
                      _perderVida();
                    }
                    _verificarRespuesta(esCorrecta);
                  },
              child: const Text(
                'COMPROBAR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstruirPalabra(Map<String, dynamic> ejercicio, ThemeData theme) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        double shake = estadoPalabra['error']
            ? _shakeAnimation.value * 10 * (1 - _shakeAnimation.value)
            : 0;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Palabra objetivo
                Text(
                  ejercicio['palabra'],
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Área de slots para construir la palabra
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: estadoPalabra['error']
                        ? const Color(0xFFFFEBEE)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: estadoPalabra['error']
                          ? const Color(0xFFFF4B4B)
                          : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      return DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          final letra = details.data;
                          setState(() {
                            if (estadoPalabra['slots'][index] != null) {
                              return;
                            }

                            // Remover la letra de otros slots si ya estaba usada
                            for (int i = 0; i < estadoPalabra['slots'].length; i++) {
                              if (estadoPalabra['slots'][i] == letra) {
                                estadoPalabra['slots'][i] = null;
                                break;
                              }
                            }

                            estadoPalabra['slots'][index] = letra;
                            estadoPalabra['error'] = false;

                            // Verificar si se completó la palabra
                            bool allFilled = estadoPalabra['slots'].every(
                              (slot) => slot != null,
                            );

                            if (allFilled) {
                              _verificarPalabraFormada();
                            }
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          bool hasContent = estadoPalabra['slots'][index] != null;
                          bool isHovering = candidateData.isNotEmpty;

                          return Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              color: hasContent
                                  ? theme.cardColor
                                  : isHovering
                                  ? const Color(0xFF1CB0F6).withOpacity(0.2)
                                  : theme.cardColor,
                              border: Border.all(
                                color: isHovering
                                    ? const Color(0xFF1CB0F6)
                                    : theme.dividerColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: hasContent
                                  ? Text(
                                    estadoPalabra['slots'][index]!,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  )
                                  : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón reiniciar si hay letras colocadas
                if (estadoPalabra['slots'].any((slot) => slot != null))
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        estadoPalabra['slots'] = <String?>[null, null, null, null, null];
                        estadoPalabra['error'] = false;
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF1CB0F6)),
                    label: const Text(
                      'Reiniciar',
                      style: TextStyle(
                        color: Color(0xFF1CB0F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Letras disponibles para arrastrar
                Text(
                  'Arrastra las letras:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 15),

                // Grid de letras más compacto para teléfono
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, // 6 columnas para que quepa en teléfono
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: estadoPalabra['letrasDisponibles'].length,
                  itemBuilder: (context, index) {
                    String letra = estadoPalabra['letrasDisponibles'][index];
                    bool yaUsada = estadoPalabra['slots'].contains(letra);

                    return Draggable<String>(
                      data: letra,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1CB0F6),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              letra,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        decoration: BoxDecoration(
                          color: theme.disabledColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AnimatedOpacity(
                        opacity: yaUsada ? 0.3 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              letra,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verificarPalabraFormada() {
    String palabraFormada = estadoPalabra['slots'].join('');
    String palabraCorrecta = estadoPalabra['palabra'];

    if (palabraFormada == palabraCorrecta) {
      _verificarRespuesta(true);
    } else {
      _perderVida();
      setState(() {
        estadoPalabra['error'] = true;
      });
      _shakeController.forward().then((_) {
        _shakeController.reset();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              estadoPalabra['error'] = false;
            });
          }
        });
      });
    }
  }

  Widget _buildInterpretarSenas(Map<String, dynamic> ejercicio, ThemeData theme) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        double shake = estadoSenasPalabra['error']
            ? _shakeAnimation.value * 10 * (1 - _shakeAnimation.value)
            : 0;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Título explicativo
                Text(
                  'Lee estas señas y forma la palabra:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Señas que forman la palabra
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: estadoSenasPalabra['senias'].map<Widget>((senia) {
                      return GestureDetector(
                        onLongPress: () => _mostrarHint(senia),
                        child: Container(
                          width: 50,
                          height: 60,
                          child: Center(
                            child: Text(
                              senia,
                              style: const TextStyle(
                                fontFamily: 'ChileanSignLanguage',
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),
                
                Text(
                  'Mantén presionado las señas para ver pistas',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Área de slots para la respuesta
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: estadoSenasPalabra['error']
                        ? const Color(0xFFFFEBEE)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: estadoSenasPalabra['error']
                          ? const Color(0xFFFF4B4B)
                          : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      return DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          final letra = details.data;
                          setState(() {
                            if (estadoSenasPalabra['slots'][index] != null) {
                              return;
                            }

                            // Remover la letra de otros slots si ya estaba usada
                            for (int i = 0; i < estadoSenasPalabra['slots'].length; i++) {
                              if (estadoSenasPalabra['slots'][i] == letra) {
                                estadoSenasPalabra['slots'][i] = null;
                                break;
                              }
                            }

                            estadoSenasPalabra['slots'][index] = letra;
                            estadoSenasPalabra['error'] = false;

                            // Verificar si se completó la palabra
                            bool allFilled = estadoSenasPalabra['slots'].every(
                              (slot) => slot != null,
                            );

                            if (allFilled) {
                              _verificarInterpretacionSenas();
                            }
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          bool hasContent = estadoSenasPalabra['slots'][index] != null;
                          bool isHovering = candidateData.isNotEmpty;

                          return Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              color: hasContent
                                  ? theme.cardColor
                                  : isHovering
                                  ? const Color(0xFF1CB0F6).withOpacity(0.2)
                                  : theme.cardColor,
                              border: Border.all(
                                color: isHovering
                                    ? const Color(0xFF1CB0F6)
                                    : theme.dividerColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: hasContent
                                  ? Text(
                                    estadoSenasPalabra['slots'][index]!,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  )
                                  : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón reiniciar si hay letras colocadas
                if (estadoSenasPalabra['slots'].any((slot) => slot != null))
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        estadoSenasPalabra['slots'] = <String?>[null, null, null, null, null];
                        estadoSenasPalabra['error'] = false;
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF1CB0F6)),
                    label: const Text(
                      'Reiniciar',
                      style: TextStyle(
                        color: Color(0xFF1CB0F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Letras disponibles para arrastrar
                Text(
                  'Arrastra las letras:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 15),

                // Grid de letras más compacto para teléfono
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, // 6 columnas para que quepa en teléfono
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: estadoSenasPalabra['letrasDisponibles'].length,
                  itemBuilder: (context, index) {
                    String letra = estadoSenasPalabra['letrasDisponibles'][index];
                    bool yaUsada = estadoSenasPalabra['slots'].contains(letra);

                    return Draggable<String>(
                      data: letra,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1CB0F6),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              letra,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        decoration: BoxDecoration(
                          color: theme.disabledColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AnimatedOpacity(
                        opacity: yaUsada ? 0.3 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              letra,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verificarInterpretacionSenas() {
    String palabraFormada = estadoSenasPalabra['slots'].join('');
    String palabraCorrecta = estadoSenasPalabra['palabra'];

    if (palabraFormada == palabraCorrecta) {
      _verificarRespuesta(true);
    } else {
      _perderVida();
      setState(() {
        estadoSenasPalabra['error'] = true;
      });
      _shakeController.forward().then((_) {
        _shakeController.reset();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              estadoSenasPalabra['error'] = false;
            });
          }
        });
      });
    }
  }

  Widget _buildFeedbackYBoton(ThemeData theme) {
    if (!_mostrandoFeedback) return const SizedBox(height: 80);

    return AnimatedBuilder(
      animation: _feedbackAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _feedbackAnimation.value,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Feedback visual
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                decoration: BoxDecoration(
                  color: _respuestaCorrecta 
                      ? const Color(0xFF58CC02) 
                      : const Color(0xFFFF4B4B),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: (_respuestaCorrecta 
                          ? const Color(0xFF58CC02) 
                          : const Color(0xFFFF4B4B)).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _respuestaCorrecta ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _respuestaCorrecta ? '¡Correcto!' : '¡Incorrecto!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_respuestaCorrecta) ...[
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _continuarSiguienteEjercicio,
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _verificarRespuesta(bool correcta) {
    if (vidas <= 0) return; // No procesar si no hay vidas

    setState(() {
      _mostrandoFeedback = true;
      _respuestaCorrecta = correcta;
    });

    _feedbackController.forward();

    if (correcta) {
      setState(() {
        ejercicios[ejercicioActual]['completado'] = true;
        aciertos++;
      });
      _progressController.animateTo((ejercicioActual + 1) / totalEjercicios);
    } else {
      // Resetear estado si es incorrecto
      if (ejercicios[ejercicioActual]['tipo'] == 'escribir') {
        _escribirController.clear();
      } else if (ejercicios[ejercicioActual]['tipo'] == 'ordenar') {
        setState(() {
          estadoOrdenar['slots'] = <Map<String, String>?>[
            null, null, null, null, null, null, null,
          ];
        });
      } else if (ejercicios[ejercicioActual]['tipo'] == 'seleccionMultiple') {
        setState(() {
          _opcionSeleccionada = null;
        });
      } else if (ejercicios[ejercicioActual]['tipo'] == 'reconocimiento') {
        setState(() {
          estadoReconocimiento['seleccionadas'].clear();
        });
      } else if (ejercicios[ejercicioActual]['tipo'] == 'construirPalabra') {
        setState(() {
          estadoPalabra['slots'] = <String?>[null, null, null, null, null];
        });
      } else if (ejercicios[ejercicioActual]['tipo'] == 'interpretarSeñas') {
        setState(() {
          estadoSenasPalabra['slots'] = <String?>[null, null, null, null, null];
        });
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _mostrandoFeedback = false;
          });
          _feedbackController.reset();
        }
      });
    }
  }

  void _continuarSiguienteEjercicio() {
    setState(() {
      _mostrandoFeedback = false;
      _opcionSeleccionada = null;
      _escribirController.clear();
    });
    _feedbackController.reset();

    if (ejercicioActual < totalEjercicios - 1) {
      setState(() {
        ejercicioActual++;
      });
    } else {
      _mostrarDialogoFinalizacion();
    }
  }

  void _mostrarDialogoFinalizacion() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              '¡Lección completada!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              'Has completado todas las letras del abecedario en lengua de señas',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '$aciertos/$totalEjercicios',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF58CC02),
                        ),
                      ),
                      Text(
                        'Aciertos',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.dividerColor,
                  ),
                  Column(
                    children: [
                      Text(
                        '$vidas',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4B4B),
                        ),
                      ),
                      Text(
                        'Vidas restantes',
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
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _completarNivelYContinuar(context),
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para completar nivel y guardar progreso
  Future<void> _completarNivelYContinuar(BuildContext context) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
          ),
        ),
      );

      // Guardar progreso en Firestore
      bool exito = await _nivelesService.completarNivel(
        numeroNivel: 5, // Nivel 5
        aciertos: aciertos,
        totalEjercicios: totalEjercicios,
        vidasRestantes: vidas,
        fallosTotales: totalFallos,
      );

      // Cerrar loading
      Navigator.pop(context);

      if (exito) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '¡Felicitaciones! Has completado todo el abecedario',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF58CC02),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Cerrar diálogos y volver a niveles
        Navigator.pop(context); // Cierra diálogo de finalización
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaNiveles()),
        );
      } else {
        // Error al guardar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al guardar progreso. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Cerrar loading si está abierto
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}