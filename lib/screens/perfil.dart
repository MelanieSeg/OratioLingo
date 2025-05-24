import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  // Firebase Auth instance (comentado)
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Variables para los switches
  bool notificationsEnabled = true;
  bool darkThemeEnabled = false;
  
  // Variables para información del usuario (valores de ejemplo)
  String username = "Poro Lolero";
  String email = "test@correotest.cl";
  String registrationDate = "Se unió por primera vez el 10 de febrero del 2020";

  @override
  void initState() {
    super.initState();
    // Cargar información del usuario
    _cargarInformacionUsuario();
  }

  void _cargarInformacionUsuario() {
    // Implementación con Firebase (comentado)
    /*
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        username = currentUser.displayName ?? "Usuario";
        email = currentUser.email ?? "";
        // registrationDate se puede obtener de Firestore o user.metadata.creationTime
      });
    }
    */
  }

  void _cerrarSesion() {
    // Implementación con Firebase (comentado)
    /*
    _auth.signOut().then((_) {
      Navigator.pushReplacementNamed(context, '/main');
    });
    */
    
    // Implementación temporal sin Firebase
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _editarPerfil() {
    // Implementar navegación a pantalla de edición de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de editar perfil no implementada')),
    );
  }

  void _cambiarContrasena() {
    // Implementar funcionalidad para cambiar contraseña
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header con información del usuario
          _buildHeader(),
          
          // Contenido principal
          Expanded(
            child: Stack(
              children: [
                // Card con información
                _buildContentCard(),
                
                // Botón flotante de editar perfil
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildEditProfileButton(),
                ),
              ],
            ),
          ),
          
          // Barra de navegación inferior
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF6A4C93),
      ),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      transform: Matrix4.translationValues(0, -32, 0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información Personal
                _buildSectionTitle('Información Personal'),
                const SizedBox(height: 8),
                _buildInfoField('Nombre', username),
                const SizedBox(height: 8),
                _buildInfoField('Correo', email),
                const SizedBox(height: 8),
                _buildInfoField('Fecha de Creación', registrationDate),
                const SizedBox(height: 24),
                
                // Preferencias
                _buildSectionTitle('Preferencias'),
                const SizedBox(height: 8),
                _buildSwitchOption('Notificaciones', notificationsEnabled, (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                  // Guardar preferencia en SharedPreferences
                }),
                const SizedBox(height: 8),
                _buildSwitchOption('Tema Nocturno', darkThemeEnabled, (value) {
                  setState(() {
                    darkThemeEnabled = value;
                  });
                  // Implementar cambio de tema
                }),
                const SizedBox(height: 8),
                _buildChangePasswordButton(),
                const SizedBox(height: 24),
                
                // Botón de cerrar sesión
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6A4C93),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return GestureDetector(
      onTap: _cambiarContrasena,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Text(
          'Cambiar Contraseña',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Cerrar Sesión',
          style: TextStyle(fontSize: 16),
        ),
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
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
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
          _buildNavItem('Niveles', Icons.stairs, false, () => _navegarA('/niveles')),
          _buildNavItem('Videos', Icons.play_circle, false, () => _navegarA('/videos')),
          _buildNavItem('Juegos', Icons.games, false, () => _navegarA('/juegos')),
          _buildNavItem('Progreso', Icons.trending_up, true, () => _navegarA('/progreso')),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive, VoidCallback onTap) {
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
                color: isActive ? const Color(0xFF6A4C93) : const Color(0xFF666666),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? const Color(0xFF6A4C93) : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}