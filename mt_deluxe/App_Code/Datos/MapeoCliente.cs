using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de MapeoCliente
/// </summary>
public class MapeoCliente : DbContext
{
    static MapeoCliente()
    {
        Database.SetInitializer<MapeoCliente>(null);
    }

    public MapeoCliente()
            : base("name=bd_proyecto")
    {

    }

    public DbSet<Cliente> client { get; set; }
    public DbSet<TokenCliente> token { get; set; }
    public DbSet<AccesoCliente> accesoClientes { get; set; }
    public DbSet<Notificacion> notificacion { get; set; }
    public DbSet<Destino> destino { get; set; }
    public DbSet<MPago> pago { get; set; }

    //
    public DbSet<Conductor> conduc { get; set; }
    //

    protected override void OnModelCreating(DbModelBuilder builder)
    {
        builder.HasDefaultSchema("public");

        base.OnModelCreating(builder);
    }
}