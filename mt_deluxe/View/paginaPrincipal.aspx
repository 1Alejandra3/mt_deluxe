<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Controller/paginaPrincipal.aspx.cs" Inherits="View_paginaPrincipal" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="shortcut icon" href="~/Imagenes/logo.png" />
    <title>Mototaxi Deluxe</title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }
        .auto-style3 {
            width: 450px;
            text-align: center;
        }
        .auto-style4 {
            text-align: center;
        }
        .auto-style5 {
            text-align: left;
        }
        .auto-style6 {
            text-align: center;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            color: #FFFFFF;
            background-color:darkred;
            font-size: 13pt;
        }
                
        </style>
</head>
<body style="background-image: url('../Imagenes/fondo7.jpg'); background-repeat:repeat-x; background-attachment: fixed; background-size:contain;">
    <form id="form1" runat="server">
        <table class="auto-style1">
            <tr>
                <td>
                    <asp:Image ID="Portada" runat="server" ImageUrl="~/Imagenes/Portada.png" Width="1327px" />
                </td>
            </tr>
        </table>
        <div>
            <table class="auto-style1">
                <tr>
                    <td>
                        <asp:Image ID="Image1" runat="server" ImageUrl="~/Imagenes/Facilitamos tu movilidad hacia donde te dirijas.png" Width="1327px" />
                    </td>
                </tr>
            </table>
            <br />
            <table class="auto-style1">
                <tr>
                    <td class="auto-style4">
                        <asp:Label ID="L1" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="20pt" Text="¿Como deseas ingresar?" ForeColor="White"></asp:Label>
                    </td>
                </tr>
            </table>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style3">
                        <asp:ImageButton ID="IB_Cliente" runat="server" ImageUrl="~/Imagenes/Icono usuario.png" Width="30%" OnClick="IB_Cliente_Click" />
                    </td>
                    <td class="auto-style3">
                        <asp:ImageButton ID="IB_Conductor" runat="server" ImageUrl="~/Imagenes/Icono conductor.png" Width="30%" OnClick="IB_Conductor_Click" />
                    </td>
                    <td class="auto-style4">
                        <asp:ImageButton ID="IB_Administrador" runat="server" ImageUrl="~/Imagenes/Icono administrador.png" Width="30%" OnClick="IB_Administrador_Click" />
                    </td>
                </tr>
            </table>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style3">
                        <asp:Label ID="L_Cliente" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Cliente" ForeColor="White"></asp:Label>
                    </td>
                    <td class="auto-style3">
                        <asp:Label ID="L_Conductor" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Conductor" ForeColor="White"></asp:Label>
                    </td>
                    <td class="auto-style4">
                        <asp:Label ID="L_Administrador" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Administrador" ForeColor="White"></asp:Label>
                    </td>
                </tr>
            </table>
            <br />
            <table class="auto-style1">
                <tr>
                    <td class="auto-style5">
                        <asp:Image ID="Image2" runat="server" ImageUrl="~/Imagenes/Quienes somos.png" Width="1327px" />
                    </td>
                </tr>
            </table>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style6">Moto Deluxe</td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
