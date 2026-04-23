//*
//* APP1JOB2 - Single-step job: open data sets for simulated application step 2
//*
//* See APP1JOB1.jcl for full comments.
//* Replace HLQ with your site high-level qualifier.
//*
//APP1JOB2 JOB CLASS=A,NOTIFY=&SYSUID,MSGCLASS=X
//*
//STEP1    EXEC PGM=OPENDSN
//STEPLIB  DD   DSN=HLQ.TEST.LOADLIB,DISP=SHR
//SYSUDUMP DD   SYSOUT=*
//CNTRL    DD   *
OPEN=DATASETS-FOR-SIMULATED-APP1JOB2
/*
