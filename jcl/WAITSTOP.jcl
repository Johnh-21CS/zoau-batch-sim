//*
//* APP1JOB1 (JCL approach) - Three-step orchestration job
//*
//* This is the JCL-only alternative to the Python/ZOAU script.
//* It uses three steps and the internal reader to:
//*   Step 1 - Submit a controlling job that waits and issues a Modify command
//*   Step 2 - Run the OPENDSN program to open the data sets
//*   Step 3 - Submit the next job in the application cycle
//*
//* Prerequisites:
//*   - WAITSTOP PROC available in your PROCLIB
//*   - SUBNEXT  PROC available in your PROCLIB
//*   - OPENDSN program available in HLQ.TEST.LOADLIB
//*
//* Replace HLQ with your site high-level qualifier.
//*
//APP1JOB1 JOB CLASS=A,NOTIFY=&SYSUID,MSGCLASS=X
//*
//* ---------------------------------------------------------------
//* STEP 1: Submit the controlling job via the internal reader.
//*
//*   IEBGENER is used as a simple copy utility here.
//*   SYSUT1 contains inline JCL (delimited by ZZ) for the
//*   controlling job. SYSUT2 routes it to SYSOUT=(,INTRDR),
//*   which causes JES to read and queue it as a new job.
//*
//*   The controlling job (CONTROL1) uses the WAITSTOP PROC to
//*   wait TIME= seconds, then issues a Modify command to close
//*   the data sets opened in Step 2.
//* ---------------------------------------------------------------
//SUB1     EXEC PGM=IEBGENER
//SYSIN    DD DUMMY,DCB=BLKSIZE=80
//SYSPRINT DD SYSOUT=*
//SYSUT2   DD SYSOUT=(,INTRDR)
//SYSUT1   DD DATA,DLM=ZZ
//CONTROL1 JOB CLASS=A,NOTIFY=&SYSUID,MSGCLASS=X
//INCLUDES JCLLIB ORDER=HLQ.APPXRUN.JCL
//         EXPORT SYMLIST=*
//         SET TIME=900                 SECONDS TO WAIT BEFORE CLOSE
//         SET JOB=APP1JOB1             JOB NAME TO ISSUE MODIFY TO
//WAITSTOP EXEC WAITSTOP
ZZ
//*
//* ---------------------------------------------------------------
//* STEP 2: Run the data set open program.
//*
//*   OPENDSN opens the data sets and waits for a Modify command
//*   (F APP1JOB1,CLOSE) to close them and terminate.
//*   The controlling job submitted in Step 1 issues this command
//*   after the TIME= interval has elapsed.
//* ---------------------------------------------------------------
//AP1S2    EXEC PGM=OPENDSN
//STEPLIB  DD   DSN=HLQ.TEST.LOADLIB,DISP=SHR
//SYSUDUMP DD   SYSOUT=*
//CNTRL    DD   *
OPEN=DATASETS-FOR-SIMULATED-APP1JOB1
/*
//*
//* ---------------------------------------------------------------
//* STEP 3: Submit the next job in the application cycle.
//*
//*   SUBNEXT is an external PROC that submits the job named
//*   in the NEXTJOB symbolic parameter.
//* ---------------------------------------------------------------
//         SET NEXTJOB=APP1JOB2
//SUBN     EXEC SUBNEXT
