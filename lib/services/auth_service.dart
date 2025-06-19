import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Método para verificar si el usuario actual es administrador
  Future<bool> esAdministrador() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Recargar el usuario para obtener el estado más reciente
      await user.reload();

      // Busca en la colección de administradores
      final adminDoc =
          await _firestore.collection('administradores').doc(user.uid).get();

      // El usuario es admin si existe en la colección y está activo
      return adminDoc.exists && adminDoc.data()?['activo'] == true;
    } catch (e) {
      print('Error verificando rol de administrador: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Obtener ID del usuario actual
  Future<String?> obtenerIdUsuarioActual() async {
    return _auth.currentUser?.uid;
  }
}
