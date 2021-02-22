using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de AccesoConductor
/// </summary>
[Serializable]
[Table("acceso_conductor", Schema = "seguridad")]
public class AccesoConductor
{
    private int id;
    private int idConductor;
    private string ip;
    private string mac;
    private DateTime fechaInicio;
    private string session;
    private Nullable<DateTime> fechaFin;

    [Key]
    [Column("id")]
    public int Id { get => id; set => id = value; }
    [Column("id_conductor")]
    public int IdConductor { get => idConductor; set => idConductor = value; }
    [Column("ip")]
    public string Ip { get => ip; set => ip = value; }
    [Column("mac")]
    public string Mac { get => mac; set => mac = value; }
    [Column("fecha_inicio")]
    public DateTime FechaInicio { get => fechaInicio; set => fechaInicio = value; }
    [Column("session")]
    public string Session { get => session; set => session = value; }
    [Column("fecha_fin")]
    public Nullable<DateTime> FechaFin { get => fechaFin; set => fechaFin = value; }
}