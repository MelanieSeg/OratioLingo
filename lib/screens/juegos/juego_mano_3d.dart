import 'package:flutter/material.dart';

class JuegoMano3D extends StatefulWidget {
  const JuegoMano3D({super.key});

  @override
  State<JuegoMano3D> createState() => _JuegoMano3DState();
}

class _JuegoMano3DState extends State<JuegoMano3D>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
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
            Expanded(child: _buildContent(theme)),
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
                'Mano 3D',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Espaciador para centrar el título
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono animado de construcción
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1CB0F6,
                      ).withAlpha(51), // Changed from withOpacity(0.2)
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.back_hand,
                      size: 80,
                      color: Color(0xFF1CB0F6),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          // Título principal
          Text(
            '🚧 Próximamente 🚧',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Descripción del juego
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(
                  0xFF1CB0F6,
                ).withAlpha(77), // Changed from withOpacity(0.3)
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(
                    26,
                  ), // Changed from withOpacity(0.1)
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Juego de Mano 3D',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1CB0F6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'En este emocionante juego podrás:',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Lista de características
                ..._buildFeatureList(theme),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Información de desarrollo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(
                26,
              ), // Changed from withOpacity(0.1)
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withAlpha(
                  77,
                ), // Changed from withOpacity(0.3)
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Estamos trabajando duro para traerte esta increíble experiencia. ¡Mantente al pendiente!',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Botón para volver
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                'VOLVER A JUEGOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CB0F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureList(ThemeData theme) {
    final features = [
      {
        'icon': Icons.threed_rotation, // Fixed the icon name
        'text': 'Interactuar con una mano 3D realista',
      },
      {'icon': Icons.touch_app, 'text': 'Mover cada dedo individualmente'},
      {'icon': Icons.school, 'text': 'Aprender las señas del abecedario'},
      {'icon': Icons.games, 'text': 'Desafíos progresivos y divertidos'},
      {'icon': Icons.emoji_events, 'text': 'Sistema de logros y recompensas'},
    ];

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1CB0F6,
                    ).withAlpha(51), // Changed from withOpacity(0.2)
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: const Color(0xFF1CB0F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    feature['text'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
