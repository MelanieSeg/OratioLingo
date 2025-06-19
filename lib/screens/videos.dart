import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/diccionario.dart';
import 'package:OratioLingo/services/videos_service.dart';
import 'package:OratioLingo/utils/dialog_utils.dart';
import 'package:OratioLingo/services/firestore_services.dart';
import 'package:url_launcher/url_launcher.dart';

class PantallaVideos extends StatefulWidget {
  const PantallaVideos({super.key});

  @override
  State<PantallaVideos> createState() => _PantallaVideosState();
}

class _PantallaVideosState extends State<PantallaVideos> {
  // Services
  final VideosService _videosService = VideosService();
  final FirestoreServices _firestoreServices = FirestoreServices();

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State variables
  List<Map<String, dynamic>> _todosLosVideos = []; // Lista completa de videos
  List<Map<String, dynamic>> _videosToShow =
      []; // Lista que se muestra (filtrada)
  List<String> _categorias = []; // Categorías disponibles
  String? _categoriaSeleccionada; // Categoría seleccionada para filtrar
  bool _isLoading = true; // Estado de carga
  bool _isSearching = false; // Estado de búsqueda
  String _searchQuery = ''; // Consulta de búsqueda
  Timer?
  _debounceTimer; // Timer para retrasar la búsqueda mientras el usuario escribe

  @override
  void initState() {
    super.initState();
    _cargarVideos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // CARGA DE DATOS
  Future<void> _cargarVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar todos los videos
      final videos = await _videosService.obtenerTodosLosVideos();

      // Extraer categorías únicas
      final Set<String> categoriasSet = {};
      for (var video in videos) {
        if (video['categoria'] != null &&
            video['categoria'].toString().isNotEmpty) {
          categoriasSet.add(video['categoria'].toString());
        }
      }

      // Actualizar state
      if (mounted) {
        setState(() {
          _todosLosVideos = videos;
          _videosToShow = videos;
          _categorias = categoriasSet.toList()
            ..sort(); // Ordenar alfabéticamente
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar videos: $e');
      }
      if (mounted) {
        _mostrarMensaje('Error al cargar videos', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // FILTRADO DE VIDEOS
  void _buscarVideos(String query) {
    // Cancelar timer anterior si existe
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Crear nuevo timer para debounce
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _searchQuery = query.trim().toLowerCase();
        _isSearching = _searchQuery.isNotEmpty;

        // Aplicar filtros
        _aplicarFiltros();
      });
    });
  }

  void _filtrarPorCategoria(String? categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;

      // Limpiar búsqueda si selecciona categoría
      if (categoria != null) {
        _searchController.clear();
        _searchQuery = '';
        _isSearching = false;
      }

      // Aplicar filtros
      _aplicarFiltros();
    });

    if (categoria != null) {
      _mostrarMensaje('Mostrando videos de: $categoria');
    }
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> resultados = _todosLosVideos;

    // Filtrar por categoría si está seleccionada
    if (_categoriaSeleccionada != null) {
      resultados = resultados
          .where((video) => video['categoria'] == _categoriaSeleccionada)
          .toList();
    }

    // Filtrar por texto de búsqueda
    if (_isSearching && _searchQuery.isNotEmpty) {
      resultados = resultados.where((video) {
        final String titulo = (video['titulo'] ?? '').toString().toLowerCase();
        final String categoria = (video['categoria'] ?? '')
            .toString()
            .toLowerCase();
        final String descripcion = (video['descripcion'] ?? '')
            .toString()
            .toLowerCase();

        return titulo.contains(_searchQuery) ||
            categoria.contains(_searchQuery) ||
            descripcion.contains(_searchQuery);
      }).toList();
    }

    setState(() {
      _videosToShow = resultados;
    });
  }

  void _resetearFiltros() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
      _categoriaSeleccionada = null;
      _videosToShow = _todosLosVideos;
    });
  }

  // UI METHODS
  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _abrirVideo(String url) {
    try {
      final Uri uri = Uri.parse(url);
      launchUrl(uri, mode: LaunchMode.platformDefault).catchError((error) {
        _mostrarMensaje('Error al abrir video', isError: true);
        return false;
      });
    } catch (e) {
      _mostrarMensaje('URL inválida', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),

            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildSearchBar(theme),
            ),

            // Filtros de categoría
            _buildCategoriesFilter(theme),

            // Contenido principal
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildVideosContent(theme),
            ),

            _buildBottomNavBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Container(
      height: 60,
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _mostrarModalPerfil,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.person, color: Color(0xFF6A4C93), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar videos...',
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: theme.colorScheme.primary),
                onPressed: () {
                  _searchController.clear();
                  _buscarVideos('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
      onChanged: _buscarVideos,
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildCategoriesFilter(ThemeData theme) {
    if (_categorias.isEmpty) return const SizedBox();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // Botón "Todos"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: const Text('Todos'),
              selected: _categoriaSeleccionada == null,
              onSelected: (_) => _filtrarPorCategoria(null),
              backgroundColor: theme.cardColor,
              selectedColor: theme.colorScheme.primary.withAlpha(50),
              labelStyle: TextStyle(
                color: _categoriaSeleccionada == null
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          // Botones de categorías
          ..._categorias.map((categoria) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(categoria),
                selected: _categoriaSeleccionada == categoria,
                onSelected: (_) => _filtrarPorCategoria(
                  _categoriaSeleccionada == categoria ? null : categoria,
                ),
                backgroundColor: theme.cardColor,
                selectedColor: theme.colorScheme.primary.withAlpha(50),
                labelStyle: TextStyle(
                  color: _categoriaSeleccionada == categoria
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVideosContent(ThemeData theme) {
    // Si no hay videos disponibles
    if (_todosLosVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay videos disponibles',
              style: TextStyle(fontSize: 18, color: theme.disabledColor),
            ),
          ],
        ),
      );
    }

    // Si hay filtro aplicado pero sin resultados
    if (_videosToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              _categoriaSeleccionada != null
                  ? 'No hay videos en la categoría "$_categoriaSeleccionada"'
                  : 'No se encontraron videos que coincidan con "$_searchQuery"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: theme.disabledColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetearFiltros,
              icon: const Icon(Icons.refresh),
              label: const Text('Mostrar todos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar los videos en una cuadrícula
    return RefreshIndicator(
      onRefresh: _cargarVideos,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _videosToShow.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final video = _videosToShow[index];
          return _buildVideoCard(video, theme);
        },
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, ThemeData theme) {
    final String titulo = video['titulo'] ?? '';
    final String imagen = video['miniatura'] ?? '';
    final String categoria = video['categoria'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (video['url'] != null && video['url'].toString().isNotEmpty) {
            _abrirVideo(video['url']);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // La imagen base
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imagen,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error_outline),
                      ),
                    ),
                  ),
                  // Overlay semi-transparente
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(128),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Ícono de play en el centro
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  // Categoría en la esquina
                  if (categoria.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          categoria,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.bottomAppBarTheme.color ?? theme.cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            'Niveles',
            Icons.layers,
            false,
            _abrirPantallaNiveles,
            theme,
          ),
          _buildNavItem(
            'Diccionario',
            Icons.book,
            false,
            _abrirPantallaDiccionario,
            theme,
          ),
          _buildNavItem('Videos', Icons.play_circle_outline, true, null, theme),
          _buildNavItem(
            'Juegos',
            Icons.games,
            false,
            _abrirPantallaJuegos,
            theme,
          ),
          _buildNavItem(
            'Progreso',
            Icons.bar_chart,
            false,
            _abrirPantallaProgreso,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback? onTap,
    ThemeData theme,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? theme.colorScheme.primary : theme.disabledColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalPerfil() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opciones de Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _abrirEditarPerfil();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Editar Perfil'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _cerrarSesion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cerrarSesion() async {
    await DialogUtils.mostrarDialogoCerrarSesion(context, _firestoreServices);
  }

  void _abrirPantallaProgreso() {
    Navigator.of(context).pushNamed('/progreso');
  }

  void _abrirPantallaJuegos() {
    Navigator.of(context).pushNamed('/juegos');
  }

  void _abrirPantallaNiveles() {
    Navigator.of(context).pushNamed('/niveles');
  }

  void _abrirEditarPerfil() {
    Navigator.of(context).pushNamed('/perfil');
  }

  void _abrirPantallaDiccionario() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PantallaDiccionario()),
    );
  }
}
