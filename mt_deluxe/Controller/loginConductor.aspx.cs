using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_loginConductor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void Login_Conductor_Authenticate1(object sender, AuthenticateEventArgs e)
    {
        Conductor conductor = new Conductor();
        conductor.Usuario = Login_Conductor.UserName;
        conductor.Contrasena = Login_Conductor.Password;

        conductor = new DaoConductor().login(conductor);
        MAC conexion = new MAC();
        AccesoConductor accesoc = new AccesoConductor();

        object s = Session["user"] = conductor; //Variable llena (Se inicio sesión)

        if (s != null)
        {
            Session["user"] = conductor;

            accesoc.FechaInicio = DateTime.Now;
            accesoc.Ip = conexion.ip();
            accesoc.Mac = conexion.mac();
            accesoc.Session = Session.SessionID;
            accesoc.IdConductor = conductor.IdConductor;
            new DaoSeguridadConductor().insertarAcceso(accesoc);
        }

        if ((conductor == null) || (conductor.Sesion.Equals("inactivo")) || (conductor.Sesion.Equals("espera")))
        {
            ((Label)Login_Conductor.FindControl("LN_Mensaje")).Text = "Usuario o clave incorrecta";
            Session["user"] = null; //Variable vacia (No ha iniciado sesión)

        }
        else
        {
            if (s != null)
                Response.Redirect("conductor.aspx");
        }
    }

    protected void LB_Recuperacion_Contraseña_Click(object sender, EventArgs e)
    {
        Response.Redirect("GenerarTokenConductor.aspx");
    }
}