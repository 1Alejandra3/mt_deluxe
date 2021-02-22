<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Controller/conductor.aspx.cs" Inherits="View_conductor" %>

<%@ Register assembly="CrystalDecisions.Web, Version=13.0.4000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" namespace="CrystalDecisions.Web" tagprefix="CR" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Principal Conductor</title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }
        .auto-style2 {
            text-align: right;
        }
        .auto-style5 {
            color: #FF0000;
        }
        .auto-style8 {
            width: 690px;
            text-align: right;
        }
        .auto-style9 {
            text-align: left;
            width: 880px;
        }
        .auto-style10 {
            text-align: center;
            width: 60px;
        }
        .auto-style11 {
            width: 455px;
            text-align: right;
            height: 37px;
        }
        .auto-style12 {
            width: 415px;
            text-align: center;
            height: 37px;
        }
        .auto-style15 {
            width: 650px;
            text-align: right;
        }
        .auto-style21 {
            width: 630px;
            text-align: center;
        }
        .auto-style24 {
            width: 360px;
        }
        .auto-style27 {
            width: 743px;
            text-align: center;
        }
        .auto-style31 {
            height: 37px;
        }
        .auto-style35 {
            width: 302px;
        }
        .auto-style36 {
            width: 379px;
        }
        .auto-style37 {
            width: 251px;
            text-align: center;
        }
        .auto-style39 {
            width: 1259px;
        }
        .auto-style40 {
            width: 252px;
        }
        .auto-style41 {
            width: 252px;
            text-align: right;
        }
        .auto-style42 {
            text-align: center;
        }
        .auto-style43 {
            width: 181px;
        }
        </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style10">
                        <asp:Image ID="Image1" runat="server" ImageUrl="~/Imagenes/Icono conductor.png" Width="100%" />
                    </td>
                    <td class="auto-style9">
            &nbsp;&nbsp;&nbsp;&nbsp;
                        <asp:Label ID="LB_NombreCo" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt"></asp:Label>
&nbsp;<asp:Label ID="LB_ApellidoCo" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt"></asp:Label>
                    </td>
                    <td class="auto-style2">
            <asp:Menu ID="Menu_Conductor" runat="server" BackColor="#FFFBD6" DynamicHorizontalOffset="2" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="#990000" StaticSubMenuIndent="10px" Orientation="Horizontal">
                <DynamicHoverStyle BackColor="#990000" ForeColor="White" />
                <DynamicMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                <DynamicMenuStyle BackColor="#FFFBD6" />
                <DynamicSelectedStyle BackColor="#FFCC66" />
                <Items>
                    <asp:MenuItem NavigateUrl="~/View/modificarConductor.aspx" Text="Actualizar Datos" Value="Actualizar datos"></asp:MenuItem>
                    <asp:MenuItem Text="Eliminar Cuenta" Value="Eliminar Cuenta" NavigateUrl="~/View/eliminarConductor.aspx"></asp:MenuItem>
                    <asp:MenuItem NavigateUrl="~/View/cerrarSesionCo.aspx" Text="Cerrar Sesión" Value="Cerrar Sesión"></asp:MenuItem>
                </Items>
                <StaticHoverStyle BackColor="#990000" ForeColor="White" />
                <StaticMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                <StaticSelectedStyle BackColor="#FFCC66" />
            </asp:Menu>
                    </td>
                </tr>
            </table>
            <br />
            <table class="auto-style1">
                <tr>
                    <td>
                        <asp:ScriptManager ID="ScriptManager1" runat="server">
                        </asp:ScriptManager>
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <ContentTemplate>
                                <table class="auto-style1">
                                    <tr>
                                        <td class="auto-style11">
                                            <asp:Button ID="B_Ingreso_Estado" runat="server" Font-Bold="True" Font-Italic="False" Font-Names="Segoe UI" Font-Size="12pt" Text="Ingresar Estado" OnClick="B_Ingreso_Estado_Click" />
                                        </td>
                                        <td class="auto-style12">
                                            <asp:Button ID="B_Servicio" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Solicitud de carreras" OnClick="B_Historial_Click" />
                                        </td>
                                        <td class="auto-style31">
                                            <asp:Button ID="B_Historial" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" OnClick="B_ComentarCl_Click" Text="Historial" />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <table class="auto-style1">
                                    <tr>
                                        <td class="auto-style15">
                                            <asp:Label ID="L_Estado" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Estado:"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:Label ID="LB_Estado" runat="server" CssClass="auto-style5" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="Black"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                                <table class="auto-style1">
                                    <tr>
                                        <td class="auto-style8">
                                            <asp:ObjectDataSource ID="ODS_estado" runat="server" SelectMethod="estado" TypeName="DaoConductor"></asp:ObjectDataSource>
                                            <asp:DropDownList ID="DDL_Estado" runat="server" DataSourceID="ODS_estado" DataTextField="Disponibilidad" DataValueField="Id" Font-Names="Segoe UI" Font-Size="12pt">
                                            </asp:DropDownList>
                                        </td>
                                        <td>
                                            <asp:Button ID="BG_Estado" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="10pt" OnClick="Button1_Click" Text="Guardar" />
                                        </td>
                                    </tr>
                                </table>
                                <table class="auto-style1">
                                    <tr>
                                        <td class="auto-style24">&nbsp;</td>
                                        <td class="auto-style21">
                                            <asp:Label ID="L_Historial" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Solicitud de servicio"></asp:Label>
                                        </td>
                                        <td>&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td class="auto-style24">&nbsp;</td>
                                        <td class="auto-style21">
                                            <asp:GridView ID="Tabla_HistorialCarreras" runat="server" AutoGenerateColumns="False" CellPadding="4" DataSourceID="ODS_Solicitud" Font-Names="Segoe UI" Font-Size="11pt" ForeColor="#333333" GridLines="None" OnRowCommand="Tabla_HistorialCarreras_RowCommand" DataKeyNames="Id">
                                                <AlternatingRowStyle BackColor="White" />
                                                <Columns>
                                                    <asp:BoundField DataField="NombreCl" HeaderText="Nombre Cliente" SortExpression="NombreCl" />
                                                    <asp:BoundField DataField="Destino" HeaderText="Destino" SortExpression="Destino" />
                                                    <asp:BoundField DataField="Ubicacion" HeaderText="Ubicacion" SortExpression="Ubicacion" />
                                                    <asp:BoundField DataField="DescripcionServicio" HeaderText="Descripcion Servicio" SortExpression="DescripcionServicio" />
                                                    <asp:BoundField DataField="Tarifa" HeaderText="Tarifa" SortExpression="Tarifa" />
                                                    <asp:BoundField DataField="MetodoPago" HeaderText="Metodo Pago" SortExpression="MetodoPago" />
                                                    <asp:BoundField DataField="FechaCarrera" HeaderText="Fecha Carrera" SortExpression="FechaCarrera" DataFormatString="{0:dd/MM/yyyy}"/>
                                                    <asp:BoundField DataField="Id" HeaderText="Id" SortExpression="Id" Visible="False" />
                                                    <asp:BoundField DataField="IdCliente" HeaderText="IdCliente" SortExpression="IdCliente" Visible="False" />
                                                    <asp:BoundField DataField="IdUbicacion" HeaderText="IdUbicacion" SortExpression="IdUbicacion" Visible="False" />
                                                    <asp:BoundField DataField="IdDestino" HeaderText="IdDestino" SortExpression="IdDestino" Visible="False" />
                                                    <asp:BoundField DataField="Pago" HeaderText="Pago" SortExpression="Pago" Visible="False" />
                                                    <asp:BoundField DataField="Kilometro" HeaderText="Kilometro" SortExpression="Kilometro" Visible="False" />
                                                    <asp:BoundField DataField="Estado" HeaderText="Estado" SortExpression="Estado" Visible="False" />
                                                    <asp:BoundField DataField="Conductor" HeaderText="Conductor" SortExpression="Conductor" Visible="False" />
                                                    <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                                    <asp:BoundField DataField="ComentarioDeConductor" HeaderText="ComentarioDeConductor" SortExpression="ComentarioDeConductor" Visible="False" />
                                                    <asp:BoundField DataField="ComentarioDeCliente" HeaderText="ComentarioDeCliente" SortExpression="ComentarioDeCliente" Visible="False" />
                                                    <asp:BoundField DataField="FechaFinCarrera" HeaderText="FechaFinCarrera" SortExpression="FechaFinCarrera" Visible="False" />
                                                    <asp:TemplateField HeaderText="Confirmar" ShowHeader="False">
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandArgument='<%#Eval("IdCliente") + ";" +Eval("Id")%>' Text="Aceptar"></asp:LinkButton>
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
                                            <asp:ObjectDataSource ID="ODS_Solicitud" runat="server" SelectMethod="mostrarHistorial" TypeName="DaoConductor"></asp:ObjectDataSource>
                                            <br />
                                            <asp:Label ID="L_Aceptado" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                        </td>
                                        <td>&nbsp;</td>
                                    </tr>
                                </table>
                                <table class="auto-style1">
                                    <tr>
                                        <td class="auto-style35">&nbsp;</td>
                                        <td class="auto-style27">
                                            <asp:Label ID="L_Carreras" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Historial de Carreras"></asp:Label>
                                        </td>
                                        <td>&nbsp;</td>
                                    </tr>
                                </table>
                                <table class="auto-style39">
                                    <tr>
                                        <td class="auto-style36">&nbsp;</td>
                                        <td class="auto-style37">
                                            <asp:Label ID="L_Fecha" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Fecha Carrera"></asp:Label>
                                            <asp:TextBox ID="TextBoxfiltrar" runat="server" TextMode="Date" AutoPostBack="True"></asp:TextBox>
                                        </td>
                                        <td class="auto-style37">
                                            <asp:Button ID="B_Ganancias" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="10pt" OnClick="B_Ganancias_Click" Text="Ganancias" />
                                            <asp:Label ID="L_Pesos" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="$"></asp:Label>
                                            <asp:Label ID="L_Ganancias" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                        </td>
                                        <td class="auto-style41">
                                            <asp:Button ID="B_ReportHistorial" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="10pt" OnClick="B_ReportHistorial_Click" Text="Generar Reporte Historial" />
                                            <asp:Label ID="L_HistorialCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                        </td>
                                        <td class="auto-style40">&nbsp;</td>
                                    </tr>
                                </table>
                                <table class="auto-style1">
                                    <tr>
                                        <td class="auto-style43">&nbsp;</td>
                                        <td class="auto-style27">
                                            <br />
                                            <asp:GridView ID="Tabla_Carreras" runat="server" AutoGenerateColumns="False" CellPadding="4" DataKeyNames="Id" DataSourceID="ODS_Carreras" Font-Names="Segoe UI" Font-Size="11pt" ForeColor="#333333" GridLines="None" OnRowCommand="Tabla_Carreras_RowCommand" OnRowUpdating="Tabla_Carreras_RowUpdating">
                                                <AlternatingRowStyle BackColor="White" />
                                                <Columns>
                                                    <asp:BoundField DataField="Conductor" HeaderText="Soy" ReadOnly="True" SortExpression="Conductor" />
                                                    <asp:BoundField DataField="NombreCl" HeaderText="Cliente" ReadOnly="True" SortExpression="NombreCl" />
                                                    <asp:BoundField DataField="Destino" HeaderText="Destino" ReadOnly="True" SortExpression="Destino" />
                                                    <asp:BoundField DataField="Ubicacion" HeaderText="Ubicacion" ReadOnly="True" SortExpression="Ubicacion" />
                                                    <asp:BoundField DataField="Tarifa" HeaderText="Tarifa" ReadOnly="True" SortExpression="Tarifa" />
                                                    <asp:BoundField DataField="FechaCarrera" DataFormatString="{0:dd/MM/yyyy}" HeaderText="Fecha Carrera" ReadOnly="True" SortExpression="FechaCarrera" />
                                                    <asp:BoundField DataField="FechaFinCarrera" HeaderText="Fecha Fin Carrera" ReadOnly="True" SortExpression="FechaFinCarrera" />
                                                    <asp:BoundField DataField="ComentarioDeConductor" HeaderText="Comentario" SortExpression="ComentarioDeConductor" />
                                                    <asp:BoundField DataField="Id" HeaderText="Id" SortExpression="Id" Visible="False" />
                                                    <asp:BoundField DataField="IdCliente" HeaderText="IdCliente" SortExpression="IdCliente" Visible="False" />
                                                    <asp:BoundField DataField="IdUbicacion" HeaderText="IdUbicacion" SortExpression="IdUbicacion" Visible="False" />
                                                    <asp:BoundField DataField="IdDestino" HeaderText="IdDestino" SortExpression="IdDestino" Visible="False" />
                                                    <asp:BoundField DataField="DescripcionServicio" HeaderText="DescripcionServicio" SortExpression="DescripcionServicio" Visible="False" />
                                                    <asp:BoundField DataField="Pago" HeaderText="Pago" SortExpression="Pago" Visible="False" />
                                                    <asp:BoundField DataField="Kilometro" HeaderText="Kilometro" SortExpression="Kilometro" Visible="False" />
                                                    <asp:BoundField DataField="Estado" HeaderText="Estado" SortExpression="Estado" Visible="False" />
                                                    <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                                    <asp:BoundField DataField="ComentarioDeCliente" HeaderText="ComentarioDeCliente" SortExpression="ComentarioDeCliente" Visible="False" />
                                                    <asp:CommandField EditText="Comentar" ShowEditButton="True" UpdateText="Comentar" />
                                                    <asp:BoundField DataField="Conversacion" HeaderText="Conversacion" ReadOnly="True" SortExpression="Conversacion">
                                                    <HeaderStyle Width="200px" />
                                                    </asp:BoundField>
                                                    <asp:TemplateField HeaderText="IngresoConver">
                                                        <ItemTemplate>
                                                            <asp:TextBox ID="TB_Conversar" runat="server" Font-Names="Segoe UI" Font-Size="10pt"></asp:TextBox>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Conversar" ShowHeader="False">
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandArgument='<%# Eval("Id") %>' CommandName="Enviar" Text="Enviar"></asp:LinkButton>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                                <FooterStyle BackColor="#990000" Font-Bold="True" ForeColor="White" />
                                                <HeaderStyle BackColor="#990000" Font-Bold="True" ForeColor="White" />
                                                <PagerStyle BackColor="#FFCC66" ForeColor="#333333" HorizontalAlign="Center" />
                                                <PagerTemplate>
                                                    <asp:TextBox ID="TB_Conversacion" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Text='<%# Eval("Id") %>'></asp:TextBox>
                                                </PagerTemplate>
                                                <RowStyle BackColor="#FFFBD6" ForeColor="#333333" />
                                                <SelectedRowStyle BackColor="#FFCC66" Font-Bold="True" ForeColor="Navy" />
                                                <SortedAscendingCellStyle BackColor="#FDF5AC" />
                                                <SortedAscendingHeaderStyle BackColor="#4D0000" />
                                                <SortedDescendingCellStyle BackColor="#FCF6C0" />
                                                <SortedDescendingHeaderStyle BackColor="#820000" />
                                            </asp:GridView>
                                            <asp:ObjectDataSource ID="ODS_Carreras" runat="server" DataObjectTypeName="Notificacion" SelectMethod="filtrarCarrera" TypeName="DaoConductor" UpdateMethod="comentar">
                                                <SelectParameters>
                                                    <asp:ControlParameter ControlID="TextBoxfiltrar" Name="fechaInicio" PropertyName="Text" Type="DateTime" />
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                            <br />
                                            <asp:Label ID="L_NoFiltro" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                        </td>
                                        <td>&nbsp;</td>
                                    </tr>
                                </table>
                                <table class="auto-style1">
                                    <tr>
                                        <td class="auto-style42">
                                            <CR:CrystalReportViewer ID="CRV_HistorialConductor" runat="server" AutoDataBind="True" EnableDatabaseLogonPrompt="False" EnableParameterPrompt="False" GroupTreeImagesFolderUrl="" Height="1269px" ReportSourceID="CRS_Historial" ToolbarImagesFolderUrl="" ToolPanelWidth="200px" Visible="False" Width="1082px" />
                                            <CR:CrystalReportSource ID="CRS_Historial" runat="server">
                                                <Report FileName="C:\Users\User\Downloads\Moto Deluxe\mt_deluxe\mt_deluxe\Reportes\HistorialCo.rpt">
                                                </Report>
                                            </CR:CrystalReportSource>
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="BG_Estado" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="Tabla_HistorialCarreras" EventName="RowCommand" />
                                <asp:AsyncPostBackTrigger ControlID="Tabla_Carreras" EventName="CallingDataMethods" />
                                <asp:AsyncPostBackTrigger ControlID="Tabla_Carreras" EventName="RowCommand" />
                            </Triggers>
                        </asp:UpdatePanel>
                        <br />
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
