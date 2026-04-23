//*
//* APP1JOB1 - Single-step job: open data sets for simulated application step 1
//*
//* This is a simple single-step job used by the Python/ZOAU orchestration
//* script. Its only responsibility is to run the OPENDSN program, which
//* opens the data sets and waits for a Modify command (F APP1JOB1,CLOSE)
//* to close them and terminate.
//*
//* Replace HLQ with your site high-level qualifier.
//* Replace OPENDSN with your data set open program name.
//* Replace QA.ZDMF.TEST.LOADLIB with the load library containing OPENDSN.
//*
//APP1JOB1 JOB CLASS=A,NOTIFY=&SYSUID,MSGCLASS=X
//*
//STEP1    EXEC PGM=OPENDSN
//STEPLIB  DD   DSN=HLQ.TEST.LOADLIB,DISP=SHR
//SYSUDUMP DD   SYSOUT=*
//CNTRL    DD   *
OPEN=DATASETS-FOR-SIMULATED-APP1JOB1
/*
