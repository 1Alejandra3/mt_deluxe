using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_cerrarSesionCo : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        new DaoSeguridadConductor().cerrarAcceso(((Conductor)Session["user"]).IdConductor);

        Session["user"] = null;
        Response.Redirect("loginConductor.aspx");
    }
}