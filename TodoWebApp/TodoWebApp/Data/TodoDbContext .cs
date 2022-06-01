using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TodoWebApp.Models;

namespace TodoWebApp.Data
{
    public class TodoDbContext : IdentityDbContext
    {
        public TodoDbContext(DbContextOptions<TodoDbContext> options)
            : base(options)
        {
        }
        public DbSet<TodoWebApp.Models.Todo>? Todo { get; set; }
        public DbSet<TodoWebApp.Models.Todo>? Task { get; set; }
    }
}