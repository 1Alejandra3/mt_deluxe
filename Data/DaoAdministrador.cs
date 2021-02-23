using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using Utilitarios;

/// <summary>
/// Descripción breve de DAOAdministrador
/// </summary>
/// 
namespace Data
{
    public class DaoAdministrador
    {
        public Administrador login(Administrador administrador)
        {
            return new MapeoAdministrador().administrador.Where(x => x.Usuario.ToUpper().Equals(administrador.Usuario.ToUpper()) && x.Contrasena.Equals(administrador.Contrasena)).FirstOrDefault();
        }

        //Aceptar conductor
        public List<Conductor> mostrar()
        {
            return new MapeoAdministrador().conductor.Where(x => x.Sesion.Contains("espera") || x.Sesion.Contains("sancionado")).ToList();
        }

        public List<Cliente> mostrarClienteAceptar()
        {
            return new MapeoAdministrador().cliente.Where(x => x.Sesion.Contains("sancionado")).ToList();
        }

        public List<Conductor> MostrarConductores()
        {
            return new MapeoAdministrador().conductor.OrderBy(x => x.IdConductor).ToList();
        }

        //traer Email conductor
        public Conductor buscarEmail(double idConductor)
        {
            return new MapeoConductor().conduc.Where(x => x.IdConductor == idConductor).First();
        }

        public Cliente buscarEmailCl(double idCliente)
        {
            return new MapeoCliente().client.Where(x => x.IdCliente == idCliente).First();
        }

        public List<Cliente> mostrarCliente()
        {
            return new MapeoAdministrador().cliente.Where(x => x.Sesion.Contains("activo")).ToList();
        }

        //Select Pago Conductor List
        public List<Notificacion> notificacion()
        {
            using (var db = new MapeoConductor())
            {
                List<Notificacion> lista = (from n in db.notificacion
                                            join co in db.conduc on n.IdConductor equals co.IdConductor
                                            select new
                                            {
                                                n,
                                                co.Nombre
                                            }).ToList().Select(m => new Notificacion
                                            {
                                                Id = m.n.Id,
                                                IdConductor = m.n.IdConductor,
                                                NombreCo = m.Nombre
                                            }).OrderBy(x => x.IdConductor).ToList();

                var conductores = lista.GroupBy(x => x.IdConductor).Select(grp => grp.ToList());

                List<Notificacion> listaCo = new List<Notificacion>();

                foreach (var item in conductores)
                {
                    Notificacion notificacion = new Notificacion();
                    notificacion.ListaConductores = item;
                    notificacion.IdConductor = notificacion.ListaConductores.First().IdConductor;
                    notificacion.NombreCo = notificacion.ListaConductores.First().NombreCo;
                    listaCo.Add(notificacion);
                }

                return listaCo;
            }
        }

        //Select Comentarios Conductor
        public List<Notificacion> mostrarCarreraConductor()
        {
            using (var db = new MapeoConductor())
            {
                return (from n in db.notificacion
                        join cl in db.client on n.IdCliente equals cl.IdCliente
                        join co in db.conduc on n.IdConductor equals co.IdConductor
                        orderby n.FechaCarrera
                        select new
                        {
                            n,
                            cl.Nombrecl,
                            co.Sesion
                        }).ToList().Select(m => new Notificacion
                        {
                            Id = m.n.Id,
                            IdCliente = m.n.IdCliente,
                            IdDestino = m.n.IdDestino,
                            IdUbicacion = m.n.IdUbicacion,
                            Tarifa = m.n.Tarifa,
                            FechaCarrera = m.n.FechaCarrera,
                            Estado = m.n.Estado,
                            IdConductor = m.n.IdConductor,
                            Conductor = m.n.Conductor,
                            ComentarioDeCliente = m.n.ComentarioDeCliente,
                            FechaFinCarrera = m.n.FechaFinCarrera,
                            NombreCl = m.Nombrecl,
                            Sesion = m.Sesion
                        }).Where(x => x.Estado.Contains("Aceptado") && x.ComentarioDeCliente != null).OrderBy(x => x.FechaCarrera).ToList();
            }
        }

        //Select Comentarios Cliente
        public List<Notificacion> mostrarServiciosCliente()
        {
            using (var db = new MapeoCliente())
            {
                return (from n in db.notificacion
                        join cl in db.client on n.IdCliente equals cl.IdCliente
                        orderby n.FechaCarrera
                        select new
                        {
                            n,
                            cl.Nombrecl,
                            cl.Sesion
                        }).ToList().Select(m => new Notificacion
                        {
                            Id = m.n.Id,
                            IdCliente = m.n.IdCliente,
                            IdDestino = m.n.IdDestino,
                            IdUbicacion = m.n.IdUbicacion,
                            Tarifa = m.n.Tarifa,
                            FechaCarrera = m.n.FechaCarrera,
                            Estado = m.n.Estado,
                            IdConductor = m.n.IdConductor,
                            Conductor = m.n.Conductor,
                            ComentarioDeConductor = m.n.ComentarioDeConductor,
                            FechaFinCarrera = m.n.FechaFinCarrera,
                            NombreCl = m.Nombrecl,
                            Sesion = m.Sesion
                        }).Where(x => x.Estado.Contains("Aceptado") && x.ComentarioDeConductor != null).OrderBy(x => x.FechaCarrera).ToList();
            }
        }

        //Update Estado
        public void sesionConductor(Conductor conductor)
        {
            using (var db = new MapeoConductor())
            {
                Conductor estadoAnterior = db.conduc.Where(x => x.IdConductor == conductor.IdConductor).First();
                estadoAnterior.Sesion = conductor.Sesion;

                db.conduc.Attach(estadoAnterior);

                var entry = db.Entry(estadoAnterior);
                entry.State = EntityState.Modified;
                db.SaveChanges();
            }
        }


        //Update Estado
        public void sesionCliente(Cliente cliente)
        {
            using (var db = new MapeoCliente())
            {
                Cliente estadoAnterior = db.client.Where(x => x.IdCliente == cliente.IdCliente).First();
                estadoAnterior.Sesion = cliente.Sesion;

                db.client.Attach(estadoAnterior);

                var entry = db.Entry(estadoAnterior);
                entry.State = EntityState.Modified;
                db.SaveChanges();
            }
        }

        public void sancionConductor(Conductor conductor)
        {
            using (var db = new MapeoConductor())
            {
                Conductor sancion = db.conduc.Where(x => x.IdConductor == conductor.IdConductor).First();
                sancion.Sesion = conductor.Sesion;
                sancion.FechaSancion = conductor.FechaSancion;

                db.conduc.Attach(sancion);

                var entry = db.Entry(sancion);
                entry.State = EntityState.Modified;
                db.SaveChanges();
            }
        }

        //Select Id COnductor Notificacion
        public Notificacion buscaridConductorN(double idConductor)
        {
            return new MapeoConductor().notificacion.Where(x => x.IdConductor == idConductor).FirstOrDefault();
        }


        //Select Id Conductor Conductor
        public Conductor buscaridConductorCo(double idConductor)
        {
            return new MapeoConductor().conduc.Where(x => x.IdConductor == idConductor).FirstOrDefault();
        }

        //Select Id Cliente Notificacion
        public Notificacion buscaridClienteN(double idCliente)
        {
            return new MapeoConductor().notificacion.Where(x => x.IdCliente == idCliente).FirstOrDefault();
        }

        //Select Id Cliente cliente
        public Cliente buscaridClienteC(double idCliente)
        {
            return new MapeoConductor().client.Where(x => x.IdCliente == idCliente).FirstOrDefault();
        }

        public void sancionCliente(Cliente cliente)
        {
            using (var db = new MapeoCliente())
            {
                Cliente sancion = db.client.Where(x => x.IdCliente == cliente.IdCliente).First();
                sancion.Sesion = cliente.Sesion;
                sancion.FechaSancion = cliente.FechaSancion;

                db.client.Attach(sancion);

                var entry = db.Entry(sancion);
                entry.State = EntityState.Modified;
                db.SaveChanges();
            }
        }

        //Select Desprendible
        public Notificacion generarDesprendible(int idCo)
        {
            using (var db = new MapeoAdministrador())
            {
                return (from n in db.notificacion
                        join co in db.conductor on n.IdConductor equals co.IdConductor
                        select new
                        {
                            n,
                            co.Nombre,
                            co.Apellido,
                            co.Cedula,
                            co.Placa
                        }).ToList().Select(m => new Notificacion
                        {
                            Id = m.n.Id,
                            IdConductor = m.n.IdConductor,
                            Tarifa = m.n.Tarifa,
                            NombreCo = m.Nombre,
                            ApellidoCo = m.Apellido,
                            Cedula = m.Cedula,
                            Placa = m.Placa
                        }).Where(x => x.IdConductor == idCo).FirstOrDefault();
            }
        }

        //Calcular Ganancias (Reporte)
        public double ganancias(int idConductor)
        {
            return new MapeoConductor().notificacion.Where(x => x.IdConductor == idConductor).Sum(x => x.Tarifa);
        }
    }
}