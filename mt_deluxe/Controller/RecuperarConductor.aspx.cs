using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_RecuperarConductor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString.Count > 0)
        {
            TokenConductor token = new DaoSeguridadConductor().getTokenByToken(Request.QueryString[0]);

            if (token == null)
                this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('El Token es invalido. Genere uno nuevo');window.location=\"loginConductor.aspx\"</script>");

            else if (token.Vigencia < DateTime.Now)
                this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('El Token esta vencido. Genere uno nuevo');window.location=\"loginConductor.aspx\"</script>");
            else
                Session["user_id"] = token.IdConductor;
        }

        else
        Response.Redirect("loginConductor.aspx");
    }

    protected void B_Cambiar_Click(object sender, EventArgs e)
    {
        Conductor conductor = new Conductor();
        conductor.IdConductor = int.Parse(Session["user_id"].ToString());
        conductor.Contrasena = Tb_Contraseña.Text;

        new DaoSeguridadConductor().updateClave(conductor);

        this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('Su contraseña fue actualizada');window.location=\"loginConductor.aspx\"</script>");
    }
}