using model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using fileLog.Models;
using System.Data.Entity;

namespace fileLog.Controllers
{
    public class JobTableNameController : ApiController
    {
        // GET: api/FileJobTableName
        SPlusEntities sPlusDB = new SPlusEntities();
        public dynamic Get()
        {
           
            var jobnames = sPlusDB.FW_CO_FILECONTROL.Where(x => x.PROCESSID.ToLower().Contains("upload")).GroupBy(x => x.PROCESSID).Select(x => x.Key.ToUpper());
            var tablenames = sPlusDB.get_allMasterTable().Select(x => x.ToUpper());
            var fileJobTableHadMatch = sPlusDB.web_jobtable.Select(x => new { tableName = x.tablename.ToUpper(), jobName=x.jobname.ToUpper(),id= x.id,jobFileName= x.jobfilename });
            return new { jobnames, tablenames, fileJobTableHadMatch };
        }

        // GET: api/FileJobTableName/5
        public string Get(int id)
        {
            var n = "cas";
            return "value";
        }

        // POST: api/FileJobTableName
        public HttpResponseMessage Post(List<SaveJobTable> modes)
        {
            
             foreach(var n in modes)
             {
                 var data = sPlusDB.web_jobtable.FirstOrDefault(x => x.jobname == n.jobName);
                 if (data != null)
                 { sPlusDB.Entry(data).State = EntityState.Modified; }
                 else
                 {
                     web_jobtable newJobTable = new web_jobtable {  jobname=n.jobName, tablename=n.tableName};
                     sPlusDB.web_jobtable.Add(newJobTable);
                 }

             }
             sPlusDB.SaveChanges();
             return Request.CreateResponse(HttpStatusCode.OK);
             
        }

        // PUT: api/FileJobTableName/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/FileJobTableName/5
        public void Delete(int id)
        {
        }
    }
}
