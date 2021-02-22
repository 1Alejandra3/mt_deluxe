using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_cerrarSesionA : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Session["user"] = null;
        Response.Redirect("loginAdministrador.aspx");
    }
}