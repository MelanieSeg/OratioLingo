import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'usuarios';

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Crear un nuevo usuario (registro) con verificación de correo
  Future<UserCredential> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String nombreUsuario,
    String? descripcion,
    DateTime? fechaNacimiento,
    String? numeroTelefono,
    String? urlPhotoPerfil,
  }) async {
    try {
      // 1. Verificar si el nombre de usuario ya existe
      final usuarioExistente = await _firestore
          .collection(_usersCollection)
          .where('nombreUsuario', isEqualTo: nombreUsuario)
          .get();
      
      if (usuarioExistente.docs.isNotEmpty) {
        throw Exception('Este nombre de usuario ya está en uso');
      }

      // 2. Crear usuario en Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Enviar correo de verificación
      await userCredential.user!.sendEmailVerification();

      // 4. Crear documento del usuario en Firestore
      await _firestore.collection(_usersCollection).doc(userCredential.user!.uid).set({
        'nombre': nombre,
        'nombreUsuario': nombreUsuario,
        'correo': email,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'estaValidado': false, // Por defecto no está validado hasta que verifique su correo
        'correoVerificado': false, // Estado de verificación del correo
        'descripcion': descripcion ?? '',
        'fechaNacimiento': fechaNacimiento,
        'numeroTelefono': numeroTelefono ?? '',
        'urlPhotoPerfil': urlPhotoPerfil ?? '',
        'uid': userCredential.user!.uid,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('La contraseña es demasiado débil');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Ya existe una cuenta con este correo electrónico');
      } else {
        throw Exception('Error al registrar: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  // Iniciar sesión con verificación de correo
  Future<UserCredential> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar con Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Verificar si el usuario existe en Firestore
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userCredential.user!.uid)
          .get();
      
      if (!docSnapshot.exists) {
        // Si no existe en Firestore pero sí en Auth, creamos un error
        await _auth.signOut();
        throw Exception('Usuario no encontrado en la base de datos');
      }
      
      // 3. Verificar si el correo está verificado
      if (!userCredential.user!.emailVerified) {
        // Si no está verificado, enviamos un nuevo correo y cerramos sesión
        await userCredential.user!.sendEmailVerification();
        await _auth.signOut();
        throw Exception(
          'Por favor, verifica tu correo electrónico antes de iniciar sesión. '
          'Se ha enviado un nuevo correo de verificación.'
        );
      }
      
      // 4. Actualizar el estado de verificación en Firestore si es necesario
      if (docSnapshot.data()!['correoVerificado'] == false) {
        await _firestore
            .collection(_usersCollection)
            .doc(userCredential.user!.uid)
            .update({
              'correoVerificado': true,
              'estaValidado': true
            });
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No existe usuario con este correo electrónico');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta');
      } else {
        throw Exception('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Verificar estado del correo y actualizarlo si es necesario
  Future<bool> verificarEstadoCorreo() async {
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }
    
    // Recargar usuario para obtener estado actualizado
    await currentUser!.reload();
    final user = _auth.currentUser;
    
    if (user!.emailVerified) {
      // Actualizar en Firestore si es necesario
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();
      
      if (docSnapshot.exists && docSnapshot.data()!['correoVerificado'] == false) {
        await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .update({
              'correoVerificado': true,
              'estaValidado': true
            });
      }
      
      return true;
    }
    
    return false;
  }

  // Enviar correo de verificación nuevamente
  Future<void> reenviarCorreoVerificacion() async {
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }
    
    await currentUser!.sendEmailVerification();
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Obtener datos del usuario actual
  Future<Map<String, dynamic>> obtenerDatosUsuarioActual() async {
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    final docSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(currentUser!.uid)
        .get();
    
    if (!docSnapshot.exists) {
      throw Exception('Usuario no encontrado en la base de datos');
    }
    
    return docSnapshot.data()!;
  }
  
  // Actualizar datos de usuario
  Future<void> actualizarDatosUsuario(Map<String, dynamic> datos) async {
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUser!.uid)
        .update(datos);
  }
  
  // Actualizar foto de perfil
  Future<void> actualizarFotoPerfil(String urlFoto) async {
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }
    
    await _firestore
        .collection(_usersCollection)
        .doc(currentUser!.uid)
        .update({'urlPhotoPerfil': urlFoto});
  }
}