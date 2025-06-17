import 'package:cloud_firestore/cloud_firestore.dart';

class EstadisticasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener estadísticas generales
  Future<Map<String, dynamic>> obtenerEstadisticasGenerales() async {
    try {
      // Contar total de usuarios
      final totalUsuarios = await _firestore
          .collection('usuarios')
          .count()
          .get()
          .then((value) => value.count);

      // Contar videos disponibles
      final totalVideos = await _firestore
          .collection('videos')
          .count()
          .get()
          .then((value) => value.count);

      // Usuarios activos hoy (aproximado - se puede mejorar con una consulta más precisa)
      final DateTime hoy = DateTime.now();
      final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);

      final usuariosActivosHoy = await _firestore
          .collection('usuarios')
          .where('ultima_actividad', isGreaterThanOrEqualTo: inicioHoy)
          .count()
          .get()
          .then((value) => value.count);

      // Conteo de niveles completados
      final nivelesCompletados = await _firestore
          .collectionGroup('niveles')
          .where('isFinished', isEqualTo: true)
          .count()
          .get()
          .then((value) => value.count);

      return {
        'total_usuarios': totalUsuarios,
        'total_videos': totalVideos,
        'usuarios_activos_hoy': usuariosActivosHoy,
        'niveles_completados': nivelesCompletados,
        // Aquí puedes añadir más estadísticas según necesites
      };
    } catch (e) {
      print('Error al obtener estadísticas generales: $e');
      return {
        'total_usuarios': 0,
        'total_videos': 0,
        'usuarios_activos_hoy': 0,
        'niveles_completados': 0,
      };
    }
  }

  // Obtener usuarios activos (ejemplo básico)
  Future<List<Map<String, dynamic>>> obtenerUsuariosActivos() async {
    try {
      final snapshot =
          await _firestore
              .collection('usuarios')
              .orderBy('ultima_actividad', descending: true)
              .limit(10)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener usuarios activos: $e');
      return [];
    }
  }
}
