<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Controller/cliente.aspx.cs" Inherits="View_cliente" %>

<%@ Register assembly="CrystalDecisions.Web, Version=13.0.4000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" namespace="CrystalDecisions.Web" tagprefix="CR" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Principal Cliente</title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
            height: 80px;
        }
        .auto-style2 {
            text-align: left;
        }
        .auto-style3 {
            text-align: left;
            width: 880px;
        }
        .auto-style4 {
            font-size: 15pt;
        }
        .auto-style5 {
            text-align: center;
            width: 60px;
        }
        .auto-style6 {
            width: 100%;
        }
        .auto-style20 {
            text-align: center;
        }
        .auto-style29 {
            width: 360px;
        }
        .auto-style30 {
            width: 630px;
        }
        .auto-style31 {
            width: 630px;
            text-align: center;
        }
        .auto-style32 {
            width: 641px;
            text-align: center;
        }
        .auto-style43 {
            width: 416px;
        }
        .auto-style44 {
            width: 416px;
            text-align: right;
        }
        .auto-style45 {
            width: 150px;
        }
        .auto-style47 {
            width: 416px;
            text-align: center;
        }
        .auto-style48 {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            font-size: 8pt;
        }
        .auto-style49 {
            text-align: right;
        }
        .auto-style50 {
            width: 207px;
        }
        </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style5">
                        &nbsp;<asp:Image ID="Image1" runat="server" ImageUrl="~/Imagenes/Icono usuario.png" Width="100%" />
                    </td>
                    <td class="auto-style3">
                        &nbsp;&nbsp;&nbsp;&nbsp;
                        <asp:Label ID="LB_NombreCl" runat="server" CssClass="auto-style4" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" ForeColor="Black"></asp:Label>
&nbsp;<asp:Label ID="LB_ApellidoCl" runat="server" CssClass="auto-style4" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" ForeColor="Black"></asp:Label>
                    </td>
                    <td class="auto-style2">
                        <asp:Menu ID="Menu_Cliente" runat="server" BackColor="#FFFBD6" DynamicHorizontalOffset="2" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="#990000" StaticSubMenuIndent="10px" Orientation="Horizontal">
                            <DynamicHoverStyle BackColor="#990000" ForeColor="White" />
                            <DynamicMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                            <DynamicMenuStyle BackColor="#FFFBD6" />
                            <DynamicSelectedStyle BackColor="#FFCC66" />
                            <Items>
                                <asp:MenuItem NavigateUrl="~/View/modificarCliente.aspx" Text="Actualizar Datos" Value="Actualizar Datos"></asp:MenuItem>
                                <asp:MenuItem Text="Eliminar Cuenta" Value="Eliminar Usuario" NavigateUrl="~/View/eliminarCliente.aspx"></asp:MenuItem>
                                <asp:MenuItem NavigateUrl="~/View/cerrarSesionCl.aspx" Text="Cerrar Sesión" Value="Cerrar Sesión"></asp:MenuItem>
                            </Items>
                            <StaticHoverStyle BackColor="#990000" ForeColor="White" />
                            <StaticMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                            <StaticSelectedStyle BackColor="#FFCC66" />
                        </asp:Menu>
                    </td>
                </tr>
            </table>
        </div>
        <table class="auto-style6">
            <tr>
                <td>
                    <asp:ScriptManager ID="ScriptManager1" runat="server">
                    </asp:ScriptManager>
                </td>
            </tr>
        </table>
        <table class="auto-style6">
            <tr>
                <td>
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <table class="auto-style6">
                                <tr>
                                    <td class="auto-style32">
                                        <asp:Button ID="B_SolServicio" runat="server" OnClick="Button1_Click1" Text="Solicitar Servicio" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" />
                                    </td>
                                    <td class="auto-style20">
                                        <asp:Button ID="B_Historial" runat="server" OnClick="Button2_Click" Text="Historial De Servicio" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" />
                                    </td>
                                </tr>
                            </table>
                            <table class="auto-style6">
                                <tr>
                                    <td class="auto-style20">
                                        <asp:Label ID="LT_Servicio" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="23pt" Text="Solicitud de Servicio"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <table class="auto-style6">
                                <tr>
                                    
                                    </td>
                                    </tr>
                                <tr>
                                    <td class="auto-style47" rowspan="9">
                                        <br />
                                        <asp:Table ID="Tabla_Rutas" runat="server" BorderStyle="Groove" CssClass="auto-style48" HorizontalAlign="Right">
                                            <asp:TableHeaderRow>
                                                <asp:TableHeaderCell>N°</asp:TableHeaderCell>
                                                <asp:TableHeaderCell>Ruta</asp:TableHeaderCell>
                                                <asp:TableHeaderCell>Distancia (Km)</asp:TableHeaderCell>
                                            </asp:TableHeaderRow>
                                            <asp:TableRow>
                                                <asp:TableCell>1</asp:TableCell>
                                                <asp:TableCell>Centro - Pilaca &amp; Vis.</asp:TableCell>
                                                <asp:TableCell>9.5</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>2</asp:TableCell>
                                                <asp:TableCell>Centro - Limonal &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>6.9</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>3</asp:TableCell>
                                                <asp:TableCell>Centro - La Granja &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>7.7</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>4</asp:TableCell>
                                                <asp:TableCell>Centro - Mesetas &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>1.2</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>5</asp:TableCell>
                                                <asp:TableCell>Centro - Santa Ana &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>9.7</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>6</asp:TableCell>
                                                <asp:TableCell>Centro - Las Mercedes &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>6.4</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>7</asp:TableCell>
                                                <asp:TableCell>Centro - San Bernardo &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>12</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>8</asp:TableCell>
                                                <asp:TableCell>Centro - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>14</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>9</asp:TableCell>
                                                <asp:TableCell>Pilaca - Limonal &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>4.3</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>10</asp:TableCell>
                                                <asp:TableCell>Pilaca - La Granja &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>2.3</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>11</asp:TableCell>
                                                <asp:TableCell>Pilaca - Mesetas &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>7.9</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>12</asp:TableCell>
                                                <asp:TableCell>Pilaca - Santa Ana &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>15</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>13</asp:TableCell>
                                                <asp:TableCell>Pilaca - Las Mercedes &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>11</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>14</asp:TableCell>
                                                <asp:TableCell>Pilaca - San Bernardo &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>17</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>15</asp:TableCell>
                                                <asp:TableCell>Pilaca - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>19</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>16</asp:TableCell>
                                                <asp:TableCell>Limonal - La Granja &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>3.1</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>17</asp:TableCell>
                                                <asp:TableCell>Limonal - Mesetas &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>6.9</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>18</asp:TableCell>
                                                <asp:TableCell>Limonal - Santa Ana &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>12</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>19</asp:TableCell>
                                                <asp:TableCell>Limonal - Las Mercedes &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>9.3</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>20</asp:TableCell>
                                                <asp:TableCell>Limonal - San Bernardo &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>14</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>21</asp:TableCell>
                                                <asp:TableCell>Limonal - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>17</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>22</asp:TableCell>
                                                <asp:TableCell>La Granja - Mesetas &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>5.7</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>23</asp:TableCell>
                                                <asp:TableCell>La Granja - Santa Ana &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>13</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>24</asp:TableCell>
                                                <asp:TableCell>La Granja - Las Mercedes &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>10</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>25</asp:TableCell>
                                                <asp:TableCell>La Granja - San Bernardo &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>15</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>26</asp:TableCell>
                                                <asp:TableCell>La Granja - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>18</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>27</asp:TableCell>
                                                <asp:TableCell>Mesetas - Santa Ana &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>8.4</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>28</asp:TableCell>
                                                <asp:TableCell>Mesetas - Las Mercedes &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>5.2</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>29</asp:TableCell>
                                                <asp:TableCell>Mesetas - San Bernardo &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>10</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>30</asp:TableCell>
                                                <asp:TableCell>Mesetas - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>13</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>31</asp:TableCell>
                                                <asp:TableCell>Santa Ana - Las Mercedes &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>5</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>32</asp:TableCell>
                                                <asp:TableCell>Santa Ana - San Bernardo &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>4.6</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>33</asp:TableCell>
                                                <asp:TableCell>Santa Ana - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>12</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>34</asp:TableCell>
                                                <asp:TableCell>Las Mercedes - San Bernardo &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>3.1</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>35</asp:TableCell>
                                                <asp:TableCell>Las Mercedes - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>7.7</asp:TableCell>
                                            </asp:TableRow>
                                            <asp:TableRow>
                                                <asp:TableCell>36</asp:TableCell>
                                                <asp:TableCell>San Bernardo - Guane &amp; Vic.</asp:TableCell>
                                                <asp:TableCell>8.3</asp:TableCell>
                                            </asp:TableRow>
                                        </asp:Table>
                                    </td>
                                    <td class="auto-style44"><strong>
                                        <asp:Label ID="L_Destino" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Text="Destino"></asp:Label>
                                        </strong></td>
                                    <td class="auto-style43">
                                        <asp:DropDownList ID="DropDownListDestino" runat="server" DataSourceID="ODS_Destino" DataTextField="LugarDestino" DataValueField="Id">
                                        </asp:DropDownList>
                                        <asp:ObjectDataSource ID="ODS_Destino" runat="server" SelectMethod="destino" TypeName="DaoCliente"></asp:ObjectDataSource>
                                    </td>
                                    <td class="auto-style43" rowspan="3">
                                        <div class="auto-style20">
                                            <asp:GridView ID="GV_Disponibles" runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#CC9966" BorderStyle="None" BorderWidth="1px" CellPadding="4" DataSourceID="ODS_ConductoresDisponibles" Font-Names="Segoe UI" Font-Size="11pt" ForeColor="Black">
                                                <Columns>
                                                    <asp:BoundField DataField="Nombre" HeaderText="Conductores" SortExpression="Nombre" />
                                                    <asp:BoundField DataField="Apellido" HeaderText="Disponibles" SortExpression="Apellido" />
                                                    <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                                    <asp:BoundField DataField="FechaDeNacimiento" HeaderText="FechaDeNacimiento" SortExpression="FechaDeNacimiento" Visible="False" />
                                                    <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" Visible="False" />
                                                    <asp:BoundField DataField="Placa" HeaderText="Placa" SortExpression="Placa" Visible="False" />
                                                    <asp:BoundField DataField="Celular" HeaderText="Celular" SortExpression="Celular" Visible="False" />
                                                    <asp:BoundField DataField="Usuario" HeaderText="Usuario" SortExpression="Usuario" Visible="False" />
                                                    <asp:BoundField DataField="Contrasena" HeaderText="Contrasena" SortExpression="Contrasena" Visible="False" />
                                                    <asp:BoundField DataField="Modificado" HeaderText="Modificado" SortExpression="Modificado" Visible="False" />
                                                    <asp:BoundField DataField="Sesion" HeaderText="Sesion" SortExpression="Sesion" Visible="False" />
                                                    <asp:BoundField DataField="IdEstado" HeaderText="IdEstado" SortExpression="IdEstado" Visible="False" />
                                                    <asp:BoundField DataField="DispEstado" HeaderText="DispEstado" SortExpression="DispEstado" Visible="False" />
                                                    <asp:BoundField DataField="Cedula" HeaderText="Cedula" SortExpression="Cedula" Visible="False" />
                                                    <asp:BoundField DataField="FechaSancion" HeaderText="FechaSancion" SortExpression="FechaSancion" Visible="False" />
                                                </Columns>
                                                <FooterStyle BackColor="#FFFFCC" ForeColor="#330099" />
                                                <HeaderStyle BackColor="#990000" Font-Bold="True" ForeColor="#FFFFCC" />
                                                <PagerStyle BackColor="#FFFFCC" ForeColor="#330099" HorizontalAlign="Center" />
                                                <RowStyle BackColor="White" ForeColor="#330099" />
                                                <SelectedRowStyle BackColor="#FFCC66" Font-Bold="True" ForeColor="#663399" />
                                                <SortedAscendingCellStyle BackColor="#FEFCEB" />
                                                <SortedAscendingHeaderStyle BackColor="#AF0101" />
                                                <SortedDescendingCellStyle BackColor="#F6F0C0" />
                                                <SortedDescendingHeaderStyle BackColor="#7E0000" />
                                            </asp:GridView>
                                        </div>
                                        <asp:ObjectDataSource ID="ODS_ConductoresDisponibles" runat="server" SelectMethod="conductoresDisponibles" TypeName="DaoCliente"></asp:ObjectDataSource>
                                    </td>
                                    <tr>
                                        <td class="auto-style44"><strong>
                                            <asp:Label ID="L_Ubicacion" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Text="Ubicacion"></asp:Label>
                                            </strong></td>
                                        <td class="auto-style43">
                                            <asp:DropDownList ID="DropDownListUbicacion" runat="server" DataSourceID="ODS_Ubicacion" DataTextField="LugarUbicacion" DataValueField="Id">
                                            </asp:DropDownList>
                                            <asp:ObjectDataSource ID="ODS_Ubicacion" runat="server" SelectMethod="ubicacion" TypeName="DaoCliente"></asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style44">
                                            <asp:Label ID="L_Descripcion" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Descricion de servicio"></asp:Label>
                                        </td>
                                        <td class="auto-style43">
                                            <asp:TextBox ID="TextBoxDescripcion" runat="server" Height="85px" TextMode="MultiLine" Width="242px"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style20" colspan="2">
                                            <asp:Button ID="B_Calcular" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="10pt" OnClick="B_Calcular_Click" Text="Calcular" />
                                            <br />
                                        </td>
                                        <td class="auto-style47">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style49">
                                            <asp:Label ID="L_kilometros" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Kilometros"></asp:Label>
                                        </td>
                                        <td class="auto-style2">
                                            <asp:TextBox ID="TextBoxKilometros" runat="server" Enabled="False"></asp:TextBox>
                                        </td>
                                        <td class="auto-style20">&nbsp;</td>
                                        <td class="auto-style20">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style44">
                                            <asp:Label ID="L_tarifa" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Tarifa"></asp:Label>
                                        </td>
                                        <td class="auto-style43" colspan="2">
                                            <asp:TextBox ID="TextBoxTarifa" runat="server" Enabled="False"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style44">
                                            <asp:Label ID="L_Pago" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Modo de pago"></asp:Label>
                                        </td>
                                        <td class="auto-style43" colspan="2">
                                            <asp:DropDownList ID="DropDownListPago" runat="server" DataSourceID="ODS_Pag" DataTextField="Descripcion" DataValueField="Id">
                                            </asp:DropDownList>
                                            <asp:ObjectDataSource ID="ODS_Pag" runat="server" SelectMethod="pago" TypeName="DaoCliente"></asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style44">
                                            <asp:Button ID="B_Solicitud" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="10pt" OnClick="B_Solicitud_Click" Text="Guardar" />
                                        </td>
                                        <td class="auto-style43" colspan="2">
                                            <asp:Button ID="B_Recibo" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="10pt" OnClick="B_Recibo_Click" Text="Generar Recibo" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style20" colspan="2">
                                            <asp:Label ID="L_Factura" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                            <asp:Label ID="L_Pedido" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                        </td>
                                        <td></td>
                                    </tr>
                                </tr>
                                </table>
                            &nbsp;
                            <table class="auto-style6">
                                <tr>
                                    <td class="auto-style29">
                                        <br />
                                    </td>
                                    <td class="auto-style31">
                                        <asp:Label ID="L_Historial" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Tu Historial de Servicios"></asp:Label>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                            <table class="auto-style6">
                                <tr>
                                    <td class="auto-style29">&nbsp;</td>
                                    <td class="auto-style31">
                                        <asp:Label ID="L_Fecha" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Fecha Carrera"></asp:Label>
                                        <asp:TextBox ID="TextBoxfiltrar" runat="server" TextMode="Date" AutoPostBack="True" OnTextChanged="TextBoxfiltrar_TextChanged"></asp:TextBox>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                            <table class="auto-style6">
                                <tr>
                                    <td class="auto-style50">&nbsp;</td>
                                    <td class="auto-style30">
                                        <div class="auto-style20">
                                            <asp:GridView ID="Tabla_HistorialServicios" runat="server" AutoGenerateColumns="False" CellPadding="4" DataKeyNames="Id" DataSourceID="ODS_Servicios" Font-Names="Segoe UI" Font-Size="11pt" ForeColor="#333333" GridLines="None" OnRowCommand="Tabla_HistorialServicios_RowCommand" OnRowUpdating="Tabla_HistorialServicios_RowUpdating">
                                                <AlternatingRowStyle BackColor="White" />
                                                <Columns>
                                                    <asp:BoundField DataField="NombreCl" HeaderText="Soy" ReadOnly="True" SortExpression="NombreCl" />
                                                    <asp:BoundField DataField="Conductor" HeaderText="Conductor" ReadOnly="True" SortExpression="Conductor" />
                                                    <asp:BoundField DataField="Destino" HeaderText="Destino" ReadOnly="True" SortExpression="Destino" />
                                                    <asp:BoundField DataField="Ubicacion" HeaderText="Ubicacion" ReadOnly="True" SortExpression="Ubicacion" />
                                                    <asp:BoundField DataField="Tarifa" HeaderText="Tarifa" ReadOnly="True" SortExpression="Tarifa" />
                                                    <asp:BoundField DataField="FechaCarrera" DataFormatString="{0:dd/MM/yyyy}" HeaderText="FechaCarrera" ReadOnly="True" SortExpression="FechaCarrera" />
                                                    <asp:BoundField DataField="ComentarioDeCliente" HeaderText="ComentarioDeCliente" SortExpression="ComentarioDeCliente" />
                                                    <asp:BoundField DataField="Id" HeaderText="Id" SortExpression="Id" Visible="False" />
                                                    <asp:BoundField DataField="IdCliente" HeaderText="IdCliente" SortExpression="IdCliente" Visible="False" />
                                                    <asp:BoundField DataField="IdUbicacion" HeaderText="IdUbicacion" SortExpression="IdUbicacion" Visible="False" />
                                                    <asp:BoundField DataField="IdDestino" HeaderText="IdDestino" SortExpression="IdDestino" Visible="False" />
                                                    <asp:BoundField DataField="DescripcionServicio" HeaderText="DescripcionServicio" SortExpression="DescripcionServicio" Visible="False" />
                                                    <asp:BoundField DataField="Pago" HeaderText="Pago" SortExpression="Pago" Visible="False" />
                                                    <asp:BoundField DataField="Kilometro" HeaderText="Kilometro" SortExpression="Kilometro" Visible="False" />
                                                    <asp:BoundField DataField="Estado" HeaderText="Estado" SortExpression="Estado" Visible="False" />
                                                    <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                                    <asp:BoundField DataField="ComentarioDeConductor" HeaderText="ComentarioDeConductor" SortExpression="ComentarioDeConductor" Visible="False" />
                                                    <asp:BoundField DataField="FechaFinCarrera" HeaderText="FechaFinCarrera" SortExpression="FechaFinCarrera" Visible="False" />
                                                    <asp:CommandField EditText="Comentar" ShowEditButton="True" />
                                                    <asp:BoundField DataField="Conversacion" HeaderText="Conversacion" ReadOnly="True" SortExpression="Conversacion" />
                                                    <asp:TemplateField>
                                                        <ItemTemplate>
                                                            <asp:TextBox ID="TB_Conversar" runat="server" Font-Names="Segoe UI" Font-Size="10pt"></asp:TextBox>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Conversar" ShowHeader="False">
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandArgument='<%# Eval("Id") %>' CommandName="Enviar" Text="Enviar"></asp:LinkButton>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                                <FooterStyle BackColor="#990000" Font-Bold="True" ForeColor="White" />
                                                <HeaderStyle BackColor="#990000" Font-Bold="True" ForeColor="White" />
                                                <PagerStyle BackColor="#FFCC66" ForeColor="#333333" HorizontalAlign="Center" />
                                                <RowStyle BackColor="#FFFBD6" ForeColor="#333333" />
                                                <SelectedRowStyle BackColor="#FFCC66" Font-Bold="True" ForeColor="Navy" />
                                                <SortedAscendingCellStyle BackColor="#FDF5AC" />
                                                <SortedAscendingHeaderStyle BackColor="#4D0000" />
                                                <SortedDescendingCellStyle BackColor="#FCF6C0" />
                                                <SortedDescendingHeaderStyle BackColor="#820000" />
                                            </asp:GridView>
                                        </div>
                                        <asp:ObjectDataSource ID="ODS_Servicios" runat="server" DataObjectTypeName="Notificacion" SelectMethod="filtrarServicios" TypeName="DaoCliente" UpdateMethod="comentar">
                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="TextBoxfiltrar" Name="fechaInicio" PropertyName="Text" Type="DateTime" />
                                            </SelectParameters>
                                        </asp:ObjectDataSource>
                                        <CR:CrystalReportViewer ID="CRV_Factura" runat="server" AutoDataBind="True" EnableDatabaseLogonPrompt="False" EnableParameterPrompt="False" GroupTreeImagesFolderUrl="" Height="1202px" OnInit="CRV_Factura_Init" ReportSourceID="CRS_Factura" ToolbarImagesFolderUrl="" ToolPanelWidth="200px" Visible="False" Width="1104px" />
                                        <CR:CrystalReportSource ID="CRS_Factura" runat="server">
                                            <Report FileName="C:\Users\User\Downloads\Moto Deluxe\mt_deluxe\mt_deluxe\Reportes\FacturaCl.rpt">
                                            </Report>
                                        </CR:CrystalReportSource>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                            <table class="auto-style6">
                                <tr>
                                    <td class="auto-style45">
                                        &nbsp;</td>
                                    <td>
                                        &nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="B_Solicitud" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="Tabla_HistorialServicios" EventName="CallingDataMethods" />
                            <asp:AsyncPostBackTrigger ControlID="CRV_Factura" EventName="AfterRender" />
                            <asp:AsyncPostBackTrigger ControlID="Tabla_HistorialServicios" EventName="RowCommand" />
                        </Triggers>
                    </asp:UpdatePanel>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
