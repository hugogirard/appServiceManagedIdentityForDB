using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using TodoWebApp.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Add services to the container.
var todoCnxString = builder.Configuration["TodoCnxString"];

var orderCnxString = builder.Configuration["OrderCnxString"];

builder.Services.AddDbContext<TodoDbContext>
    (options =>
    options.UseSqlServer(todoCnxString));

builder.Services.AddDbContext<ItemDbContext>
    (options =>
    options.UseSqlServer(orderCnxString));

builder.Services.AddControllersWithViews();

var app = builder.Build();

var scopedFactory = app.Services.GetService<IServiceScopeFactory>();

using (var scope = scopedFactory.CreateScope())
{
    var todoDbContext = scope.ServiceProvider.GetService<TodoDbContext>();
    todoDbContext.Database.EnsureCreated();
    var itemDbContext = scope.ServiceProvider.GetService<ItemDbContext>();
    itemDbContext.Database.EnsureCreated();
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
