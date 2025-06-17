import 'package:OratioLingo/screens/progreso.dart';
import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/niveles.dart';
import 'package:OratioLingo/screens/perfil.dart';
import 'package:OratioLingo/screens/videos.dart';
import 'package:OratioLingo/screens/juegos/juego_memoria.dart';
import 'package:OratioLingo/screens/juegos/juego_mano_3d.dart';
import 'package:OratioLingo/screens/juegos/juego_quiz_rapido.dart';

class PantallaJuegos extends StatefulWidget {
  const PantallaJuegos({super.key});

  @override
  _PantallaJuegosState createState() => _PantallaJuegosState();
}

class _PantallaJuegosState extends State<PantallaJuegos> {
  bool _isModalVisible = false;

  final List<Map<String, dynamic>> juegos = [
    {
      'titulo': 'Memoria de Señas',
      'descripcion': 'Encuentra las parejas entre señas y letras',
      'icono': Icons.psychology,
      'color': const Color(0xFF58CC02),
      'disponible': true,
      'pantalla': () => const JuegoMemoria(),
    },
    {
      'titulo': 'Quiz Rápido',
      'descripcion': 'Responde rápido las señas que aparecen',
      'icono': Icons.quiz,
      'color': const Color(0xFFFF9500),
      'disponible': false,
      'pantalla': null,
    },
    {
      'titulo': 'Mano 3D',
      'descripcion': 'Forma las señas moviendo los dedos',
      'icono': Icons.back_hand,
      'color': const Color(0xFF1CB0F6),
      'disponible': false, // Cambiar a true cuando esté listo
      'pantalla': () => const JuegoMano3D(),
    },
    {
      'titulo': 'Deletreo',
      'descripcion': 'Deletrea palabras usando señas',
      'icono': Icons.spellcheck,
      'color': const Color(0xFFFF4B4B),
      'disponible': false,
      'pantalla': () => const JuegoQuizRapido(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(theme),
          Expanded(child: _buildGamesContent(theme)),
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
                    Icons.games,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16),
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

  Widget _buildGamesContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Text(
            "🎮 Juegos Divertidos",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Aprende jugando con las primeras 6 letras del abecedario",
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 20),

          // Grid de juegos responsivo
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcular número de columnas basado en el ancho
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 400) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: juegos.length,
                  itemBuilder: (context, index) {
                    return _buildGameCard(juegos[index], theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> juego, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (juego['disponible']) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => juego['pantalla']()),
          );
        } else {
          _mostrarDialogoProximamente(juego['titulo']);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                juego['disponible']
                    ? juego['color'].withOpacity(0.3)
                    : theme.disabledColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono del juego
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          juego['disponible']
                              ? juego['color'].withOpacity(0.2)
                              : theme.disabledColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      juego['icono'],
                      size: 32,
                      color:
                          juego['disponible']
                              ? juego['color']
                              : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título del juego
                  Text(
                    juego['titulo'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          juego['disponible']
                              ? theme.textTheme.bodyLarge?.color
                              : theme.disabledColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    juego['descripcion'],
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          juego['disponible']
                              ? theme.textTheme.bodyMedium?.color
                              : theme.disabledColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Botón de acción
                  Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          juego['disponible']
                              ? juego['color']
                              : theme.disabledColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        juego['disponible'] ? 'JUGAR' : 'PRÓXIMAMENTE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge de "nuevo" o "próximamente"
            if (!juego['disponible'])
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PRONTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoProximamente(String nombreJuego) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
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
                Icon(Icons.construction, size: 60, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  '¡Próximamente!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El juego "$nombreJuego" estará disponible muy pronto.',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ENTENDIDO'),
                  ),
                ),
              ],
            ),
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
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.layers, "Niveles", false, theme),
          _buildNavItem(Icons.play_circle_outline, "Videos", false, theme),
          _buildNavItem(Icons.games, "Juegos", true, theme),
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
            SizedBox(height: 4),
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
    setState(() {
      _isModalVisible = !_isModalVisible;
    });

    if (_isModalVisible) {
      _showProfileModal();
    }
  }

  void _showProfileModal() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          contentPadding: EdgeInsets.all(20),
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Editar Perfil"),
                ),
              ),
              SizedBox(height: 12),
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Cerrar Sesión"),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isModalVisible = false;
      });
    });
  }

  void _onNavItemTap(String label) {
    switch (label) {
      case "Niveles":
        _abrirPantallaNiveles();
        break;
      case "Videos":
        _abrirPantallaVideos();
        break;
      case "Progreso":
        _abrirPantallaProgreso();
        break;
      case "Juegos":
        // Ya estamos en juegos
        break;
    }
  }

  void _cerrarSesion() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _abrirPantallaProgreso() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaProgreso()),
    );
  }

  void _abrirPantallaVideos() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaVideos()),
    );
  }

  void _abrirPantallaNiveles() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaNiveles()),
    );
  }

  void _abrirEditarPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaPerfil()),
    );
  }
}
