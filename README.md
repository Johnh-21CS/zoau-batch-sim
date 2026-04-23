# zoau-batch-sim

A sample project demonstrating two approaches to simulating a traditional z/OS batch application that opens data sets at regularly scheduled intervals — one using pure JCL, and one using Python with IBM Z Open Automation Utilities (ZOAU).

This repo accompanies the IBM Community blog post:
**"Python and ZOAU: A Modern Approach to z/OS Batch Automation"**

---

## What This Does

The simulated application:
1. Submits a job that opens one or more data sets
2. Holds them open for a configurable interval (simulating active workload)
3. Issues a z/OS Modify command to close the data sets and end the job
4. Moves to the next job in the cycle
5. After all jobs complete, submits a final job that uses a JES SCHEDULE card to wait for the next scheduled cycle

---

## Repository Structure

```
zoau-batch-sim/
├── README.md
├── LICENSE
├── python/
│   └── run_app1.py        # Python + ZOAU orchestration script
└── jcl/
    ├── APP1JOB1.jcl       # Sample single-step data set open job
    ├── APP1JOB2.jcl       # Sample single-step data set open job
    ├── APP1NXT.jcl        # Next-cycle job (uses JES SCHEDULE)
    └── WAITSTOP.jcl       # JCL-only approach: controlling job PROC
```

---

## Prerequisites

### For the Python + ZOAU approach
- z/OS with USS (UNIX System Services) enabled
- Python 3.x available on USS
- [IBM Z Open Automation Utilities (ZOAU)](https://www.ibm.com/docs/en/zoau) installed
- Install the Python bindings:
  ```bash
  pip install zoautil_py
  ```

### For the JCL approach
- z/OS with JES2 or JES3
- Access to a PROCLIB where you can store the `WAITSTOP` and `SUBNEXT` PROCs
- The `OPENDSN` program available in a STEPLIB (see note below)

### The OPENDSN Program
Both approaches reference a program called `OPENDSN` — a user-supplied program that opens data sets, performs I/O, and responds to a z/OS Modify command (`F jobname,CLOSE`) to close them and terminate. This program is not included in this repo. You can substitute your own program that exhibits the same behavior, or adapt the scripts to open data sets using another method.

---

## Setup

1. **Clone or download this repo** to your workstation or directly to a USS directory on z/OS.

2. **Customize the high-level qualifier (HLQ).**
   All references to `HLQ` in the scripts and JCL are placeholders. Replace with your site's appropriate high-level qualifier, for example:
   ```
   HLQ.APPXRUN.JCL  →  USERID.APPXRUN.JCL
   ```

3. **Upload the JCL members** to a partitioned data set (PDS) on z/OS:
   ```
   HLQ.APPXRUN.JCL(APP1JOB1)
   HLQ.APPXRUN.JCL(APP1JOB2)
   HLQ.APPXRUN.JCL(APP1NXT)
   ```

4. **Upload the Python script** to a USS directory, for example:
   ```
   /u/userid/zoau-batch-sim/python/run_app1.py
   ```

---

## Running the Python + ZOAU Version

From USS:
```bash
cd /u/userid/zoau-batch-sim/python
python3 run_app1.py
```

The script will:
- Submit each job in the list sequentially
- Print progress to stdout
- Issue Modify commands via ZOAU's `opercmd` interface
- Submit the next-cycle job when complete

To adjust the interval that data sets are held open, edit the `time_datasets_open` variable in `run_app1.py`:
```python
time_datasets_open = 600   # seconds — change to suit your test interval
```

---

## Running the JCL Version

Submit `APP1JOB1.jcl` to JES. The job will:
- Submit a controlling job via the internal reader that waits and issues the Modify command
- Run the `OPENDSN` program to open the data sets
- Submit the next job in the cycle via the `SUBNEXT` PROC

Ensure the `WAITSTOP` and `SUBNEXT` PROCs are available in your PROCLIB before submitting.

---

## Customization

| Parameter | Location | Description |
|---|---|---|
| `HLQ` | All files | Replace with your high-level qualifier |
| `time_datasets_open` | `run_app1.py` | Seconds to hold data sets open |
| `joblist` | `run_app1.py` | Add or remove jobs in the cycle |
| `TIME=900` | `WAITSTOP.jcl` | JCL equivalent wait interval (seconds) |
| `OPENDSN` | JCL members | Replace with your data set open program |

---

## Further Reading

- [IBM Z Open Automation Utilities documentation](https://www.ibm.com/docs/en/zoau)
- [zoautil_py on PyPI](https://pypi.org/project/zoautil-py/)
- [z/OS JCL Reference](https://www.ibm.com/docs/en/zos/latest?topic=reference-zos-jcl)

---

## License

MIT License — see [LICENSE](LICENSE) for details.
This sample is provided as-is for educational and reference purposes.
