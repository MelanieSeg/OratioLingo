import 'package:flutter/material.dart';
import 'package:OratioLingo/services/videos_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GestionarVideosScreen extends StatefulWidget {
  const GestionarVideosScreen({super.key});

  @override
  State<GestionarVideosScreen> createState() => _GestionarVideosScreenState();
}

class _GestionarVideosScreenState extends State<GestionarVideosScreen> {
  final VideosService _videosService = VideosService();

  List<Map<String, dynamic>> _videos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarVideos();
  }

  Future<void> _cargarVideos() async {
    try {
      setState(() => _cargando = true);
      final videos = await _videosService.obtenerTodosLosVideos();

      if (mounted) {
        setState(() {
          _videos = videos;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError('Error al cargar videos: $e');
      }
    }
  }

  Future<void> _mostrarDialogoAgregarVideo() async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();

    String? categoriaSeleccionada;
    final List<String> categorias = [
      'Alfabeto',
      'Números',
      'Saludos',
      'Familia',
      'Colores',
      'Animales',
      'Comida',
      'Emociones',
      'Otros',
    ];

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9C27B0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.video_library,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Agregar Video'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título del video',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: 'URL de YouTube',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'https://www.youtube.com/watch?v=...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        categorias.map((categoria) {
                          return DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                    onChanged: (valor) {
                      categoriaSeleccionada = valor;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción (opcional)',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (tituloController.text.trim().isEmpty ||
                      urlController.text.trim().isEmpty ||
                      categoriaSeleccionada == null) {
                    _mostrarError('Título, URL y categoría son requeridos');
                    return;
                  }

                  if (!_esUrlYouTubeValida(urlController.text.trim())) {
                    _mostrarError(
                      'Por favor ingresa una URL válida de YouTube',
                    );
                    return;
                  }

                  Navigator.pop(context);
                  await _agregarVideo(
                    tituloController.text.trim(),
                    urlController.text.trim(),
                    categoriaSeleccionada!,
                    descripcionController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Agregar'),
              ),
            ],
          ),
    );
  }

  bool _esUrlYouTubeValida(String url) {
    return url.contains('youtube.com/watch?v=') ||
        url.contains('youtu.be/') ||
        url.contains('youtube.com/embed/');
  }

  String _extraerIdVideo(String url) {
    RegExp regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  String _generarUrlMiniatura(String url) {
    final videoId = _extraerIdVideo(url);
    return videoId.isNotEmpty
        ? 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg'
        : '';
  }

  Future<void> _agregarVideo(
    String titulo,
    String url,
    String categoria,
    String descripcion,
  ) async {
    try {
      setState(() => _cargando = true);

      final videoId = _extraerIdVideo(url);
      final miniatura = _generarUrlMiniatura(url);

      await _videosService.agregarVideo({
        'titulo': titulo,
        'url': url,
        'categoria': categoria,
        'descripcion': descripcion,
        'video_id': videoId,
        'miniatura': miniatura,
        'fecha_agregado': DateTime.now(),
        'activo': true,
      });

      await _cargarVideos();
      _mostrarExito('Video agregado exitosamente');
    } catch (e) {
      _mostrarError('Error al agregar video: $e');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _eliminarVideo(String videoId, String titulo) async {
    final confirmar = await _mostrarDialogoConfirmacion(
      '¿Eliminar video?',
      '¿Estás seguro de que quieres eliminar "$titulo"? Esta acción no se puede deshacer.',
    );

    if (confirmar) {
      try {
        await _videosService.eliminarVideo(videoId);
        await _cargarVideos();
        _mostrarExito('Video eliminado exitosamente');
      } catch (e) {
        _mostrarError('Error al eliminar video: $e');
      }
    }
  }

  Future<void> _abrirVideo(String url) async {
    try {
      // Asegurarse que la URL sea válida
      final Uri uri = Uri.parse(url);

      // Primer intento: usar LaunchMode.platformDefault (recomendado)
      if (await canLaunchUrl(uri)) {
        final bool success = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );

        if (!success) {
          // Segundo intento: usar el navegador externo
          final bool externalSuccess = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (!externalSuccess) {
            // Tercer intento: modo navegador interno
            await launchUrl(
              uri,
              mode: LaunchMode.inAppWebView,
              webViewConfiguration: const WebViewConfiguration(
                enableJavaScript: true,
                enableDomStorage: true,
              ),
            );
          }
        }
      } else {
        _mostrarError('No se puede abrir la URL: $url');
      }
    } catch (e) {
      _mostrarError('Error al abrir video: $e');
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
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
        ) ??
        false;
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
                    : _buildVideosList(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarVideo,
        backgroundColor: const Color(0xFF9C27B0),
        child: const Icon(Icons.add, color: Colors.white),
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
                Icons.video_library,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Gestionar Videos',
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

  Widget _buildVideosList(ThemeData theme) {
    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay videos agregados',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega el primer video usando el botón +',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarVideos,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Videos de YouTube',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_videos.length} video${_videos.length != 1 ? 's' : ''} disponible${_videos.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  return _buildVideoCard(video, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, ThemeData theme) {
    final String miniatura = video['miniatura'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Miniatura del video
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child:
                      miniatura.isNotEmpty
                          ? Image.network(
                            miniatura,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.video_library,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                          : const Icon(
                            Icons.video_library,
                            size: 50,
                            color: Colors.grey,
                          ),
                ),
                // Overlay de play
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                // Botón de eliminar
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _eliminarVideo(video['id'], video['titulo']),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información del video
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        video['titulo'] ?? 'Sin título',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        video['categoria'] ?? 'Sin categoría',
                        style: const TextStyle(
                          color: Color(0xFF9C27B0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                if (video['descripcion'] != null &&
                    video['descripcion'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    video['descripcion'],
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Agregado: ${_formatearFecha(video['fecha_agregado'])}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _abrirVideo(video['url']),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Ver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    try {
      DateTime fechaDateTime;
      if (fecha is String) {
        fechaDateTime = DateTime.parse(fecha);
      } else {
        fechaDateTime = fecha.toDate();
      }
      return '${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
