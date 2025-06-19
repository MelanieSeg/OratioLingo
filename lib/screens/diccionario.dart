import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/niveles.dart';
import 'package:OratioLingo/screens/videos.dart';
import 'package:OratioLingo/screens/juegos.dart';
import 'package:OratioLingo/screens/progreso.dart';
import 'package:OratioLingo/screens/perfil.dart';
import 'package:OratioLingo/utils/dialog_utils.dart';
import 'package:OratioLingo/services/firestore_services.dart';

class PantallaDiccionario extends StatefulWidget {
  const PantallaDiccionario({super.key});

  @override
  _PantallaDiccionarioState createState() => _PantallaDiccionarioState();
}

class _PantallaDiccionarioState extends State<PantallaDiccionario> {
  bool _isModalVisible = false;
  String _filtroSeleccionado = 'Todos'; // 'Todos', 'A-M', 'N-Z'

  // Lista completa del abecedario con información adicional
  final List<Map<String, dynamic>> abecedario = [
    {
      'letra': 'A',
      'letraSeña': 'a',
      'descripcion': 'Puño cerrado con pulgar al lado',
      'categoria': 'A-M',
      'color': const Color(0xFF58CC02),
      'dificultad': 'Fácil',
    },
    {
      'letra': 'B',
      'letraSeña': 'b',
      'descripcion': 'Cuatro dedos juntos, pulgar sobre palma',
      'categoria': 'A-M',
      'color': const Color(0xFF58CC02),
      'dificultad': 'Fácil',
    },
    {
      'letra': 'C',
      'letraSeña': 'c',
      'descripcion': 'Forma de C con la mano',
      'categoria': 'A-M',
      'color': const Color(0xFF58CC02),
      'dificultad': 'Fácil',
    },
    {
      'letra': 'D',
      'letraSeña': 'd',
      'descripcion': 'Índice arriba, otros dedos doblados',
      'categoria': 'A-M',
      'color': const Color(0xFF58CC02),
      'dificultad': 'Fácil',
    },
    {
      'letra': 'E',
      'letraSeña': 'e',
      'descripcion': 'Dedos doblados sobre palma',
      'categoria': 'A-M',
      'color': const Color(0xFF58CC02),
      'dificultad': 'Fácil',
    },
    {
      'letra': 'F',
      'letraSeña': 'f',
      'descripcion': 'Círculo con índice y pulgar',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'G',
      'letraSeña': 'g',
      'descripcion': 'Índice y pulgar extendidos horizontalmente',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'H',
      'letraSeña': 'h',
      'descripcion': 'Índice y medio extendidos horizontalmente',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'I',
      'letraSeña': 'i',
      'descripcion': 'Meñique extendido hacia arriba',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'J',
      'letraSeña': 'j',
      'descripcion': 'Meñique dibuja una J en el aire',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'K',
      'letraSeña': 'k',
      'descripcion': 'Índice arriba, medio en ángulo',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'L',
      'letraSeña': 'l',
      'descripcion': 'Índice y pulgar en forma de L',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'M',
      'letraSeña': 'm',
      'descripcion': 'Pulgar entre anular y meñique',
      'categoria': 'A-M',
      'color': const Color(0xFFFF9500),
      'dificultad': 'Medio',
    },
    {
      'letra': 'N',
      'letraSeña': 'n',
      'descripcion': 'Pulgar entre medio y anular',
      'categoria': 'N-Z',
      'color': const Color(0xFF1CB0F6),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'Ñ',
      'letraSeña': 'n',
      'descripcion': 'N con movimiento ondulatorio',
      'categoria': 'N-Z',
      'color': const Color(0xFF1CB0F6),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'O',
      'letraSeña': 'o',
      'descripcion': 'Todos los dedos forman un círculo',
      'categoria': 'N-Z',
      'color': const Color(0xFF1CB0F6),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'P',
      'letraSeña': 'p',
      'descripcion': 'Como K pero apuntando hacia abajo',
      'categoria': 'N-Z',
      'color': const Color(0xFF1CB0F6),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'Q',
      'letraSeña': 'q',
      'descripcion': 'Como G pero apuntando hacia abajo',
      'categoria': 'N-Z',
      'color': const Color(0xFF1CB0F6),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'R',
      'letraSeña': 'r',
      'descripcion': 'Índice y medio cruzados',
      'categoria': 'N-Z',
      'color': const Color(0xFF1CB0F6),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'S',
      'letraSeña': 's',
      'descripcion': 'Puño cerrado con pulgar sobre dedos',
      'categoria': 'N-Z',
      'color': const Color(0xFF1CB0F6),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'T',
      'letraSeña': 't',
      'descripcion': 'Pulgar entre índice y medio',
      'categoria': 'N-Z',
      'color': const Color(0xFFFF4B4B),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'U',
      'letraSeña': 'u',
      'descripcion': 'Índice y medio juntos hacia arriba',
      'categoria': 'N-Z',
      'color': const Color(0xFFFF4B4B),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'V',
      'letraSeña': 'v',
      'descripcion': 'Índice y medio separados en V',
      'categoria': 'N-Z',
      'color': const Color(0xFFFF4B4B),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'W',
      'letraSeña': 'w',
      'descripcion': 'Índice, medio y anular separados',
      'categoria': 'N-Z',
      'color': const Color(0xFFFF4B4B),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'X',
      'letraSeña': 'x',
      'descripcion': 'Índice doblado como gancho',
      'categoria': 'N-Z',
      'color': const Color(0xFFFF4B4B),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'Y',
      'letraSeña': 'y',
      'descripcion': 'Pulgar y meñique extendidos',
      'categoria': 'N-Z',
      'color': const Color(0xFFFF4B4B),
      'dificultad': 'Difícil',
    },
    {
      'letra': 'Z',
      'letraSeña': 'z',
      'descripcion': 'Índice dibuja una Z en el aire',
      'categoria': 'N-Z',
      'color': const Color(0xFFFF4B4B),
      'dificultad': 'Difícil',
    },
  ];

  List<Map<String, dynamic>> get letrasFiltradaslist {
    if (_filtroSeleccionado == 'Todos') {
      return abecedario;
    }
    return abecedario
        .where((letra) => letra['categoria'] == _filtroSeleccionado)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(theme),
          Expanded(child: _buildDictionaryContent(theme)),
          _buildBottomNavBar(theme),
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
                    Icons.book,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _toggleModal,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                  ),
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
      ),
    );
  }

  Widget _buildDictionaryContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Text(
            "Diccionario de señas",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Aprende todas las letras del abecedario en lenguaje de señas",
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 10),

          // Filtros
          _buildFilterButtons(theme),
          const SizedBox(height: 10),

          // Grid de letras responsivo - siempre 3 columnas
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.6,
              ),
              itemCount: letrasFiltradaslist.length,
              itemBuilder: (context, index) {
                return _buildLetterCard(letrasFiltradaslist[index], theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(ThemeData theme) {
    final filtros = ['Todos', 'A-M', 'N-Z'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filtros.map((filtro) {
              final isSelected = _filtroSeleccionado == filtro;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _filtroSeleccionado = filtro;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      filtro,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLetterCard(Map<String, dynamic> letra, ThemeData theme) {
    return GestureDetector(
      onTap: () => _mostrarDetalleLetra(letra),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: letra['color'].withAlpha(77), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Letra en fuente normal
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: letra['color'].withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        letra['letra'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: letra['color'],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Letra en señas (fuente especial)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: letra['color'].withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        letra['letraSeña'],
                        style: TextStyle(
                          fontFamily: 'ChileanSignLanguage',
                          fontSize: 40,
                          color: letra['color'],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Indicador de dificultad
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(
                        letra['dificultad'],
                      ).withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      letra['dificultad'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getDifficultyColor(letra['dificultad']),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge de categoría
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: letra['color'],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  letra['categoria'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String dificultad) {
    switch (dificultad) {
      case 'Fácil':
        return const Color(0xFF58CC02);
      case 'Medio':
        return const Color(0xFFFF9500);
      case 'Difícil':
        return const Color(0xFFFF4B4B);
      default:
        return Colors.grey;
    }
  }

  void _mostrarDetalleLetra(Map<String, dynamic> letra) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título con letra normal
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Letra ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      letra['letra'],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: letra['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Seña en grande
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: letra['color'].withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: letra['color'].withAlpha(77),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letra['letraSeña'],
                      style: TextStyle(
                        fontFamily: 'ChileanSignLanguage',
                        fontSize: 80,
                        color: letra['color'],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Descripción detallada
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Cómo hacer la seña:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        letra['descripcion'],
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Información adicional
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Categoría',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: letra['color'].withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  letra['categoria'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: letra['color'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Dificultad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                    letra['dificultad'],
                                  ).withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  letra['dificultad'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getDifficultyColor(
                                      letra['dificultad'],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Botón de cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: letra['color'],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ENTENDIDO'),
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
        color: theme.colorScheme.surface,
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
          _buildNavItem(Icons.layers, "Niveles", false, theme),
          _buildNavItem(Icons.book, "Diccionario", true, theme),
          _buildNavItem(Icons.play_circle_outline, "Videos", false, theme),
          _buildNavItem(Icons.games, "Juegos", false, theme),
          _buildNavItem(Icons.trending_up, "Progreso", false, theme),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    ThemeData theme,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTap(label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isSelected ? theme.colorScheme.primary : theme.disabledColor,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleModal() {
    setState(() {
      _isModalVisible = !_isModalVisible;
    });

    if (_isModalVisible) {
      _showProfileModal();
    }
  }

  void _showProfileModal() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Editar Perfil"),
                ),
              ),
              SizedBox(height: 12),
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Cerrar Sesión"),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isModalVisible = false;
      });
    });
  }

  void _onNavItemTap(String label) {
    switch (label) {
      case "Niveles":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaNiveles()),
        );
        break;
      case "Videos":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaVideos()),
        );
        break;
      case "Juegos":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaJuegos()),
        );
        break;
      case "Progreso":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaProgreso()),
        );
        break;
      case "Diccionario":
        // Ya estamos en diccionario
        break;
    }
  }

  final FirestoreServices _firestoreServices = FirestoreServices();

  void _cerrarSesion() async {
    await DialogUtils.mostrarDialogoCerrarSesion(context, _firestoreServices);
  }

  void _abrirEditarPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaPerfil()),
    );
  }
}
