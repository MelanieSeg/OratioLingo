import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NivelesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el progreso actual del usuario
  Future<List<Map<String, dynamic>>> obtenerProgreso() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('niveles')
          .orderBy('numero_nivel')
          .get();

      if (snapshot.docs.isEmpty) {
        // Si no existe progreso, inicializar niveles por defecto
        await _inicializarNiveles();
        return await obtenerProgreso();
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener progreso: $e');
      rethrow;
    }
  }

  // Inicializar niveles por defecto (solo nivel 1 desbloqueado)
  Future<void> _inicializarNiveles() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final batch = _firestore.batch();
      final userRef = _firestore.collection('usuarios').doc(user.uid);

      // Crear niveles del 1 al 10 (puedes ajustar según necesites)
      for (int i = 1; i <= 10; i++) {
        final nivelRef = userRef.collection('niveles').doc('nivel_$i');
        batch.set(nivelRef, {
          'numero_nivel': i,
          'isFinished': false,
          'isUnlocked': i == 1, // Solo el primer nivel desbloqueado
          'puntuacion_maxima': 0,
          'intentos': 0,
          'fecha_creacion': FieldValue.serverTimestamp(),
          'fecha_ultima_actualizacion': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('Niveles inicializados correctamente');
    } catch (e) {
      print('Error al inicializar niveles: $e');
      rethrow;
    }
  }

  // Completar un nivel específico
  Future<bool> completarNivel({
    required int numeroNivel,
    required int aciertos,
    required int totalEjercicios,
    required int vidasRestantes,
    required int fallosTotales,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Calcular puntuación (puedes ajustar la fórmula)
      int puntuacion = _calcularPuntuacion(
        aciertos: aciertos,
        totalEjercicios: totalEjercicios,
        vidasRestantes: vidasRestantes,
        fallosTotales: fallosTotales,
      );

      final batch = _firestore.batch();
      final userRef = _firestore.collection('usuarios').doc(user.uid);

      // Actualizar el nivel actual
      final nivelActualRef = userRef.collection('niveles').doc('nivel_$numeroNivel');
      
      // Obtener datos actuales del nivel
      final nivelActualDoc = await nivelActualRef.get();
      final datosActuales = nivelActualDoc.data() ?? {};
      final puntuacionAnterior = datosActuales['puntuacion_maxima'] ?? 0;
      final intentosAnteriores = datosActuales['intentos'] ?? 0;

      batch.update(nivelActualRef, {
        'isFinished': true,
        'puntuacion_maxima': puntuacion > puntuacionAnterior ? puntuacion : puntuacionAnterior,
        'ultima_puntuacion': puntuacion,
        'intentos': intentosAnteriores + 1,
        'aciertos_ultima_sesion': aciertos,
        'fallos_ultima_sesion': fallosTotales,
        'vidas_restantes_ultima_sesion': vidasRestantes,
        'fecha_ultima_actualizacion': FieldValue.serverTimestamp(),
        'fecha_completado': FieldValue.serverTimestamp(),
      });

      // Desbloquear el siguiente nivel
      final siguienteNivel = numeroNivel + 1;
      final siguienteNivelRef = userRef.collection('niveles').doc('nivel_$siguienteNivel');
      
      // Verificar si existe el siguiente nivel
      final siguienteNivelDoc = await siguienteNivelRef.get();
      if (siguienteNivelDoc.exists) {
        batch.update(siguienteNivelRef, {
          'isUnlocked': true,
          'fecha_desbloqueado': FieldValue.serverTimestamp(),
          'fecha_ultima_actualizacion': FieldValue.serverTimestamp(),
        });
      }

      // Actualizar estadísticas generales del usuario
      await _actualizarEstadisticasGenerales(
        aciertos: aciertos,
        fallosTotales: fallosTotales,
        nivelCompletado: numeroNivel,
      );

      await batch.commit();
      
      print('Nivel $numeroNivel completado exitosamente');
      return true;
    } catch (e) {
      print('Error al completar nivel: $e');
      return false;
    }
  }

  // Calcular puntuación basada en rendimiento
  int _calcularPuntuacion({
    required int aciertos,
    required int totalEjercicios,
    required int vidasRestantes,
    required int fallosTotales,
  }) {
    // Fórmula de puntuación (puedes ajustarla)
    double porcentajeAciertos = (aciertos / totalEjercicios) * 100;
    int bonusVidas = vidasRestantes * 50; // 50 puntos por vida restante
    int penalizacionFallos = fallosTotales * 10; // -10 puntos por fallo
    
    int puntuacionBase = (porcentajeAciertos * 10).round(); // Base sobre 1000
    int puntuacionFinal = puntuacionBase + bonusVidas - penalizacionFallos;
    
    return puntuacionFinal.clamp(0, 1000); // Máximo 1000 puntos
  }

  // Actualizar estadísticas generales del usuario
  Future<void> _actualizarEstadisticasGenerales({
    required int aciertos,
    required int fallosTotales,
    required int nivelCompletado,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore.collection('usuarios').doc(user.uid);
      final estadisticasRef = userRef.collection('estadisticas').doc('general');

      await _firestore.runTransaction((transaction) async {
        final estadisticasDoc = await transaction.get(estadisticasRef);
        
        if (estadisticasDoc.exists) {
          final datos = estadisticasDoc.data()!;
          transaction.update(estadisticasRef, {
            'total_aciertos': (datos['total_aciertos'] ?? 0) + aciertos,
            'total_fallos': (datos['total_fallos'] ?? 0) + fallosTotales,
            'niveles_completados': (datos['niveles_completados'] ?? 0) + 1,
            'nivel_maximo_alcanzado': nivelCompletado > (datos['nivel_maximo_alcanzado'] ?? 0) 
                ? nivelCompletado 
                : (datos['nivel_maximo_alcanzado'] ?? 0),
            'fecha_ultima_actividad': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(estadisticasRef, {
            'total_aciertos': aciertos,
            'total_fallos': fallosTotales,
            'niveles_completados': 1,
            'nivel_maximo_alcanzado': nivelCompletado,
            'fecha_creacion': FieldValue.serverTimestamp(),
            'fecha_ultima_actividad': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error al actualizar estadísticas generales: $e');
    }
  }

  // Verificar si un nivel está desbloqueado
  Future<bool> estaDesbloqueado(int numeroNivel) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('niveles')
          .doc('nivel_$numeroNivel')
          .get();

      if (!doc.exists) return numeroNivel == 1; // Solo nivel 1 por defecto

      return doc.data()?['isUnlocked'] ?? false;
    } catch (e) {
      print('Error al verificar si nivel está desbloqueado: $e');
      return false;
    }
  }

  // Obtener estadísticas de un nivel específico
  Future<Map<String, dynamic>?> obtenerEstadisticasNivel(int numeroNivel) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('niveles')
          .doc('nivel_$numeroNivel')
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error al obtener estadísticas del nivel: $e');
      return null;
    }
  }

  // Resetear progreso de un nivel (para desarrollo/testing)
  Future<bool> resetearNivel(int numeroNivel) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('niveles')
          .doc('nivel_$numeroNivel')
          .update({
        'isFinished': false,
        'puntuacion_maxima': 0,
        'ultima_puntuacion': 0,
        'aciertos_ultima_sesion': 0,
        'fallos_ultima_sesion': 0,
        'vidas_restantes_ultima_sesion': 0,
        'fecha_ultima_actualizacion': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error al resetear nivel: $e');
      return false;
    }
  }
}