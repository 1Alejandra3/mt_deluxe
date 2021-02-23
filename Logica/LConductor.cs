using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data;
using Utilitarios;

namespace Logica
{
     public class LConductor
    {
        public string login(Conductor conductor)
        {
            conductor = new DaoConductor().login(conductor);


            if ((conductor == null) || (conductor.Sesion.Equals("inactivo")))
            {
                return "Usuario o clave incorrecto";
                Session["user"] = null; //Variable vacia (No ha iniciado sesión)
            }
            else
            {
                if (s != null)
                    Response.Redirect("conductor.aspx");
            }

        }
    }
}
