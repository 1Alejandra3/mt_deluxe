using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Web;

public class Correo
{
    public Correo()
    {

    }
    public void enviarCorreo(String correoDestino, String userToken, String mensaje)
    {

        try
        {
            //Configuración del Mensaje
            MailMessage mail = new MailMessage();
            SmtpClient SmtpServer = new SmtpClient("smtp.gmail.com");
            //Especificamos el correo desde el que se enviará el Email y el nombre de la persona que lo envía
            mail.From = new MailAddress("mototaxideluxe@gmail.com", "Correo de Recuperación");

            //Aquí ponemos el asunto del correo
            mail.Subject = "Recuperación Contraseña";
            //Aquí ponemos el mensaje que incluirá el correo
            mail.Body = mensaje;
            //Especificamos a quien enviaremos el Email, no es necesario que sea Gmail, puede ser cualquier otro proveedor
            mail.To.Add(correoDestino);

            SmtpServer.Port = 587; //Puerto que utiliza Gmail para sus servicios
            //Especificamos las credenciales con las que enviaremos el mail
            SmtpServer.Credentials = new System.Net.NetworkCredential("mototaxideluxe@gmail.com", "Deluxe123");
            SmtpServer.EnableSsl = true;
            SmtpServer.Send(mail);
        }
        catch (Exception ex)
        {

        }
    }

    public void enviarCorreoNotificacion(String correoDestino, String mensaje)
    {

        try
        {
            //Configuración del Mensaje
            MailMessage mail = new MailMessage();
            SmtpClient SmtpServer = new SmtpClient("smtp.gmail.com");
            //Especificamos el correo desde el que se enviará el Email y el nombre de la persona que lo envía
            mail.From = new MailAddress("mototaxideluxe@gmail.com", "Servicio Mototaxi");

            //Aquí ponemos el asunto del correo
            mail.Subject = "Confirmacion de servicio";
            //Aquí ponemos el mensaje que incluirá el correo
            mail.Body = mensaje;
            //Especificamos a quien enviaremos el Email, no es necesario que sea Gmail, puede ser cualquier otro proveedor
            mail.To.Add(correoDestino);

            SmtpServer.Port = 587; //Puerto que utiliza Gmail para sus servicios
            //Especificamos las credenciales con las que enviaremos el mail
            SmtpServer.Credentials = new System.Net.NetworkCredential("mototaxideluxe@gmail.com", "Deluxe123");
            SmtpServer.EnableSsl = true;
            SmtpServer.Send(mail);
        }
        catch (Exception ex)
        {

        }
    }
}