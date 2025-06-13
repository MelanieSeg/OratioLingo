import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<List<Map<String, dynamic>>> processVideos(
  List<QueryDocumentSnapshot> docs,
) {
  return compute((docs) {
    return docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }, docs);
}

class PantallaVideos extends StatefulWidget {
  const PantallaVideos({super.key});

  @override
  State<PantallaVideos> createState() => _PantallaVideosState();
}

class _PantallaVideosState extends State<PantallaVideos>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  final List<DocumentSnapshot> _videos = [];

  @override
  void initState() {
    super.initState();
    _getVideos();
  }

  Future<void> _getVideos() async {
    var query = FirebaseFirestore.instance
        .collection('videos')
        .orderBy('titulo')
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.length < _limit) {
      _hasMore = false;
    }

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    setState(() {
      _videos.addAll(snapshot.docs);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildSearchBar(theme),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildVideosGrid(theme),
              ),
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
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
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
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildVideosGrid(ThemeData theme) {
    return GridView.builder(
      itemCount: _videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final data = _videos[index].data() as Map<String, dynamic>;
        final titulo = data['titulo'] ?? '';
        final imagen = data['imagen'] ?? '';
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Abrir el video usando data['url']
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child:
                      imagen.isNotEmpty
                          ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imagen,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(Icons.error),
                            ),
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: theme.colorScheme.primary,
                                size: 48,
                              ),
                            ),
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.bottomAppBarTheme.color ?? theme.cardColor,
        boxShadow: [
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
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isActive ? theme.colorScheme.primary : theme.disabledColor,
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
              SizedBox(height: 16),
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
                  child: Text('Editar Perfil'),
                ),
              ),
              SizedBox(height: 8),
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
                  child: Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cerrarSesion() {
    Navigator.of(context).pushReplacementNamed('/login');
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
}
