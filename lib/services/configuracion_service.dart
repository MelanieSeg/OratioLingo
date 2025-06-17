import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _configCollection = 'configuracion';
  final String _configDocId = 'sistema'; // Documento único para configuración

  // Obtener toda la configuración
  Future<Map<String, dynamic>> obtenerConfiguracion() async {
    try {
      final doc =
          await _firestore
              .collection(_configCollection)
              .doc(_configDocId)
              .get();

      if (doc.exists) {
        return doc.data() ?? {};
      } else {
        // Si no existe, crear con valores por defecto
        final configDefault = {
          'nombre_app': 'OratioLingo',
          'mensaje_bienvenida': 'Bienvenido a OratioLingo',
          'puntos_respuesta_correcta': 10,
          'preguntas_por_nivel': 20,
          'permitir_reintentos': true,
          'registro_abierto': true,
          'verificacion_email': false,
        };

        await _firestore
            .collection(_configCollection)
            .doc(_configDocId)
            .set(configDefault);

        return configDefault;
      }
    } catch (e) {
      print('Error al obtener configuración: $e');
      return {};
    }
  }

  // Actualizar un valor específico de la configuración
  Future<void> actualizarConfiguracion(String clave, dynamic valor) async {
    try {
      await _firestore.collection(_configCollection).doc(_configDocId).update({
        clave: valor,
        'ultima_actualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al actualizar configuración: $e');
      throw Exception('Error al actualizar configuración: $e');
    }
  }

  // Resetear progreso general (¡función peligrosa!)
  Future<void> resetearProgresoGeneral() async {
    try {
      // Esto es solo un marcador - la implementación real sería más compleja
      // y requeriría eliminar colecciones de progreso o resetear valores
      await _firestore.collection(_configCollection).doc('reset_log').set({
        'fecha_reset': FieldValue.serverTimestamp(),
        'motivo': 'Reset manual desde panel de administración',
      });

      // Aquí iría la lógica real para resetear el progreso
    } catch (e) {
      print('Error al resetear progreso general: $e');
      throw Exception('Error al resetear progreso: $e');
    }
  }

  // Exportar datos (placeholder)
  Future<void> exportarDatos() async {
    try {
      // Aquí implementarías la lógica real de exportación
      await Future.delayed(const Duration(seconds: 2)); // Simular proceso
    } catch (e) {
      print('Error al exportar datos: $e');
      throw Exception('Error al exportar datos: $e');
    }
  }
}
