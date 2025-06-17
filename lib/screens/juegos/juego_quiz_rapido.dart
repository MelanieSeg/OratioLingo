import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class JuegoQuizRapido extends StatefulWidget {
  const JuegoQuizRapido({super.key});

  @override
  State<JuegoQuizRapido> createState() => _JuegoQuizRapidoState();
}

class _JuegoQuizRapidoState extends State<JuegoQuizRapido>
    with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _timerController;
  late AnimationController _feedbackController;
  late AnimationController _progressController;
  late Animation<double> _timerAnimation;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _progressAnimation;

  // Estados del juego
  Timer? _gameTimer;
  int tiempoRestante = 10; // 10 segundos por pregunta
  int preguntaActual = 0;
  int respuestasCorrectas = 0;
  int puntuacion = 0;
  bool juegoIniciado = false;
  bool juegoTerminado = false;
  bool mostrandoFeedback = false;
  String? respuestaSeleccionada;
  bool respuestaCorrecta = false;

  final int totalPreguntas = 6;
  final int tiempoPorPregunta = 10;

  // Datos de las primeras 6 letras
  final List<Map<String, dynamic>> preguntas = [
    {
      'senia': 'a',
      'opciones': ['A', 'B', 'C'],
      'correcta': 'A',
    },
    {
      'senia': 'b',
      'opciones': ['A', 'B', 'C'],
      'correcta': 'B',
    },
    {
      'senia': 'c',
      'opciones': ['B', 'C', 'D'],
      'correcta': 'C',
    },
    {
      'senia': 'd',
      'opciones': ['C', 'D', 'E'],
      'correcta': 'D',
    },
    {
      'senia': 'e',
      'opciones': ['D', 'E', 'F'],
      'correcta': 'E',
    },
    {
      'senia': 'f',
      'opciones': ['E', 'F', 'G'],
      'correcta': 'F',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _mezclarPreguntas();
  }

  void _initAnimations() {
    _timerController = AnimationController(
      duration: Duration(seconds: tiempoPorPregunta),
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _timerAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _timerController, curve: Curves.linear));

    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _mezclarPreguntas() {
    preguntas.shuffle(Random());
    for (var pregunta in preguntas) {
      pregunta['opciones'].shuffle(Random());
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    _feedbackController.dispose();
    _progressController.dispose();
    _gameTimer?.cancel();
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
            if (!juegoIniciado && !juegoTerminado)
              _buildInstrucciones(theme)
            else if (juegoTerminado)
              _buildResultados(theme)
            else
              Expanded(child: _buildJuego(theme)),
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
                'Quiz Rápido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          if (juegoIniciado && !juegoTerminado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                '${preguntaActual + 1}/$totalPreguntas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInstrucciones(ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, size: 80, color: const Color(0xFFFF9500)),
            const SizedBox(height: 24),

            Text(
              'Quiz Rápido de Señas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Text(
              '¡Pon a prueba tu velocidad!',
              style: TextStyle(
                fontSize: 18,
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildInstruccionItem('⏱️ 10 segundos por pregunta', theme),
                  const SizedBox(height: 12),
                  _buildInstruccionItem('🎯 6 preguntas en total', theme),
                  const SizedBox(height: 12),
                  _buildInstruccionItem('⚡ Más rápido = más puntos', theme),
                  const SizedBox(height: 12),
                  _buildInstruccionItem('🏆 ¡Supera tu mejor marca!', theme),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9500),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _iniciarJuego,
                child: const Text(
                  'COMENZAR QUIZ',
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

  Widget _buildInstruccionItem(String texto, ThemeData theme) {
    return Row(
      children: [
        Text(
          texto,
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildJuego(ThemeData theme) {
    if (mostrandoFeedback) {
      return _buildFeedback(theme);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Barra de progreso
          _buildProgressBar(theme),
          const SizedBox(height: 20),

          // Timer circular
          _buildTimerCircular(theme),
          const SizedBox(height: 30),

          // Pregunta
          _buildPregunta(theme),
          const SizedBox(height: 30),

          // Opciones de respuesta
          Expanded(child: _buildOpciones(theme)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              'Puntos: $puntuacion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF9500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: (preguntaActual) / totalPreguntas,
              backgroundColor: theme.dividerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF9500),
              ),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimerCircular(ThemeData theme) {
    return AnimatedBuilder(
      animation: _timerAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: _timerAnimation.value,
                strokeWidth: 6,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timerAnimation.value > 0.3
                      ? const Color(0xFF58CC02)
                      : const Color(0xFFFF4B4B),
                ),
              ),
            ),
            Text(
              '$tiempoRestante',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    _timerAnimation.value > 0.3
                        ? const Color(0xFF58CC02)
                        : const Color(0xFFFF4B4B),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPregunta(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 * 255 ≈ 26
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '¿Qué letra representa esta seña?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withAlpha(26), // 0.1 * 255 ≈ 26
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                preguntas[preguntaActual]['senia'],
                style: const TextStyle(
                  fontFamily: 'ChileanSignLanguage',
                  fontSize: 80,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpciones(ThemeData theme) {
    return Column(
      children:
          preguntas[preguntaActual]['opciones'].map<Widget>((opcion) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    elevation: 0,
                    side: BorderSide(color: theme.dividerColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _seleccionarRespuesta(opcion),
                  child: Text(
                    opcion,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFeedback(ThemeData theme) {
    return AnimatedBuilder(
      animation: _feedbackAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _feedbackAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color:
                        respuestaCorrecta
                            ? const Color(0xFF58CC02)
                            : const Color(0xFFFF4B4B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    respuestaCorrecta ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  respuestaCorrecta ? '¡Correcto!' : '¡Incorrecto!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color:
                        respuestaCorrecta
                            ? const Color(0xFF58CC02)
                            : const Color(0xFFFF4B4B),
                  ),
                ),
                if (!respuestaCorrecta) ...[
                  const SizedBox(height: 16),
                  Text(
                    'La respuesta correcta era: ${preguntas[preguntaActual]['correcta']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.textTheme.bodyMedium?.color,
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

  Widget _buildResultados(ThemeData theme) {
    final porcentajeAciertos =
        (respuestasCorrectas / totalPreguntas * 100).round();
    String mensaje;
    Color colorMensaje;
    IconData icono;

    if (porcentajeAciertos >= 80) {
      mensaje = '¡Excelente!';
      colorMensaje = const Color(0xFF58CC02);
      icono = Icons.emoji_events;
    } else if (porcentajeAciertos >= 60) {
      mensaje = '¡Bien hecho!';
      colorMensaje = const Color(0xFFFF9500);
      icono = Icons.thumb_up;
    } else {
      mensaje = '¡Sigue practicando!';
      colorMensaje = const Color(0xFF1CB0F6);
      icono = Icons.school;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorMensaje,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),

            Text(
              mensaje,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorMensaje,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Quiz completado',
              style: TextStyle(
                fontSize: 18,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildResultadoItem(
                    'Respuestas correctas',
                    '$respuestasCorrectas/$totalPreguntas',
                    Icons.check_circle,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildResultadoItem(
                    'Precisión',
                    '$porcentajeAciertos%',
                    Icons
                        .gps_fixed, // Cambiado de Icons.target a Icons.gps_fixed
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildResultadoItem(
                    'Puntuación final',
                    '$puntuacion pts',
                    Icons.stars,
                    theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB0F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _reiniciarJuego,
                    child: const Text('JUGAR DE NUEVO'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
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

  Widget _buildResultadoItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  void _iniciarJuego() {
    setState(() {
      juegoIniciado = true;
      preguntaActual = 0;
      respuestasCorrectas = 0;
      puntuacion = 0;
    });
    _iniciarTimer();
  }

  void _iniciarTimer() {
    setState(() {
      tiempoRestante = tiempoPorPregunta;
    });

    _timerController.forward();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tiempoRestante--;
      });

      if (tiempoRestante <= 0) {
        timer.cancel();
        _tiempoAgotado();
      }
    });
  }

  void _seleccionarRespuesta(String respuesta) {
    _gameTimer?.cancel();
    _timerController.stop();

    setState(() {
      respuestaSeleccionada = respuesta;
      respuestaCorrecta = respuesta == preguntas[preguntaActual]['correcta'];
      mostrandoFeedback = true;
    });

    if (respuestaCorrecta) {
      respuestasCorrectas++;
      // Puntuación basada en tiempo restante
      puntuacion += (tiempoRestante * 10) + 50;
    }

    _feedbackController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      _siguientePregunta();
    });
  }

  void _tiempoAgotado() {
    setState(() {
      respuestaSeleccionada = null;
      respuestaCorrecta = false;
      mostrandoFeedback = true;
    });

    _feedbackController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      _siguientePregunta();
    });
  }

  void _siguientePregunta() {
    _feedbackController.reset();
    _timerController.reset();

    setState(() {
      mostrandoFeedback = false;
      respuestaSeleccionada = null;
    });

    if (preguntaActual < totalPreguntas - 1) {
      setState(() {
        preguntaActual++;
      });
      _iniciarTimer();
    } else {
      setState(() {
        juegoTerminado = true;
      });
    }
  }

  void _reiniciarJuego() {
    _timerController.reset();
    _feedbackController.reset();
    _progressController.reset();
    _gameTimer?.cancel();

    setState(() {
      juegoIniciado = false;
      juegoTerminado = false;
      mostrandoFeedback = false;
      preguntaActual = 0;
      respuestasCorrectas = 0;
      puntuacion = 0;
      tiempoRestante = tiempoPorPregunta;
    });

    _mezclarPreguntas();
  }
}
