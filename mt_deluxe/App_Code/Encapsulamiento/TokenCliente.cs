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
[Table("token_recuperacion", Schema = "seguridad")]

public class TokenCliente
{
  
    private int id;
    private int idCliente;
    private string token;
    private DateTime creado;
    private DateTime vigencia;

    [Key]
    [Column("id")]
    public int Id { get => id; set => id = value; }
    [Column("id_cliente")]
    public int IdCliente { get => idCliente; set => idCliente = value; }
    [Column("token")]
    public string Token { get => token; set => token = value; }
    [Column("creado")]
    public DateTime Creado { get => creado; set => creado = value; }
    [Column("vigencia")]
    public DateTime Vigencia { get => vigencia; set => vigencia = value; }
}