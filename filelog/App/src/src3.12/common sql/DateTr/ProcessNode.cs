using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using StarLight.CommonApp;
using System.Collections;
using System.Diagnostics;
using StarLight.CommonBase;

namespace ScoreServer_BatchJob.Takeup
{


    public class Runtime
    {

        private Hashtable hs;
        private Queue<string> sqlIDs;
        public int EffectTotal { get; set; }
        private string xmlFileName;
        public double TimeTotal { get; set; }
        public List<ResultInfo> ResultInfos { get; set; }

        public Runtime(string xmlFileName, Hashtable hs, Queue<string> sqlIDs)
        {
            this.hs = hs;
            this.xmlFileName = xmlFileName;
            this.sqlIDs = sqlIDs;
        }

        public int BeginToCalc(CmEasyDAC dac, CmErrorLogFile log)
        {
            ResultInfos = new List<ResultInfo>();
            Stopwatch watch = new Stopwatch();//temp for log every run time cost
            Stopwatch watch2 = new Stopwatch();//for totlal
            watch2.Start();
            int effect = 0;
            int i = 1;
            double timeCost = 0;
            foreach (var SQLID in sqlIDs)
            {
                watch.Reset();
                watch.Start();
                effect = dac.SQLExecute(xmlFileName, SQLID, hs);
                EffectTotal = EffectTotal + effect;
                watch.Stop();
                timeCost = watch.ElapsedMilliseconds / 1000;
                Console.WriteLine(i.ToString() + ":" + timeCost + "s" + " : " + SQLID);
                Console.WriteLine("\t" + "  " + effect + " record/records effect.");
                log.WriteLine(i.ToString() + ":" + timeCost + "s" + " : " + SQLID);
                log.WriteLine("\t" + effect + " record/records effect.");
                ResultInfos.Add(new ResultInfo { Effect = effect, RunIndex = i, SqlID = SQLID, Timecost = timeCost });
                i = i + 1;
            }
            watch2.Stop();
            TimeTotal = watch2.ElapsedMilliseconds / 1000;
            Console.WriteLine("TimeTotal:" + TimeTotal + "s");
            log.WriteLine("TimeTotal:" + TimeTotal + "s");
            Console.WriteLine("Check Cost More Time");
            #region   only for test
            /*
            string readLine= Console.ReadLine();
            int num = 0;
            while (!String.IsNullOrEmpty(readLine) || Convert.ToInt32(readLine) != -1)
            {
                num = Convert.ToInt32(readLine);

                log.WriteLine("\t" + "------"+ "Cost more time SQLID");
                foreach(var info in ResultInfos.Where(x=>x.Timecost>=num))
                {
                    Console.WriteLine(info.Timecost+"s"+":"+info.SqlID);
                    log.WriteLine(info.Timecost + "s" + ":" + info.SqlID);
                   
                }
               Console.WriteLine("Check Cost More Time");
               readLine= Console.ReadLine();


            }
            */
            #endregion
            foreach (var info in ResultInfos.Where(x => x.Timecost >= 30.0))
            {
                Console.WriteLine(info.Timecost + "s" + ":" + info.SqlID);
                log.WriteLine(info.Timecost + "s" + ":" + info.SqlID);

            }
            return 1;
        }

    }

    public class ResultInfo
    {
        public int RunIndex { get; set; }
        public string SqlID { get; set; }
        public int Effect { get; set; }
        public double Timecost { get; set; }

    }
}
