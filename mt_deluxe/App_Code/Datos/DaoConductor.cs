using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de DaoConductor
/// </summary>
public class DaoConductor
{
    public Conductor login(Conductor conductor)
    {
        return new MapeoConductor().conduc.Where(x => x.Usuario.ToUpper().Equals(conductor.Usuario.ToUpper()) && x.Contrasena.Equals(conductor.Contrasena)).FirstOrDefault();
    }

    public Conductor getloginByUsuariocon(string usuario)
    {
        return new MapeoConductor().conduc.Where(x => x.Usuario.ToUpper().Equals(usuario.ToUpper())).FirstOrDefault();
    }

    //Insert Conductor
    public void inserConductor(Conductor conductor)
    {
        using (var db = new MapeoConductor())
        {
            db.conduc.Add(conductor);
            db.SaveChanges();
        }
    }

    //Update (Delete) Conductor
    public void eliminarConductor(Conductor conductor)
    {
        using (var db = new MapeoConductor())
        {
            Conductor conductorAnterior = db.conduc.Where(x => x.IdConductor == conductor.IdConductor).FirstOrDefault();
            conductorAnterior.Sesion = "inactivo";

            db.conduc.Attach(conductorAnterior);

            var entry = db.Entry(conductorAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    //Select ConductorModificar
    public Conductor mostrarRegistro(int idConductor)
    {
        return new MapeoConductor().conduc.Where(x => x.IdConductor == idConductor).First();
    }

    //Update Conductor
    public void modificarConductor(Conductor conductor)
    {
        using (var db = new MapeoConductor())
        {
            Conductor conductorAnterior = db.conduc.Where(x => x.IdConductor == conductor.IdConductor).FirstOrDefault();
            conductorAnterior.Nombre = conductor.Nombre;
            conductorAnterior.Apellido = conductor.Apellido;
            conductorAnterior.FechaDeNacimiento = conductor.FechaDeNacimiento;
            conductorAnterior.Email = conductor.Email;
            conductorAnterior.Placa = conductor.Placa;
            conductorAnterior.Usuario = conductor.Usuario;
            conductorAnterior.Contrasena = conductor.Contrasena;

            db.conduc.Attach(conductorAnterior);

            var entry = db.Entry(conductorAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    //List Estado
    public List<Estado> estado()
    {
        List<Estado> lista = new MapeoConductor().estado.ToList();
        Estado state = new Estado();
        state.Id = 0;
        state.Disponibilidad = "-- Seleccione --";
        lista.Add(state);
        return lista.OrderBy(x => x.Id).ToList();
    }

    //Update Estado
    public void estadoConductor(Conductor conductor)
    {
        using (var db = new MapeoConductor())
        {
            Conductor estadoAnterior = db.conduc.Where(x => x.IdConductor == conductor.IdConductor).First();
            estadoAnterior.IdEstado = conductor.IdEstado;

            db.conduc.Attach(estadoAnterior);

            var entry = db.Entry(estadoAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    //Select Solicitudes
    public List<Notificacion> mostrarHistorial()
    {
        using (var db = new MapeoConductor())
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
                        Estado = m.n.Estado,
                        IdConductor = m.n.IdConductor,
                        Conductor = m.n.Conductor,
                        ComentarioDeConductor = m.n.ComentarioDeConductor,
                        FechaFinCarrera = m.n.FechaFinCarrera,
                        NombreCl = m.Nombrecl,
                        Destino = m.LugarDestino,
                        Ubicacion = m.LugarUbicacion,
                        MetodoPago = m.Descripcion
                    }).Where(x => x.Estado.Contains("Pendiente")).OrderBy(x => x.FechaCarrera).ToList();
        }
    }

    //Validacion Existencia
    public Conductor validarExistencia(Conductor conductorE)
    {
        return new MapeoConductor().conduc.Where(x => x.Usuario.Equals(conductorE.Usuario)).FirstOrDefault();
    }

    //Update (Servicio Aceptado)
    public void aceptarServicio(Notificacion notificacion)
    {
        using (var db = new MapeoConductor())
        {
            Notificacion notificacionAnterior = db.notificacion.Where(x => x.Id == notificacion.Id).FirstOrDefault();
            notificacionAnterior.Estado = notificacion.Estado;
            notificacionAnterior.Conductor = notificacion.Conductor;
            notificacionAnterior.IdConductor = notificacion.IdConductor;

            db.notificacion.Attach(notificacionAnterior);

            var entry = db.Entry(notificacionAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    //Select Email Cliente
    public Cliente buscarEmail(double idCliente)
    {
        return new MapeoCliente().client.Where(x => x.IdCliente == idCliente).First();
    }

    //Select Id Notificacion
    public Notificacion buscarId(int notificacionId)
    {
        return new MapeoConductor().notificacion.Where(x => x.Id == notificacionId).FirstOrDefault();
    }

    //Selec Carreras Filtro
    public List<Notificacion> filtrarCarrera(DateTime? fechaInicio)
    {
        using (var db = new MapeoConductor())
        {
            List<Notificacion> filtro = (from n in db.notificacion
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
                                             ComentarioDeConductor = m.n.ComentarioDeConductor,
                                             FechaFinCarrera = m.n.FechaFinCarrera,
                                             Conversacion = m.n.Conversacion,
                                             NombreCl = m.Nombrecl,
                                             Destino = m.LugarDestino,
                                             Ubicacion = m.LugarUbicacion
                                         }).Where(x => x.Estado.Contains("Aceptado") && x.IdConductor == ((Conductor)HttpContext.Current.Session["user"]).IdConductor).ToList();

            if (fechaInicio != null)
            {
                filtro = filtro.Where(x => x.FechaCarrera == fechaInicio).ToList();
                return filtro;
            }

            return filtro;
        }
    }

    //Selec Carreras Timer
    public List<Notificacion> carrerasTimer()
    {
        using (var db = new MapeoConductor())
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
                                             ComentarioDeConductor = m.n.ComentarioDeConductor,
                                             FechaFinCarrera = m.n.FechaFinCarrera,
                                             Conversacion = m.n.Conversacion,
                                             NombreCl = m.Nombrecl,
                                             Destino = m.LugarDestino,
                                             Ubicacion = m.LugarUbicacion
                                         }).Where(x => x.Estado.Contains("Aceptado") && x.IdConductor == ((Conductor)HttpContext.Current.Session["user"]).IdConductor).ToList();
        }
    }

    //Calcular ganancias
    public double ganancias(Notificacion notificacionT)
    {
        return new MapeoConductor().notificacion.Where(x => x.IdConductor == notificacionT.IdConductor && x.Estado.Contains("Aceptado")).Sum(x => x.Tarifa);

    }

    //Update (Comentar)
    public void comentar(Notificacion notificacion)
    {
        using (var db = new MapeoConductor())
        {
            Notificacion notificacionAnterior = db.notificacion.Where(x => x.Id == notificacion.Id).FirstOrDefault();
            notificacionAnterior.ComentarioDeConductor = notificacion.ComentarioDeConductor;
            notificacionAnterior.FechaFinCarrera = DateTime.Now;

            db.notificacion.Attach(notificacionAnterior);

            var entry = db.Entry(notificacionAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    //Reporte Historial
    public List<Notificacion> reporteHistorial(Notificacion notificacio)
    {
        using (var db = new MapeoConductor())
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
                                             ComentarioDeConductor = m.n.ComentarioDeConductor,
                                             FechaFinCarrera = m.n.FechaFinCarrera,
                                             Conversacion = m.n.Conversacion,
                                             NombreCl = m.Nombrecl,
                                             Destino = m.LugarDestino,
                                             Ubicacion = m.LugarUbicacion
                                         }).Where(x => x.Estado.Contains("Aceptado") && x.IdConductor == ((Conductor)HttpContext.Current.Session["user"]).IdConductor).ToList();
        }
    }

    //Update (Conversacion)
    public void coversar(Notificacion notificacion)
    {
        using (var db = new MapeoConductor())
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