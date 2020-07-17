using DotNetCoreSqlDb.Models;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DotNetCoreSqlDb.Controllers
{
    public class TodosController : Controller
    {
        private readonly MyDatabaseContext _context;
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetry;

        public TodosController(MyDatabaseContext context, ILogger<TodosController> logger, TelemetryClient telemetry)
        {
            this._context = context;
            this._logger = logger;
            this._telemetry = telemetry;
        }

        // GET: Todos
        public async Task<IActionResult> Index()
        {
            var correlationId = Guid.NewGuid().ToString();
            var logContext = new Dictionary<string, object> { ["correlationId"] = correlationId };
            var eventContext = new Dictionary<string, string> { ["correlationId"] = correlationId };

            using (_logger.BeginScope(logContext))
            {
                try
                {
                    _telemetry.TrackEvent("LoadingItems", eventContext);

                    var items = await _context.Todo.ToListAsync();
                    var eventMetrics = new Dictionary<string, double> { ["itemCount"] = items.Count };

                    _logger.LogInformation($"Returning [{items.Count}] item(s)...");
                    _telemetry.TrackEvent("LoadedItems", eventContext, eventMetrics);

                    return View(items);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while loading items.");

                    throw;
                }
            }
        }

        // GET: Todos/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            var correlationId = Guid.NewGuid().ToString();
            var logContext = new Dictionary<string, object> { ["correlationId"] = correlationId, ["itemId"] = id };
            var eventContext = new Dictionary<string, string> { ["correlationId"] = correlationId, ["itemId"] = id.ToString() };

            using (_logger.BeginScope(logContext))
            {
                try
                {
                    _telemetry.TrackEvent("LoadingItemDetail", eventContext);

                    if (id == null)
                    {
                        _logger.LogWarning($"Item [{nameof(id)}] not provided.");
                        return BadRequest($"Item [{nameof(id)}] required.");
                    }

                    var todo = await _context.Todo.FirstOrDefaultAsync(m => m.ID == id);

                    if (todo == null)
                    {
                        _logger.LogWarning($"Item [{id}] not found.");
                        return NotFound($"Item [{id}] not found.");
                    }

                    _logger.LogInformation($"Returning item [{id}]...");
                    _telemetry.TrackEvent("ItemDetailLoaded", eventContext);

                    return View(todo);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error occurred while retrieving item [{id}] details.");

                    throw;
                }
            }
        }

        // GET: Todos/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Todos/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("ID,Description,CreatedDate")] Todo todo)
        {
            if (ModelState.IsValid)
            {
                _context.Add(todo);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }

            return View(todo);
        }

        // GET: Todos/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var todo = await _context.Todo.FindAsync(id);

            if (todo == null)
            {
                return NotFound();
            }
            return View(todo);
        }

        // GET: Todos/RandomMetric/5/blobname/correlationid
        [HttpGet, ActionName("RandomMetric")]
        public async Task<IActionResult> RandomMetric(int? id, string blobName, string correlationId)
        {
            Random rand = new Random();
            var metricValue = rand.NextDouble() * id;            

            var eventContext = new Dictionary<string, string> { ["correlationId"] = correlationId, ["itemId"] = id.ToString(), ["bloblocation"] = blobName, ["fluxCapacitance"] = metricValue.ToString() };
            _telemetry.TrackEvent("RandomMetric", eventContext);

            var todo = await _context.Todo.FindAsync(id);
            if (id == null || todo == null)
            {
                var logContext = new Dictionary<string, string> { ["correlationId"] = correlationId, ["itemId"] = id.ToString(), ["bloblocation"] = blobName, ["fluxCapacitance"] = metricValue.ToString() };
                using (_logger.BeginScope(logContext))
                {
                    _logger.LogError("Todos | RandomMetric | 404 | Not Found");
                }
                    return NotFound();
            }
            return RedirectToAction(nameof(Index));
        }

        // POST: Todos/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("ID,Description,CreatedDate")] Todo todo)
        {
            if (id != todo.ID)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(todo);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!TodoExists(todo.ID))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            return View(todo);
        }

        // GET: Todos/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var todo = await _context.Todo
                .FirstOrDefaultAsync(m => m.ID == id);
            if (todo == null)
            {
                return NotFound();
            }

            return View(todo);
        }

        // POST: Todos/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var todo = await _context.Todo.FindAsync(id);
            _context.Todo.Remove(todo);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool TodoExists(int id)
        {
            return _context.Todo.Any(e => e.ID == id);
        }
    }
}
