import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

      // Obtener progreso por nivel
      final progresoNiveles = await _obtenerProgresoNiveles();

      // Obtener actividad por día (últimos 7 días)
      final actividadPorDia = await _obtenerActividadPorDia();

      return {
        'total_usuarios': totalUsuarios,
        'total_videos': totalVideos,
        'usuarios_activos_hoy': usuariosActivosHoy,
        'niveles_completados': nivelesCompletados,
        'progreso_niveles': progresoNiveles,
        'actividad_por_dia': actividadPorDia,
      };
    } catch (e) {
      print('Error al obtener estadísticas generales: $e');
      return {
        'total_usuarios': 0,
        'total_videos': 0,
        'usuarios_activos_hoy': 0,
        'niveles_completados': 0,
        'progreso_niveles': {},
        'actividad_por_dia': [],
      };
    }
  }

  // Obtener progreso por niveles
  Future<Map<int, int>> _obtenerProgresoNiveles() async {
    final Map<int, int> progreso = {};

    try {
      // Para cada nivel del 1 al 6, contamos usuarios que lo han completado
      for (int nivel = 1; nivel <= 6; nivel++) {
        final completados = await _firestore
            .collectionGroup('niveles')
            .where('numero_nivel', isEqualTo: nivel)
            .where('isFinished', isEqualTo: true)
            .count()
            .get()
            .then((value) => value.count);

        progreso[nivel] = completados ?? 0;
      }
    } catch (e) {
      print('Error al obtener progreso por niveles: $e');
    }

    return progreso;
  }

  // Obtener actividad por día de los últimos 7 días
  Future<List<Map<String, dynamic>>> _obtenerActividadPorDia() async {
    List<Map<String, dynamic>> resultado = [];

    try {
      // Obtener los últimos 7 días
      final DateTime hoy = DateTime.now();
      final formato = DateFormat('dd/MM');

      for (int i = 6; i >= 0; i--) {
        final dia = DateTime(hoy.year, hoy.month, hoy.day - i);
        final diaSiguiente = DateTime(hoy.year, hoy.month, hoy.day - i + 1);

        // Contar usuarios activos ese día
        final activos = await _firestore
            .collection('usuarios')
            .where('ultima_actividad', isGreaterThanOrEqualTo: dia)
            .where('ultima_actividad', isLessThan: diaSiguiente)
            .count()
            .get()
            .then((value) => value.count);

        resultado.add({'fecha': formato.format(dia), 'activos': activos});
      }
    } catch (e) {
      print('Error al obtener actividad por día: $e');
    }

    return resultado;
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

        // Formatear fecha para presentación
        if (data['ultima_actividad'] != null) {
          try {
            final Timestamp timestamp = data['ultima_actividad'];
            final DateTime dateTime = timestamp.toDate();
            data['ultima_actividad_formatted'] = DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format(dateTime);
          } catch (e) {
            data['ultima_actividad_formatted'] = 'Fecha inválida';
          }
        } else {
          data['ultima_actividad_formatted'] = 'Sin actividad';
        }

        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener usuarios activos: $e');
      return [];
    }
  }

  // Obtener distribución de uso de funciones
  Future<Map<String, int>> obtenerDistribucionFunciones() async {
    try {
      // Estas consultas son solo ejemplos. Dependen de cómo estés registrando
      // el uso de funcionalidades en tu aplicación

      final videosVistos = await _firestore
          .collection('estadisticas')
          .doc('videos')
          .get()
          .then((doc) => doc.exists ? (doc.data()?['total_vistas'] ?? 0) : 0);

      final juegosCompletados = await _firestore
          .collection('estadisticas')
          .doc('juegos')
          .get()
          .then((doc) => doc.exists ? (doc.data()?['total_juegos'] ?? 0) : 0);

      final diccionarioUsos = await _firestore
          .collection('estadisticas')
          .doc('diccionario')
          .get()
          .then(
            (doc) => doc.exists ? (doc.data()?['total_consultas'] ?? 0) : 0,
          );

      return {
        'videos': videosVistos,
        'juegos': juegosCompletados,
        'diccionario': diccionarioUsos,
        'niveles': 100, // Valor de ejemplo
      };
    } catch (e) {
      print('Error al obtener distribución de funciones: $e');
      return {'videos': 30, 'juegos': 25, 'diccionario': 15, 'niveles': 30};
    }
  }
}
