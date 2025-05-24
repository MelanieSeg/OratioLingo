import 'package:flutter/material.dart';

class PantallaVideos extends StatefulWidget {
  const PantallaVideos({super.key});

  @override
  State<PantallaVideos> createState() => _PantallaVideosState();
}

class _PantallaVideosState extends State<PantallaVideos> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Videos de Aprendizaje',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Próximamente: Contenido de videos\npara mejorar tu aprendizaje',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Container(
      height: 60,
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  Icons.school,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _mostrarModalPerfil,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(4.0),
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
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.bottomAppBarTheme.color ?? theme.cardColor,
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
          _buildNavItem(
            'Niveles',
            Icons.layers,
            false,
            _abrirPantallaNiveles,
            theme,
          ),
          _buildNavItem('Videos', Icons.play_circle_outline, true, null, theme),
          _buildNavItem(
            'Juegos',
            Icons.games,
            false,
            _abrirPantallaJuegos,
            theme,
          ),
          _buildNavItem(
            'Progreso',
            Icons.bar_chart,
            false,
            _abrirPantallaProgreso,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback? onTap,
    ThemeData theme,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? theme.colorScheme.primary : theme.disabledColor,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isActive ? theme.colorScheme.primary : theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalPerfil() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opciones de Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 16),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Editar Perfil'),
                ),
              ),
              SizedBox(height: 8),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cerrarSesion() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _abrirPantallaProgreso() {
    Navigator.of(context).pushNamed('/progreso');
  }

  void _abrirPantallaJuegos() {
    Navigator.of(context).pushNamed('/juegos');
  }

  void _abrirPantallaNiveles() {
    Navigator.of(context).pushNamed('/niveles');
  }

  void _abrirEditarPerfil() {
    Navigator.of(context).pushNamed('/perfil');
  }
}
