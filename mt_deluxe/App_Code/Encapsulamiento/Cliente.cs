using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de Cliente
/// </summary>
[Serializable]
[Table("cliente", Schema = "delux")]
public class Cliente
{
    private int idCliente;
    private string nombrecl;
    private string apellido;
    private DateTime fechaDeNacimiento;
    private string email;
    private string usuario;
    private string contrasena;
    private string modificado;
    private string sesion;
    private Nullable<DateTime> fechaSancion;

    [Key]
    [Column("id_cliente")]
    public int IdCliente { get => idCliente; set => idCliente = value; }
    [Column("nombre")]
    public string Nombrecl { get => nombrecl; set => nombrecl = value; }
    [Column("apellido")]
    public string Apellido { get => apellido; set => apellido = value; }
    [Column("fecha_de_nacimiento")]
    public DateTime FechaDeNacimiento { get => fechaDeNacimiento; set => fechaDeNacimiento = value; }
    [Column("email")]
    public string Email { get => email; set => email = value; }
    [Column("usuario")]
    public string Usuario { get => usuario; set => usuario = value; }
    [Column("contrasena")]
    public string Contrasena { get => contrasena; set => contrasena = value; }
    [Column("modificado")]
    public string Modificado { get => modificado; set => modificado = value; }
    [Column("sesion")]
    public string Sesion { get => sesion; set => sesion = value; }
    [Column("fecha_sancion")]
    public DateTime? FechaSancion { get => fechaSancion; set => fechaSancion = value; }
}