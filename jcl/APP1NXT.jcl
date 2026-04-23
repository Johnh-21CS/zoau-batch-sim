//*
//* APP1NXT - Next-cycle job
//*
//* This job is submitted at the end of each application simulation cycle.
//* It uses a JES SCHEDULE card to defer execution until the next scheduled
//* interval, simulating the wait between batch application invocations
//* (e.g., daily, hourly).
//*
//* Adjust the SCHEDULE card to match your required cycle interval.
//* Replace HLQ with your site high-level qualifier.
//*
//APP1NXT  JOB CLASS=A,NOTIFY=&SYSUID,MSGCLASS=X
//*
//* JES SCHEDULE card — defers this job until the next cycle.
//* Adjust START= to set the next invocation time.
//* Example below schedules for 06:00 the following day.
//*
// SCHEDULE START=0600
//*
//STEP1    EXEC PGM=IEFBR14
//*
//* When this job activates, it submits APP1JOB1 to begin the next cycle.
//* Uncomment and adapt the steps below to chain back into the job stream.
//*
//*SUBMIT   EXEC PGM=IEBGENER
//*SYSIN    DD DUMMY,DCB=BLKSIZE=80
//*SYSPRINT DD SYSOUT=*
//*SYSUT2   DD SYSOUT=(,INTRDR)
//*SYSUT1   DD DSN=HLQ.APPXRUN.JCL(APP1JOB1),DISP=SHR
/*
