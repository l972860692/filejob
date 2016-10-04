using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using StarLight.CommonBase;
using StarLight.CommonApp;
using StarLight.Server;
using System.Diagnostics;
using System.Threading;
namespace ScoreServer_BatchJob.Takeup
{
    class Ext_Takeup_Acutal : ISCOREBatch
    {

        //private StarProcessState ps;
        private const string processName = "Ext_Takeup_Acutal";//for log and jc
        private CmJobControl jc;
        private ProcessState ps = new ProcessState();
        private CmErrorLogFile log = null; //to write log to file
        private string runID = "TakingUP_RunID"; //JobID  for jc
        private string XmlFileName = "SQL_VDR_EXT_MT_PEG_TAKINGUP.xml";
        private CmEasyDAC dac;
        Stopwatch sw = new Stopwatch();
        public void Initialize(string _processName, string[] _svcNoList)
        {
            ps.ProcessID = processName;
            log = new CmErrorLogFile(ps.ProcessID);
            log.WriteLine("Proces " + ps.ProcessID + " started ...");
            jc = new CmJobControl(ps.ProcessID, runID, "", "ALL", "");
            Console.WriteLine("Proces " + ps.ProcessID + " started ...");
        }

        public int Process()
        {
            #region  Init variable... loading xml file
            int year = 2014;
            int month = 8;
            Hashtable hs = new Hashtable();
            hs["ComputingYear"] = year.ToString();
            hs["ComputingMonth"] = month.ToString();
            hs["ProcessDay"] = GetProcessDay();
            DateTime dtBegin = new DateTime(year, month, 01);
            DateTime dtEnd = new DateTime(year, month, 01).AddMonths(1);
            hs["dtBegin"] = dtBegin.ToString("yyyy-MM-dd");
            hs["dtEnd"] = dtEnd.ToString("yyyy-MM-dd"); ;


            CmErrorLogFile log = new CmErrorLogFile(runID);
            #endregion

            try
            {
                //合并以前的upload和takingup
                BeginProcessOldPegTakingup(hs);
            

            }
            catch (ApplicationException ex)
            {
                log.WriteLine("Exception encountered for process " + ps.ProcessID, ex);
                jc.jobStatus = CmJobControl.JOBSTATUS_FAIL;
                ////jc.CloseJob(CmJobControl.JOBSTATUS_FAIL); //, ex.Message);
            }
            return 1;
        }

        public void CleanUp()
        {
            //Dispose Dac
            if (this.dac != null)
                this.dac.Dispose();
            Console.WriteLine("Proces " + ps.ProcessID + " ended.");
            log.WriteLine("Proces " + ps.ProcessID + " ended.");
        }



        //合并以前的upload和takingup
        private int BeginProcessOldPegTakingup(Hashtable hsDateParam)
        {

            string SQLID = "0";
            Stopwatch watch = new Stopwatch();
            this.dac = new CmEasyDAC();
            Queue<string> sqlIDs = new Queue<string>();


            // SQLID
            SQLID = "TEMP_CLEAR";sqlIDs.Enqueue(SQLID);
            //Copy equipmodel
            SQLID = "COPY_EQUIPMODEL"; sqlIDs.Enqueue(SQLID);
            SQLID = "UPDATE_HISSVCNO"; sqlIDs.Enqueue(SQLID);           
            SQLID = "DETERMINE_MBB_RECORDS";sqlIDs.Enqueue(SQLID);
            SQLID = "DETERMINE_MOBILESHARE_RECORDS"; sqlIDs.Enqueue(SQLID);
            SQLID = "DETERMINE_NM_RECORDS"; sqlIDs.Enqueue(SQLID);
            SQLID = "DETERMINE_SUPPERSIM_RECORDS"; sqlIDs.Enqueue(SQLID);
            SQLID = "DETERMINE_SIMONLY_RECORDS"; sqlIDs.Enqueue(SQLID);
            SQLID = "DETERMIN_CP_IGNORE"; sqlIDs.Enqueue(SQLID);
            SQLID = "SET_NO_PAY_FOR_EMPTY_AITYPEANDLINETYPE"; sqlIDs.Enqueue(SQLID);
            //这个里面测试有问题case when @YEAR = 2014 and @MONTH= 8 
            SQLID = "GET_LATEST_INFO_FOR_MBB"; sqlIDs.Enqueue(SQLID);

            #region    now have use this no cease OUA5174001
            SQLID = "UPDATE_PORT_IN_TYPE"; sqlIDs.Enqueue(SQLID);
            #endregion
            SQLID = "SVCNO_EMPTY_UPDATE"; sqlIDs.Enqueue(SQLID);
            SQLID = "EFF_EMPTY_UPDATE"; sqlIDs.Enqueue(SQLID);
            SQLID = "ORDERCLOSEDATE_EMPTY_UPDATE"; sqlIDs.Enqueue(SQLID);           

            #region no use
            // SQLID = "CUSTID_EMPTY_UPDATE";

            #endregion 
            SQLID = "GET_REPORTINFO_FROM_SPEAR"; sqlIDs.Enqueue(SQLID); //提前
            SQLID = "UPDATE_DEALERCODE_FROMSPEAR"; sqlIDs.Enqueue(SQLID); //提前
            SQLID = "EMPTY_DEALERCODE"; sqlIDs.Enqueue(SQLID);
            SQLID = "REJECT_INVALID_DEALERCODE"; sqlIDs.Enqueue(SQLID);           
           
            #region no use
            //CP and Change service or change VS order ignore already
            //#region 7.Ignore CP order  mp --cv can  update  once  finally
            //watch.Reset();watch.Start();SQLID = "IGNORE_CP_ORDER";
            //RejectResult = dac.SQLExecute(XmlFileName, SQLID, hsDateParam);
            //RejectCount += RejectResult;
            //Console.WriteLine("(7) IGNORE_CP_ORDER...");
            //Console.WriteLine("\t" + RejectResult + " record/records effect.");
            //log.WriteLine("(7) IGNORE_CP_ORDER...");
            //log.WriteLine("\t" + RejectResult + " record/records effect.");

            //#endregion
              #endregion
            SQLID = "IGNORE_VOID_ORDER"; sqlIDs.Enqueue(SQLID);
            SQLID = "IGNORE_VOID_CI"; sqlIDs.Enqueue(SQLID);
            SQLID = "IGNORE_CEASE_ORDER"; sqlIDs.Enqueue(SQLID);           
            SQLID = "IGNORE_MAINLINE_CEASED"; sqlIDs.Enqueue(SQLID);
            SQLID = "MAINLINECEASE_2"; sqlIDs.Enqueue(SQLID);           

             #region   no use
             //Duplicate check all done in AI computation
            //#region 12.Multiple SvcNO and EffectiveDate  mp --cv can  update  once  finally
            //watch.Reset();watch.Start();SQLID = "MULTIPLE_SVCNOANDEFFE_SAMEMONTH_UPDATE";
            //RejectResult = dac.SQLExecute(XmlFileName, SQLID, hsDateParam);
            //RejectCount += RejectResult;
            //Console.WriteLine("(12) MULTIPLE_SVCNOANDEFFE_SAMEMONTH_UPDATE...");
            //Console.WriteLine("\t" + RejectResult + " record/records effect.");
            //log.WriteLine("(12) MULTIPLE_SVCNOANDEFFE_SAMEMONTH_UPDATE...");
            //log.WriteLine("\t" + RejectResult + " record/records effect.");
            //#endregion
            //这里有点问题

            //Duplicate check all done in AI computation
            //#region 13.Multiple SvcNO and EffectiveDate But Different OrderNO   mp --cv can  update  once  finally
            //watch.Reset();watch.Start();SQLID = "MULTIPLE_SVCNO_DIFFERENT_ORDERNO";
            //RejectResult = dac.SQLExecute(XmlFileName, SQLID, hsDateParam);
            //RejectCount += RejectResult;
            //Console.WriteLine("(13) MULTIPLE_SVCNO_DIFFERENT_ORDERNO...");
            //Console.WriteLine("\t" + RejectResult + " record/records effect.");
            //log.WriteLine("(13) MULTIPLE_SVCNO_DIFFERENT_ORDERNO...");
            //log.WriteLine("\t" + RejectResult + " record/records effect.");
             //#endregion
             #endregion
             SQLID = "UPDATE_PrevEqptPenaltyContractDate"; sqlIDs.Enqueue(SQLID);
             SQLID = "PRE_TO_POST"; sqlIDs.Enqueue(SQLID);
             SQLID = "UPDATE_TIEIN"; sqlIDs.Enqueue(SQLID);
             SQLID = "UPDATE_CK_BALANCE"; sqlIDs.Enqueue(SQLID);
             SQLID = "FRESH_EQUIPMODEL_FOR_MBBRECON"; sqlIDs.Enqueue(SQLID);            
             SQLID = "UPDATE_APPROVAL"; sqlIDs.Enqueue(SQLID);
             SQLID = "UPDATE_CIS_PEGASUS"; sqlIDs.Enqueue(SQLID);
             SQLID = "UPDATE_CIS_CKM"; sqlIDs.Enqueue(SQLID);
             SQLID = "SET_CUSTTYPE"; sqlIDs.Enqueue(SQLID);
           
             #region   no use
             //PASS_SUPERSIM
            //PASS_MBBRECON
            //IGNORE_CP_ORDER
           //UPDATE_AITYPE_FOR_NL                 
            //SQLID = "PASS_SUPERSIM";                  
           //SQLID = "PASS_MBBRECON";
           //SQLID = "PASS_MBBVAS";
           //SQLID = "UPDATE_AITYPE_FOR_NL";
             //SQLID = "UPDATE_AITYPE_FOR_CI";

            #endregion

             SQLID = "REJECT_TOS"; sqlIDs.Enqueue(SQLID);
            //提前 SQLID = "GET_REPORTINFO_FROM_SPEAR"; sqlIDs.Enqueue(SQLID);
             SQLID = "UPDATE_CUSTID_FROMSPEAR"; sqlIDs.Enqueue(SQLID);
             //提前 SQLID = "UPDATE_DEALERCODE_FROMSPEAR"; sqlIDs.Enqueue(SQLID);
             SQLID = "RESET_VENDORTYPE"; sqlIDs.Enqueue(SQLID);
             SQLID = "RESET_VENDORCODE"; sqlIDs.Enqueue(SQLID);
             SQLID = "GET_REPORTINFO_FROM_EASIPOS"; sqlIDs.Enqueue(SQLID);
             SQLID = "INIT_REPORTINFO"; sqlIDs.Enqueue(SQLID);
             SQLID = "REJECT_IGNORE_CV_BASEDON_MAINLINE"; sqlIDs.Enqueue(SQLID);
             SQLID = "IGNORE_VAS_CEASED"; sqlIDs.Enqueue(SQLID);
             #region   no use
             // SQLID = "COUNT_ALLSERMP_INPUT"; sqlIDs.Enqueue(SQLID);
            // SQLID = "COUNT_ALLSERMP_REJECT"; sqlIDs.Enqueue(SQLID);
             // SQLID = "COUNT_ALLSERMP_IGNORE"; sqlIDs.Enqueue(SQLID);
             #endregion
             SQLID = "MASTER_TO_ALLSER_MP"; sqlIDs.Enqueue(SQLID);

             #region   no use
             //  SQLID = "COUNT_ALLSERCV_INPUT"; sqlIDs.Enqueue(SQLID);
            // SQLID = "COUNT_ALLSERCV_REJECT"; sqlIDs.Enqueue(SQLID);
             // SQLID = "COUNT_ALLSERCV_IGNORE"; sqlIDs.Enqueue(SQLID);
             #endregion

            // SQLID = "MASTER_TO_ALLSER_CV"; sqlIDs.Enqueue(SQLID);
             SQLID = "MASTER_TO_MBBVAS_CV"; sqlIDs.Enqueue(SQLID);
             SQLID = "INSERT_ALLCOUNT"; sqlIDs.Enqueue(SQLID);//以后需要叫rectype
               
             Runtime r= new Runtime(XmlFileName,hsDateParam,sqlIDs);
             r.BeginToCalc(dac, log);
            
            return 1;
        }

        public string GetProcessDay()
        {
            CmEasyDAC dac = new CmEasyDAC();
            DataSet ds = dac.SQLSelect(XmlFileName, "GET_PROCESSDAY", null, "GET_PROCESSDAY");
            return ds.Tables[0].Rows[0]["PARAMCATECODE"].ToString();
        }



    }

 
}
