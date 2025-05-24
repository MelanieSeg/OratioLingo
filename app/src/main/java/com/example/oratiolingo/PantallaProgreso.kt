package com.example.oratiolingo

import android.app.AlertDialog
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.Firebase
import com.google.firebase.auth.auth
import android.content.Intent
import android.widget.Button
import com.example.oratiolingo.databinding.ActivityPantallaProgresoBinding

class PantallaProgreso : AppCompatActivity() {
    private lateinit var binding: ActivityPantallaProgresoBinding
    private lateinit var auth: FirebaseAuth
    private var logoutDialog: AlertDialog? = null // Para manejar el estado del modal
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        auth = Firebase.auth
        binding = ActivityPantallaProgresoBinding.inflate(layoutInflater)
        setContentView(binding.root)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }


        //Llamada al modal de perfil
        binding.imgPerfil.setOnClickListener{
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

                val btnEditarPerfil = dialogView.findViewById<Button>(R.id.btnEditarPerfil)
                btnEditarPerfil.setOnClickListener {
                    // Acción para editar perfil
                    abrirEditarPerfil()
                    logoutDialog?.dismiss()
                }

                logoutDialog?.show()
            }
        }


        binding.lnlNiveles.setOnClickListener{
            abrirPantallaNiveles()
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

    private fun abrirPantallaJuegos(){
        val intent = Intent(this, PantallaJuegos::class.java)
        startActivity(intent)

    }

    private fun abrirPantallaVideos(){
        val intent = Intent(this, PantallaVideos::class.java)
        startActivity(intent)
    }

    private fun abrirPantallaNiveles(){
        val intent = Intent(this, PantallaNiveles::class.java)
        startActivity(intent)
    }

    private fun abrirEditarPerfil(){
        val intent = Intent(this, PantallaPerfil::class.java)
        startActivity(intent)

    }

}