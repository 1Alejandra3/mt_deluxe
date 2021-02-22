using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_GenerarTokenConductor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void B_Recuperar_Click(object sender, EventArgs e)
    {
        Conductor conductor = new DaoConductor().getloginByUsuariocon(TB_User_Name.Text);

        if (conductor != null)
        {
            TokenConductor token = new TokenConductor();
            token.Creado = DateTime.Now;
            token.IdConductor = conductor.IdConductor;
            token.Vigencia = DateTime.Now.AddHours(2);


            token.Token = encriptar(JsonConvert.SerializeObject(token));

            new DaoSeguridadConductor().insertarToken(token);

            Correo correo = new Correo();

            String mensaje = "su link de acceso es: " + "http://localhost:55797/View/RecuperarConductor.aspx?" + token.Token;
            correo.enviarCorreo(conductor.Email, token.Token, mensaje);

            L_Mensaje.Text = "Su nueva contraseña ha sido enviada a su correo";

            //   }

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