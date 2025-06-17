import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/admin/gestionar_admins.dart';
import 'package:OratioLingo/screens/admin/gestionar_videos.dart';
import 'package:OratioLingo/screens/admin/estadisticas.dart'
    as estadisticas_screen;
import 'package:OratioLingo/screens/admin/configuracion.dart';
import 'package:OratioLingo/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  bool _cargando = false;

  // Opciones del menú principal
  final List<Map<String, dynamic>> _opcionesMenu = [
    {
      'titulo': 'Gestionar Administradores',
      'descripcion': 'Agregar, activar/desactivar admins',
      'icono': Icons.admin_panel_settings,
      'color': const Color(0xFF58CC02),
      'screen': () => const GestionarAdminsScreen(),
    },
    {
      'titulo': 'Gestionar Videos',
      'descripcion': 'Videos de YouTube del contenido',
      'icono': Icons.video_library,
      'color': const Color(0xFF9C27B0),
      'screen': () => const GestionarVideosScreen(),
    },
    {
      'titulo': 'Estadísticas',
      'descripcion': 'Progreso de usuarios y métricas',
      'icono': Icons.analytics,
      'color': const Color(0xFF2196F3),
      'screen': () => const estadisticas_screen.EstadisticasScreen(),
    },
    {
      'titulo': 'Configuración',
      'descripcion': 'Ajustes generales del sistema',
      'icono': Icons.settings,
      'color': const Color(0xFFFF9800),
      'screen': () => const ConfiguracionScreen(),
    },
  ];

  Future<void> _cerrarSesion() async {
    final confirmar = await _mostrarDialogoConfirmacion();
    if (confirmar) {
      setState(() => _cargando = true);
      try {
        await _authService.cerrarSesion();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          _mostrarError('Error al cerrar sesión: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _cargando = false);
        }
      }
    }
  }

  Future<bool> _mostrarDialogoConfirmacion() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('Cerrar Sesión'),
                content: const Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
        ) ??
        false;
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

  void _navegarA(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildTopBar(theme),
                  Expanded(child: _buildMenuContainer(theme)),
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
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.admin_panel_settings,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Panel de Administrador',
                style: TextStyle(
                  color: theme.cardColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _cerrarSesion,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // Usar .withValues() en lugar de withOpacity para resolver advertencias
                    color: Colors.red.withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withAlpha((0.3 * 255).round()),
                    ),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContainer(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Saludo y descripción
            Text(
              '¡Bienvenido, Administrador!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Gestiona la plataforma OratioLingo desde aquí',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 10),

            // Grid de opciones
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _opcionesMenu.length,
              itemBuilder: (context, index) {
                final opcion = _opcionesMenu[index];
                return _buildMenuCard(opcion, theme);
              },
            ),

            const SizedBox(height: 10),

            // Información adicional
            _buildInfoCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> opcion, ThemeData theme) {
    return GestureDetector(
      onTap: () => _navegarA(opcion['screen']()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // Usando .withAlpha() en lugar de withOpacity para resolver las advertencias
              color: (opcion['color'] as Color).withAlpha((0.1 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: (opcion['color'] as Color).withAlpha((0.2 * 255).round()),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (opcion['color'] as Color).withAlpha(
                    (0.1 * 255).round(),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  opcion['icono'] as IconData,
                  color: opcion['color'] as Color,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                opcion['titulo'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                opcion['descripcion'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            'Información Importante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recuerda que los cambios que realices afectarán a todos los usuarios de la plataforma. Utiliza estas herramientas con responsabilidad.',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
