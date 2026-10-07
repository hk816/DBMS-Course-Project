import { Router, type IRouter } from "express";
import mysql from "mysql2/promise";

const router: IRouter = Router();

const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || "127.0.0.1",
  port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USER || "root",
  password: process.env.MYSQL_PASSWORD || "",
  database: process.env.MYSQL_DATABASE || "healthinsurancedb",
  waitForConnections: true,
  connectionLimit: 10,
});

const id = (prefix: string, n: number) => `${prefix}-${n}`;

router.get("/insurance/state", async (_req, res) => {
  try {
    const [customers] = await pool.query<any[]>(`SELECT customer_id, customer_name, date_of_birth, gender, phone, email, address FROM Customer ORDER BY customer_id`);
    const [plans] = await pool.query<any[]>(`SELECT p.plan_id,p.plan_name,p.coverage_limit,p.premium_amount,
      COALESCE(GROUP_CONCAT(CONCAT(t.treatment_name,' (',pt.coverage_percentage,'%)') ORDER BY t.treatment_name SEPARATOR ', '),'') covered_treatments,
      COALESCE(MAX(pt.coverage_percentage),0) coverage_percent
      FROM Plan p LEFT JOIN PlanTreatment pt ON p.plan_id=pt.plan_id LEFT JOIN Treatment t ON t.treatment_id=pt.treatment_id
      GROUP BY p.plan_id,p.plan_name,p.coverage_limit,p.premium_amount ORDER BY p.plan_id`);
    const [policies] = await pool.query<any[]>(`SELECT policy_id,policy_number,customer_id,plan_id,start_date,end_date,sum_insured,status FROM Policy ORDER BY policy_id`);
    const [dependents] = await pool.query<any[]>(`SELECT dependent_id,policy_id,dependent_name,relationship,date_of_birth,gender FROM Dependent ORDER BY dependent_id`);
    const [payments] = await pool.query<any[]>(`SELECT pr.premium_id,pr.policy_id,pr.due_date,pr.amount_due,pr.status,
      MAX(pay.payment_date) paid_date,MAX(pay.transaction_reference) reference
      FROM Premium pr LEFT JOIN Payment pay ON pay.premium_id=pr.premium_id GROUP BY pr.premium_id,pr.policy_id,pr.due_date,pr.amount_due,pr.status ORDER BY pr.premium_id`);
    const [hospitals] = await pool.query<any[]>(`SELECT hospital_id,hospital_name,address,city,phone,hospital_type FROM Hospital ORDER BY hospital_id`);
    const [claims] = await pool.query<any[]>(`SELECT cl.claim_id,cl.claim_number,p.customer_id,cl.policy_id,cl.hospital_id,t.treatment_name,cl.claim_date,cl.claim_amount,cl.status
      FROM Claim cl JOIN Policy p ON p.policy_id=cl.policy_id JOIN Treatment t ON t.treatment_id=cl.treatment_id ORDER BY cl.claim_id DESC`);
    const [docs] = await pool.query<any[]>(`SELECT document_id,claim_id,document_name,document_type,verification_status FROM ClaimDocument ORDER BY document_id`);
    const [settlements] = await pool.query<any[]>(`SELECT settlement_id,claim_id,settlement_date,settlement_amount,settlement_status,payment_reference FROM Settlement ORDER BY settlement_id`);
    const [appeals] = await pool.query<any[]>(`SELECT appeal_id,claim_id,reason,status,remarks FROM Appeal ORDER BY appeal_id`);

    res.json({
      customers: customers.map(x=>({id:id('CUS',x.customer_id),fullName:x.customer_name,dob:x.date_of_birth?.toISOString?.().slice(0,10)||x.date_of_birth,gender:x.gender,phone:x.phone,email:x.email,address:x.address,governmentId:""})),
      plans: plans.map(x=>({id:id('PLN',x.plan_id),name:x.plan_name,coveredTreatments:x.covered_treatments||'',coveragePercent:Number(x.coverage_percent),maxCoverageINR:Number(x.coverage_limit),annualPremiumINR:Number(x.premium_amount)})),
      policies: policies.map(x=>({id:id('POL',x.policy_id),policyNumber:x.policy_number,customerId:id('CUS',x.customer_id),planId:id('PLN',x.plan_id),startDate:x.start_date?.toISOString?.().slice(0,10)||x.start_date,endDate:x.end_date?.toISOString?.().slice(0,10)||x.end_date,sumInsuredINR:Number(x.sum_insured),remainingLimitINR:Number(x.sum_insured),status:x.status})),
      dependents: dependents.map(x=>({id:id('DEP',x.dependent_id),policyId:id('POL',x.policy_id),name:x.dependent_name,relationship:x.relationship,dob:x.date_of_birth?.toISOString?.().slice(0,10)||x.date_of_birth,gender:x.gender})),
      payments: payments.map(x=>({id:id('PAY',x.premium_id),policyId:id('POL',x.policy_id),dueDate:x.due_date?.toISOString?.().slice(0,10)||x.due_date,amountINR:Number(x.amount_due),status:x.status,paidDate:x.paid_date?.toISOString?.().slice(0,10)||x.paid_date||'',reference:x.reference||''})),
      hospitals: hospitals.map(x=>({id:id('HSP',x.hospital_id),name:x.hospital_name,address:x.address,city:x.city,phone:x.phone,category:x.hospital_type})),
      claims: claims.map(x=>({id:id('CLM',x.claim_id),claimNumber:x.claim_number,customerId:id('CUS',x.customer_id),policyId:id('POL',x.policy_id),hospitalId:id('HSP',x.hospital_id),treatment:x.treatment_name,claimDate:x.claim_date?.toISOString?.().slice(0,10)||x.claim_date,amountINR:Number(x.claim_amount),status:x.status,documents:docs.filter(d=>d.claim_id===x.claim_id).map(d=>({id:id('DOC',d.document_id),name:d.document_name,type:d.document_type,status:d.verification_status}))})),
      settlements:settlements.map(x=>({id:id('SET',x.settlement_id),claimId:id('CLM',x.claim_id),date:x.settlement_date?.toISOString?.().slice(0,10)||x.settlement_date,amountINR:Number(x.settlement_amount),status:x.settlement_status,paymentReference:x.payment_reference})),
      appeals: appeals.map(x=>({id:id('APL',x.appeal_id),claimId:id('CLM',x.claim_id),reason:x.reason,status:x.status,resolutionNotes:x.remarks||''})),
    });
  } catch (e:any) {
    res.status(500).json({error:e?.message||"MySQL connection failed"});
  }
});

const num = (value: string) => Number(String(value).split('-').pop());

router.post("/insurance/customers", async (req,res)=>{
  try {
    const {fullName,dob,gender,phone,email,address}=req.body;
    const [r] = await pool.execute<any>(`INSERT INTO Customer(customer_name,date_of_birth,gender,phone,email,address) VALUES (?,?,?,?,?,?)`,[fullName,dob||null,gender||'Other',phone,email,address||'']);
    res.json({id:id('CUS',r.insertId)});
  } catch(e:any){res.status(400).json({error:e?.message||'Could not create customer'});}
});

router.post("/insurance/hospitals", async (req,res)=>{
  try { const {name,address,city,phone,category}=req.body; const [r]=await pool.execute<any>(`INSERT INTO Hospital(hospital_name,address,city,phone,hospital_type) VALUES (?,?,?,?,?)`,[name,address,city,phone,category]); res.json({id:id('HSP',r.insertId)}); }
  catch(e:any){res.status(400).json({error:e?.message||'Could not create hospital'});}
});

router.post("/insurance/claims", async (req,res)=>{
  try {
    const {customerId,policyId,hospitalId,treatment,claimDate,amountINR,documentName,documentType}=req.body;
    const policy_id=num(policyId), hospital_id=num(hospitalId);
    const [tr]=await pool.query<any[]>(`SELECT treatment_id FROM Treatment WHERE treatment_name=? LIMIT 1`,[treatment]);
    if(!tr.length) return res.status(400).json({error:'Treatment name does not exist in MySQL Treatment table'});
    const [r]=await pool.execute<any>(`INSERT INTO Claim(claim_number,policy_id,hospital_id,treatment_id,claim_date,admission_date,discharge_date,claim_amount,status) VALUES (?,?,?,?,?,?,?,?,?)`,[
      `UI-${Date.now()}`,policy_id,hospital_id,tr[0].treatment_id,claimDate,claimDate,claimDate,Number(amountINR),'Pending']);
    if(documentName) await pool.execute(`INSERT INTO ClaimDocument(claim_id,document_type,document_name,submission_date,verification_status) VALUES (?,?,?,?,?)`,[r.insertId,documentType||'Other',documentName,claimDate,'Pending']);
    res.json({id:id('CLM',r.insertId)});
  } catch(e:any){res.status(400).json({error:e?.message||'Could not create claim'});}
});

router.delete("/insurance/claims/:id", async (req,res)=>{
  try { await pool.execute(`DELETE FROM Claim WHERE claim_id=?`,[num(req.params.id)]); res.json({ok:true}); }
  catch(e:any){res.status(400).json({error:e?.message||'Could not delete claim'});}
});

router.post("/insurance/evaluate/:id", async (req,res)=>{
  try { const [rows]=await pool.query<any[]>(`CALL EvaluateClaim(?)`,[num(req.params.id)]); res.json(rows); }
  catch(e:any){res.status(400).json({error:e?.message||'Evaluation failed'});}
});

export default router;
