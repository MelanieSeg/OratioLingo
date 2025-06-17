import 'package:flutter/material.dart';
import 'package:OratioLingo/services/admin_service.dart';
import 'package:OratioLingo/services/auth_service.dart';

class GestionarAdminsScreen extends StatefulWidget {
  const GestionarAdminsScreen({super.key});

  @override
  State<GestionarAdminsScreen> createState() => _GestionarAdminsScreenState();
}

class _GestionarAdminsScreenState extends State<GestionarAdminsScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _administradores = [];
  bool _cargando = true;
  String? _adminActualId;

  @override
  void initState() {
    super.initState();
    _cargarAdministradores();
    _obtenerAdminActual();
  }

  Future<void> _obtenerAdminActual() async {
    try {
      _adminActualId = await _authService.obtenerIdUsuarioActual();
    } catch (e) {
      print('Error al obtener admin actual: $e');
    }
  }

  Future<void> _cargarAdministradores() async {
    try {
      setState(() => _cargando = true);
      final admins = await _adminService.obtenerTodosLosAdministradores();

      if (mounted) {
        setState(() {
          _administradores = admins;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError('Error al cargar administradores: $e');
      }
    }
  }

  Future<void> _mostrarDialogoAgregarAdmin() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF58CC02),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Agregar Administrador'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña temporal',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nombreController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty ||
                      passwordController.text.trim().isEmpty) {
                    _mostrarError('Todos los campos son requeridos');
                    return;
                  }

                  Navigator.pop(context);
                  await _agregarAdministrador(
                    nombreController.text.trim(),
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Agregar'),
              ),
            ],
          ),
    );
  }

  Future<void> _agregarAdministrador(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      setState(() => _cargando = true);
      await _adminService.crearAdministrador(nombre, email, password);
      await _cargarAdministradores();
      _mostrarExito('Administrador agregado exitosamente');
    } catch (e) {
      _mostrarError('Error al agregar administrador: $e');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _cambiarEstadoAdmin(String adminId, bool nuevoEstado) async {
    // Prevenir que el admin se desactive a sí mismo
    if (adminId == _adminActualId && !nuevoEstado) {
      _mostrarError('No puedes desactivarte a ti mismo');
      return;
    }

    try {
      await _adminService.cambiarEstadoAdministrador(adminId, nuevoEstado);
      await _cargarAdministradores();
      _mostrarExito(
        nuevoEstado ? 'Administrador activado' : 'Administrador desactivado',
      );
    } catch (e) {
      _mostrarError('Error al cambiar estado: $e');
    }
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

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: const Color(0xFF58CC02),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(theme),
          Expanded(
            child:
                _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAdminsList(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarAdmin,
        backgroundColor: const Color(0xFF58CC02),
        child: const Icon(Icons.person_add, color: Colors.white),
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
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: theme.cardColor),
            ),
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
                'Gestionar Administradores',
                style: TextStyle(
                  color: theme.cardColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminsList(ThemeData theme) {
    if (_administradores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay administradores registrados',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega el primer administrador usando el botón +',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarAdministradores,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Lista de Administradores',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_administradores.length} administrador${_administradores.length != 1 ? 'es' : ''} registrado${_administradores.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _administradores.length,
                itemBuilder: (context, index) {
                  final admin = _administradores[index];
                  return _buildAdminCard(admin, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> admin, ThemeData theme) {
    final bool esAdminActual = admin['id'] == _adminActualId;
    final bool estaActivo = admin['activo'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              esAdminActual
                  ? const Color(0xFF58CC02).withOpacity(0.3)
                  : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        estaActivo
                            ? const Color(0xFF58CC02).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    esAdminActual ? Icons.star : Icons.person,
                    color: estaActivo ? const Color(0xFF58CC02) : Colors.grey,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Información del admin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              admin['nombre'] ?? 'Sin nombre',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          if (esAdminActual)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF58CC02),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'TÚ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        admin['email'] ?? 'Sin email',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  estaActivo
                                      ? const Color(0xFF58CC02).withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              estaActivo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                color:
                                    estaActivo
                                        ? const Color(0xFF58CC02)
                                        : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (admin['fecha_creacion'] != null)
                            Text(
                              'Desde: ${_formatearFecha(admin['fecha_creacion'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Switch de estado (solo si no es el admin actual)
                if (!esAdminActual)
                  Switch(
                    value: estaActivo,
                    onChanged:
                        (valor) => _cambiarEstadoAdmin(admin['id'], valor),
                    activeColor: const Color(0xFF58CC02),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    try {
      DateTime fechaDateTime;
      if (fecha is String) {
        fechaDateTime = DateTime.parse(fecha);
      } else {
        fechaDateTime = fecha.toDate();
      }
      return '${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
