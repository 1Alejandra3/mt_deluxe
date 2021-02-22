using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_eliminarConductor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Conductor conductor = new Conductor();

        object s = Session["user"];
        if (s != null)
        {
            conductor.IdConductor = ((Conductor)Session["user"]).IdConductor;
            new DaoConductor().eliminarConductor(conductor);
            Session["user"] = null;
            Response.Redirect("loginConductor.aspx");
        }
    }
}