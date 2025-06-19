class PasswordValidator {
  /// Valida una contraseña según los criterios de seguridad
  ///
  /// Retorna null si la contraseña es válida o un mensaje de error si no cumple los criterios
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa una contraseña';
    }

    // Longitud mínima
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Validación de mayúsculas
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe incluir al menos una letra mayúscula';
    }

    // Validación de minúsculas
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe incluir al menos una letra minúscula';
    }

    // Validación de números
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe incluir al menos un número';
    }

    // Validación de caracteres especiales
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Debe incluir al menos un caracter especial';
    }

    return null;
  }

  /// Texto de ayuda para las contraseñas
  static const String helperText =
      'Mínimo 8 caracteres, incluir mayúsculas, minúsculas, números y caracteres especiales';
}
