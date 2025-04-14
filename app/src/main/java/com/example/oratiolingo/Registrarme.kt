package com.example.oratiolingo

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.oratiolingo.databinding.ActivityRegistrarmeBinding
import com.google.firebase.Firebase
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.auth
import android.util.Log as log

class Registrarme : AppCompatActivity() {
    private lateinit var binding: ActivityRegistrarmeBinding
    private lateinit var auth: FirebaseAuth
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityRegistrarmeBinding.inflate(layoutInflater)
        setContentView(binding.root)
        auth = Firebase.auth // Inicializar la variable de autenticación de Firebase




        //Validaciones
        binding.btnRegistrar.setOnClickListener {


            //Variables
            val email = binding.etEmail.text.toString()
            val password = binding.etPassword.text.toString()
            val confirmarPassword = binding.etConfirmarPassword.text.toString()

            if (email.isEmpty()) {
                binding.etEmail.error = "Ingrese su correo"
                return@setOnClickListener
            }
            if (password.isEmpty()) {
                binding.etPassword.error = "Ingrese la contraseña"
                return@setOnClickListener
            }
            if (confirmarPassword.isEmpty()) {
                binding.etConfirmarPassword.error = "Ingrese la contraseña"
                return@setOnClickListener
            }
            if (password != confirmarPassword) {
                binding.etConfirmarPassword.error = "Las contraseñas no coinciden"
                return@setOnClickListener
            }
            signUp(email, password)
        }

    }

    fun signUp(email: String, password: String){
        auth.createUserWithEmailAndPassword(email,password)
            .addOnCompleteListener(this){
                if (it.isSuccessful){
                    Toast.makeText(this, "Registro exitoso", Toast.LENGTH_SHORT).show()
                    val pantallaMain = Intent(this, MainActivity::class.java)
                    startActivity(pantallaMain)
                }else{
                    Toast.makeText(this, "Error", Toast.LENGTH_SHORT).show()
                }
            }
    }
}