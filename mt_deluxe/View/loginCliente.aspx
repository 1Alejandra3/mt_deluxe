<%@ Page Title="Cliente" Language="C#" MasterPageFile="~/View/clienteMaster.master" AutoEventWireup="true" CodeFile="~/Controller/loginCliente.aspx.cs" Inherits="View_loginCliente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
    .auto-style3 {
        text-align: center;
    }
        .auto-style4 {
            width: 100%;
        }
        .auto-style5 {
            height: 28px;
        text-align: center;
    }
        .auto-style6 {
            font-size: 15pt;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }
    .auto-style7 {
        text-align: left;
        width: 681px;
    }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="auto-style7">
        <asp:Login ID="Login_Cliente" runat="server" BackColor="#FFFBD6" BorderColor="#FFDFAD" BorderPadding="4" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#333333" Height="200px" Width="675px" OnAuthenticate="Login_Cliente_Authenticate">
            <InstructionTextStyle Font-Italic="True" ForeColor="Black" />
            <LayoutTemplate>
                <table cellpadding="4" cellspacing="0" style="border-collapse:collapse;">
                    <tr>
                        <td>
                            <table cellpadding="0" style="height:200px;width:675px;">
                                <tr>
                                    <td align="center" colspan="3" style="color:White;background-color:#990000;font-weight:bold;" class="auto-style6">Iniciar sesión</td>
                                </tr>
                                <tr>
                                    <td rowspan="2" class="auto-style3">
                                        <asp:Image ID="Image1" runat="server" ImageUrl="~/Imagenes/Icono usuario.png" Width="50%" />
                                    </td>
                                    <td align="right">
                                        <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserName" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt">Nombre de usuario:</asp:Label>
                                    </td>
                                    <td class="auto-style3">
                                        <asp:TextBox ID="UserName" runat="server" Font-Size="12pt" Font-Names="Segoe UI Light"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName" ErrorMessage="El nombre de usuario es obligatorio." ToolTip="El nombre de usuario es obligatorio." ValidationGroup="Login_Cliente">*</asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="Password" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt">Contraseña:</asp:Label>
                                    </td>
                                    <td class="auto-style3">
                                        <asp:TextBox ID="Password" runat="server" Font-Size="12pt" TextMode="Password" Font-Names="Segoe UI"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="Password" ErrorMessage="La contraseña es obligatoria." ToolTip="La contraseña es obligatoria." ValidationGroup="Login_Cliente">*</asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="auto-style3">
                                        <asp:CheckBox ID="RememberMe" runat="server" Text="Recordármelo la próxima vez." Font-Names="Segoe UI" Font-Size="12pt" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="3" style="color:Red;">
                                        <asp:Label ID="LN_Mensaje" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="auto-style5">
                                        <asp:Button ID="LoginButton" runat="server" BackColor="White" BorderColor="#CC9966" BorderStyle="Solid" BorderWidth="1px" CommandName="Login" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="#990000" Text="Inicio de sesión" ValidationGroup="Login_Cliente" Font-Bold="True" />
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
        <table class="auto-style4">
            <tr>
                <td class="auto-style3">
                    <asp:Label ID="Label3" runat="server" Font-Names="Segoe UI Light" Font-Size="12pt" Text="¿Has olvidado tu contraseña?"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="auto-style3">
                    <asp:LinkButton ID="LB_Recuperacion_Contraseña" runat="server" Font-Names="Segoe UI" Font-Size="12pt" OnClick="LB_Recuperacion_Contraseña_Click" ForeColor="Blue">Recuperar Contraseña</asp:LinkButton>
                </td>
            </tr>
        </table>
        <table class="auto-style4">
            <tr>
                <td class="auto-style3">
                    <asp:Label ID="Label2" runat="server" Font-Names="Segoe UI Light" Font-Size="12pt" Text="¿No te has unido?"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="auto-style3">
                    <asp:HyperLink ID="HL_RegistrarCl" runat="server" Font-Names="Segoe UI" Font-Size="12pt" NavigateUrl="~/View/registroCliente.aspx" ForeColor="Blue">Registrate</asp:HyperLink>
                </td>
            </tr>
        </table>
</div>
</asp:Content>
