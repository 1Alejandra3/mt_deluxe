<%@ Page Title="" Language="C#" MasterPageFile="~/View/clienteMaster.master" AutoEventWireup="true" CodeFile="~/Controller/GenerarTokenCliente.aspx.cs" Inherits="View_GenerarTokenCliente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
        .auto-style3 {
            width: 100%;
        height: 85px;
    }
    .auto-style4 {
        text-align: center;
    }
    .auto-style5 {
        text-align: center;
        height: 27px;
    }
    .auto-style6 {
        width: 277px;
        text-align: right;
    }
    .auto-style7 {
        text-align: left;
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
             <tr>
            <td class="auto-style5" colspan="2">
                        <asp:Button ID="B_Recuperar" runat="server" OnClick="B_Recuperar_Click" Text="Recuperar" Font-Names="Segoe UI" Font-Bold="True" Font-Size="12pt" />
             </td>
        </tr>
        <tr>
           <td class="auto-style4" colspan="2">
                        <asp:Label ID="L_Mensaje" runat="server" Font-Names="Segoe UI" Font-Size="12pt"></asp:Label>
           </td>
        </tr>
    </table>
</asp:Content>

               
