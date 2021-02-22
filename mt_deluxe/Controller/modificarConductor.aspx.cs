using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_modificarConductor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(!IsPostBack)
            datos();
    }

    protected void B_ModificarCl_Click(object sender, EventArgs e)
    {
        Conductor conductor = new Conductor();

        conductor.IdConductor = ((Conductor)Session["user"]).IdConductor;

        object s = Session["user"] = conductor;
        if (s != null)
        {
            conductor.Nombre = TB_MF_NombreCo.Text;
            conductor.Apellido = TB_MF_ApellidoCo.Text;
            conductor.FechaDeNacimiento = DateTime.Parse(TB_MF_FechaNacCo.Text);
            conductor.Email = TB_MF_CorreoCo.Text;
            conductor.Placa = TB_MF_PlacaCo.Text;
            conductor.Celular = TB_MF_CelularCo.Text;
            conductor.Usuario = TB_MF_UsuarioCo.Text;
            conductor.Contrasena = TB_MF_ContraseñaCo.Text;
            conductor.Modificado = ((Conductor)Session["user"]).Usuario;

            new DaoConductor().modificarConductor(conductor);

            Response.Redirect("modificarConductor.aspx");
        }
    }

    public void datos()
    {
        DaoConductor dco = new DaoConductor();
        Conductor conductor = new Conductor();

        conductor = dco.mostrarRegistro(((Conductor)Session["user"]).IdConductor);
        TB_MF_NombreCo.Text = conductor.Nombre;
        TB_MF_ApellidoCo.Text = conductor.Apellido;
        TB_MF_FechaNacCo.Text = conductor.FechaDeNacimiento.ToString();
        TB_MF_CorreoCo.Text = conductor.Email;
        TB_MF_PlacaCo.Text = conductor.Placa;
        TB_MF_CelularCo.Text = conductor.Celular;
        TB_MF_Cedula.Text = conductor.Cedula;
        TB_MF_UsuarioCo.Text = conductor.Usuario;
        TB_MF_ContraseñaCo.Text = conductor.Contrasena;
    }
}