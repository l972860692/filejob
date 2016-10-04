using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using model;
using fileLog.Models;

namespace fileLog.Controllers
{
    public class JobTableMactchDataController : ApiController
    {
        // GET: api/JobTableMactchData
        SPlusEntities db = new SPlusEntities(); 
        public dynamic Post(JobDataModel jobDataModel)
        {
            //getJobTableData 'MTVASSPE_UPLOADING','2016-01-01','2016-02-01'
         //   jobDataModel.TheBeginDate = new DateTime(jobDataModel.TheBeginDate.Year,jobDataModel.TheBeginDate.Month,1);
          //  jobDataModel.TheEndDate = jobDataModel.TheBeginDate.AddMonths(1);

            var data=db.getJobTableData(jobDataModel.JobName,jobDataModel.TheBeginDate,jobDataModel.TheEndDate).ToList();
             
            var datas = db.getJobTableData("MTVASSPE_UPLOADING",Convert.ToDateTime("2016-01-01"), Convert.ToDateTime("2016-02-01"));
            return datas;
        }

        [Route("JobTableMactchData/ishavematchtable/{jobname}")]
        public bool GetValue(string jobname)
        {
              if(  db.web_jobtable.FirstOrDefault(x=>x.jobname.ToLower()==jobname.ToLower()) ==null)
              {

                  return false;
              }
            return true;
        }

        // GET: api/JobTableMactchData/5
        public string Get(int id)
        {
            return "value";
        }

        // POST: api/JobTableMactchData

        // PUT: api/JobTableMactchData/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/JobTableMactchData/5
        public void Delete(int id)
        {
        }
    }
}
