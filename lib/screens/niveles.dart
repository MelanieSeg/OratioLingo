import 'package:flutter/material.dart';
import 'package:gestos/screens/juegos.dart';
import 'package:gestos/screens/perfil.dart';
import 'package:gestos/screens/videos.dart';

class PantallaNiveles extends StatefulWidget {
  const PantallaNiveles({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PantallaNivelesState createState() => _PantallaNivelesState();
}

class _PantallaNivelesState extends State<PantallaNiveles> {
  bool _isModalVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Barra superior
          _buildTopBar(theme),
          // Contenedor de niveles
          Expanded(child: _buildLevelsContainer(theme)),
          // Barra de navegación inferior
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
                    Icons.fingerprint,
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

  Widget _buildLevelsContainer(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            // Primera fila de niveles
            _buildLevelRow([
              _buildLevel(1, true, "✓", theme),
              _buildLevel(2, true, "✓", theme),
              _buildLevel(3, false, "3", theme),
            ]),
            SizedBox(height: 32),
            // Segunda fila de niveles
            _buildLevelRow([
              _buildLevel(4, false, null, theme),
              _buildLevel(5, false, null, theme),
              _buildLevel(6, false, null, theme),
            ]),
            SizedBox(height: 32),
            // Sección de examen
            _buildExamSection(theme),
            SizedBox(height: 32),
            // Tercera fila de niveles
            _buildLevelRow([
              _buildLevel(7, false, null, theme),
              _buildLevel(8, false, null, theme),
              _buildLevel(9, false, null, theme),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(List<Widget> levels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [levels[0], _buildPath(), levels[1], _buildPath(), levels[2]],
    );
  }

  Widget _buildLevel(
    int number,
    bool isCompleted,
    String? displayText,
    ThemeData theme,
  ) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isCompleted ? theme.colorScheme.primary : theme.disabledColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child:
            displayText != null
                ? Text(
                  displayText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: displayText == "✓" ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : Icon(Icons.lock, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildPath() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildExamSection(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 2,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: 8),
        Text(
          "Examen de nivel",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          "Pon a prueba tus conocimientos",
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.amber[700],
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.star, color: Colors.white, size: 40),
              Icon(Icons.lock, color: theme.disabledColor, size: 24),
            ],
          ),
        ),
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
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.layers, "Niveles", true, theme),
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
      case "Videos":
        _abrirPantallaVideos();
        break;
      case "Juegos":
        _abrirPantallaJuegos();
        break;
      case "Progreso":
        _abrirPantallaProgreso();
        break;
      case "Niveles":
        // Ya estamos en niveles
        break;
    }
  }

  void _cerrarSesion() {
    // TODO: Implementar Firebase auth.signOut()
    print("Cerrando sesión...");
    // Navegar a pantalla de login
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _abrirPantallaProgreso() {
    print("Abriendo pantalla de progreso...");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaProgreso()),
    );
  }

  void _abrirPantallaJuegos() {
    print("Abriendo pantalla de juegos...");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaJuegos()),
    );
  }

  void _abrirPantallaVideos() {
    print("Abriendo pantalla de videos...");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaVideos()),
    );
  }

  void _abrirEditarPerfil() {
    print("Abriendo editar perfil...");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaPerfil()),
    );
  }
}
