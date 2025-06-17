import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _adminsCollection = 'administradores';

  // Obtener todos los administradores
  Future<List<Map<String, dynamic>>> obtenerTodosLosAdministradores() async {
    try {
      final snapshot =
          await _firestore
              .collection(_adminsCollection)
              .orderBy('fecha_creacion', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener administradores: $e');
      throw Exception('Error al obtener administradores: $e');
    }
  }

  // Crear un nuevo administrador
  Future<void> crearAdministrador(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      // 1. Crear usuario en Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Guardar datos en la colección de administradores
      await _firestore
          .collection(_adminsCollection)
          .doc(userCredential.user!.uid)
          .set({
            'nombre': nombre,
            'email': email,
            'activo': true,
            'fecha_creacion': FieldValue.serverTimestamp(),
            'creado_por': _auth.currentUser?.uid,
          });
    } catch (e) {
      print('Error al crear administrador: $e');
      throw Exception('Error al crear administrador: $e');
    }
  }

  // Cambiar estado (activar/desactivar) de un administrador
  Future<void> cambiarEstadoAdministrador(
    String adminId,
    bool nuevoEstado,
  ) async {
    try {
      await _firestore.collection(_adminsCollection).doc(adminId).update({
        'activo': nuevoEstado,
        'ultima_actualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al cambiar estado del administrador: $e');
      throw Exception('Error al cambiar estado del administrador: $e');
    }
  }
}
