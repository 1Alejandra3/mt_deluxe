<%@ Page Title="Registro Conductor" Language="C#" MasterPageFile="~/View/conductorMaster.master" AutoEventWireup="true" CodeFile="~/Controller/registroConductor.aspx.cs" Inherits="View_registroConductor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
    .auto-style3 {
        text-align: center;
    }
        .auto-style5 {
            width: 100%;
        }
        .auto-style6 {
            text-align: center;
        }
        .auto-style9 {
            width: 309px;
            text-align: center;
        }
    .auto-style10 {
        width: 309px;
        height: 23px;
        text-align: center;
    }
    .auto-style11 {
        width: 246px;
        height: 23px;
            text-align: center;
        }
    .auto-style12 {
        width: 309px;
        text-align: center;
        height: 34px;
    }
    .auto-style13 {
        width: 246px;
        height: 34px;
            text-align: center;
        }
    .auto-style14 {
        width: 309px;
        text-align: center;
        height: 32px;
    }
    .auto-style15 {
        width: 246px;
        height: 32px;
            text-align: center;
        }
    .auto-style16 {
        width: 100%;
        height: 306px;
    }
        .auto-style18 {
            width: 246px;
            text-align: center;
        }
        .auto-style19 {
            text-align: center;
            height: 32px;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }
        .auto-style20 {
            font-size: 10pt;
        }
        .auto-style21 {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            font-size: 10pt;
        }
        .auto-style22 {
            width: 309px;
            text-align: center;
            height: 33px;
        }
        .auto-style23 {
            width: 246px;
            text-align: center;
            height: 33px;
        }
        .auto-style24 {
            text-align: center;
            height: 32px;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            width: 309px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <table class="auto-style5">
        <tr>
            <td class="auto-style6">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <asp:Label ID="Label2" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="30pt" Text="Registro Conductor"></asp:Label>
            </td>
        </tr>
    </table>
    <table class="auto-style5">
        <tr>
            <td class="auto-style6">
                <asp:Label ID="L_ExisteUsuario" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
            </td>
        </tr>
    </table>
    <table class="auto-style16">
        <tr>
            <td class="auto-style22">
                <asp:Label ID="Label3" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Nombre:"></asp:Label>
            </td>
            <td class="auto-style23">
            <asp:TextBox ID="TB_NombreCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Nombre" runat="server" ControlToValidate="TB_NombreCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                <br />
                <asp:RegularExpressionValidator ID="REV_Nombre" runat="server" ControlToValidate="TB_NombreCo" ErrorMessage="Caracteres invalidos" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="[a-zA-Z ]+"></asp:RegularExpressionValidator>
            </td>
        </tr>
        <tr>
            <td class="auto-style9">
                <asp:Label ID="Label4" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Apellido:"></asp:Label>
            &nbsp;</td>
            <td class="auto-style18">
            <asp:TextBox ID="TB_ApellidoCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Apellido" runat="server" ControlToValidate="TB_ApellidoCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                <br />
                <asp:RegularExpressionValidator ID="REV_Apellido" runat="server" ControlToValidate="TB_ApellidoCo" ErrorMessage="Caracteres invalidos" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="[a-zA-Z ]+"></asp:RegularExpressionValidator>
            </td>
        </tr>
        <tr>
            <td class="auto-style9">
                <asp:Label ID="Label5" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Fecha de nacimiento:"></asp:Label>
            </td>
            <td class="auto-style18">
            <asp:TextBox ID="TB_FechaCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_FechaNacimiento" runat="server" ControlToValidate="TB_FechaCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                <br />
                <span class="auto-style21">dd-mm-aaaa<br />
                <asp:RegularExpressionValidator ID="REV_Fecha" runat="server" ControlToValidate="TB_FechaCo" ErrorMessage="Fecha invalida" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="^([0-2][0-9]|3[0-1])(\/|-)(0[1-9]|1[0-2])\2(\d{4})$"></asp:RegularExpressionValidator>
                </span></td>
        </tr>
        <tr>
            <td class="auto-style9">
                <asp:Label ID="Label6" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Email:"></asp:Label>
            </td>
            <td class="auto-style18">
            <asp:TextBox ID="TB_EmailCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Email" runat="server" ControlToValidate="TB_EmailCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                <br />
                <asp:RegularExpressionValidator ID="REV_Email" runat="server" ControlToValidate="TB_EmailCo" ErrorMessage="Ingrese una direccion de correo valida" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"></asp:RegularExpressionValidator>
            </td>
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" />
        </tr>
        <tr>
            <td class="auto-style12">
                <asp:Label ID="Label7" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Placa:"></asp:Label>
            </td>
            <td class="auto-style13">
            <asp:TextBox ID="TB_PlacaCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Placa" runat="server" ControlToValidate="TB_PlacaCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                <br />
                <asp:RegularExpressionValidator ID="REV_Placa" runat="server" ControlToValidate="TB_PlacaCo" ErrorMessage="Ingrese una placa valida" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="[a-zA-Z]{3}[0-9]{2}[a-zA-Z]|[a-zA-Z]{3}[0-9]{2}"></asp:RegularExpressionValidator>
            </td>
        </tr>
        <tr>
            <td class="auto-style14">
                <asp:Label ID="Label8" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Celular:"></asp:Label>
            </td>
            <td class="auto-style15">
            <asp:TextBox ID="TB_CelularCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Celular" runat="server" ControlToValidate="TB_CelularCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                <br />
                <asp:RegularExpressionValidator ID="REV_Celular" runat="server" ControlToValidate="TB_CelularCo" ErrorMessage="Numero invalido" Font-Names="Segoe UI" Font-Size="10pt" ValidationExpression="^([0-9])*$"></asp:RegularExpressionValidator>
            </td>
        </tr>
        <tr>
            <td class="auto-style24">
                <asp:Label ID="Label11" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Cedula"></asp:Label>
            </td>
            <td class="auto-style19">
                <asp:TextBox ID="TB_CedulaCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Cedula" runat="server" ControlToValidate="TB_CedulaCo" ErrorMessage="*" Font-Bold="True" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td class="auto-style19" colspan="2">
                <strong><span class="auto-style20">Nota: </span></strong><span class="auto-style20">Es necesario la placa del vehiculo y la cedula para investigar si existen infracciones de transito (el numero de cedula no volverá a ser utilizado para otros fines)</span></td>
        </tr>
        <tr>
            <td class="auto-style10">
                <asp:Label ID="Label9" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Usuario:"></asp:Label>
            </td>
            <td class="auto-style11">
            <asp:TextBox ID="TB_UsuarioCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Usuario" runat="server" ControlToValidate="TB_UsuarioCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td class="auto-style9">
                <asp:Label ID="Label10" runat="server" Font-Bold="True" Font-Names="Segoe UI" Font-Size="15pt" Text="Contraseña:"></asp:Label>
            </td>
            <td class="auto-style18">
            <asp:TextBox ID="TB_ContraseñaCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" Width="200px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="RFV_TB_Contraseña" runat="server" ControlToValidate="TB_ContraseñaCo" ErrorMessage="*" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
            </td>
        </tr>
    </table>
    <br />
<table class="auto-style5">
    <tr>
        <td class="auto-style6">
            <asp:Button ID="B_Registrar_Co" runat="server" Font-Bold="True" Font-Names="Segoe UI" Text="Registrar" OnClick="B_Registrar_Co_Click" Font-Size="12pt" />
        </td>
    </tr>
</table>
    </asp:Content>

