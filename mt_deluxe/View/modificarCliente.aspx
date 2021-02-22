<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Controller/modificarCliente.aspx.cs" Inherits="View_modificarCliente" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Modificar Datos Cliente</title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
            border-radius: 75px;
        }
        .auto-style2 {
            width: 100%;
        }
        .auto-style3 {
            text-align: center;
        }
        .auto-style4 {
            width: 312px;
        }
        .auto-style5 {
            width: 312px;
            text-align: center;
        }
        .auto-style6 {
            width: 312px;
            text-align: right;
        }
        .auto-style7 {
            width: 312px;
            text-align: center;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            font-size: 10pt;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table class="auto-style1">
                <tr>
                    <td>
                        <asp:Image ID="Image1" runat="server" ImageUrl="~/Imagenes/Portada.png" CssClass="auto-style1" />
                    </td>
                </tr>
            </table>
            <table class="auto-style2">
                <tr>
                    <td>
                        <asp:HyperLink ID="HL_VolverCliente" runat="server" Font-Italic="True" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="Black" NavigateUrl="~/View/cliente.aspx">◄ Volver a Principal</asp:HyperLink>
                    </td>
                </tr>
            </table>
            <table class="auto-style2">
                <tr>
                    <td class="auto-style3">
                        <asp:Label ID="Label1" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="Datos Personales"></asp:Label>
                    </td>
                </tr>
            </table>
            <table class="auto-style2">
                <tr>
                    <td class="auto-style3">
                        <asp:Image ID="Image2" runat="server" ImageUrl="~/Imagenes/Icono usuario.png" Width="10%" />
                    </td>
                </tr>
            </table>
            <br />
            <table class="auto-style2">
                <tr>
                    <td class="auto-style4">&nbsp;</td>
                    <td class="auto-style6">
                        <asp:Label ID="Label2" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Nombre"></asp:Label>
                    </td>
                    <td class="auto-style5">
                        <asp:TextBox ID="TB_MF_NombreCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
                    </td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style4">&nbsp;</td>
                    <td class="auto-style6">
                        <asp:Label ID="Label3" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Apellido"></asp:Label>
                    </td>
                    <td class="auto-style5">
                        <asp:TextBox ID="TB_MF_ApellidoCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
                    </td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style4" rowspan="2">&nbsp;</td>
                    <td class="auto-style6" rowspan="2">
                        <asp:Label ID="Label4" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Fecha de Nacimiento"></asp:Label>
                    </td>
                    <td class="auto-style5">
                        <asp:TextBox ID="TB_MF_FechaNacCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
                    </td>
                    <td rowspan="2">&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style7">dd - mm - aaaa</td>
                </tr>
                <tr>
                    <td class="auto-style4">&nbsp;</td>
                    <td class="auto-style6">
                        <asp:Label ID="Label5" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Correo Electronico"></asp:Label>
                    </td>
                    <td class="auto-style5">
                        <asp:TextBox ID="TB_MF_CorreoCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
                    </td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style4">&nbsp;</td>
                    <td class="auto-style6">
                        <asp:Label ID="Label6" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Usuario"></asp:Label>
                    </td>
                    <td class="auto-style5">
                        <asp:TextBox ID="TB_MF_UsuarioCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
                    </td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style4">&nbsp;</td>
                    <td class="auto-style6">
                        <asp:Label ID="Label7" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Contraseña"></asp:Label>
                    </td>
                    <td class="auto-style5">
                        <asp:TextBox ID="TB_MF_ContraseñaCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>
            <br />
            <table class="auto-style2">
                <tr>
                    <td class="auto-style3">
                        <asp:Button ID="B_ModificarCl" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Guardar" OnClick="B_ModificarCl_Click" />
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
