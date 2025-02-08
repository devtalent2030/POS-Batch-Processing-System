//*=======================================================================*
//* POS_BATCH_MASTER: Master JCL to run POS Batch Processing System      *
//*                                                                       *
//* This JCL executes batch jobs for validating transactions (A6),         *
//* splitting transactions (A7), processing sales and layaways (A8),      *
//* and handling returns (A9).                                            *
//*=======================================================================*

//POSBATCH JOB (ACCT),'POS BATCH SYSTEM',CLASS=A,MSGCLASS=A,
//            NOTIFY=&SYSUID
//*=======================================================================*
//* STEP 1: Compile and Run A6 - Transaction Validation
//*=======================================================================*
//A6COMP   EXEC PGM=IGYWCLG
//A6SYSIN  DD DSN=KC03YYY.DCMAFD01.A6.CBL(A6EDIT),DISP=SHR
//A6SYSLIB DD DSN=SYS1.COBLIB,DISP=SHR
//A6SYSPCH DD DSN=KC03YYY.DCMAFD01.A6.LIST,DISP=SHR
//A6SYSLMOD DD DSN=KC03YYY.DCMAFD01.A6.LOAD,DISP=SHR
//A6SYSOUT DD SYSOUT=*
//A6EXEC   EXEC PGM=A6EDIT
//A6IN     DD DSN=KC03E9B.DCMAFD01.A6.INV.DAT,DISP=SHR
//A6OUT    DD DSN=KC03E9B.DCMAFD01.A6.VAL.DAT,DISP=SHR
//A6RPT    DD DSN=KC03E9B.DCMAFD01.A6.ERPT.OUT,DISP=SHR

//*=======================================================================*
//* STEP 2: Compile and Run A7 - Transaction Splitting
//*=======================================================================*
//A7COMP   EXEC PGM=IGYWCLG
//A7SYSIN  DD DSN=KC03YYY.DCMAFD01.A7.CBL(A7SPLIT),DISP=SHR
//A7SYSLIB DD DSN=SYS1.COBLIB,DISP=SHR
//A7SYSPCH DD DSN=KC03YYY.DCMAFD01.A7.LIST,DISP=SHR
//A7SYSLMOD DD DSN=KC03YYY.DCMAFD01.A7.LOAD,DISP=SHR
//A7SYSOUT DD SYSOUT=*
//A7EXEC   EXEC PGM=A7SPLIT
//A7IN     DD DSN=KC03E9B.DCMAFD01.A6.VAL.DAT,DISP=SHR
//A7SLDAT  DD DSN=KC03E9B.DCMAFD01.A7.SL.DAT,DISP=SHR
//A7RETDAT DD DSN=KC03E9B.DCMAFD01.A7.RET.DAT,DISP=SHR
//A7RPT    DD DSN=KC03E9B.DCMAFD01.A7.RPT.OUT,DISP=SHR

//*=======================================================================*
//* STEP 3: Compile and Run A8 - Sales & Layaway Processing
//*=======================================================================*
//A8COMP   EXEC PGM=IGYWCLG
//A8SYSIN  DD DSN=KC03YYY.DCMAFD01.A8.CBL(A8SL),DISP=SHR
//A8SYSLIB DD DSN=SYS1.COBLIB,DISP=SHR
//A8SYSPCH DD DSN=KC03YYY.DCMAFD01.A8.LIST,DISP=SHR
//A8SYSLMOD DD DSN=KC03YYY.DCMAFD01.A8.LOAD,DISP=SHR
//A8SYSOUT DD SYSOUT=*
//A8EXEC   EXEC PGM=A8SL
//A8SLDAT  DD DSN=KC03E9B.DCMAFD01.A7.SL.DAT,DISP=SHR
//A8RPT    DD DSN=KC03E9B.DCMAFD01.A8.RPT.OUT,DISP=SHR

//*=======================================================================*
//* STEP 4: Compile and Run A9 - Returns Processing
//*=======================================================================*
//A9COMP   EXEC PGM=IGYWCLG
//A9SYSIN  DD DSN=KC03YYY.DCMAFD01.A9.CBL(A9RET),DISP=SHR
//A9SYSLIB DD DSN=SYS1.COBLIB,DISP=SHR
//A9SYSPCH DD DSN=KC03YYY.DCMAFD01.A9.LIST,DISP=SHR
//A9SYSLMOD DD DSN=KC03YYY.DCMAFD01.A9.LOAD,DISP=SHR
//A9SYSOUT DD SYSOUT=*
//A9EXEC   EXEC PGM=A9RET
//A9RETDAT DD DSN=KC03E9B.DCMAFD01.A7.RET.DAT,DISP=SHR
//A9RPT    DD DSN=KC03E9B.DCMAFD01.A9.RPT.OUT,DISP=SHR

//*=======================================================================*
//* END OF JOB
//*=======================================================================*