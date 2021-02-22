using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;
using System.Data;
using Newtonsoft.Json;
using System.Text;
using Telegram.Bot;

public partial class View_conductor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.AppRelativeVirtualPath.Contains("loginConductor.aspx")) //Alguien digitó URL
        {
            Response.Cache.SetNoStore(); //Navegador no almacena pagina en cache
            if (Session["user"] == null)
                Response.Redirect("loginConductor.aspx");
        }
        else
        {
            Response.Redirect("conductor.aspx");
        }

        //if (Session["user"] != null)
        //{
        //    Response.Redirect("loginConductor.aspx");

        //    if ((Conductor)Session["user"] != null)
        //        Response.Redirect("conductor.aspx");
        //}

        if (!IsPostBack)
        {
            Conductor conductor = new Conductor();
            LB_NombreCo.Text = ((Conductor)Session["user"]).Nombre;
            LB_ApellidoCo.Text = ((Conductor)Session["user"]).Apellido;

            validacion();
            off();
        }
    }

    public void validacion()
    {
        if (((Conductor)Session["user"]).IdEstado == 1)
        {
            LB_Estado.Text = "Disponible";
            LB_Estado.ForeColor = Color.FromArgb(71, 181, 31);
        }
        else
        {
            if (((Conductor)Session["user"]).IdEstado == 2)
            {
                LB_Estado.Text = "Ocupado";
                LB_Estado.ForeColor = Color.FromArgb(250, 0, 0);
            }
            else
            {
                if (((Conductor)Session["user"]).IdEstado == 3)
                {
                    LB_Estado.Text = "Fuera de línea";
                    LB_Estado.ForeColor = Color.FromArgb(32, 42, 188);
                }
            }
        }
    }

    public void off()
    {
        L_Estado.Visible = true;
        LB_Estado.Visible = true;
        DDL_Estado.Visible = true;
        BG_Estado.Visible = true;

        L_Historial.Visible = false;
        Tabla_HistorialCarreras.Visible = false;
        L_Aceptado.Visible = false;

        L_Carreras.Visible = false;
        Tabla_Carreras.Visible = false;
        B_Ganancias.Visible = false;
        L_Pesos.Visible = false;
        L_Ganancias.Visible = false;
        L_Fecha.Visible = false;
        TextBoxfiltrar.Visible = false;

        B_ReportHistorial.Visible = false;
        CRV_HistorialConductor.Visible = false;
        L_HistorialCo.Visible = false;
    }

    protected void B_Ingreso_Estado_Click(object sender, EventArgs e)
    {
        L_Estado.Visible = true;
        LB_Estado.Visible = true;
        DDL_Estado.Visible = true;
        BG_Estado.Visible = true;

        L_Historial.Visible = false;
        Tabla_HistorialCarreras.Visible = false;
        L_Aceptado.Visible = false;

        L_Carreras.Visible = false;
        Tabla_Carreras.Visible = false;
        B_Ganancias.Visible = false;
        L_Pesos.Visible = false;
        L_Ganancias.Visible = false;
        L_Fecha.Visible = false;
        TextBoxfiltrar.Visible = false;

        B_ReportHistorial.Visible = false;
        CRV_HistorialConductor.Visible = false;
        L_HistorialCo.Visible = false;
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        Conductor conductor = new Conductor();

        conductor.IdConductor = ((Conductor)Session["user"]).IdConductor;

        object s = Session["user"] = conductor;
        if (s != null)
        {
            conductor.IdEstado = int.Parse(DDL_Estado.SelectedValue);

            new DaoConductor().estadoConductor(conductor);
        }

        validacion();
        DDL_Estado.ClearSelection();

        L_Estado.Visible = true;
        LB_Estado.Visible = true;
        DDL_Estado.Visible = true;
        BG_Estado.Visible = true;
    }

    protected void B_ComentarCl_Click(object sender, EventArgs e)
    {
        L_Estado.Visible = false;
        LB_Estado.Visible = false;
        DDL_Estado.Visible = false;
        BG_Estado.Visible = false;

        L_Carreras.Visible = true;
        Tabla_Carreras.Visible = true;
        B_Ganancias.Visible = true;
        L_Pesos.Visible = true;
        L_Ganancias.Visible = true;
        L_Fecha.Visible = true;
        TextBoxfiltrar.Visible = true;

        L_Historial.Visible = false;
        Tabla_HistorialCarreras.Visible = false;
        L_Aceptado.Visible = false;

        B_ReportHistorial.Visible = true;
        CRV_HistorialConductor.Visible = false;
        L_HistorialCo.Visible = true;
    }

    protected void B_Historial_Click(object sender, EventArgs e)
    {
        L_Estado.Visible = false;
        LB_Estado.Visible = false;
        DDL_Estado.Visible = false;
        BG_Estado.Visible = false;

        L_Historial.Visible = true;
        Tabla_HistorialCarreras.Visible = true;
        L_Aceptado.Visible = true;

        L_Carreras.Visible = false;
        Tabla_Carreras.Visible = false;
        B_Ganancias.Visible = false;
        L_Pesos.Visible = false;
        L_Ganancias.Visible = false;
        L_Fecha.Visible = false;
        TextBoxfiltrar.Visible = false;
        B_ReportHistorial.Visible = false;
        CRV_HistorialConductor.Visible = false;
        L_HistorialCo.Visible = false;
    }

    protected void Tabla_HistorialCarreras_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string[] variables = new string[2];

        variables = e.CommandArgument.ToString().Split(';');

        var IdC = variables[0];
        var IdN = variables[1];

        int idCliente = Convert.ToInt32(IdC);
        int idNotificacion = Convert.ToInt32(IdN);

        Correo correo = new Correo();
        Cliente cliente = new Cliente();

        cliente = new DaoConductor().buscarEmail(idCliente);

        //telegram tl = new telegram();

        String mensaje = "Su Servicio a sido confirmado por favor espere unos minutos, ya uno de nuestros conductores se acerca al lugar que se solicito";
        correo.enviarCorreoNotificacion(cliente.Email, mensaje);

        L_Aceptado.Text = "Servicio Aceptado";

        Notificacion notificacion = new Notificacion();

        notificacion = new DaoConductor().buscarId(idNotificacion);

        notificacion.Estado = "Aceptado";
        notificacion.Conductor = ((Conductor)Session["user"]).Nombre;
        notificacion.IdConductor = ((Conductor)Session["user"]).IdConductor;
        new DaoConductor().aceptarServicio(notificacion);

        Tabla_HistorialCarreras.DataBind();
    }

    protected void B_Ganancias_Click(object sender, EventArgs e)
    {
        try
        {
            Notificacion notificacion = new Notificacion();

            notificacion.IdConductor = ((Conductor)Session["user"]).IdConductor;

            double suma = new DaoConductor().ganancias(notificacion);
            double ganancia = suma * 0.25;

            L_Ganancias.Text = ganancia.ToString();

            B_Ganancias.Visible = true;
            L_Pesos.Visible = true;
            L_Ganancias.Visible = true;
        }
        catch (Exception ex)
        {
            L_Ganancias.Text = "No tiene ganancias";
        }
    }

    protected void Tabla_Carreras_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        DateTime fechaCarrera = DateTime.Parse(e.OldValues["FechaCarrera"].ToString());
        e.NewValues.Insert(1, "FechaCarrera", fechaCarrera);
    }

    protected void B_ReportHistorial_Click(object sender, EventArgs e)

    {
        try
        {
            Notificacion notificacion = new Notificacion();
            CRS_Historial.ReportDocument.SetDataSource(reporte(notificacion));
            CRV_HistorialConductor.ReportSource = CRS_Historial;

            CRV_HistorialConductor.Visible = true;
        }
        catch (Exception ex)
        {
            L_HistorialCo.Text = "No hay historial para mostrar";
        }

        CRV_HistorialConductor.Visible = true;
    }

    protected HistorialConductor reporte(Notificacion notificacion)
    {
        HistorialConductor informe = new HistorialConductor();
        List<Notificacion> factura = new DaoConductor().reporteHistorial(notificacion);

        DataTable datosFinal = informe.Historial;
        DataRow fila;

        foreach (var item in factura)
        {
            fila = datosFinal.NewRow();
            fila["NombreConductor"] = ((Conductor)Session["user"]).Nombre;
            fila["NombreCliente"] = item.NombreCl;
            fila["Destino"] = item.Destino;
            fila["Ubicacion"] = item.Ubicacion;
            fila["Tarifa"] = item.Tarifa;
            fila["FechaCarrera"] = item.FechaCarrera;
            datosFinal.Rows.Add(fila);
        }

        return informe;
    }

    protected void Tabla_Carreras_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Enviar")
        {
            int idNotificacion = Convert.ToInt32(e.CommandArgument);

            Notificacion notificacion = new DaoConductor().buscarId(idNotificacion);

            //Captura la fila
            int numFila = ((GridViewRow)((LinkButton)e.CommandSource).Parent.Parent).RowIndex;

            //Busca el control TextBox
            TextBox tb_conversar = (Tabla_Carreras.Rows[numFila].Cells[20].FindControl("TB_Conversar") as TextBox);

            //Obtiene valor
            string mensaje = tb_conversar.Text;

            notificacion.Conversacion = ("Conductor " + ((Conductor)Session["user"]).Nombre + ": " + mensaje);
            new DaoConductor().coversar(notificacion);

            Tabla_Carreras.DataBind();
            //this.RegisterStartupScript("<script type='text/javascript'> window.setInterval(, milliseconds)</script>");
        }
    }


    protected void CRV_HistorialConductor_Init(object sender, EventArgs e)
    {

    }
}   


