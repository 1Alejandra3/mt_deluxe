using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de DaoSeguridadConductor
/// </summary>
public class DaoSeguridadConductor
{
    public void insertarToken(TokenConductor tokenconductor)
    {
        using (var db = new MapeoConductor())
        {
            db.token.Add(tokenconductor);
            db.SaveChanges();
        }
    }

    public void insertarAcceso(AccesoConductor accesoConductor)
    {
        using (var db = new MapeoConductor())
        {
            db.accesoconductor.Add(accesoConductor);
            db.SaveChanges();
        }
    }

    public void cerrarAcceso(int id_conductor)
    {
        using (var db = new MapeoConductor())
        {
            AccesoConductor acceso = db.accesoconductor.Where(x => x.IdConductor == id_conductor && x.FechaFin == null).FirstOrDefault();
            acceso.FechaFin = DateTime.Now;

            db.accesoconductor.Attach(acceso);

            var entry = db.Entry(acceso);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }
    public TokenConductor getTokenByUser(int usuarioId)
    {
        return new MapeoConductor().token.Where(x => x.IdConductor == usuarioId && x.Vigencia > DateTime.Now).FirstOrDefault();
    }

    public TokenConductor getTokenByToken(string tokenn)
    {
        return new MapeoConductor().token.Where(x => x.Token == tokenn).FirstOrDefault();
    }

    public void updateClave(Conductor conductor)
    {
        using (var db = new MapeoConductor())
        {
            Conductor usuarioAnterior = db.conduc.Where(x => x.IdConductor == conductor.IdConductor).First();
            usuarioAnterior.Contrasena = conductor.Contrasena;

            db.conduc.Attach(usuarioAnterior);

            var entry = db.Entry(usuarioAnterior);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }
}