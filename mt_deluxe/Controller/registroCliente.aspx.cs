using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Utilitarios;
using Data;
using Logica;

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
            Redireccionamiento red = new LRegistroCliente().registro(cliente);

            TB_UsuarioCl.Text = red.TbUsuario;

            L_ExisteUsuario.Text = red.Mensaje;
            TB_NombreCl.Text = red.TbNombre;
            TB_ApellidoCl.Text = red.TbApellido;
            red.TbFechaNacimiento = DateTime.Parse(TB_FechaNacimientoCl.Text);
            TB_CorreoCl.Text = red.TbCorreo;
            TB_UsuarioCl.Text = red.TbUsuario;
            TB_ContraseñaCl.Text = red.TbContraseña;
        }
        catch (Exception ex)
        {
            return;
        }
    }
}