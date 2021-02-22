<%@ Page Title="Registro Cliente" Language="C#" MasterPageFile="~/View/clienteMaster.master" AutoEventWireup="true" CodeFile="~/Controller/registroCliente.aspx.cs" Inherits="View_registroCliente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
    .auto-style3 {
        text-align: center;
    }
    .auto-style4 {
        width: 309px;
        text-align: center;
    }
    .auto-style5 {
        font-size: 15pt;
    }
        .auto-style7 {
            width: 2px;
            text-align: center;
        }
        .auto-style8 {
            width: 100%;
        }
        .auto-style9 {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            font-size: 10pt;
        }
        .auto-style10 {
            width: 309px;
            text-align: center;
            height: 67px;
        }
        .auto-style11 {
            text-align: center;
            height: 67px;
        }
        .auto-style12 {
            width: 309px;
            text-align: center;
            height: 65px;
        }
        .auto-style13 {
            text-align: center;
            height: 65px;
        }
        </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <table class="auto-style8">
        <tr>
            <td class="auto-style3">
                <asp:Label ID="Label9" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="30pt" Text="Registro Cliente"></asp:Label>
            </td>
        </tr>
    </table>
    <table class="auto-style8">
        <tr>
            <td class="auto-style3">
                <asp:Label ID="L_ExisteUsuario" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
            </td>
        </tr>
    </table>
<table class="auto-style8">
    <tr>
        <td class="auto-style10">
            <asp:Label ID="Label3" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Nombre:"></asp:Label>
        </td>
        <td class="auto-style11">
            <asp:TextBox ID="TB_NombreCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
            <asp:RequiredFieldValidator ID="RFV_TB_Nombre" runat="server" ControlToValidate="TB_NombreCl" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
            <br />
            <asp:RegularExpressionValidator ID="REV_Nombre" runat="server" ControlToValidate="TB_NombreCl" ErrorMessage="Caracteres invalidos" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="[a-zA-Z ]+"></asp:RegularExpressionValidator>
        </td>
    </tr>
    <tr>
        <td class="auto-style12">
            <asp:Label ID="Label4" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Apellido:"></asp:Label>
        </td>
        <td class="auto-style13">
            <asp:TextBox ID="TB_ApellidoCl" runat="server" Font-Names="Times New Roman" Font-Size="12pt" Width="200px"></asp:TextBox>
            <asp:RequiredFieldValidator ID="RFV_TB_Apellido1" runat="server" ControlToValidate="TB_ApellidoCl" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
            <br />
            <asp:RegularExpressionValidator ID="REV_Apellido" runat="server" ControlToValidate="TB_ApellidoCl" ErrorMessage="Caracteres invalidos" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="[a-zA-Z ]+"></asp:RegularExpressionValidator>
        </td>
    </tr>
    <tr>
        <td class="auto-style4">
            <asp:Label ID="Label5" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Fecha de Nacimiento:"></asp:Label>
        </td>
        <td class="auto-style3">
            <asp:TextBox ID="TB_FechaNacimientoCl" runat="server" Font-Names="Times New Roman" Font-Size="12pt" Width="200px"></asp:TextBox>
            <asp:RequiredFieldValidator ID="RFV_TB_FechaNacimiento" runat="server" ControlToValidate="TB_FechaNacimientoCl" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
            <br />
            <span class="auto-style9">dd-mm-aaaa<br />
            <asp:RegularExpressionValidator ID="REV_Fecha" runat="server" ControlToValidate="TB_FechaNacimientoCl" ErrorMessage="Fecha Invalida" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="^([0-2][0-9]|3[0-1])(\/|-)(0[1-9]|1[0-2])\2(\d{4})$"></asp:RegularExpressionValidator>
            </span></td>
    </tr>
    <tr>
        <td class="auto-style4">
            <asp:Label ID="Label6" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Correo Electronico:"></asp:Label>
        </td>
        <td class="auto-style3">
            <asp:TextBox ID="TB_CorreoCl" runat="server" Font-Names="Times New Roman" Font-Size="12pt" Width="200px"></asp:TextBox>
            <asp:RequiredFieldValidator ID="RFV_TB_Correo" runat="server" ControlToValidate="TB_CorreoCl" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
            <br />
            <span class="auto-style9">
            <asp:RegularExpressionValidator ID="REV_Email" runat="server" ControlToValidate="TB_CorreoCl" ErrorMessage="Ingrese una dirección de correo valida" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"></asp:RegularExpressionValidator>
            </span>
        </td>
    </tr>
    <tr>
        <td class="auto-style4">
            <asp:Label ID="Label7" runat="server" CssClass="auto-style5" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Usuario:"></asp:Label>
        </td>
        <td class="auto-style3">
            <asp:TextBox ID="TB_UsuarioCl" runat="server" Font-Names="Times New Roman" Font-Size="12pt" Width="200px"></asp:TextBox>
            <asp:RequiredFieldValidator ID="RFV_TB_Usuario" runat="server" ControlToValidate="TB_UsuarioCl" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
        </td>
    </tr>
    <tr>
        <td class="auto-style4">
            <asp:Label ID="Label8" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Contraseña:"></asp:Label>
        </td>
        <td class="auto-style3">
            <asp:TextBox ID="TB_ContraseñaCl" runat="server" Font-Names="Times New Roman" Font-Size="12pt" Width="200px"></asp:TextBox>
            <asp:RequiredFieldValidator ID="RFV_Constraseña" runat="server" ControlToValidate="TB_ContraseñaCl" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
        </td>
    </tr>
</table>
<br />
<table class="auto-style8">
    <tr>
        <td class="auto-style7">
            <asp:Button ID="B_Registrar" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt" Text="Registrar" OnClick="B_Registrar_Click" />
        </td>
    </tr>
</table>
</asp:Content>

