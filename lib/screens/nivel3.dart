import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/niveles.dart';

class Nivel3Screen extends StatefulWidget {
  const Nivel3Screen({super.key});

  @override
  State<Nivel3Screen> createState() => _Nivel3ScreenState();
}

class _Nivel3ScreenState extends State<Nivel3Screen>
    with TickerProviderStateMixin {
  int ejercicioActual = 0;
  int aciertos = 0;
  final totalEjercicios = 5; // Solo K, L, M, N, Ñ

  // Controladores para animaciones
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late AnimationController _shakeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _shakeAnimation;

  // Estados para cada ejercicio
  Map<String, dynamic> estadoEmparejamiento = {
    'parejas': [
      {'senia': 'k', 'letra': 'K', 'emparejada': false, 'error': false},
      {'senia': 'l', 'letra': 'L', 'emparejada': false, 'error': false},
      {'senia': 'm', 'letra': 'M', 'emparejada': false, 'error': false},
      {'senia': 'n', 'letra': 'N', 'emparejada': false, 'error': false},
      {'senia': 'n~', 'letra': 'Ñ', 'emparejada': false, 'error': false},
    ],
    'parejasBarajadas': <Map<String, dynamic>>[],
    'seleccionado': null,
    'parejasCorrectas': 0,
  };

  Map<String, dynamic> estadoOrdenar = {
    'senias': ['n~', 'm', 'n', 'k', 'l'],
    'orden': ['K', 'L', 'M', 'N', 'Ñ'],
    'ordenActual': <String>[],
    'completado': false,
    'slots': <Map<String, String>?>[
      null,
      null,
      null,
      null,
      null,
    ], // Slots específicos para cada posición con tipo explícito
    'error': false,
  };

  final TextEditingController _escribirController = TextEditingController();
  String? _opcionSeleccionada;
  bool _mostrandoFeedback = false;
  bool _respuestaCorrecta = false;

  final List<Map<String, dynamic>> ejercicios = [
    {
      'tipo': 'emparejar',
      'titulo': 'Empareja las señas con sus letras',
      'completado': false,
    },
    {
      'tipo': 'seleccionMultiple',
      'titulo': '¿Qué letra representa esta seña?',
      'senia': 'k',
      'opciones': ['L', 'K', 'N'],
      'correcta': 'K',
      'completado': false,
    },
    {
      'tipo': 'ordenar',
      'titulo': 'Organiza las señas en orden alfabético',
      'senias': ['n~', 'k', 'n', 'm', 'l'],
      'orden': ['K', 'L', 'M', 'N', 'Ñ'],
      'completado': false,
    },
    {
      'tipo': 'seleccionMultiple',
      'titulo': '¿Cuál es la seña para la letra N?',
      'senia': 'n',
      'opciones': ['Ñ', 'M', 'N'],
      'correcta': 'N',
      'completado': false,
    },
    {
      'tipo': 'escribir',
      'titulo': 'Escribe la letra que representa esta seña',
      'senia': 'n~',
      'respuesta': 'Ñ',
      'completado': false,
    },
  ];

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

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _barajarCartasEmparejamiento();
  }

  void _barajarCartasEmparejamiento() {
    List<Map<String, dynamic>> parejas = List.from(
      estadoEmparejamiento['parejas'],
    );

    // Crear listas separadas para señas y letras
    List<Map<String, dynamic>> senias = [];
    List<Map<String, dynamic>> letras = [];

    for (var pareja in parejas) {
      senias.add({
        'tipo': 'senia',
        'contenido': pareja['senia'],
        'id': 'senia_${pareja['senia']}',
        'emparejada': false,
        'error': false,
        'letraCorrespondiente': pareja['letra'], // Añade esta referencia
      });
      letras.add({
        'tipo': 'letra',
        'contenido': pareja['letra'],
        'id': 'letra_${pareja['letra']}',
        'emparejada': false,
        'error': false,
        'seniaCorrespondiente': pareja['senia'], // Añade esta referencia
      });
    }

    // Barajar ambas listas
    senias.shuffle();
    letras.shuffle();

    setState(() {
      estadoEmparejamiento['senias'] = senias;
      estadoEmparejamiento['letras'] = letras;
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    _shakeController.dispose();
    _escribirController.dispose();
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
            // Barra de progreso mejorada estilo Duolingo
            _buildProgressBar(theme),

            // Contenido principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Cabecera con botón cerrar
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
                        // Contador de vidas estilo Duolingo
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 30,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '3',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Container(
      height: 10,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Stack(
        children: [
          // Fondo de la barra
          Container(
            height: 10,
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.dark
                      ? theme.dividerColor
                      : const Color.fromARGB(255, 187, 185, 189),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Progreso
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              double progress =
                  (ejercicioActual +
                      (_respuestaCorrecta && _mostrandoFeedback ? 1 : 0)) /
                  totalEjercicios;
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        theme
                            .colorScheme
                            .primary, // Usar el color primary del theme
                    borderRadius: BorderRadius.circular(10),
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
      case 'ordenar':
        return _buildOrdenar(ejercicio, theme);
      case 'escribir':
        return _buildEscribir(ejercicio, theme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildEmparejamiento(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Toca las cartas para emparejarlas',
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // Contador de progreso
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${estadoEmparejamiento['parejasCorrectas']} de 5 parejas',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: Row(
            children: [
              // Columna de señas
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Señas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: estadoEmparejamiento['parejas'].length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final carta = estadoEmparejamiento['senias'][index];
                          return _buildCartaEmparejamiento(
                            carta['id'],
                            carta['contenido'],
                            carta['emparejada'],
                            carta['error'],
                            true, // Es seña
                            theme,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Columna de letras
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Letras',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: estadoEmparejamiento['parejas'].length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final carta = estadoEmparejamiento['letras'][index];
                          return _buildCartaEmparejamiento(
                            carta['id'],
                            carta['contenido'],
                            carta['emparejada'],
                            carta['error'],
                            false, // Es letra
                            theme,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 65,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child:
              emparejada
                  ? const Icon(Icons.check, color: Colors.white, size: 32)
                  : error
                  ? const Icon(Icons.close, color: Colors.white, size: 32)
                  : Text(
                    contenido,
                    style: TextStyle(
                      fontFamily: esSenia ? 'ChileanSignLanguage' : null,
                      fontSize: esSenia ? 40 : 32,
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

        // Verificar si es una pareja correcta
        if (_esParejaCorrecto(primeraCarta, carta)) {
          _marcarParejaCorrecta(primeraCarta, carta);
          estadoEmparejamiento['parejasCorrectas']++;

          if (estadoEmparejamiento['parejasCorrectas'] == 5) {
            _verificarRespuesta(true);
          }
        } else {
          // Marcar error temporal
          _marcarError(primeraCarta, carta);
          _shakeController.forward().then((_) {
            _shakeController.reset();
            // Quitar el error después de un momento
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

  // Corregir el método _marcarError para manejar correctamente las cartas incorrectas
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

  // Corregir el método _limpiarErrores para asegurarnos de que todos los errores se limpian
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

  // Modifica _esParejaCorrecto para usar directamente las referencias
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

  // También modifica _marcarParejaCorrecta para actualizar el estado correctamente
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
          // Seña grande con mejor diseño
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor, width: 2),
            ),
            child: Center(
              child: Text(
                ejercicio['senia'],
                style: const TextStyle(
                  fontFamily: 'ChileanSignLanguage',
                  fontSize: 100,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Opciones con mejor estilo
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
                  onPressed:
                      _mostrandoFeedback
                          ? null
                          : () {
                            setState(() {
                              _opcionSeleccionada = opcion;
                            });
                            _verificarRespuesta(
                              opcion == ejercicio['correcta'],
                            );
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

  Widget _buildOrdenar(Map<String, dynamic> ejercicio, ThemeData theme) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        double shake =
            estadoOrdenar['error']
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
                    color:
                        estadoOrdenar['error']
                            ? const Color(0xFFFFEBEE)
                            : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          estadoOrdenar['error']
                              ? const Color(0xFFFF4B4B)
                              : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      return DragTarget<Map<String, String>>(
                        onAcceptWithDetails: (details) {
                          final data = details.data;
                          setState(() {
                            // Verificar si el slot ya tiene un elemento
                            if (estadoOrdenar['slots'][index] != null) {
                              return; // No sobreescribir un slot ocupado
                            }

                            // Encontrar dónde estaba este elemento antes (si estaba)
                            int oldIndex = -1;
                            for (
                              int i = 0;
                              i < estadoOrdenar['slots'].length;
                              i++
                            ) {
                              var slot = estadoOrdenar['slots'][i];
                              if (slot != null &&
                                  slot['senia'] == data['senia']) {
                                oldIndex = i;
                                break;
                              }
                            }

                            // Limpiar el slot anterior si existe
                            if (oldIndex != -1) {
                              estadoOrdenar['slots'][oldIndex] = null;
                            }

                            // Colocar en el nuevo slot
                            estadoOrdenar['slots'][index] = data;
                            estadoOrdenar['error'] = false;

                            // Verificar si está completo
                            bool allFilled = estadoOrdenar['slots'].every(
                              (slot) => slot != null,
                            );

                            if (allFilled) {
                              _verificarOrden();
                            }
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          bool hasContent =
                              estadoOrdenar['slots'][index] != null;
                          bool isHovering = candidateData.isNotEmpty;

                          return Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  hasContent
                                      ? theme.cardColor
                                      : isHovering
                                      ? const Color(0xFF1CB0F6).withOpacity(0.2)
                                      : theme.cardColor,
                              border: Border.all(
                                color:
                                    isHovering
                                        ? const Color(0xFF1CB0F6)
                                        : theme.dividerColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                hasContent
                                    ? Center(
                                      child: Text(
                                        estadoOrdenar['slots'][index]!['senia']!,
                                        style: const TextStyle(
                                          fontFamily: 'ChileanSignLanguage',
                                          fontSize: 30,
                                        ),
                                      ),
                                    )
                                    : Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.6),
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

                // Botón para limpiar
                if (estadoOrdenar['slots'].any((slot) => slot != null))
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        estadoOrdenar['slots'] = <Map<String, String>?>[
                          null,
                          null,
                          null,
                          null,
                          null,
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
                  spacing: 15,
                  runSpacing: 15,
                  alignment: WrapAlignment.center,
                  children:
                      ejercicio['senias'].map<Widget>((senia) {
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
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1CB0F6),
                                borderRadius: BorderRadius.circular(16),
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
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: theme.disabledColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: AnimatedOpacity(
                            opacity: yaUsada ? 0.3 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              width: 90,
                              height: 70,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
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
                                    fontSize: 40,
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
      'k': 'K',
      'l': 'L',
      'm': 'M',
      'n': 'N',
      'n~': 'Ñ',
    };
    return conversion[senia] ?? senia.toUpperCase();
  }

  Widget _buildEscribir(Map<String, dynamic> ejercicio, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Seña grande
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor, width: 2),
            ),
            child: Center(
              child: Text(
                ejercicio['senia'],
                style: const TextStyle(
                  fontFamily: 'ChileanSignLanguage',
                  fontSize: 100,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Campo de texto mejorado
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
                _verificarRespuesta(
                  valor.toUpperCase() == ejercicio['respuesta'],
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // Botón verificar estilo Duolingo
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
              onPressed:
                  _escribirController.text.isEmpty
                      ? null
                      : () {
                        _verificarRespuesta(
                          _escribirController.text.toUpperCase() ==
                              ejercicio['respuesta'],
                        );
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

  Widget _buildFeedbackYBoton(ThemeData theme) {
    if (!_mostrandoFeedback) return const SizedBox(height: 80);

    return AnimatedBuilder(
      animation: _feedbackAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _feedbackAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color:
                  _respuestaCorrecta
                      ? const Color(0xFFD7FFB8)
                      : const Color(0xFFFFE6E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _respuestaCorrecta
                        ? const Color(0xFF58CC02)
                        : const Color(0xFFFF4B4B),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            _respuestaCorrecta
                                ? const Color(0xFF58CC02)
                                : const Color(0xFFFF4B4B),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _respuestaCorrecta ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      _respuestaCorrecta
                          ? '¡Excelente!'
                          : '¡Respuesta incorrecta!',
                      style: TextStyle(
                        color:
                            _respuestaCorrecta
                                ? const Color(0xFF58CC02)
                                : const Color(0xFFFF4B4B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_respuestaCorrecta) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
          ),
        );
      },
    );
  }

  void _verificarRespuesta(bool correcta) {
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
      // Actualizar progreso inmediatamente
      _progressController.animateTo((ejercicioActual + 1) / totalEjercicios);
    } else {
      // Resetear estado si es incorrecto
      if (ejercicios[ejercicioActual]['tipo'] == 'escribir') {
        _escribirController.clear();
      } else if (ejercicios[ejercicioActual]['tipo'] == 'ordenar') {
        setState(() {
          estadoOrdenar['slots'] = <Map<String, String>?>[
            null,
            null,
            null,
            null,
            null,
          ];
        });
      } else if (ejercicios[ejercicioActual]['tipo'] == 'seleccionMultiple') {
        setState(() {
          _opcionSeleccionada = null;
        });
      }

      // Ocultar feedback después de 2 segundos
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
                // Icono de celebración
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

                // Título
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

                // Descripción
                Text(
                  'Has practicado las letras K, L, M, N y Ñ',
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
                          const Text(
                            '100%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF58CC02),
                            ),
                          ),
                          Text(
                            'Precisión',
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
                            '$totalEjercicios',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1CB0F6),
                            ),
                          ),
                          Text(
                            'Ejercicios',
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

                // Botón continuar
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
                    onPressed: () {
                      Navigator.pop(context); // Cierra el diálogo
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaNiveles(),
                        ), // Vuelve a la pantalla anterior
                      );
                    },
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
}
