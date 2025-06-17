import 'package:cloud_firestore/cloud_firestore.dart';

class VideosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _videosCollection = 'videos';

  // Obtener todos los videos
  Future<List<Map<String, dynamic>>> obtenerTodosLosVideos() async {
    try {
      final snapshot =
          await _firestore
              .collection(_videosCollection)
              .orderBy('fecha_agregado', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener videos: $e');
      throw Exception('Error al obtener videos: $e');
    }
  }

  // Agregar nuevo video
  Future<void> agregarVideo(Map<String, dynamic> videoData) async {
    try {
      await _firestore.collection(_videosCollection).add(videoData);
    } catch (e) {
      print('Error al agregar video: $e');
      throw Exception('Error al agregar video: $e');
    }
  }

  // Eliminar video
  Future<void> eliminarVideo(String videoId) async {
    try {
      await _firestore.collection(_videosCollection).doc(videoId).delete();
    } catch (e) {
      print('Error al eliminar video: $e');
      throw Exception('Error al eliminar video: $e');
    }
  }
}
