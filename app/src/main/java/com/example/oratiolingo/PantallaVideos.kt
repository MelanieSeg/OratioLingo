package com.example.oratiolingo

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.oratiolingo.databinding.ActivityPantallaVideosBinding
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.Firebase
import com.google.firebase.auth.auth
import kotlin.math.log

class PantallaVideos : AppCompatActivity() {
    private lateinit var binding: ActivityPantallaVideosBinding
    private lateinit var auth: FirebaseAuth
    private var logoutDialog: AlertDialog? = null // Para manejar el estado del modal


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityPantallaVideosBinding.inflate(layoutInflater)
        auth = Firebase.auth
        setContentView(binding.root)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }


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
        }

        binding.lnlJuegos.setOnClickListener{
            abrirPantallaJuegos()
        }

        binding.lnlNiveles.setOnClickListener {
            abrirPantallaNiveles()

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

    private fun abrirPantallaJuegos() {
        val intent = Intent(this, PantallaJuegos::class.java)
        startActivity(intent)
    }


    private fun abrirPantallaNiveles(){
        val intent = Intent(this, PantallaNiveles::class.java)
        startActivity(intent)
    }

}