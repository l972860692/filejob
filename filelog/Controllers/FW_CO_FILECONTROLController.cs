using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using model;

namespace fileLog.Controllers
{
    public class FW_CO_FILECONTROLController : Controller
    {
        //old version
       // private SPlusEntities db = new SPlusEntities();

        // GET: FW_CO_FILECONTROL
        /*
        public ActionResult Index()
        {
            var m = db.FW_CO_FILECONTROL.OrderBy(x => x.RUNID).Where(x=>x.RUNID !=null).Skip(100).Take(20).ToList();
            ViewBag.data = m;
            return View();
        }

        // GET: FW_CO_FILECONTROL/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            FW_CO_FILECONTROL fW_CO_FILECONTROL = db.FW_CO_FILECONTROL.FirstOrDefault(x=>x.RUNID==id);
            if (fW_CO_FILECONTROL == null)
            {
                return HttpNotFound();
            }
            return View(fW_CO_FILECONTROL);
        }

        // GET: FW_CO_FILECONTROL/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: FW_CO_FILECONTROL/Create
        // 为了防止“过多发布”攻击，请启用要绑定到的特定属性，有关 
        // 详细信息，请参阅 http://go.microsoft.com/fwlink/?LinkId=317598。
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "RECID,PROCESSID,RUNID,SUBPROCESS,ISREPROCESS,FILENAME,STARTSEQNO,ENDSEQNO,PROCESSDATETIME,OUTPUTFILENAME,NOFINPUT,NOFVALID,NOFREJECT,NOFIGNORE,DELETEIND")] FW_CO_FILECONTROL fW_CO_FILECONTROL)
        {
            if (ModelState.IsValid)
            {
                db.FW_CO_FILECONTROL.Add(fW_CO_FILECONTROL);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(fW_CO_FILECONTROL);
        }

        // GET: FW_CO_FILECONTROL/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            FW_CO_FILECONTROL fW_CO_FILECONTROL = db.FW_CO_FILECONTROL.Find(id);
            if (fW_CO_FILECONTROL == null)
            {
                return HttpNotFound();
            }
            return View(fW_CO_FILECONTROL);
        }

        // POST: FW_CO_FILECONTROL/Edit/5
        // 为了防止“过多发布”攻击，请启用要绑定到的特定属性，有关 
        // 详细信息，请参阅 http://go.microsoft.com/fwlink/?LinkId=317598。
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "RECID,PROCESSID,RUNID,SUBPROCESS,ISREPROCESS,FILENAME,STARTSEQNO,ENDSEQNO,PROCESSDATETIME,OUTPUTFILENAME,NOFINPUT,NOFVALID,NOFREJECT,NOFIGNORE,DELETEIND")] FW_CO_FILECONTROL fW_CO_FILECONTROL)
        {
            if (ModelState.IsValid)
            {
                db.Entry(fW_CO_FILECONTROL).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(fW_CO_FILECONTROL);
        }

        // GET: FW_CO_FILECONTROL/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            FW_CO_FILECONTROL fW_CO_FILECONTROL = db.FW_CO_FILECONTROL.Find(id);
            if (fW_CO_FILECONTROL == null)
            {
                return HttpNotFound();
            }
            return View(fW_CO_FILECONTROL);
        }

        // POST: FW_CO_FILECONTROL/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            FW_CO_FILECONTROL fW_CO_FILECONTROL = db.FW_CO_FILECONTROL.Find(id);
            db.FW_CO_FILECONTROL.Remove(fW_CO_FILECONTROL);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
         * */
    }
}
