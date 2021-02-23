using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utilitarios;
using Data;

namespace Logica
{
    public class LCliente
    {
        public string login(Cliente cliente)
        {
           cliente= new DaoCliente().login(cliente);


        if ((cliente == null) || (cliente.Sesion.Equals("inactivo")))
            {
                return "Usuario o clave incorrecto";
                Session["user"] = null; //Variable vacia (No ha iniciado sesión)
            }
            else
            {
                if (s != null)
                    Response.Redirect("cliente.aspx");
            }

        }
    }
}
