using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

/// <summary>
/// Descripción breve de Destino
/// </summary>
[Serializable]
[Table("destino", Schema = "delux")]
public class Destino
{

    int id;
    string lugarDestino;
    string lugarUbicacion;

    [Key]
    [Column("id")]
    public int Id { get => id; set => id = value; }
    [Column("lugar_destino")]
    public string LugarDestino { get => lugarDestino; set => lugarDestino = value; }
    [Column("lugar_ubicacion")]
    public string LugarUbicacion { get => lugarUbicacion; set => lugarUbicacion = value; }
}