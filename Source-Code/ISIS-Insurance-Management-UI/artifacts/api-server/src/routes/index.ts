import { Router, type IRouter } from "express";
import healthRouter from "./health";
import insuranceRouter from "./insurance";

const router: IRouter = Router();

router.use(healthRouter);
router.use(insuranceRouter);

export default router;
