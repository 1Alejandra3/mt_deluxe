using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_modificarCliente : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            datos();
    }

    protected void B_ModificarCl_Click(object sender, EventArgs e)
    {
        Cliente cliente = new Cliente();

        cliente.IdCliente = ((Cliente)Session["user"]).IdCliente;

        object s = Session["user"] = cliente;
        if (s != null)
        {
            cliente.Nombrecl = TB_MF_NombreCl.Text;
            cliente.Apellido = TB_MF_ApellidoCl.Text;
            cliente.FechaDeNacimiento = DateTime.Parse(TB_MF_FechaNacCl.Text);
            cliente.Email = TB_MF_CorreoCl.Text;
            cliente.Usuario = TB_MF_UsuarioCl.Text;
            cliente.Contrasena = TB_MF_ContraseñaCl.Text;
            cliente.Modificado = ((Cliente)Session["user"]).Usuario;

            new DaoCliente().modificarCliente(cliente);

            Response.Redirect("modificarCliente.aspx");
        }
    }

    public void datos()
    {
        DaoCliente dcl = new DaoCliente();
        Cliente cliente = new Cliente();

        cliente = dcl.mostrarRegistro(((Cliente)Session["user"]).IdCliente);
        TB_MF_NombreCl.Text = cliente.Nombrecl;
        TB_MF_ApellidoCl.Text = cliente.Apellido;
        TB_MF_FechaNacCl.Text = cliente.FechaDeNacimiento.ToString();
        TB_MF_CorreoCl.Text = cliente.Email;
        TB_MF_UsuarioCl.Text = cliente.Usuario;
        TB_MF_ContraseñaCl.Text = cliente.Contrasena;
    }
}