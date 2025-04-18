package com.example.oratiolingo

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import com.example.oratiolingo.databinding.ActivityMainBinding
import com.google.firebase.Firebase
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.auth

class MainActivity  : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding // Declarar la variable de enlace
    private lateinit var auth: FirebaseAuth // Declarar la variable de autenticación de Firebase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityMainBinding.inflate(layoutInflater) // Inflar la vista utilizando el enlace de vista para que sirve?
        auth = Firebase.auth // Inicializar la variable de autenticación de Firebase
        setContentView(binding.root) // Establecer la vista raíz en la actividad

        val tvRegistrar = binding.tvRegistrar

        tvRegistrar.setOnClickListener {
            val intent = Intent(this, Registrarme::class.java)
            startActivity(intent)
        }


        binding.btnLogin.setOnClickListener {
            //Obtener el correo
            val email = binding.etEmail.text.toString()
            //Obtener la contraseña
            val password = binding.etPassword.text.toString()

            if (email.isEmpty()){
                binding.etEmail.error = "Ingrese su correo"
                return@setOnClickListener
            }
            if (password.isEmpty()){
                binding.etPassword.error = "Ingrese la contraseña"
            }

            signIn(email, password)

        }
    }
    fun signIn(email: String, password: String){
        auth.signInWithEmailAndPassword(email,password)
            .addOnCompleteListener(this){
                if (it.isSuccessful){
                    Toast.makeText(this, "Bienvenido", Toast.LENGTH_SHORT).show()
                    val intent = Intent(this, PantallaNiveles::class.java)
                    startActivity(intent)
                    finish()
                }else{
                    Toast.makeText(this, "Error", Toast.LENGTH_SHORT).show()
                }
            }
    }


}