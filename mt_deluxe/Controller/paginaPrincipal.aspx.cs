using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_paginaPrincipal : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void IB_Cliente_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("loginCliente.aspx");
    }

    protected void IB_Conductor_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("loginConductor.aspx");
    }

    protected void IB_Administrador_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("loginAdministrador.aspx");
    }
}