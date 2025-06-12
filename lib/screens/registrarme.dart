import 'package:flutter/material.dart';
import '../services/firestore_services.dart';

class RegistrarmeScreen extends StatelessWidget {
  const RegistrarmeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: const [
              SizedBox(height: 20),
              _RegistroHeader(),
              SizedBox(height: 30),
              _RegistroForm(),
              SizedBox(height: 20),
              _RegistroFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para la cabecera del registro
class _RegistroHeader extends StatelessWidget {
  const _RegistroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          child: Icon(
            Icons.fingerprint,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Registrarme",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }
}

// Widget para el formulario del registro
class _RegistroForm extends StatefulWidget {
  const _RegistroForm();

  @override
  State<_RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<_RegistroForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _nombreUsuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  DateTime? _fechaNacimiento;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _nombreUsuarioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _descripcionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Mostrar selector de fecha
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  // Mostrar diálogo de verificación
  void _mostrarDialogoVerificacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Verificación requerida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_email_read,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Hemos enviado un correo electrónico de verificación. Por favor, verifica tu cuenta para poder iniciar sesión.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/verificacion');
              },
            ),
          ],
        );
      },
    );
  }

  // Registrar usuario
  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreServices = FirestoreServices();
      await firestoreServices.registrarUsuario(
        nombre: _nombreController.text.trim(),
        nombreUsuario: _nombreUsuarioController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        descripcion: _descripcionController.text.trim(),
        fechaNacimiento: _fechaNacimiento,
        numeroTelefono: _telefonoController.text.trim(),
      );
      
      if (mounted) {
        _mostrarDialogoVerificacion();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nombre completo
          TextFormField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              prefixIcon: Icon(Icons.person, color: theme.iconTheme.color),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa tu nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Nombre de usuario
          TextFormField(
            controller: _nombreUsuarioController,
            decoration: InputDecoration(
              labelText: 'Nombre de usuario',
              prefixIcon: Icon(Icons.alternate_email, color: theme.iconTheme.color),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa un nombre de usuario';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email, color: theme.iconTheme.color),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa tu correo electrónico';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.iconTheme.color,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa una contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirmar contraseña
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.iconTheme.color,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, confirma tu contraseña';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Descripción (opcional)
          TextFormField(
            controller: _descripcionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              prefixIcon: Icon(Icons.description, color: theme.iconTheme.color),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fecha de nacimiento
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento (opcional)',
                prefixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
              child: Text(
                _fechaNacimiento == null
                    ? 'Seleccionar fecha'
                    : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                style: TextStyle(color: _fechaNacimiento == null ? Colors.grey : null),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Teléfono (opcional)
          TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Número de teléfono (opcional)',
              prefixIcon: Icon(Icons.phone, color: theme.iconTheme.color),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Botón de registro
          ElevatedButton(
            onPressed: _isLoading ? null : _registrarUsuario,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Registrarme', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// Widget para el footer del registro
class _RegistroFooter extends StatelessWidget {
  const _RegistroFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Ya tienes una cuenta?',
              style: TextStyle(color: Colors.grey[700]),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          'Al registrarte, aceptas nuestros términos y condiciones',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}