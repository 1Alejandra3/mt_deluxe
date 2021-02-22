<%@ Page Title="" Language="C#" MasterPageFile="~/View/conductorMaster.master" AutoEventWireup="true" CodeFile="~/Controller/RecuperarConductor.aspx.cs" Inherits="View_RecuperarConductor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
        .auto-style4 {
            text-align: center;
        }
        .auto-style5 {
            text-align: justify;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <table class="auto-style3">
        <tr>
            <td
                class="auto-style4">
                <asp:Label ID="L_Contraseña" runat="server" Text="Digite su nueva contaseña: " Font-Names="Segoe UI"></asp:Label>
                <asp:TextBox ID="Tb_Contraseña" runat="server" Font-Names="Segoe UI" Font-Size="12pt" CssClass="auto-style5"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td
                class="auto-style4">
                <asp:Label ID="L_Repetir" runat="server" Text="Repita su nueva contraseña: " Font-Names="Segoe UI"></asp:Label>
                 <asp:TextBox ID="TB_Repetir" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
                 <br />
                 <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToCompare="Tb_Contraseña" ControlToValidate="TB_Repetir" ErrorMessage="CompareValidator" Font-Names="Segoe UI"></asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td
                class="auto-style4">
                 <asp:Button ID="B_Cambiar" runat="server" OnClick="B_Cambiar_Click" Text="Cambiar" Font-Names="Segoe UI" Font-Bold="True" Font-Size="12pt" />
            </td>
        </tr>
    </table>
</asp:Content>

