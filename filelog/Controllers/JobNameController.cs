using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using model;

namespace fileLog.Controllers
{
    public class JobNameController : ApiController
    {
        // GET: api/FileName
        public dynamic Get()
        {
             /* --old version
            SPlusEntities sPlusDB = new SPlusEntities();
            var filenames = sPlusDB.FW_CO_FILECONTROL.Where(x => x.PROCESSID.ToLower().Contains("upload")).GroupBy(x => x.PROCESSID).Select(x=>x.Key);
            */
            ScorePlusUATEntities spDB = new ScorePlusUATEntities();
            /*  -- use the view to replace 
            var n=  from jobname in spDB.ls_cfg_jobname 
                    join   jobmatch in spDB.ls_cfg_jobtablematch
                    on  jobname.jobname equals jobmatch.jobname into matchallGroup
                    from item  in  matchallGroup.DefaultIfEmpty() 
                    select new {  }  
             * */

            var n = spDB.ls_cfg_jobmatch_view.ToList();
            return n;
            
        }

        // GET: api/FileName/5
        public string Get(int id)
        {
            return "value";
        }

        // POST: api/FileName
        public void Post([FromBody]string value)
        {
        }

        // PUT: api/FileName/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/FileName/5
        public void Delete(int id)
        {
        }
    }
}
