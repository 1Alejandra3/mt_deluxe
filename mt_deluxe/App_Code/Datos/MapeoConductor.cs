using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de MapeoConductor
/// </summary>
public class MapeoConductor : DbContext
{
    static MapeoConductor()
    {
        Database.SetInitializer<MapeoCliente>(null);
    }

    public MapeoConductor()
        : base("name=bd_proyecto")
    {
        
    }

    public DbSet<Conductor> conduc { get; set; }
    public DbSet<TokenConductor> token { get; set; }
    public DbSet<AccesoConductor> accesoconductor { get; set; }
    public DbSet<Estado> estado { get; set; }

    //
    public DbSet<Notificacion> notificacion { get; set; }
    public DbSet<Cliente> client { get; set; }
    public DbSet<Destino> destino { get; set; }
    public DbSet<MPago> pago { get; set; }
    //

    protected override void OnModelCreating(DbModelBuilder builder)
    {
        builder.HasDefaultSchema("public");

        base.OnModelCreating(builder);
    }
}