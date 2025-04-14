package com.example.oratiolingo

import android.content.Intent
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.oratiolingo.databinding.ActivityPantallaPrincipalBinding
import com.google.firebase.Firebase
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.auth

class PantallaPrincipal : AppCompatActivity() {
    private lateinit var binding: ActivityPantallaPrincipalBinding // Declarar la variable de enlace
    private lateinit var auth: FirebaseAuth // Declarar la variable de autenticación de Firebase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityPantallaPrincipalBinding.inflate(layoutInflater) // Inflar la vista utilizando el enlace de vista para que sirve?
        auth = Firebase.auth // Inicializar la variable de autenticación de Firebase
        setContentView(binding.root)


        binding.btnCerrarSesion.setOnClickListener {
            auth.signOut()

            if (auth.currentUser == null) {
                val intent = Intent(this, MainActivity::class.java)
                startActivity(intent)
                finish()
            }
        }


    }
}

