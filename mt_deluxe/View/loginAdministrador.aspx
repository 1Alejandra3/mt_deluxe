<%@ Page Title="Administrador" Language="C#" MasterPageFile="~/View/administradorMaster.master" AutoEventWireup="true" CodeFile="~/Controller/loginAdministrador.aspx.cs" Inherits="View_loginAdministrador" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
    .auto-style3 {
        text-align: center;
    }
        .auto-style4 {
        font-size: 15pt;
        font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
    }
        </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="auto-style3">
        <asp:Login ID="Login_Administrador" runat="server" BackColor="#FFFBD6" BorderColor="#FFDFAD" BorderPadding="4" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#333333" Height="200px" Width="675px" OnAuthenticate="Login_Administrador_Authenticate1">
            <InstructionTextStyle Font-Italic="True" ForeColor="Black" />
            <LayoutTemplate>
                <table cellpadding="4" cellspacing="0" style="border-collapse:collapse;">
                    <tr>
                        <td>
                            <table cellpadding="0" style="height:200px;width:675px;">
                                <tr>
                                    <td align="center" colspan="3" style="color:White;background-color:#990000;font-weight:bold;" class="auto-style4">Iniciar sesión</td>
                                </tr>
                                <tr>
                                    <td rowspan="2">
                                        <asp:Image ID="Image1" runat="server" ImageUrl="~/Imagenes/Icono administrador.png" Width="50%" />
                                    </td>
                                    <td align="right">
                                        <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserName" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt">Nombre de usuario:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="UserName" runat="server" Font-Size="12pt" Font-Names="Segoe UI"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName" ErrorMessage="El nombre de usuario es obligatorio." ToolTip="El nombre de usuario es obligatorio." ValidationGroup="Login_Administrador">*</asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="Password" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt">Contraseña:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="Password" runat="server" Font-Size="12pt" TextMode="Password" Font-Names="Segoe UI"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="Password" ErrorMessage="La contraseña es obligatoria." ToolTip="La contraseña es obligatoria." ValidationGroup="Login_Administrador">*</asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:CheckBox ID="RememberMe" runat="server" Text="Recordármelo la próxima vez." Font-Names="Segoe UI" Font-Size="12pt" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="3" style="color:Red;">
                                        <asp:Label ID="LN_Mensaje" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:Button ID="LoginButton" runat="server" BackColor="White" BorderColor="#CC9966" BorderStyle="Solid" BorderWidth="1px" CommandName="Login" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="#990000" Text="Inicio de sesión" ValidationGroup="Login_Administrador" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </LayoutTemplate>
            <LoginButtonStyle BackColor="White" BorderColor="#CC9966" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#990000" />
            <TextBoxStyle Font-Size="0.8em" />
            <TitleTextStyle BackColor="#990000" Font-Bold="True" Font-Size="0.9em" ForeColor="White" />
        </asp:Login>
</div>
</asp:Content>

