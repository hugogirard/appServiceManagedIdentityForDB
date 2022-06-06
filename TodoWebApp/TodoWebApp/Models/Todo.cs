using System.ComponentModel.DataAnnotations;

namespace TodoWebApp.Models;

public class Todo
{
    [Key]
    public int Id { get; set; }

    [MaxLength(256)]
    public string Title { get; set; }

    [MaxLength(256)]
    public string Description { get; set; }

    public Todo()
    {

    }
}
