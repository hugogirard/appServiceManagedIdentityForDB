/*
* Notice: Any links, references, or attachments that contain sample scripts, code, or commands comes with the following notification.
*
* This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
* THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
* INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
*
* We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
* provided that You agree:
*
* (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
* (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
* (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits,
* including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
*
* Please note: None of the conditions outlined in the disclaimer above will superseded the terms and conditions contained within the Premier Customer Services Description.
*
* DEMO POC - "AS IS"
*/

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
