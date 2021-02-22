<%@ Page Title="Conductor" Language="C#" MasterPageFile="~/View/conductorMaster.master" AutoEventWireup="true" CodeFile="~/Controller/loginConductor.aspx.cs" Inherits="View_loginConductor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
    .auto-style3 {
        text-align: center;
        width: 300px;
    }
        .auto-style9 {
            width: 100%;
            height: 58px;
        }
    .auto-style10 {
        font-size: 15pt;
        font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
    }
    .auto-style11 {
        width: 275px;
    }
        .auto-style12 {
            height: 25px;
        }
        .auto-style13 {
            text-align: center;
            width: 100%;
            height: 355px;
        }
        .auto-style14 {
            width: 100%;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="auto-style13">
        <asp:Login ID="Login_Conductor" runat="server" BackColor="#FFFBD6" BorderColor="#FFDFAD" BorderPadding="4" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#333333" Height="200px" Width="675px" OnAuthenticate="Login_Conductor_Authenticate1">
            <InstructionTextStyle Font-Italic="True" ForeColor="Black" />
            <LayoutTemplate>
                <table cellpadding="4" cellspacing="0" style="border-collapse:collapse;">
                    <tr>
                        <td>
                            <table cellpadding="0" style="height:200px;width:675px;">
                                <tr>
                                    <td align="center" colspan="3" style="color:White;background-color:#990000;font-weight:bold;" class="auto-style10">Iniciar sesión</td>
                                </tr>
                                <tr>
                                    <td class="auto-style11" rowspan="2">
                                        <asp:Image ID="Image1" runat="server" ImageUrl="~/Imagenes/Icono conductor.png" Width="50%" />
                                    </td>
                                    <td align="right">
                                        <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserName" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt">Nombre de usuario:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="UserName" runat="server" Font-Size="12pt" Font-Names="Segoe UI"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName" ErrorMessage="El nombre de usuario es obligatorio." ToolTip="El nombre de usuario es obligatorio." ValidationGroup="Login_Conductor">*</asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="Password" Font-Bold="True" Font-Names="Segoe UI" Font-Size="12pt">Contraseña:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="Password" runat="server" Font-Size="12pt" TextMode="Password" Font-Names="Segoe UI"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="Password" ErrorMessage="La contraseña es obligatoria." ToolTip="La contraseña es obligatoria." ValidationGroup="Login_Conductor">*</asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:CheckBox ID="RememberMe" runat="server" Text="Recordármelo la próxima vez." Font-Names="Segoe UI" Font-Size="12pt" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="3" style="color:Red;">
                                        <asp:Label ID="LN_Mensaje" runat="server" Font-Names="Segoe UI Light" Font-Size="12pt"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:Button ID="LoginButton" runat="server" BackColor="White" BorderColor="#CC9966" BorderStyle="Solid" BorderWidth="1px" CommandName="Login" Font-Names="Segoe UI" Font-Size="12pt" ForeColor="#990000" Text="Inicio de sesión" ValidationGroup="Login_Conductor" Font-Bold="True" />
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
        <table class="auto-style9">
            <tr>
                <td>
                    <asp:Label ID="Label3" runat="server" Font-Names="Segoe UI Light" Font-Size="12pt" Text="¿Has olvidado tu contraseña?"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="auto-style12">
                    <asp:LinkButton ID="LB_Recuperacion_Contraseña" runat="server" Font-Names="Segoe UI" Font-Size="12pt" OnClick="LB_Recuperacion_Contraseña_Click" ForeColor="Blue">Recuperar Contraseña</asp:LinkButton>
                </td>
            </tr>
        </table>
        <table class="auto-style14">
            <tr>
                <td>
                    <asp:Label ID="Label2" runat="server" Font-Names="Segoe UI Light" Font-Size="12pt" Text="¿No te has unido?"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:HyperLink ID="HL_RegistrarCo" runat="server" Font-Names="Segoe UI" Font-Size="12pt" NavigateUrl="~/View/registroConductor.aspx" ForeColor="Blue">Registrate</asp:HyperLink>
                </td>
            </tr>
        </table>
</div>
</asp:Content>

