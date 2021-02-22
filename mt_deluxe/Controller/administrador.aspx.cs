using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_administrador : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.AppRelativeVirtualPath.Contains("loginAdministrador.aspx"))
        {
            Response.Cache.SetNoStore(); //Navegador no almacena pagina en cache
            if (Session["user"] == null)
                Response.Redirect("loginAdministrador.aspx");
        }
        else
        {
            Response.Redirect("administrador.aspx");
        }

        //if (Session["user"] != null)
        //    Response.Redirect("loginAdministrador.aspx");

        if (!IsPostBack)
        {
            L_AceptarConductor.Visible = false;
            tabla_Conductor.Visible = false;
            L_Cliente.Visible = false;
            Tabla_cliente.Visible = false;
            L_Pago.Visible = false;
            L_ConductorNombre.Visible = false;
            DropDownListConductor.Visible = false;
            L_PendAceptar.Visible = false;

            B_guardar.Visible = false;
            tabla_SancionarCliente.Visible = false;
            tabla_SancionarConductor.Visible = false;
            L_Sancionar.Visible = false;
            Tabla_Conductores.Visible = false;

            CRV_Desprendible.Visible = false;
            Tabla_AceptarCl.Visible = false;
            L_SancAceptar.Visible = false;
        }
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        L_AceptarConductor.Visible = true;
        tabla_Conductor.Visible = true;
        L_Cliente.Visible = false;
        Tabla_cliente.Visible = false;
        L_Pago.Visible = false;
        L_ConductorNombre.Visible = false;
        DropDownListConductor.Visible = false;
        L_PendAceptar.Visible = true;
        Tabla_AceptarCl.Visible = false;

        B_guardar.Visible = false;
        tabla_SancionarCliente.Visible = false;
        tabla_SancionarConductor.Visible = false;
        L_Sancionar.Visible = false;
        Tabla_Conductores.Visible = true;

        CRV_Desprendible.Visible = false;
        L_SancAceptar.Visible = false;
    }

    protected void tabla_Conductor_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int  idConductor = Convert.ToInt32(e.CommandArgument);

        Correo correo = new Correo();
        Conductor conductor = new Conductor();

        conductor = new DaoAdministrador().buscarEmail(idConductor);

        String mensaje = "Su cuenta ya se encuentra activa, puedes ofrecer nuestros servicio a nuestros clientes";
        correo.enviarCorreoNotificacion(conductor.Email, mensaje);
        conductor.Sesion = "activo";

        new DaoAdministrador().sesionConductor(conductor);
        L_confirmacion.Text = "Solicitud Aceptado";

        tabla_Conductor.DataBind();
    }

    protected void B_Cliente_Click(object sender, EventArgs e)
    {
        L_AceptarConductor.Visible = false;
        tabla_Conductor.Visible = false;
        L_Cliente.Visible = true;
        Tabla_cliente.Visible = true;
        L_Pago.Visible = false;
        L_ConductorNombre.Visible = false;
        DropDownListConductor.Visible = false;
        B_guardar.Visible = false;
        tabla_SancionarCliente.Visible = false;
        tabla_SancionarConductor.Visible = false;
        L_Sancionar.Visible = false;
        Tabla_Conductores.Visible = false;
        CRV_Desprendible.Visible = false;
        L_PendAceptar.Visible = false;
        Tabla_AceptarCl.Visible = true;
        L_SancAceptar.Visible = true;
    }

    protected void B_pago_Click(object sender, EventArgs e)
    {
        L_AceptarConductor.Visible = false;
        tabla_Conductor.Visible = false;
        L_Cliente.Visible = false;
        Tabla_cliente.Visible = false;
        L_Pago.Visible = true;
        L_ConductorNombre.Visible = true;
        DropDownListConductor.Visible = true;
        B_guardar.Visible = true;
        tabla_SancionarCliente.Visible = false;
        tabla_SancionarConductor.Visible = false;
        L_Sancionar.Visible = false;
        Tabla_Conductores.Visible = false;
        CRV_Desprendible.Visible = false;
        L_PendAceptar.Visible = false;
        Tabla_AceptarCl.Visible = false;
        L_SancAceptar.Visible = false;
    }

    protected void B_Sancion_Click(object sender, EventArgs e)
    {
        L_AceptarConductor.Visible = false;
        tabla_Conductor.Visible = false;
        L_Cliente.Visible = false;
        Tabla_cliente.Visible = false;
        L_Pago.Visible = false;
        L_ConductorNombre.Visible = false;
        DropDownListConductor.Visible = false;
        B_guardar.Visible = false;
        tabla_SancionarCliente.Visible = true;
        tabla_SancionarConductor.Visible = true;
        L_Sancionar.Visible = true;
        Tabla_Conductores.Visible = false;
        CRV_Desprendible.Visible = false;
        L_PendAceptar.Visible = false;
        Tabla_AceptarCl.Visible = false;
        L_SancAceptar.Visible = false;
    }

    protected void tabla_SancionarConductor_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        double idCo = Convert.ToDouble(e.CommandArgument);
        
        Notificacion notificacion = new Notificacion();
        notificacion = new DaoAdministrador().buscaridConductorN(idCo);

        Conductor conductor = new Conductor();
        conductor = new DaoAdministrador().buscaridConductorCo(idCo);

        conductor.FechaSancion = DateTime.Now;
        conductor.Sesion = "sancionado";

        new DaoAdministrador().sancionConductor(conductor);
        
        Correo correo = new Correo();
        string mensaje = "Tu cuenta a sido sancionada por inconformidad de los usuarios . Espera que uno de nuestros administradores vuelva a activar tu cuenta";
        correo.enviarCorreoNotificacion(conductor.Email, mensaje);
       
        tabla_SancionarConductor.DataBind();
    }

    protected void tabla_SancionarCliente_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        double idCl = Convert.ToDouble(e.CommandArgument);
        
        Notificacion notificacion = new Notificacion();
        notificacion = new DaoAdministrador().buscaridClienteN(idCl);

        Cliente cliente = new Cliente();
        cliente = new DaoAdministrador().buscaridClienteC(idCl);

        cliente.FechaSancion = DateTime.Now;
        cliente.Sesion = "sancionado";
        

        new DaoAdministrador().sancionCliente(cliente);

        Correo correo = new Correo();
        string mensaje = "Tu cuenta a sido sancionada por inconformidad de los usuarios . Espera que uno de nuestros administradores te vuelva activar tu cuenta";
        correo.enviarCorreoNotificacion(cliente.Email, mensaje);
        
        tabla_SancionarConductor.DataBind();
    }

    protected void B_guardar_Click1(object sender, EventArgs e)
    {
        int idConductor = Convert.ToInt32(DropDownListConductor.SelectedValue);
        CRS_Desprendible.ReportDocument.SetDataSource(desprendible(idConductor));
        CRV_Desprendible.ReportSource = CRS_Desprendible;
        //CRS_Desprendible.ReportDocument.ExportToHttpResponse(ExportFormatType.PortableDocFormat, Response, true, "Desprendible.");
        CRV_Desprendible.Visible = true;
    }

    protected Pago desprendible(int idCo)
    {
        Pago informe = new Pago();
        Notificacion desprendible = new DaoAdministrador().generarDesprendible(idCo);

        DataTable datosFinal = informe.TablaPago;
        DataRow fila;

        double suma = new DaoAdministrador().ganancias(idCo);
        double ganancia = suma * 0.25;

        fila = datosFinal.NewRow();
        fila["NombreConductor"] = desprendible.NombreCo; 
        fila["ApellidoConductor"] = desprendible.ApellidoCo;
        fila["Cedula"] = desprendible.Cedula;
        fila["Placa"] = desprendible.Placa;
        fila["Tarifa"] = ganancia;

        datosFinal.Rows.Add(fila);
        return informe;
    }

    protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int idCliente = Convert.ToInt32(e.CommandArgument);

        Correo correo = new Correo();
        Cliente cliente = new Cliente();

        cliente = new DaoAdministrador().buscarEmailCl(idCliente);

        String mensaje = "Su cuenta ya a sido activa";
        correo.enviarCorreoNotificacion(cliente.Email, mensaje);
        cliente.Sesion = "activo";

        new DaoAdministrador().sancionCliente(cliente);
        L_AceptarCl.Text = "Aceptado";

        Tabla_AceptarCl.DataBind();
    }
}