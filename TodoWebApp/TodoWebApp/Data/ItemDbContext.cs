using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TodoWebApp.Models;

namespace TodoWebApp.Data
{
    public class ItemDbContext : IdentityDbContext
    {
        public ItemDbContext(DbContextOptions<ItemDbContext> options)
            : base(options)
        {
        }
        public DbSet<TodoWebApp.Models.Item>? Item { get; set; }
        public DbSet<TodoWebApp.Models.Item>? Task { get; set; }
    }
}