using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_registroCliente : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void B_Registrar_Click(object sender, EventArgs e)
    {
        try
        {
            Cliente cliente = new Cliente();

            cliente.Usuario = TB_UsuarioCl.Text;
            cliente = new DaoCliente().validarExistencia(cliente);

            if (cliente != null)
            {
                L_ExisteUsuario.Text = "Usuario existente, porfavor intente con otro";
            }
            else if (cliente == null)
            {
                cliente = new Cliente();
                cliente.Nombrecl = TB_NombreCl.Text;
                cliente.Apellido = TB_ApellidoCl.Text;
                cliente.FechaDeNacimiento = DateTime.Parse(TB_FechaNacimientoCl.Text);
                cliente.Email = TB_CorreoCl.Text;
                cliente.Usuario = TB_UsuarioCl.Text;
                cliente.Contrasena = TB_ContraseñaCl.Text;
                cliente.Modificado = "mototaxideluxe";
                cliente.Sesion = "activo";

                new DaoCliente().inserCliente(cliente);
                this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('Su usuario a sido registrado con exito');window.location=\"loginCliente.aspx\"</script>");
            }
        }
        catch (Exception ex)
        {
            return;
        }
    }
}