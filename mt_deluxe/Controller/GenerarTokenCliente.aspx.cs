using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_GenerarTokenCliente : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void B_Recuperar_Click(object sender, EventArgs e)
    {
        Cliente cliente = new DaoCliente().getloginByUsuario(TB_User_Name.Text);

        if (cliente != null)
        {
            TokenCliente token = new TokenCliente();
            token.Creado =  DateTime.Now;
            token.IdCliente = cliente.IdCliente;
            token.Vigencia = DateTime.Now.AddHours(2);

            token.Token= encriptar(JsonConvert.SerializeObject(token));
          
            new DaoSeguridadCliente().insertarToken(token);

            Correo correo = new Correo();

            String mensaje = "su link de acceso es: " + "http://localhost:55797/View/RecuperarCliente.aspx?" + token.Token;
            correo.enviarCorreo(cliente.Email, token.Token, mensaje);

            L_Mensaje.Text = "Su nueva contraseña ha sido enviada a su correo";
        }

        else
        {
            L_Mensaje.Text = "El usuario digitado no existe";
        }

    }

    private string encriptar(string input)
    {
        SHA256CryptoServiceProvider provider = new SHA256CryptoServiceProvider();

        byte[] inputBytes = Encoding.UTF8.GetBytes(input);
        byte[] hashedBytes = provider.ComputeHash(inputBytes);

        StringBuilder output = new StringBuilder();

        for (int i = 0; i < hashedBytes.Length; i++)
            output.Append(hashedBytes[i].ToString("x2").ToLower());

        return output.ToString();
    }
}