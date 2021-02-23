using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Utilitarios;
using Data;
using Logica;


public partial class View_loginAdministrador : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void Login_Administrador_Authenticate1(object sender, AuthenticateEventArgs e)
    {
        Administrador administrador = new Administrador();
        administrador.Usuario = Login_Administrador.UserName;
        administrador.Contrasena = Login_Administrador.Password;

        administrador = new DaoAdministrador().login(administrador);


            ((Label)Login_Administrador.FindControl("LN_Mensaje")).Text = new LAdministrador().login(administrador);
            //Session["user"] = null; //Variable vacia (No ha iniciado sesión)
        
    }
}