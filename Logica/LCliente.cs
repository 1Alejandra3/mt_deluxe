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
        public Cascaron login(Cliente cliente)
        {
            cliente = new DaoCliente().login(cliente);
            Cascaron cascaron = new Cascaron();

            if ((cliente == null) || (cliente.Sesion.Equals("inactivo")))
            {
                cascaron.Mensaje = "Usuario o clave incorrecto";
                cascaron.Url = "loginCliente.aspx";
                //Session["user"] = null; //Variable vacia (No ha iniciado sesión)
            }
            else
            {
                //if (s != null)
                cascaron.Url = "paginaPrincipal.aspx";
            }
            return cascaron;
        }
    }
}
