
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_cliente : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.AppRelativeVirtualPath.Contains("loginCliente.aspx"))
        {
            Response.Cache.SetNoStore(); //Navegador no almacena pagina en cache
            if (Session["user"] == null)
                Response.Redirect("loginCliente.aspx");
        }
        else
        {
            Response.Redirect("cliente.aspx");
        }

        //if (Session["user"] != null)
        //    Response.Redirect("loginCliente.aspx");

        if (!IsPostBack)
        {
            Cliente cliente = new Cliente();
            LB_NombreCl.Text = ((Cliente)Session["user"]).Nombrecl;
            LB_ApellidoCl.Text = ((Cliente)Session["user"]).Apellido;

            componentes();
        }
    }
    public void componentes()
    {
        LT_Servicio.Visible = true;
        L_Destino.Visible = true;
        L_Ubicacion.Visible = true;
        L_kilometros.Visible = true;
        DropDownListDestino.Visible = true;
        DropDownListUbicacion.Visible = true;
        B_Solicitud.Visible = true;
        B_Calcular.Visible = true;
        L_tarifa.Visible = true;
        TextBoxTarifa.Visible = true;
        TextBoxDescripcion.Visible = true;
        TextBoxKilometros.Visible = true;
        L_Descripcion.Visible = true;
        L_Pedido.Visible = true;
        B_Recibo.Visible = true;
        DropDownListPago.Visible = true;
        L_Pago.Visible = true;
        CRV_Factura.Visible = false;
        GV_Disponibles.Visible = true;
        Tabla_Rutas.Visible = true;

        L_Historial.Visible = false;
        Tabla_HistorialServicios.Visible = false;
        L_Fecha.Visible = false;
        TextBoxfiltrar.Visible = false;
    }

    protected void Button1_Click1(object sender, EventArgs e)
    {
        LT_Servicio.Visible = true;
        L_Destino.Visible = true;
        L_Ubicacion.Visible = true;
        L_kilometros.Visible = true;
        DropDownListDestino.Visible = true;
        DropDownListUbicacion.Visible = true;
        B_Solicitud.Visible = true;
        B_Calcular.Visible = true;
        L_tarifa.Visible = true;
        TextBoxTarifa.Visible = true;
        TextBoxKilometros.Visible = true;
        TextBoxDescripcion.Visible = true;
        L_Descripcion.Visible = true;
        L_Pedido.Visible = true;
        B_Recibo.Visible = true;
        DropDownListPago.Visible = true;
        L_Pago.Visible = true;
        CRV_Factura.Visible = false;
        L_Factura.Visible = false;
        GV_Disponibles.Visible = true;
        Tabla_Rutas.Visible = true;

        L_Historial.Visible = false;
        Tabla_HistorialServicios.Visible = false;
        L_Fecha.Visible = false;
        TextBoxfiltrar.Visible = false;
    }

    protected void B_Solicitud_Click(object sender, EventArgs e)
    {
        try
        {
            Notificacion notificacion = new Notificacion();

            notificacion.IdDestino = int.Parse(DropDownListDestino.SelectedValue);
            notificacion.IdUbicacion = int.Parse(DropDownListUbicacion.SelectedValue);
            notificacion.IdCliente = ((Cliente)Session["user"]).IdCliente;
            notificacion.Tarifa = double.Parse(TextBoxTarifa.Text);
            notificacion.DescripcionServicio = TextBoxDescripcion.Text;
            notificacion.Pago = int.Parse(DropDownListPago.SelectedValue);
            notificacion.FechaCarrera = DateTime.Now.Date;
            notificacion.Kilometro = double.Parse(TextBoxKilometros.Text);
            notificacion.Estado = "Pendiente";

            new DaoCliente().inserServicio(notificacion);

            DropDownListDestino.ClearSelection();
            DropDownListUbicacion.ClearSelection();
            DropDownListPago.ClearSelection();
            TextBoxTarifa.Text = "";
            TextBoxDescripcion.Text = "";
            TextBoxKilometros.Text = "";
            L_Pedido.Text = "Por favor espera a que uno de nuestros conductores acepte tu solictud, Recibirá un correo notificando su servicio";

            LT_Servicio.Visible = true;
            L_Destino.Visible = true;
            L_Ubicacion.Visible = true;
            DropDownListDestino.Visible = true;
            DropDownListUbicacion.Visible = true;
            DropDownListPago.Visible = true;
            L_Pago.Visible = true;
            B_Solicitud.Visible = true;
            B_Calcular.Visible = true;
            L_tarifa.Visible = true;
            TextBoxTarifa.Visible = true;
            TextBoxDescripcion.Visible = true;
            L_Descripcion.Visible = true;
            L_Pedido.Visible = true;
            B_Recibo.Visible = true;
            GV_Disponibles.Visible = true;
            Tabla_Rutas.Visible = true;
            CRV_Factura.Visible = false;
        }
        catch(Exception ex)
        {

        }
        
    }

    protected void Button2_Click(object sender, EventArgs e)
    {
        LT_Servicio.Visible = false;
        L_Destino.Visible = false;
        L_Ubicacion.Visible = false;
        DropDownListDestino.Visible = false;
        DropDownListUbicacion.Visible = false;
        DropDownListPago.Visible = false;
        L_Pago.Visible = false;
        B_Solicitud.Visible = false;
        B_Calcular.Visible = false;
        L_tarifa.Visible = false;
        TextBoxTarifa.Visible = false;
        TextBoxDescripcion.Visible = false;
        L_Descripcion.Visible = false;
        L_Pedido.Visible = false;
        B_Recibo.Visible = false;
        L_kilometros.Visible = false;
        TextBoxKilometros.Visible = false;
        CRV_Factura.Visible = false;
        L_Factura.Visible = false;
        GV_Disponibles.Visible = false;
        Tabla_Rutas.Visible = false;

        L_Historial.Visible = true;
        Tabla_HistorialServicios.Visible = true;
        L_Fecha.Visible = true;
        TextBoxfiltrar.Visible = true;
    }

    protected void B_Calcular_Click(object sender, EventArgs e)
    {
        LT_Servicio.Visible = true;
        L_Ubicacion.Visible = true;
        DropDownListDestino.Visible = true;
        DropDownListUbicacion.Visible = true;
        DropDownListPago.Visible = true;
        L_Pago.Visible = true;
        B_Solicitud.Visible = true;
        B_Calcular.Visible = true;
        L_tarifa.Visible = true;
        TextBoxTarifa.Visible = true;
        L_Destino.Visible = true;
        TextBoxDescripcion.Visible = true;
        L_Descripcion.Visible = true;
        L_Pedido.Visible = true;
        B_Recibo.Visible = true;
        CRV_Factura.Visible = false;

        int destino = int.Parse(DropDownListDestino.SelectedValue);
        int ubicacion = int.Parse(DropDownListUbicacion.SelectedValue);
       
        double tarifa;

        //Centro -> Pilaca && Pilaca -> Centro
        if ((destino == 10 && ubicacion == 1) || (destino == 1 && ubicacion == 10))
        {
            TextBoxKilometros.Text = "9,5";
            tarifa = 9.5 * 600;
            
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Centro -> Limonal && Limonal -> Centro
        else if ((destino == 10 && ubicacion == 2) || (destino == 2 && ubicacion == 10))
        {
            TextBoxKilometros.Text = "6,9";
            tarifa = 6.9 * 600;

            TextBoxTarifa.Text = tarifa.ToString();
        }

        //Centro -> La granja && La granja -> Centro
        else if ((destino == 10 && ubicacion == 3) || (destino == 3 && ubicacion == 10))
        {
            TextBoxKilometros.Text = "7,7";
            tarifa = 7.7 * 600;

            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Centro -> Mesetas && Mesetas -> Centro
        else if ((destino == 10 && ubicacion == 4) || (destino == 4 && ubicacion == 10))
        {
            TextBoxKilometros.Text = "1,2";
            tarifa = 1.2 * 600;

            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Centro -> Santa Ana && Santa Ana -> Centro
        else if ((destino == 10 && ubicacion == 5) || (destino == 5 && ubicacion == 10))
        {

            TextBoxKilometros.Text = "9,7";
            tarifa = 9.7 * 600;

            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Centro -> La mercedes && La merceedes -> Centro
        else if ((destino == 10 && ubicacion == 6) || (destino == 6 && ubicacion == 10))
        {
            TextBoxKilometros.Text = "6,4";
            tarifa = 6.4 * 600;

            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Centro ->San bernardo && San bernardo -> Centro
        else if ((destino == 10 && ubicacion == 8) || (destino == 8 && ubicacion == 10))
        {
            TextBoxKilometros.Text = "12";
            tarifa = 12 * 600;

            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Centro ->Guane && Guane -> Centro
        else if ((destino == 10 && ubicacion == 9) || (destino == 9 && ubicacion == 10))
        {

            TextBoxKilometros.Text = "14";
            tarifa = 14 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Pilaca ->Limonal && Limonal -> Pilaca
        else if ((destino == 1 && ubicacion == 2) || (destino == 2 && ubicacion == 1))
        {
            TextBoxKilometros.Text = "4,3";
            tarifa = 4.3 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Pilaca ->La granga && La granja -> Pilaca
        else if ((destino == 1 && ubicacion == 3) || (destino == 3 && ubicacion == 1))
        {
            TextBoxKilometros.Text = "2,3";
            tarifa = 2.3 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Pilaca ->Mesetas && Mesetas -> Pilaca
        else if ((destino == 1 && ubicacion == 4) || (destino == 4 && ubicacion == 1))
        {
            TextBoxKilometros.Text = "7,9";
            tarifa = 7.9 * 600;
            TextBoxTarifa.Text = tarifa.ToString();

        }
        //Pilaca ->Santa Ana && Santa Ana -> Pilaca
        else if ((destino == 1 && ubicacion == 5) || (destino == 5 && ubicacion == 1))
        {
            TextBoxKilometros.Text = "15";
            tarifa = 15 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Pilaca ->La mercedes && La mercesdes -> Pilaca
        else if ((destino == 1 && ubicacion == 6) || (destino == 6 && ubicacion == 1))
        {
            TextBoxKilometros.Text = "11";
            tarifa = 11 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Pilaca ->San bernardo && San bernardo -> Pilaca
        else if ((destino == 1 && ubicacion == 8) || (destino == 8 && ubicacion == 1))
        {
            TextBoxKilometros.Text = "17";
            tarifa = 17 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Pilaca ->Guane && Guane -> Pilaca
        else if ((destino == 1 && ubicacion == 9) || (destino == 9 && ubicacion == 1))
        {
            TextBoxKilometros.Text = "19";
            tarifa = 19 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Limonal ->La granja && La granja -> Limonal
        else if ((destino == 2 && ubicacion == 3) || (destino == 3 && ubicacion == 2))
        {
            TextBoxKilometros.Text = "3,1";
            tarifa = 3.1 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Limonal ->Mesetas && Mesetas -> Limonal
        else if ((destino == 2 && ubicacion == 4) || (destino == 4 && ubicacion == 2))
        {
            TextBoxKilometros.Text = "6,9";
            tarifa = 6.9 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Limonal ->Santa Ana && Santa Ana -> Limonal
        else if ((destino == 2 && ubicacion == 5) || (destino == 5 && ubicacion == 2))
        {
            TextBoxKilometros.Text = "12";
            tarifa = 12 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Limonal ->Las mercedes && Las mercesdes -> Limonal
        else if ((destino == 2 && ubicacion == 6) || (destino == 6 && ubicacion == 2))
        {
            TextBoxKilometros.Text = "9,3";
            tarifa = 9.3 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Limonal ->San bernardo && San bernardo -> Limonal
        else if ((destino == 2 && ubicacion == 8) || (destino == 8 && ubicacion == 2))
        {
            TextBoxKilometros.Text = "14";
            tarifa = 14 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Limonal ->Guane && Guane -> Limonal
        else if ((destino == 2 && ubicacion == 9) || (destino == 9 && ubicacion == 2))
        {
            TextBoxKilometros.Text = "17";
            tarifa = 17 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //La granja ->Mesetas && Mesetas -> La granja
        else if ((destino == 3 && ubicacion == 4) || (destino == 4 && ubicacion == 3))
        {
            TextBoxKilometros.Text = "5,7";
            tarifa = 5.7 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //La granja ->Santa Ana && Santa Ana -> La granja
        else if ((destino == 3 && ubicacion == 5) || (destino == 5 && ubicacion == 3))
        {
            TextBoxKilometros.Text = "13";
            tarifa = 13 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //La granja ->La mercedes && La mercedes -> La granja
        else if ((destino == 3 && ubicacion == 6) || (destino == 6 && ubicacion == 3))
        {
            TextBoxKilometros.Text = "10";
            tarifa = 10 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //La granja ->San bernardo && San bernardo -> La granja
        else if ((destino == 3 && ubicacion == 8) || (destino == 8 && ubicacion == 3))
        {
            TextBoxKilometros.Text = "15";
            tarifa = 15 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //La granja ->Guane && Guane -> La granja
        else if ((destino == 3 && ubicacion == 9) || (destino == 9 && ubicacion == 3))
        {
            TextBoxKilometros.Text = "18";
            tarifa = 18 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Mesetas ->Santa Ana && Santa Ana -> Mesetas
        else if ((destino == 4 && ubicacion == 5) || (destino == 5 && ubicacion == 4))
        {
            TextBoxKilometros.Text = "8,4";
            tarifa = 8.4 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Mesetas ->La mercedes && La mercedes -> Mesetas
        else if ((destino == 4 && ubicacion == 6) || (destino == 6 && ubicacion == 4))
        {
            TextBoxKilometros.Text = "5,2";
            tarifa = 5.2 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Mesetas ->San bernardo && San bernardo -> Mesetas
        else if ((destino == 4 && ubicacion == 8) || (destino == 8 && ubicacion == 4))
        {
            TextBoxKilometros.Text = "10";
            tarifa = 10 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Mesetas ->Guane && Guane -> Mesetas
        else if ((destino == 4 && ubicacion == 9) || (destino == 9 && ubicacion == 4))
        {
            TextBoxKilometros.Text = "13";
            tarifa = 13 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Santa Ana ->La mercedes && La mercedes -> Santa Ana
        else if ((destino == 5 && ubicacion == 6) || (destino == 6 && ubicacion == 5))
        {
            TextBoxKilometros.Text = "5";
            tarifa = 5 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Santa Ana ->San bernardo && San bernardo -> Santa Ana
        else if ((destino == 5 && ubicacion == 8) || (destino == 8 && ubicacion == 5))
        {
            TextBoxKilometros.Text = "4,6";
            tarifa = 4.6 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //Santa Ana ->Guane && Guane -> Santa Ana
        else if ((destino == 5 && ubicacion == 9) || (destino == 9 && ubicacion == 5))
        {
            TextBoxKilometros.Text = "12";
            tarifa = 12 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //La mercedes -> San bernardo && San bernardo -> La mercedes
        else if ((destino == 6 && ubicacion == 8) || (destino == 8 && ubicacion == 6))
        {
            TextBoxKilometros.Text = "3,1";
            tarifa = 3.1 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //La mercedes -> Guane && Guane -> La mercedes
        else if ((destino == 6 && ubicacion == 9) || (destino == 9 && ubicacion == 6))
        {
            TextBoxKilometros.Text = "7,7";
            tarifa = 7.7 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
        //San bernardo -> Guane && San bernardo -> Guane
        else if ((destino == 8 && ubicacion == 9) || (destino == 9 && ubicacion == 8))
        {
            TextBoxKilometros.Text = "8,3";
            tarifa = 8.3 * 600;
            TextBoxTarifa.Text = tarifa.ToString();
        }
    }

    protected void B_Recibo_Click(object sender, EventArgs e)
    {
        try
        {
            Notificacion notificacion = new Notificacion();
            CRS_Factura.ReportDocument.SetDataSource(factura(notificacion));
            CRV_Factura.ReportSource = CRS_Factura;
            //CRS_Factura.ReportDocument.ExportToHttpResponse(ExportFormatType.PortableDocFormat, Response, true, "Factura Servicio " + notificacion.FechaCarrera + ".");
            CRV_Factura.Visible = true;
        }
        catch (Exception ex)
        {
            L_Factura.Text = "No se generará factura hasta que solicite un servicio";
            L_Factura.Visible = true;
        }
    }

    protected SuministroInformacion factura(Notificacion notificacion)
    {
        SuministroInformacion informe = new SuministroInformacion();
        Notificacion factura = new DaoCliente().generarFactura(notificacion);

        DataTable datosFinal = informe.Factura;
        DataRow fila;

        fila = datosFinal.NewRow();
        fila["Fecha"] = factura.FechaCarrera;
        fila["NombreCliente"] = factura.NombreCl;
        fila["Destino"] = factura.Destino;
        fila["Ubicacion"] = factura.Ubicacion;
        fila["Tarifa"] = factura.Tarifa;
        fila["MetodoPago"] = factura.MetodoPago;

        datosFinal.Rows.Add(fila);
        
        return informe;
    }

    protected void Tabla_HistorialServicios_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        DateTime fechaCarrera = DateTime.Parse(e.OldValues["FechaCarrera"].ToString());
        e.NewValues.Insert(1, "FechaCarrera", fechaCarrera);
    }

    protected void TextBoxfiltrar_TextChanged(object sender, EventArgs e)
    {
        CRV_Factura.Visible = false;
    }

    protected void Tabla_HistorialServicios_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        
            if (e.CommandName == "Enviar")
            {
                int idNotificacion = Convert.ToInt32(e.CommandArgument);

                Notificacion notificacion = new DaoConductor().buscarId(idNotificacion);

                //Captura la fila
                int numFila = ((GridViewRow)((LinkButton)e.CommandSource).Parent.Parent).RowIndex;

                //Busca el control TextBox
                TextBox tb_conversar = (Tabla_HistorialServicios.Rows[numFila].Cells[20].FindControl("TB_Conversar") as TextBox);

                //Obtiene valor
                string mensaje = tb_conversar.Text;
         
                notificacion.Conversacion = ("Cliente " + ((Cliente)Session["user"]).Nombrecl + ": " + mensaje);
                new DaoCliente().coversar(notificacion);

            
                Tabla_HistorialServicios.DataBind();
            }
        CRV_Factura.Visible = false;
    }

    protected void CRV_Factura_Init(object sender, EventArgs e)
    {

    }
}