using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_registroConductor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void B_Registrar_Co_Click(object sender, EventArgs e)
    {
        try
        {
            Conductor conductor = new Conductor();

            conductor.Usuario = TB_UsuarioCo.Text;
            conductor = new DaoConductor().validarExistencia(conductor);
            
            if (conductor != null)
            {
                L_ExisteUsuario.Text = "Usuario existente, porfavor intente con otro";
            }
            else if (conductor == null)
            {
                conductor = new Conductor();
                conductor.Nombre = TB_NombreCo.Text;
                conductor.Apellido = TB_ApellidoCo.Text;
                conductor.FechaDeNacimiento = DateTime.Parse(TB_FechaCo.Text);
                conductor.Email = TB_EmailCo.Text;
                conductor.Placa = TB_PlacaCo.Text;
                conductor.Celular = TB_CelularCo.Text;
                conductor.Usuario = TB_UsuarioCo.Text;
                conductor.Contrasena = TB_ContraseñaCo.Text;
                conductor.Modificado = "motodeluxe";
                conductor.Sesion = "espera";
                conductor.IdEstado = 3;
                conductor.Cedula = TB_CedulaCo.Text;

                new DaoConductor().inserConductor(conductor);
                this.RegisterStartupScript("mensaje", "<script type='text/javascript'>alert('Su usuario se encuentra en proceso de validación (busqueda de infracciones de transito), en las proximas 24 horas se le enviará una notificación a su correo informando si fue aceptado o rechazado');window.location=\"loginConductor.aspx\"</script>");
            }
        }
        catch (Exception ex)
        {
            return;
        }
    }
}