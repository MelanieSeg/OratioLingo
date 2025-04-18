package com.example.oratiolingo

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import com.example.oratiolingo.databinding.ActivityPantallaPrincipalBinding
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.Firebase
import com.google.firebase.auth.auth

class PantallaNiveles : AppCompatActivity() {
    private lateinit var binding: ActivityPantallaPrincipalBinding
    private lateinit var auth: FirebaseAuth
    private var logoutDialog: AlertDialog? = null // Para manejar el estado del modal

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityPantallaPrincipalBinding.inflate(layoutInflater)
        auth = Firebase.auth
        setContentView(binding.root)


        // Imagen que abre/cierra el modal
        binding.imgPerfil.setOnClickListener {
            if (logoutDialog?.isShowing == true) {
                logoutDialog?.dismiss()
            } else {
                val dialogView = layoutInflater.inflate(R.layout.activity_modal_pefil, null)
                logoutDialog = AlertDialog.Builder(this)
                    .setView(dialogView)
                    .create()

                val btnCerrarSesion = dialogView.findViewById<Button>(R.id.btnCerrarSesion)
                btnCerrarSesion.setOnClickListener {
                    cerrarSesion()
                    logoutDialog?.dismiss()
                }

                logoutDialog?.show()
            }
        }

        binding.lnlProgreso.setOnClickListener{
            abrirPantallaProgreso()
            Log.d("PantallaPrincipal", "Botón Progreso presionado")
        }

        binding.lnlJuegos.setOnClickListener{
            abrirPantallaJuegos()
        }

        binding.lnlVideos.setOnClickListener {
            abrirPantallaVideos()
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


    private fun abrirPantallaProgreso(){
        val intent = Intent(this, PantallaProgreso::class.java)
        startActivity(intent)
    }


    private fun abrirPantallaJuegos(){
        val intent = Intent(this, PantallaJuegos::class.java)
        startActivity(intent)
    }

    private fun abrirPantallaVideos(){
        val intent = Intent(this, PantallaVideos::class.java)
        startActivity(intent)
    }
}
