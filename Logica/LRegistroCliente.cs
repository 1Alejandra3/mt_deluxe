using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utilitarios;
using Data;

namespace Logica
{
    public class LRegistroCliente
    {
        public Cascaron registro(Cliente cliente)
        {
            Cascaron cascaron = new Cascaron();

            Cliente clientev = new Cliente();
            clientev = new DaoCliente().validarExistencia(cliente);

            if (clientev != null)
            {
                cascaron.Mensaje = "Usuario existente, porfavor intente con otro";
            }
            else if (clientev == null)
            {
                
                new DaoCliente().inserCliente(cliente);
            }
            return cascaron;
        }
    }
}
