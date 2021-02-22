using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de Conductor
/// </summary>
[Serializable]
[Table("conductor", Schema = "delux")]
public class Conductor
{
    private int idConductor;
    private string nombre;
    private string apellido;
    private DateTime fechaDeNacimiento;
    private string email;
    private string placa;
    private string celular;
    private string usuario;
    private string contrasena;
    private string modificado;
    private string sesion;
    private int idEstado;
    private string cedula;
    private Nullable<DateTime> fechaSancion;

    private string dispEstado;

    [Key]
    [Column("id_conductor")]
    public int IdConductor { get => idConductor; set => idConductor = value; }
    [Column("nombre")]
    public string Nombre { get => nombre; set => nombre = value; }
    [Column("apellido")]
    public string Apellido { get => apellido; set => apellido = value; }
    [Column("fecha_de_nacimiento")]
    public DateTime FechaDeNacimiento { get => fechaDeNacimiento; set => fechaDeNacimiento = value; }
    [Column("email")]
    public string Email { get => email; set => email = value; }
    [Column("placa")]
    public string Placa { get => placa; set => placa = value; }
    [Column("celular")]
    public string Celular { get => celular; set => celular = value; }
    [Column("usuario")]
    public string Usuario { get => usuario; set => usuario = value; }
    [Column("contrasena")]
    public string Contrasena { get => contrasena; set => contrasena = value; }
    [Column("modificado")]
    public string Modificado { get => modificado; set => modificado = value; }
    [Column("sesion")]
    public string Sesion { get => sesion; set => sesion = value; }
    [Column("id_estado")]
    public int IdEstado { get => idEstado; set => idEstado = value; }

    [NotMapped]
    public string DispEstado { get => dispEstado; set => dispEstado = value; }

    [Column("cedula")]
    public string Cedula { get => cedula; set => cedula = value; }
    [Column("fecha_sancion")]
    public DateTime? FechaSancion { get => fechaSancion; set => fechaSancion = value; }
}