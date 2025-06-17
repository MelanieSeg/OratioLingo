import 'package:flutter/material.dart';
import 'package:OratioLingo/services/configuracion_service.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final ConfiguracionService _configuracionService = ConfiguracionService();

  Map<String, dynamic> _configuracion = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      setState(() => _cargando = true);
      final config = await _configuracionService.obtenerConfiguracion();

      if (mounted) {
        setState(() {
          _configuracion = config;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError('Error al cargar configuración: $e');
      }
    }
  }

  Future<void> _actualizarConfiguracion(String clave, dynamic valor) async {
    try {
      await _configuracionService.actualizarConfiguracion(clave, valor);
      setState(() {
        _configuracion[clave] = valor;
      });
      _mostrarExito('Configuración actualizada');
    } catch (e) {
      _mostrarError('Error al actualizar configuración: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: const Color(0xFF58CC02),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _mostrarDialogoTexto(
    String titulo,
    String claveConfig,
    String valorActual,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: valorActual,
    );

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(titulo),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ingresa el nuevo valor...',
              ),
              maxLines: titulo.contains('mensaje') ? 3 : 1,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _actualizarConfiguracion(claveConfig, controller.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Future<void> _mostrarDialogoNumero(
    String titulo,
    String claveConfig,
    int valorActual,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: valorActual.toString(),
    );

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(titulo),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ingresa el número...',
              ),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nuevoValor = int.tryParse(controller.text.trim());
                  if (nuevoValor != null) {
                    Navigator.pop(context);
                    _actualizarConfiguracion(claveConfig, nuevoValor);
                  } else {
                    _mostrarError('Por favor ingresa un número válido');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Future<void> _resetearProgreso() async {
    final confirmar = await _mostrarDialogoConfirmacion(
      '¿Resetear todo el progreso?',
      'Esta acción eliminará todo el progreso de todos los usuarios. Esta acción NO se puede deshacer.',
    );

    if (confirmar) {
      try {
        await _configuracionService.resetearProgresoGeneral();
        _mostrarExito('Progreso reseteado exitosamente');
      } catch (e) {
        _mostrarError('Error al resetear progreso: $e');
      }
    }
  }

  Future<void> _exportarDatos() async {
    try {
      await _configuracionService.exportarDatos();
      _mostrarExito('Datos exportados exitosamente');
    } catch (e) {
      _mostrarError('Error al exportar datos: $e');
    }
  }

  Future<bool> _mostrarDialogoConfirmacion(
    String titulo,
    String mensaje,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(titulo),
                content: Text(mensaje),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(theme),
          Expanded(
            child:
                _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _buildConfigContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: theme.cardColor),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Configuración',
                style: TextStyle(
                  color: theme.cardColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          Text(
            'Configuración General',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),

          const SizedBox(height: 20),

          // Configuraciones de la app
          _buildSeccionConfig('Aplicación', [
            _buildConfigItem(
              'Nombre de la App',
              _configuracion['nombre_app'] ?? 'OratioLingo',
              Icons.app_registration,
              () => _mostrarDialogoTexto(
                'Nombre de la Aplicación',
                'nombre_app',
                _configuracion['nombre_app'] ?? 'OratioLingo',
              ),
              theme,
            ),
            _buildConfigItem(
              'Mensaje de Bienvenida',
              _configuracion['mensaje_bienvenida'] ??
                  'Bienvenido a OratioLingo',
              Icons.message,
              () => _mostrarDialogoTexto(
                'Mensaje de Bienvenida',
                'mensaje_bienvenida',
                _configuracion['mensaje_bienvenida'] ??
                    'Bienvenido a OratioLingo',
              ),
              theme,
            ),
          ], theme),

          const SizedBox(height: 24),

          // Configuraciones de juego
          _buildSeccionConfig('Configuración de Juegos', [
            _buildConfigItem(
              'Puntos por Respuesta Correcta',
              '${_configuracion['puntos_respuesta_correcta'] ?? 10} puntos',
              Icons.emoji_events,
              () => _mostrarDialogoNumero(
                'Puntos por Respuesta Correcta',
                'puntos_respuesta_correcta',
                _configuracion['puntos_respuesta_correcta'] ?? 10,
              ),
              theme,
            ),
            _buildConfigItem(
              'Preguntas por Nivel',
              '${_configuracion['preguntas_por_nivel'] ?? 20} preguntas',
              Icons.quiz,
              () => _mostrarDialogoNumero(
                'Preguntas por Nivel',
                'preguntas_por_nivel',
                _configuracion['preguntas_por_nivel'] ?? 20,
              ),
              theme,
            ),
            _buildSwitchItem(
              'Permitir Reintentos',
              _configuracion['permitir_reintentos'] ?? true,
              Icons.refresh,
              (valor) => _actualizarConfiguracion('permitir_reintentos', valor),
              theme,
            ),
          ], theme),

          const SizedBox(height: 24),

          // Configuraciones de usuarios
          _buildSeccionConfig('Usuarios', [
            _buildSwitchItem(
              'Registro Abierto',
              _configuracion['registro_abierto'] ?? true,
              Icons.person_add,
              (valor) => _actualizarConfiguracion('registro_abierto', valor),
              theme,
            ),
            _buildSwitchItem(
              'Verificación de Email',
              _configuracion['verificacion_email'] ?? false,
              Icons.verified_user,
              (valor) => _actualizarConfiguracion('verificacion_email', valor),
              theme,
            ),
          ], theme),

          const SizedBox(height: 32),

          // Acciones peligrosas
          _buildSeccionPeligrosa(theme),

          const SizedBox(height: 32),

          // Información del sistema
          _buildInfoSistema(theme),
        ],
      ),
    );
  }

  Widget _buildSeccionConfig(
    String titulo,
    List<Widget> items,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildConfigItem(
    String titulo,
    String valor,
    IconData icono,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: const Color(0xFFFF9800)),
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        valor,
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
      trailing: const Icon(Icons.edit, color: Color(0xFFFF9800)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
    String titulo,
    bool valor,
    IconData icono,
    Function(bool) onChanged,
    ThemeData theme,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: const Color(0xFFFF9800)),
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Switch(
        value: valor,
        onChanged: onChanged,
        activeColor: const Color(0xFF58CC02),
      ),
    );
  }

  Widget _buildSeccionPeligrosa(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zona Peligrosa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.red),
                ),
                title: const Text(
                  'Resetear Progreso General',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                subtitle: const Text(
                  'Elimina todo el progreso de todos los usuarios',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.warning, color: Colors.red),
                onTap: _resetearProgreso,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.download, color: Colors.blue),
                ),
                title: const Text(
                  'Exportar Datos',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Descarga backup de todos los datos'),
                trailing: const Icon(Icons.download, color: Colors.blue),
                onTap: _exportarDatos,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSistema(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Información del Sistema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInfoRow('Versión', '1.0.0', theme),
          _buildInfoRow('Base de Datos', 'Firestore', theme),
          _buildInfoRow('Último Backup', '15/06/2025', theme),
          _buildInfoRow('Total Administradores', '3', theme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
