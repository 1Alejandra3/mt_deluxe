using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de DaoSeguridadCliente
/// </summary>
public class DaoSeguridadCliente
{
    public void insertarToken(TokenCliente token)
    {
        using (var db = new MapeoCliente())
        {
            db.token.Add(token);
            db.SaveChanges();
        }
    }

    public void insertarAcceso(AccesoCliente accesoCliente)
    {
        using (var db = new MapeoCliente())
        {
            db.accesoClientes.Add(accesoCliente);
            db.SaveChanges();
        }
    }

    public void cerrarAcceso(int id_cliente)
    {
        using (var db = new MapeoCliente())
        {
            AccesoCliente acceso = db.accesoClientes.Where(x => x.IdCliente == id_cliente && x.FechaFin == null).FirstOrDefault();
            acceso.FechaFin = DateTime.Now;

            db.accesoClientes.Attach(acceso);

            var entry = db.Entry(acceso);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    public TokenCliente getTokenByUser(int usuarioId)
    {
        return new MapeoCliente().token.Where(x => x.IdCliente == usuarioId && x.Vigencia> DateTime.Now).FirstOrDefault();
    }

    public TokenCliente getTokenByToken(string tokenn)
    {
        return new MapeoCliente().token.Where(x => x.Token == tokenn).FirstOrDefault();
    }

    public void updateClave(Cliente cliente)
    {
        using (var db = new MapeoCliente())
        {
            Cliente usuarioAnterior = db.client.Where(x => x.IdCliente == cliente.IdCliente).First();
            usuarioAnterior.Contrasena = cliente.Contrasena;

            db.client.Attach(usuarioAnterior);

            var entry = db.Entry(usuarioAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

}