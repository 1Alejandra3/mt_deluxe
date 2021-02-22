using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_RecuperarCliente : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString.Count > 0)
        {
            TokenCliente token = new DaoSeguridadCliente().getTokenByToken(Request.QueryString[0]);

            if (token == null)
                  this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('El Token es invalido. Genere uno nuevo');window.location=\"loginCliente.aspx\"</script>");

            else if (token.Vigencia < DateTime.Now)
                this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('El Token esta vencido. Genere uno nuevo');window.location=\"loginCliente.aspx\"</script>");
            else
                Session["user_id"] = token.IdCliente;
        }

        else
            Response.Redirect("loginCliente.aspx");
    }

    protected void B_Cambiar_Click(object sender, EventArgs e)
    {
        Cliente cliente = new Cliente();
        cliente.IdCliente = int.Parse(Session["user_id"].ToString());
        cliente.Contrasena = Tb_Contraseña.Text;

        new DaoSeguridadCliente().updateClave(cliente);

        this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('Su contraseña fue actualizada');window.location=\"loginCliente.aspx\"</script>");

    }
}