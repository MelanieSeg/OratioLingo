import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditarPerfilScreen({super.key, required this.userData});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _nombreUsuarioController = TextEditingController();
  final _telefonoController = TextEditingController();
  DateTime? _fechaNacimiento;
  bool _isLoading = false;
  File? _imageFile;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.userData['nombre'] ?? '';
    _nombreUsuarioController.text = widget.userData['nombreUsuario'] ?? '';
    _telefonoController.text = widget.userData['numeroTelefono'] ?? '';
    _fechaNacimiento = widget.userData['fechaNacimiento']?.toDate();
    _currentPhotoUrl = widget.userData['fotoUrl'];
  }

  Future<void> _selectImage() async {
    // Check for permissions first
    PermissionStatus status;

    if (await Permission.storage.status.isDenied) {
      status = await Permission.storage.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requieren permisos para acceder a la galería'),
            ),
          );
        }
        return;
      }
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _currentPhotoUrl;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      String? photoUrl = await _uploadImage();

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({
            'nombre': _nombreController.text,
            'nombreUsuario': _nombreUsuarioController.text,
            'numeroTelefono': _telefonoController.text,
            'fechaNacimiento': _fechaNacimiento,
            if (photoUrl != null) 'fotoUrl': photoUrl,
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar cambios: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _mostrarMensaje(
    BuildContext context,
    String mensaje,
    bool esError,
  ) {
    // Elimina cualquier SnackBar existente
    ScaffoldMessenger.of(context).clearSnackBars();

    return ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: esError ? Colors.red : Colors.green,
            duration: const Duration(seconds: 1), // Duración más corta
            behavior:
                SnackBarBehavior.floating, // Hace que flote sobre el contenido
            margin: const EdgeInsets.all(8), // Agrega margen
            shape: RoundedRectangleBorder(
              // Bordes redondeados
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        )
        .closed;
  }

  Future<void> _cambiarContrasena() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    final scaffoldContext = context;

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (BuildContext dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Cambiar Contraseña'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: currentPasswordController,
                          obscureText: obscureCurrentPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña actual',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrentPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        obscureCurrentPassword =
                                            !obscureCurrentPassword,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNewPassword,
                          decoration: InputDecoration(
                            labelText: 'Nueva contraseña',
                            border: const OutlineInputBorder(),
                            helperText: 'Mínimo 6 caracteres',
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        obscureNewPassword =
                                            !obscureNewPassword,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: confirmNewPasswordController,
                          obscureText: obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmar nueva contraseña',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        obscureConfirmPassword =
                                            !obscureConfirmPassword,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Validaciones básicas
                        if (currentPasswordController.text.isEmpty ||
                            newPasswordController.text.isEmpty ||
                            confirmNewPasswordController.text.isEmpty) {
                          await _mostrarMensaje(
                            scaffoldContext,
                            'Por favor completa todos los campos',
                            true,
                          );
                          return;
                        }

                        if (newPasswordController.text !=
                            confirmNewPasswordController.text) {
                          await _mostrarMensaje(
                            scaffoldContext,
                            'Las nuevas contraseñas no coinciden',
                            true,
                          );
                          return;
                        }

                        if (newPasswordController.text.length < 6) {
                          await _mostrarMensaje(
                            scaffoldContext,
                            'La nueva contraseña debe tener al menos 6 caracteres',
                            true,
                          );
                          return;
                        }

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: currentPasswordController.text,
                            );

                            await user.reauthenticateWithCredential(credential);
                            await user.updatePassword(
                              newPasswordController.text,
                            );

                            Navigator.pop(dialogContext);
                            await _mostrarMensaje(
                              scaffoldContext,
                              'Contraseña actualizada con éxito',
                              false,
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String mensaje = 'Error al cambiar la contraseña';

                          if (e.code == 'wrong-password') {
                            mensaje = 'La contraseña actual es incorrecta';
                          } else if (e.code == 'weak-password') {
                            mensaje = 'La nueva contraseña es muy débil';
                          }

                          await _mostrarMensaje(scaffoldContext, mensaje, true);
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF6A4C93),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selectImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_currentPhotoUrl != null
                                  ? NetworkImage(_currentPhotoUrl!)
                                      as ImageProvider
                                  : null),
                      child:
                          (_imageFile == null && _currentPhotoUrl == null)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A4C93),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Fecha de nacimiento: ${_fechaNacimiento?.toString().split(' ')[0] ?? 'No seleccionada'}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaNacimiento ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (fecha != null) {
                    setState(() {
                      _fechaNacimiento = fecha;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cambiarContrasena,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF6A4C93)),
                  ),
                  child: const Text(
                    'Cambiar Contraseña',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6A4C93)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4C93),
                    foregroundColor:
                        Colors.white, // Añade esto para el color del texto
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Colors
                                      .white, // Asegura que el texto sea blanco
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
