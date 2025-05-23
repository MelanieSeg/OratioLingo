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
    return Scaffold(
      backgroundColor: Color(0xFFf5f5f5),
      body: Column(
        children: [
          // Barra superior
          _buildTopBar(),
          // Contenedor de niveles
          Expanded(
            child: _buildLevelsContainer(),
          ),
          // Barra de navegación inferior
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      color: Color(0xFF6a4c93),
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    color: Color(0xFF6a4c93),
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF6a4c93),
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

  Widget _buildLevelsContainer() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            // Primera fila de niveles
            _buildLevelRow([
              _buildLevel(1, true, "✓"),
              _buildLevel(2, true, "✓"),
              _buildLevel(3, false, "3"),
            ]),
            SizedBox(height: 32),
            // Segunda fila de niveles
            _buildLevelRow([
              _buildLevel(4, false, null),
              _buildLevel(5, false, null),
              _buildLevel(6, false, null),
            ]),
            SizedBox(height: 32),
            // Sección de examen
            _buildExamSection(),
            SizedBox(height: 32),
            // Tercera fila de niveles
            _buildLevelRow([
              _buildLevel(7, false, null),
              _buildLevel(8, false, null),
              _buildLevel(9, false, null),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(List<Widget> levels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        levels[0],
        _buildPath(),
        levels[1],
        _buildPath(),
        levels[2],
      ],
    );
  }

  Widget _buildLevel(int number, bool isCompleted, String? displayText) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isCompleted ? Color(0xFF6a4c93) : Color(0xFF9E9E9E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: displayText != null
            ? Text(
                displayText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: displayText == "✓" ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.lock,
                color: Colors.white,
                size: 24,
              ),
      ),
    );
  }

  Widget _buildPath() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildExamSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 2,
          color: Color(0xFF6a4c93),
        ),
        SizedBox(height: 8),
        Text(
          "Examen de nivel",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          "Pon a prueba tus conocimientos",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Color(0xFFFFD700),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.white,
                size: 40,
              ),
              Icon(
                Icons.lock,
                color: Colors.grey[600],
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
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
          _buildNavItem(Icons.layers, "Niveles", true),
          _buildNavItem(Icons.play_circle_outline, "Videos", false),
          _buildNavItem(Icons.games, "Juegos", false),
          _buildNavItem(Icons.trending_up, "Progreso", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTap(label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Color(0xFF6a4c93) : Color(0xFF666666),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Color(0xFF6a4c93) : Color(0xFF666666),
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
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
                    backgroundColor: Color(0xFF6a4c93),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaProgreso()));
  }

  void _abrirPantallaJuegos() {
    print("Abriendo pantalla de juegos...");
    Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaJuegos()));
  }

  void _abrirPantallaVideos() {
    print("Abriendo pantalla de videos...");
    Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaVideos()));
  }

  void _abrirEditarPerfil() {
    print("Abriendo editar perfil...");
    Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaPerfil()));
  }
}