package com.example.oratiolingo

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SwitchCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.oratiolingo.databinding.ActivityPantallaPerfilBinding
import com.google.firebase.Firebase
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.auth

class PantallaPerfil : AppCompatActivity() {
    private lateinit var binding: ActivityPantallaPerfilBinding
    private var auth: FirebaseAuth = Firebase.auth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityPantallaPerfilBinding.inflate(layoutInflater)
        auth = Firebase.auth
        setContentView(binding.root)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        // Cargar información del usuario
        cargarInformacionUsuario()

        // Configurar botón de cerrar sesión
        binding.btnLogout.setOnClickListener {
            cerrarSesion()
        }

        // Configurar botón de editar perfil
        binding.fabEditProfile.setOnClickListener {
            // Implementar la funcionalidad para editar perfil
            // Por ejemplo, navegar a una pantalla de edición
        }

        // Configurar switch de notificaciones
        binding.switchNotifications.setOnCheckedChangeListener { _, isChecked ->
            // Guardar preferencia de notificaciones
            // Ejemplo: SharedPreferences
        }

        // Configurar switch de tema nocturno
        binding.switchDarkTheme.setOnCheckedChangeListener { _, isChecked ->
            // Cambiar tema de la aplicación
            // Ejemplo: AppCompatDelegate.setDefaultNightMode()
        }

        // Configurar botón de cambiar contraseña
        binding.btnChangePassword.setOnClickListener {
            // Implementar la funcionalidad para cambiar contraseña
            // Por ejemplo, mostrar un diálogo
        }

        // Configurar navegación
        setupBottomNavigation()
    }

    private fun cargarInformacionUsuario() {
        val currentUser = auth.currentUser
        currentUser?.let { user ->
            // Cargar información del usuario
            binding.txtUsername.text = user.displayName ?: "Usuario"
            binding.txtEmail.text = user.email
            binding.txtUserEmail.text = user.email
            binding.txtName.text = user.displayName ?: "Usuario"

            // Fecha de registro (esto es solo un ejemplo, podrías obtenerlo de Firestore)
            // También puedes usar user.metadata.creationTimestamp para obtener la fecha de creación
            // binding.txtRegistrationDate.text = "Se unió por primera vez el 10 de febrero del 2020"
        }
    }

    private fun cerrarSesion() {
        auth.signOut()
        if (auth.currentUser == null) {
            val intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
            finish()
        }
    }

    private fun setupBottomNavigation() {
        binding.lnlNiveles.setOnClickListener {
            abrirPantallaNiveles()
        }

        binding.lnlVideos.setOnClickListener {
            abrirPantallaVideos()
        }

        binding.lnlJuegos.setOnClickListener {
            abrirPantallaJuegos()
        }

        binding.lnlProgreso.setOnClickListener {
            abrirPantallaProgreso()
        }
    }

    private fun abrirPantallaNiveles() {
        val intent = Intent(this, PantallaNiveles::class.java)
        startActivity(intent)
    }

    private fun abrirPantallaVideos() {
        val intent = Intent(this, PantallaVideos::class.java)
        startActivity(intent)
    }

    private fun abrirPantallaJuegos() {
        val intent = Intent(this, PantallaJuegos::class.java)
        startActivity(intent)
    }

    private fun abrirPantallaProgreso() {
        val intent = Intent(this, PantallaProgreso::class.java)
        startActivity(intent)
    }
}