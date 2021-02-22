<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Controller/administrador.aspx.cs" Inherits="View_administrador" %>

<%@ Register assembly="CrystalDecisions.Web, Version=13.0.4000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" namespace="CrystalDecisions.Web" tagprefix="CR" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Principal Administrador</title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }
        .auto-style2 {
            width: 291px;
            text-align: center;
        }
        .auto-style6 {
            width: 252px;
            text-align: left;
        }
        .auto-style8 {
            width: 283px;
            text-align: center;
        }
        .auto-style9 {
            text-align: center;
            width: 340px;
        }
        .auto-style10 {
            height: 21px;
            text-align: center;
        }
        .auto-style12 {
            width: 673px;
            text-align: center;
        }
        .auto-style14 {
            width: 17px;
        }
        .auto-style15 {
            text-align: center;
        }
        .auto-style16 {
            width: 315px;
        }
        .auto-style22 {
            width: 1265px;
        }
        .auto-style25 {
            width: 252px;
        }
        .auto-style27 {
            width: 252px;
            text-align: right;
        }
        .auto-style28 {
            height: 41px;
            text-align: center;
        }
        .auto-style31 {
            width: 253px;
        }
        .auto-style32 {
            width: 253px;
            text-align: right;
        }
        .auto-style46 {
            width: 315px;
            height: 23px;
        }
        .auto-style47 {
            width: 316px;
            height: 23px;
        }
        .auto-style48 {
            width: 316px;
        }
        .auto-style49 {
            width: 417px;
        }
        .auto-style50 {
            width: 692px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style49">&nbsp;</td>
                    <td class="auto-style50">&nbsp;</td>
                    <td>
                        <asp:Menu ID="Menu_Administrador" runat="server" BackColor="#FFFBD6" DynamicHorizontalOffset="2" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="#990000" StaticSubMenuIndent="10px">
                            <DynamicHoverStyle BackColor="#990000" ForeColor="White" />
                            <DynamicMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                            <DynamicMenuStyle BackColor="#FFFBD6" />
                            <DynamicSelectedStyle BackColor="#FFCC66" />
                            <Items>
                                <asp:MenuItem NavigateUrl="~/View/cerrarSesionA.aspx" Text="Cerrar Sesión" Value="Cerrar Sesión"></asp:MenuItem>
                            </Items>
                            <StaticHoverStyle BackColor="#990000" ForeColor="White" />
                            <StaticMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                            <StaticSelectedStyle BackColor="#FFCC66" />
                        </asp:Menu>
                    </td>
                </tr>
            </table>
            <asp:ScriptManager ID="ScriptManager1" runat="server">
                        </asp:ScriptManager>
            <table class="auto-style1">
                <tr>
                    <td>
        <asp:UpdatePanel ID="UpdatePanelAdministrador" runat="server">
            <ContentTemplate>
                <table class="auto-style1">
                    <tr>
                        <td class="auto-style2">
                            <asp:Button ID="Button1" runat="server" Text=" Conductor" OnClick="Button1_Click" />
                        </td>
                        <td class="auto-style9">
                            <asp:Button ID="B_Cliente" runat="server" OnClick="B_Cliente_Click" Text="Cliente" />
                        </td>
                        <td class="auto-style8">
                            <asp:Button ID="B_pago" runat="server" OnClick="B_pago_Click" Text="Pago Conductor" />
                        </td>
                        <td class="auto-style15">
                            <asp:Button ID="B_Sancion" runat="server" OnClick="B_Sancion_Click" Text="Sancion" />
                        </td>
                    </tr>
                </table>
                <table class="auto-style22">
                    <tr>
                        <td class="auto-style15" colspan="5">
                            <asp:Label ID="L_AceptarConductor" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Conductor"></asp:Label>
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style16">&nbsp;</td>
                        <td class="auto-style6">
                            <div class="auto-style15">
                            </div>
                            <div class="auto-style15">
                                <asp:Label ID="L_PendAceptar" runat="server" Font-Names="Segoe UI" Font-Size="15pt" Text="Pendientes y Sancionados  para Aceptar"></asp:Label>
                                <br />
                                <asp:GridView ID="tabla_Conductor" runat="server" AutoGenerateColumns="False" CellPadding="4" DataKeyNames="IdConductor" DataSourceID="ODS_SolicitudConductor" ForeColor="#333333" GridLines="None" OnRowCommand="tabla_Conductor_RowCommand">
                                    <AlternatingRowStyle BackColor="White" />
                                    <Columns>
                                        <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                        <asp:BoundField DataField="Nombre" HeaderText="Nombre" SortExpression="Nombre" />
                                        <asp:BoundField DataField="Apellido" HeaderText="Apellido" SortExpression="Apellido" />
                                        <asp:BoundField DataField="Cedula" HeaderText="Cedula" SortExpression="Cedula" />
                                        <asp:BoundField DataField="FechaDeNacimiento" HeaderText="FechaDeNacimiento" SortExpression="FechaDeNacimiento" DataFormatString="{0:dd/MM/yyyy}"/>
                                        <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
                                        <asp:BoundField DataField="Placa" HeaderText="Placa" SortExpression="Placa" />
                                        <asp:BoundField DataField="Celular" HeaderText="Celular" SortExpression="Celular" />
                                        <asp:BoundField DataField="Usuario" HeaderText="Usuario" SortExpression="Usuario" Visible="False" />
                                        <asp:BoundField DataField="Contrasena" HeaderText="Contrasena" SortExpression="Contrasena" Visible="False" />
                                        <asp:BoundField DataField="Modificado" HeaderText="Modificado" SortExpression="Modificado" Visible="False" />
                                        <asp:BoundField DataField="Sesion" HeaderText="Sesion" SortExpression="Sesion" Visible="False" />
                                        <asp:BoundField DataField="IdEstado" HeaderText="IdEstado" SortExpression="IdEstado" Visible="False" />
                                        <asp:BoundField DataField="DispEstado" HeaderText="DispEstado" SortExpression="DispEstado" Visible="False" />
                                        <asp:TemplateField HeaderText="Solictud" ShowHeader="False">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandArgument='<%# Eval("IdConductor") %>' Text="Aceptar"></asp:LinkButton>
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
                                <asp:ObjectDataSource ID="ODS_SolicitudConductor" runat="server" SelectMethod="mostrar" TypeName="DaoAdministrador"></asp:ObjectDataSource>
                                <br />
                                <asp:Label ID="L_confirmacion" runat="server"></asp:Label>
                            </div>
                        </td>
                        <td class="auto-style48">&nbsp;</td>
                        <td class="auto-style48">
                            <asp:GridView ID="Tabla_Conductores" runat="server" AutoGenerateColumns="False" CellPadding="4" DataSourceID="ODS_MostrarConductor" ForeColor="#333333" GridLines="None">
                                <AlternatingRowStyle BackColor="White" />
                                <Columns>
                                    <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                    <asp:BoundField DataField="Nombre" HeaderText="Nombre" SortExpression="Nombre" />
                                    <asp:BoundField DataField="Apellido" HeaderText="Apellido" SortExpression="Apellido" />
                                    <asp:BoundField DataField="Cedula" HeaderText="Cedula" SortExpression="Cedula" />
                                    <asp:BoundField DataField="FechaDeNacimiento" HeaderText="FechaDeNacimiento" SortExpression="FechaDeNacimiento" DataFormatString="{0:dd/MM/yyyy}"/>
                                    <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
                                    <asp:BoundField DataField="Placa" HeaderText="Placa" SortExpression="Placa" />
                                    <asp:BoundField DataField="Celular" HeaderText="Celular" SortExpression="Celular" />
                                    <asp:BoundField DataField="Usuario" HeaderText="Usuario" SortExpression="Usuario" />
                                    <asp:BoundField DataField="Contrasena" HeaderText="Contrasena" SortExpression="Contrasena" Visible="False" />
                                    <asp:BoundField DataField="Modificado" HeaderText="Modificado" SortExpression="Modificado" Visible="False" />
                                    <asp:BoundField DataField="Sesion" HeaderText="Sesion" SortExpression="Sesion" />
                                    <asp:BoundField DataField="IdEstado" HeaderText="IdEstado" SortExpression="IdEstado" Visible="False" />
                                    <asp:BoundField DataField="DispEstado" HeaderText="DispEstado" SortExpression="DispEstado" Visible="False" />
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
                            <asp:ObjectDataSource ID="ODS_MostrarConductor" runat="server" SelectMethod="MostrarConductores" TypeName="DaoAdministrador"></asp:ObjectDataSource>
                        </td>
                        <td class="auto-style48">&nbsp;</td>
                    </tr>
                </table>
                <table class="auto-style1">
                    <tr>
                        <td class="auto-style10" colspan="3">
                            <asp:Label ID="L_Cliente" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Cliente"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style12">
                            <asp:Label ID="L_SancAceptar" runat="server" Font-Names="Segoe UI" Font-Size="15pt" Text="Sancionados  para Aceptar"></asp:Label>
                            <br />
                            <asp:GridView ID="Tabla_AceptarCl" runat="server" AutoGenerateColumns="False" CellPadding="4" DataSourceID="ODS_ClienteAceptar" ForeColor="#333333" GridLines="None" OnRowCommand="GridView1_RowCommand">
                                <AlternatingRowStyle BackColor="White" />
                                <Columns>
                                    <asp:BoundField DataField="IdCliente" HeaderText="IdCliente" SortExpression="IdCliente" />
                                    <asp:BoundField DataField="Nombrecl" HeaderText="Nombrecl" SortExpression="Nombrecl" />
                                    <asp:BoundField DataField="Apellido" HeaderText="Apellido" SortExpression="Apellido" />
                                    <asp:BoundField DataField="FechaDeNacimiento" HeaderText="FechaDeNacimiento" SortExpression="FechaDeNacimiento" DataFormatString="{0:dd/MM/yyyy}"/>
                                    <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
                                    <asp:BoundField DataField="Usuario" HeaderText="Usuario" SortExpression="Usuario" Visible="False" />
                                    <asp:BoundField DataField="Contrasena" HeaderText="Contrasena" SortExpression="Contrasena" Visible="False" />
                                    <asp:BoundField DataField="Modificado" HeaderText="Modificado" SortExpression="Modificado" Visible="False" />
                                    <asp:BoundField DataField="Sesion" HeaderText="Sesion" SortExpression="Sesion" />
                                    <asp:BoundField DataField="FechaSancion" HeaderText="FechaSancion" SortExpression="FechaSancion" Visible="False" />
                                    <asp:TemplateField HeaderText="Sancionado" ShowHeader="False">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False"  CommandArgument='<%# Eval("IdCliente") %>' Text="Aceptar"></asp:LinkButton>
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
                            <asp:ObjectDataSource ID="ODS_ClienteAceptar" runat="server" SelectMethod="mostrarClienteAceptar" TypeName="DaoAdministrador"></asp:ObjectDataSource>
                            <asp:Label ID="L_AceptarCl" runat="server"></asp:Label>
                        </td>
                        <td class="auto-style14">
                            <div>
                                <br />
                            </div>
                        </td>
                        <td>
                            <asp:GridView ID="Tabla_cliente" runat="server" AutoGenerateColumns="False" CellPadding="4" DataSourceID="ODS_Cliente" ForeColor="#333333" GridLines="None">
                                <AlternatingRowStyle BackColor="White" />
                                <Columns>
                                    <asp:BoundField DataField="IdCliente" HeaderText="IdCliente" SortExpression="IdCliente" Visible="False" />
                                    <asp:BoundField DataField="Nombrecl" HeaderText="Nombrecl" SortExpression="Nombrecl" />
                                    <asp:BoundField DataField="Apellido" HeaderText="Apellido" SortExpression="Apellido" />
                                    <asp:BoundField DataField="FechaDeNacimiento" DataFormatString="{0:dd/MM/yyyy}" HeaderText="FechaDeNacimiento" SortExpression="FechaDeNacimiento" />
                                    <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
                                    <asp:BoundField DataField="Usuario" HeaderText="Usuario" SortExpression="Usuario" Visible="False" />
                                    <asp:BoundField DataField="Contrasena" HeaderText="Contrasena" SortExpression="Contrasena" Visible="False" />
                                    <asp:BoundField DataField="Modificado" HeaderText="Modificado" SortExpression="Modificado" Visible="False" />
                                    <asp:BoundField DataField="Sesion" HeaderText="Sesion" SortExpression="Sesion" Visible="False" />
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
                            <asp:ObjectDataSource ID="ODS_Cliente" runat="server" SelectMethod="mostrarCliente" TypeName="DaoAdministrador"></asp:ObjectDataSource>
                        </td>
                    </tr>
                </table>
                <table class="auto-style22">
                    <tr>
                        <td class="auto-style28" colspan="5">
                            <asp:Label ID="L_Pago" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Pago Conductor"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style25">&nbsp;</td>
                        <td class="auto-style27">
                            <br />
                            <asp:Label ID="L_ConductorNombre" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="14pt" Text="Busca tu nombre"></asp:Label>
                        </td>
                        <td class="auto-style32">
                            <br />
                            <asp:DropDownList ID="DropDownListConductor" AppendDataBoundItems="true" runat="server" DataSourceID="ODS_Conductores" DataTextField="NombreCo" DataValueField="IdConductor">
                                 <asp:ListItem Text="-- Seleccione --" Value="0"/>
                            </asp:DropDownList>
                            <asp:ObjectDataSource ID="ODS_Conductores" runat="server" SelectMethod="notificacion" TypeName="DaoAdministrador"></asp:ObjectDataSource>
                        </td>
                        <td class="auto-style31">
                            <br />
                            <asp:Button ID="B_guardar" runat="server" Text="Generar Pago" OnClick="B_guardar_Click1" />
                            <br />
                        </td>
                        <td class="auto-style31">&nbsp;</td>
                    </tr>
                </table>
                <table class="auto-style22">
                    <tr>
                        <td class="auto-style15" colspan="5">
                            <asp:Label ID="L_Sancionar" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Sancionar Cliente y Conductor"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style46"></td>
                        <td class="auto-style47">
                            <br />
                            <asp:GridView ID="tabla_SancionarConductor" runat="server" AutoGenerateColumns="False" CellPadding="4" DataSourceID="ODS_CarreraConductor" ForeColor="#333333" GridLines="None" DataKeyNames="Id" OnRowCommand="tabla_SancionarConductor_RowCommand">
                                <AlternatingRowStyle BackColor="White" />
                                <Columns>
                                    <asp:BoundField DataField="Conductor" HeaderText="Conductor" SortExpression="Conductor" />
                                    <asp:BoundField DataField="NombreCl" HeaderText="NombreCl" SortExpression="NombreCl" />
                                    <asp:BoundField DataField="ComentarioDeCliente" HeaderText="ComentarioDeCliente" SortExpression="ComentarioDeCliente" />
                                    <asp:BoundField DataField="FechaFinCarrera" HeaderText="Fecha Comentario" SortExpression="FechaFinCarrera"/>
                                    <asp:BoundField DataField="Sesion" HeaderText="Estado" SortExpression="Sesion" Visible="true" />
                                    <asp:BoundField DataField="Estado" HeaderText="Estado" SortExpression="Estado" Visible="False" />
                                    <asp:BoundField DataField="Id" HeaderText="Id" SortExpression="Id" Visible="False" />
                                    <asp:BoundField DataField="IdCliente" HeaderText="IdCliente" SortExpression="IdCliente" Visible="False" />
                                    <asp:BoundField DataField="IdUbicacion" HeaderText="IdUbicacion" SortExpression="IdUbicacion" Visible="False" />
                                    <asp:BoundField DataField="IdDestino" HeaderText="IdDestino" SortExpression="IdDestino" Visible="False" />
                                    <asp:BoundField DataField="DescripcionServicio" HeaderText="DescripcionServicio" SortExpression="DescripcionServicio" Visible="False" />
                                    <asp:BoundField DataField="Tarifa" HeaderText="Tarifa" SortExpression="Tarifa" Visible="False" />
                                    <asp:BoundField DataField="FechaCarrera" HeaderText="FechaCarrera" SortExpression="FechaCarrera" Visible="False" />
                                    <asp:BoundField DataField="Pago" HeaderText="Pago" SortExpression="Pago" Visible="False" />
                                    <asp:BoundField DataField="Kilometro" HeaderText="Kilometro" SortExpression="Kilometro" Visible="False" />
                                    <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                    <asp:BoundField DataField="ComentarioDeConductor" HeaderText="ComentarioDeConductor" SortExpression="ComentarioDeConductor" Visible="False" />
                                    <asp:BoundField DataField="Destino" HeaderText="Destino" SortExpression="Destino" Visible="False" />
                                    <asp:BoundField DataField="Ubicacion" HeaderText="Ubicacion" SortExpression="Ubicacion" Visible="False" />
                                    <asp:BoundField DataField="MetodoPago" HeaderText="MetodoPago" SortExpression="MetodoPago" Visible="False" />
                                    <asp:TemplateField HeaderText="Sancionar" ShowHeader="False">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" Text="Aceptar" CommandArgument='<%# Eval("IdConductor", "{0:N}") %>'></asp:LinkButton>
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
                            <asp:ObjectDataSource ID="ODS_CarreraConductor" runat="server" SelectMethod="mostrarCarreraConductor" TypeName="DaoAdministrador"></asp:ObjectDataSource>
                        </td>
                        <td class="auto-style47">
                            <br />
                        </td>
                        <td class="auto-style47">
                            <br />
                            <br />
                            <asp:GridView ID="tabla_SancionarCliente" runat="server" AutoGenerateColumns="False" CellPadding="4" DataSourceID="ODS_ServicioCliente" ForeColor="#333333" GridLines="None" DataKeyNames="Id" OnRowCommand="tabla_SancionarCliente_RowCommand">
                                <AlternatingRowStyle BackColor="White" />
                                <Columns>
                                    <asp:BoundField DataField="NombreCl" HeaderText="NombreCl" SortExpression="NombreCl" />
                                    <asp:BoundField DataField="Conductor" HeaderText="Conductor" SortExpression="Conductor" />
                                    <asp:BoundField DataField="ComentarioDeConductor" HeaderText="ComentarioDeConductor" SortExpression="ComentarioDeConductor" />
                                    <asp:BoundField DataField="FechaFinCarrera" HeaderText="Fecha Comentario" SortExpression="FechaFinCarrera" />
                                    <asp:BoundField DataField="Sesion" HeaderText="Estado" SortExpression="Sesion" Visible="true" />
                                    <asp:BoundField DataField="Id" HeaderText="Id" SortExpression="Id" Visible="False" />
                                    <asp:BoundField DataField="IdCliente" HeaderText="IdCliente" SortExpression="IdCliente" Visible="False" />
                                    <asp:BoundField DataField="IdUbicacion" HeaderText="IdUbicacion" SortExpression="IdUbicacion" Visible="False" />
                                    <asp:BoundField DataField="IdDestino" HeaderText="IdDestino" SortExpression="IdDestino" Visible="False" />
                                    <asp:BoundField DataField="DescripcionServicio" HeaderText="DescripcionServicio" SortExpression="DescripcionServicio" Visible="False" />
                                    <asp:BoundField DataField="Tarifa" HeaderText="Tarifa" SortExpression="Tarifa" Visible="False" />
                                    <asp:BoundField DataField="FechaCarrera" HeaderText="FechaCarrera" SortExpression="FechaCarrera" Visible="False" />
                                    <asp:BoundField DataField="Pago" HeaderText="Pago" SortExpression="Pago" Visible="False" />
                                    <asp:BoundField DataField="Kilometro" HeaderText="Kilometro" SortExpression="Kilometro" Visible="False" />
                                    <asp:BoundField DataField="Estado" HeaderText="Estado" SortExpression="Estado" Visible="False" />
                                    <asp:BoundField DataField="IdConductor" HeaderText="IdConductor" SortExpression="IdConductor" Visible="False" />
                                    <asp:BoundField DataField="ComentarioDeCliente" HeaderText="ComentarioDeCliente" SortExpression="ComentarioDeCliente" Visible="False" />
                                    <asp:BoundField DataField="Destino" HeaderText="Destino" SortExpression="Destino" Visible="False" />
                                    <asp:BoundField DataField="Ubicacion" HeaderText="Ubicacion" SortExpression="Ubicacion" Visible="False" />
                                    <asp:BoundField DataField="MetodoPago" HeaderText="MetodoPago" SortExpression="MetodoPago" Visible="False" />
                                    <asp:TemplateField HeaderText="Sancionar" ShowHeader="False">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="false" CommandName="" Text="Aceptar" CommandArgument='<%# Eval("IdCliente", "{0:N}") %>'></asp:LinkButton>
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
                            <asp:ObjectDataSource ID="ODS_ServicioCliente" runat="server" SelectMethod="mostrarServiciosCliente" TypeName="DaoAdministrador"></asp:ObjectDataSource>
                            <br />
                        </td>
                        <td class="auto-style47"></td>
                    </tr>
                </table>
                <table class="auto-style1">
                    <tr>
                        <td>
                            <CR:CrystalReportViewer ID="CRV_Desprendible" runat="server" AutoDataBind="True" EnableDatabaseLogonPrompt="False" EnableParameterPrompt="False" GroupTreeImagesFolderUrl="" Height="1202px" ReportSourceID="CRS_Desprendible" ToolbarImagesFolderUrl="" ToolPanelWidth="200px" Visible="False" Width="1104px" />
                            <CR:CrystalReportSource ID="CRS_Desprendible" runat="server">
                                <Report FileName="C:\Users\User\Downloads\Moto Deluxe\mt_deluxe\mt_deluxe\Reportes\DesprendiblesCo.rpt">
                                </Report>
                            </CR:CrystalReportSource>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </asp:UpdatePanel>
                    </td>
                    <td>
                        &nbsp;</td>
                    <td>
                        &nbsp;</td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
