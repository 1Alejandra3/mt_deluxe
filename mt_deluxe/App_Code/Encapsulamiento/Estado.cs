using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de Estado
/// </summary>
[Serializable]
[Table("estado", Schema = "delux")]
public class Estado
{
    private int id;
    private string disponibilidad;

    [Key]
    [Column("id")]
    public int Id { get => id; set => id = value; }
    [Column("disponibilidad")]
    public string Disponibilidad { get => disponibilidad; set => disponibilidad = value; }
}