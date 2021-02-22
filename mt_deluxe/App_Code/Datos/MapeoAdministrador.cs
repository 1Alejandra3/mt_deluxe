using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de MapeoAdministrador
/// </summary>
public class MapeoAdministrador : DbContext
{
    static MapeoAdministrador()
    {
        Database.SetInitializer<MapeoAdministrador>(null);
    }

    public MapeoAdministrador()
        : base("name=bd_proyecto")
    {

    }

    public DbSet<Administrador> administrador { get; set; } //Conexión bd-c#
    public DbSet<Conductor> conductor { get; set; }
    public DbSet<Cliente> cliente { get; set; }
    public DbSet<Notificacion> notificacion { get; set; }


    protected override void OnModelCreating(DbModelBuilder builder)
    {
        builder.HasDefaultSchema("public");

        base.OnModelCreating(builder);
    }
}