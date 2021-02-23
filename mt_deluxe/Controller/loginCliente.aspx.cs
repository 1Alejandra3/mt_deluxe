using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Utilitarios;
using Data;
using Logica;

public partial class View_loginCliente : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    protected void Login_Cliente_Authenticate(object sender, AuthenticateEventArgs e)
    {
        Cliente cliente = new Cliente();
        cliente.Usuario = Login_Cliente.UserName;
        cliente.Contrasena = Login_Cliente.Password;

        cliente = new DaoCliente().login(cliente);
        ((Label)Login_Cliente.FindControl("LN_Mensaje")).Text = new LCliente().login(cliente);

        MAC conexion = new MAC();
        AccesoCliente acceso = new AccesoCliente();

        object s = Session["user"] = cliente; //Variable llena (Se inicio sesión)

        if(s != null)
        {
            Session["user"] = cliente;

            acceso.FechaInicio = DateTime.Now;
            acceso.Ip = conexion.ip();
            acceso.Mac = conexion.mac();
            acceso.Session = Session.SessionID;
            acceso.IdCliente = cliente.IdCliente;

            new DaoSeguridadCliente().insertarAcceso(acceso);
        }

        
    }

    protected void LB_Recuperacion_Contraseña_Click(object sender, EventArgs e)
    {
        Response.Redirect("GenerarTokenCliente.aspx");
    }
}