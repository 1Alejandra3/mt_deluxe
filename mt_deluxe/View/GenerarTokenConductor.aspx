<%@ Page Title="" Language="C#" MasterPageFile="~/View/conductorMaster.master" AutoEventWireup="true" CodeFile="~/Controller/GenerarTokenConductor.aspx.cs" Inherits="View_GenerarTokenConductor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
        .auto-style4 {
            text-align: center;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <table class="auto-style3">
        <tr>
            <td class="auto-style6">
                        <asp:Label ID="L_User_Name" runat="server" Text="Digite su Usario: " Font-Bold="False" Font-Italic="False" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
                        <td class="auto-style7">
                        <asp:TextBox ID="TB_User_Name" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td class="auto-style4" colspan="2">
                        <asp:Button ID="B_Recuperar" runat="server" OnClick="B_Recuperar_Click" Text="Recuperar" Font-Names="Segoe UI" Font-Bold="True" Font-Size="12pt" />

            </td>
        </tr>
        <tr>
            <td class="auto-style4" colspan="2">
                        <asp:Label ID="L_Mensaje" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label> </td>
        </tr>
    </table>
</asp:Content>

