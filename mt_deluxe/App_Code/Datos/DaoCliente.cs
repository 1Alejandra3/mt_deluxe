using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de DaoCliente
/// </summary>
public class DaoCliente
{
    public Cliente login(Cliente cliente)
    {
        return new MapeoCliente().client.Where(x => x.Usuario.ToUpper().Equals(cliente.Usuario.ToUpper()) && x.Contrasena.Equals(cliente.Contrasena)).FirstOrDefault();
    }

    public Cliente getloginByUsuario(string usuario)
    {
        return new MapeoCliente().client.Where(x => x.Usuario.ToUpper().Equals(usuario.ToUpper())).FirstOrDefault();
    }

    //Insert Cliente
    public void inserCliente(Cliente cliente)
    {
        using (var db = new MapeoCliente())
        {
            db.client.Add(cliente);
            db.SaveChanges();
        }
    }

    //Validacion Existencia
    public Cliente validarExistencia(Cliente clienteE)
    {
        return new MapeoCliente().client.Where(x => x.Usuario.Equals(clienteE.Usuario)).FirstOrDefault();
    }

    public void inserServicio(Notificacion notificacion)
    {
        using (var db = new MapeoCliente())
        {
            db.notificacion.Add(notificacion);
            db.SaveChanges();
        }
    }

    //Update (Delete) Cliente
    public void eliminarCliente(Cliente cliente)
    {
        using (var db = new MapeoCliente())
        {
            Cliente clienteAnterior = db.client.Where(x => x.IdCliente == cliente.IdCliente).FirstOrDefault();
            clienteAnterior.Sesion = "inactivo";

            db.client.Attach(clienteAnterior);

            var entry = db.Entry(clienteAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    //Select Cliente
    public Cliente mostrarRegistro(int idCliente)
    {
        return new MapeoCliente().client.Where(x => x.IdCliente == idCliente).First();
    }

    //Update Cliente
    public void modificarCliente(Cliente cliente)
    {
        using (var db = new MapeoCliente())
        {
            Cliente clienteAnterior = db.client.Where(x=> x.IdCliente == cliente.IdCliente).FirstOrDefault();
            clienteAnterior.Nombrecl = cliente.Nombrecl;
            clienteAnterior.Apellido = cliente.Apellido;
            clienteAnterior.FechaDeNacimiento = cliente.FechaDeNacimiento;
            clienteAnterior.Email = cliente.Email;
            clienteAnterior.Usuario = cliente.Usuario;
            clienteAnterior.Contrasena = cliente.Contrasena;
            
            db.client.Attach(clienteAnterior);

            var entry = db.Entry(clienteAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    public List<Cliente> mostrarClientes(Cliente cliente)
    {
        return new MapeoCliente().client.Where(x => x.IdCliente == cliente.IdCliente).ToList<Cliente>();
    }

    //Select Conductores Disponibles
    public List<Conductor> conductoresDisponibles()
    {
        return new MapeoCliente().conduc.Where(x => x.IdEstado == 1).OrderBy(x => x.IdConductor).ToList();
    }

    //List Destino
    public List<Destino> destino()
    {
        List<Destino> lista = new MapeoCliente().destino.ToList();
        Destino destino = new Destino();
        destino.Id = 0;
        destino.LugarDestino = "-- Seleccione --";
        lista.Add(destino);
        return lista.OrderBy(x => x.Id).ToList();
    }

    //List Ubicacion
    public List<Destino> ubicacion()
    {
        List<Destino> lista = new MapeoCliente().destino.ToList();
        Destino destino = new Destino();
        destino.Id = 0;
        destino.LugarUbicacion = "-- Seleccione --";
        lista.Add(destino);
        return lista.OrderBy(x => x.Id).ToList();
    }

    //List Pago
    public List<MPago> pago()
    {
        List<MPago> lista = new MapeoCliente().pago.ToList();
        MPago state = new MPago();
        state.Id = 0;
        state.Descripcion = "-- Seleccione --";
        lista.Add(state);
        return lista.OrderBy(x => x.Id).ToList();
    }

    //Select Servicios Filtro
    public List<Notificacion> filtrarServicios(DateTime? fechaInicio)
    {
        using (var db = new MapeoCliente())
        {
            List<Notificacion> filtro = (from n in db.notificacion
                                        join cl in db.client on n.IdCliente equals cl.IdCliente
                                        join d in db.destino on n.IdDestino equals d.Id
                                        join u in db.destino on n.IdUbicacion equals u.Id
                                        orderby n.FechaCarrera
                                        select new
                                        {
                                            n,
                                            cl.Nombrecl,
                                            d.LugarDestino,
                                            u.LugarUbicacion
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
                                            Conversacion = m.n.Conversacion,
                                            NombreCl = m.Nombrecl,
                                            Destino = m.LugarDestino,
                                            Ubicacion = m.LugarUbicacion
                                        }).Where(x => x.Estado.Contains("Aceptado") && x.IdCliente == ((Cliente)HttpContext.Current.Session["user"]).IdCliente).ToList();

            if (fechaInicio != null)
            {
                filtro = filtro.Where(x => x.FechaCarrera == fechaInicio).ToList();
                return filtro;
            }

            return filtro;
        }
    }

    //Update (Comentar)
    public void comentar(Notificacion notificacion)
    {
        using (var db = new MapeoCliente())
        {
            Notificacion notificacionAnterior = db.notificacion.Where(x => x.Id == notificacion.Id).FirstOrDefault();
            notificacionAnterior.ComentarioDeCliente = notificacion.ComentarioDeCliente;

            db.notificacion.Attach(notificacionAnterior);

            var entry = db.Entry(notificacionAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    //Select Servicios Filtro
    public Notificacion generarFactura(Notificacion notificacion)
    {
        using (var db = new MapeoCliente())
        {
            return (from n in db.notificacion
                    join cl in db.client on n.IdCliente equals cl.IdCliente
                    join d in db.destino on n.IdDestino equals d.Id
                    join u in db.destino on n.IdUbicacion equals u.Id
                    join p in db.pago on n.Pago equals p.Id
                    orderby n.FechaCarrera
                    select new
                    {
                        n,
                        cl.Nombrecl,
                        d.LugarDestino,
                        u.LugarUbicacion,
                        p.Descripcion
                    }).ToList().Select(m => new Notificacion
                    {
                        Id = m.n.Id,
                        IdCliente = m.n.IdCliente,
                        IdDestino = m.n.IdDestino,
                        IdUbicacion = m.n.IdUbicacion,
                        Tarifa = m.n.Tarifa,
                        FechaCarrera = m.n.FechaCarrera,
                        Pago = m.n.Pago,
                        NombreCl = m.Nombrecl,
                        Destino = m.LugarDestino,
                        Ubicacion = m.LugarUbicacion,
                        MetodoPago = m.Descripcion
                    }).Where(x => x.IdCliente == ((Cliente)HttpContext.Current.Session["user"]).IdCliente).Last();
        }
    }

    //Update (Conversacion)
    public void coversar(Notificacion notificacion)
    {
        using (var db = new MapeoCliente())
        {
            Notificacion notificacionAnterior = db.notificacion.Where(x => x.Id == notificacion.Id).FirstOrDefault();
            notificacionAnterior.Conversacion = notificacion.Conversacion;

            db.notificacion.Attach(notificacionAnterior);

            var entry = db.Entry(notificacionAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }
}