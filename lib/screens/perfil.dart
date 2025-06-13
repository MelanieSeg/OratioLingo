import 'package:flutter/material.dart';
import 'theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Descomenta esto
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // <-- Descomenta esto

  // Variables para los switches
  bool notificationsEnabled = true;

  // Variables para información del usuario
  String username = "";
  String email = "";
  String registrationDate = "";

  @override
  void initState() {
    super.initState();
    _cargarInformacionUsuario();
  }

  Future<void> _cargarInformacionUsuario() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Leer datos de Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(currentUser.uid)
              .get();

      setState(() {
        username = doc.data()?['nombreUsuario'] ?? "Usuario";
        email = currentUser.email ?? "";
        registrationDate =
            currentUser.metadata.creationTime != null
                ? "Se unió por primera vez el ${currentUser.metadata.creationTime!.day}/${currentUser.metadata.creationTime!.month}/${currentUser.metadata.creationTime!.year}"
                : "";
      });
    }
  }

  void _cerrarSesion() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _editarPerfil() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Obtén los datos actuales de Firestore
    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();
    final data = doc.data() ?? {};

    final nombreController = TextEditingController(text: data['nombre'] ?? '');
    final nombreUsuarioController = TextEditingController(
      text: data['nombreUsuario'] ?? '',
    );
    final descripcionController = TextEditingController(
      text: data['descripcion'] ?? '',
    );
    final telefonoController = TextEditingController(
      text: data['numeroTelefono'] ?? '',
    );
    DateTime? fechaNacimiento =
        (data['fechaNacimiento'] != null)
            ? (data['fechaNacimiento'] as Timestamp).toDate()
            : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Editar perfil'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                        ),
                      ),
                      TextField(
                        controller: nombreUsuarioController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario',
                        ),
                      ),
                      TextField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                      ),
                      TextField(
                        controller: telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Fecha de nacimiento: '),
                          Text(
                            fechaNacimiento != null
                                ? "${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}"
                                : "No seleccionada",
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: fechaNacimiento ?? DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  fechaNacimiento = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Actualiza en Firestore
                      await FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(currentUser.uid)
                          .update({
                            'nombre': nombreController.text.trim(),
                            'nombreUsuario':
                                nombreUsuarioController.text.trim(),
                            'descripcion': descripcionController.text.trim(),
                            'numeroTelefono': telefonoController.text.trim(),
                            'fechaNacimiento': fechaNacimiento,
                          });
                      // Opcional: actualiza displayName en Auth
                      await currentUser.updateDisplayName(
                        nombreController.text.trim(),
                      );
                      // Actualiza en pantalla
                      setState(() {
                        username = nombreUsuarioController.text.trim();
                      });
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
        );
      },
    );
  }

  void _cambiarContrasena() {
    // Implementar funcionalidad para cambiar contraseña
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cambiar Contraseña'),
            content: const Text('Función no implementada'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _navegarA(String ruta) {
    Navigator.pushNamed(context, ruta);
  }

  Future<void> _actualizarNombreUsuario(String nuevoNombre) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .update({'nombreUsuario': nuevoNombre});
      setState(() {
        username = nuevoNombre;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario autenticado')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('usuarios')
              .doc(currentUser.uid)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron datos de usuario')),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final nombre = data['nombre'] ?? '';
        final nombreUsuario = data['nombreUsuario'] ?? '';
        final descripcion = data['descripcion'] ?? '';
        final telefono = data['numeroTelefono'] ?? '';
        final fechaNacimiento =
            data['fechaNacimiento'] != null
                ? (data['fechaNacimiento'] as Timestamp).toDate()
                : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Perfil')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Nombre: $nombre'),
                Text('Nombre de usuario: $nombreUsuario'),
                Text('Descripción: $descripcion'),
                Text('Teléfono: $telefono'),
                Text(
                  'Fecha de nacimiento: ${fechaNacimiento != null ? "${fechaNacimiento.day}/${fechaNacimiento.month}/${fechaNacimiento.year}" : "No registrada"}',
                ),
                Text('Correo: ${currentUser.email ?? ""}'),
                // ...otros widgets de tu perfil...
              ],
            ),
          ),
          // ...tu bottom navigation y otras acciones...
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF6A4C93)),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de perfil
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 32,
                color: Color(0xFF6A4C93),
              ),
            ),
            const SizedBox(height: 8),

            // Nombre de usuario
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Email
            Text(
              email,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      transform: Matrix4.translationValues(0, -32, 0),
      child: Card(
        color: theme.cardColor, // <-- Usa el color del tema
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Información Personal'),
                const SizedBox(height: 8),
                _buildInfoField('Nombre', username),
                const SizedBox(height: 8),
                _buildInfoField('Correo', email),
                const SizedBox(height: 8),
                _buildInfoField('Fecha de Creación', registrationDate),
                const SizedBox(height: 24),
                _buildSectionTitle('Preferencias'),
                const SizedBox(height: 8),
                _buildSwitchOption('Notificaciones', notificationsEnabled, (
                  value,
                ) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                }),
                const SizedBox(height: 8),
                _buildSwitchOption(
                  'Tema Nocturno',
                  themeNotifier.value ==
                      ThemeMode.dark, // <-- Lee el valor global
                  (value) {
                    themeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                    // No necesitas setState aquí, ValueListenableBuilder en main.dart se encarga
                  },
                ),
                const SizedBox(height: 8),
                _buildChangePasswordButton(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color:
            Theme.of(context).textTheme.titleLarge?.color, // Usa color del tema
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Usa color del tema
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Usa color del tema
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _cambiarContrasena,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Usa color del tema
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text('Cambiar Contraseña', style: theme.textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _cerrarSesion,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A4C93),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return FloatingActionButton.extended(
      onPressed: _editarPerfil,
      backgroundColor: const Color(0xFF6A4C93),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.edit),
      label: const Text('Editar Perfil'),
    );
  }

  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Usa color del tema
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            'Niveles',
            Icons.stairs,
            false,
            () => _navegarA('/niveles'),
          ),
          _buildNavItem(
            'Videos',
            Icons.play_circle,
            false,
            () => _navegarA('/videos'),
          ),
          _buildNavItem(
            'Juegos',
            Icons.games,
            false,
            () => _navegarA('/juegos'),
          ),
          _buildNavItem(
            'Progreso',
            Icons.trending_up,
            true,
            () => _navegarA('/progreso'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color:
                    isActive
                        ? const Color(0xFF6A4C93)
                        : const Color(0xFF666666),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isActive
                          ? const Color(0xFF6A4C93)
                          : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
