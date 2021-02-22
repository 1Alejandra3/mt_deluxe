using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de Administrador
/// </summary>
[Serializable]
[Table("administrador", Schema = "delux")]
public class Administrador
{
    private int id;
    private string usuario;
    private string contrasena;

    [Key]
    [Column("id")]
    public int Id { get => id; set => id = value; }
    [Column("usuario")]
    public string Usuario { get => usuario; set => usuario = value; }
    [Column("contrasena")]
    public string Contrasena { get => contrasena; set => contrasena = value; }
}