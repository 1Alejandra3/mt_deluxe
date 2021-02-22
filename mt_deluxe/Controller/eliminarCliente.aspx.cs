using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_eliminarCliente : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Cliente cliente = new Cliente();
        
        object s = Session["user"];
        if (s != null)
        {
            cliente.IdCliente = ((Cliente)Session["user"]).IdCliente;
            new DaoCliente().eliminarCliente(cliente);
            Session["user"] = null;
            Response.Redirect("loginCliente.aspx");
        }
    }
}