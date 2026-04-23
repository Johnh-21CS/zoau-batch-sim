"""
run_app1.py - Simulate a z/OS batch application using Python and ZOAU

This script orchestrates a series of z/OS jobs that open data sets,
hold them open for a configurable interval to simulate active application
use, then closes them and moves to the next job in the cycle.

Prerequisites:
  - z/OS USS with Python 3.x
  - IBM Z Open Automation Utilities (ZOAU) installed
  - zoautil_py Python package: pip install zoautil_py
  - JCL members uploaded to HLQ.APPXRUN.JCL

Usage:
  python3 run_app1.py

Customization:
  - Replace HLQ with your site high-level qualifier
  - Adjust time_datasets_open to set the hold interval in seconds
  - Add or remove entries in joblist to match your application cycle
"""

from zoautil_py import jobs, opercmd
import time


def run_app1():
    # ---------------------------------------------------------------
    # Job list — each entry is a JCL member name in HLQ.APPXRUN.JCL
    # representing one step in the simulated application cycle.
    # Each member is a simple single-step job whose only responsibility
    # is to open the data sets and wait for a Modify command to close them.
    # ---------------------------------------------------------------
    joblist = ["APP1JOB1", "APP1JOB2", "APP1JOB3", "APP1JOB4", "APP1JOB5"]

    for job_x in joblist:
        job_to_run = f"HLQ.APPXRUN.JCL({job_x})"

        # Seconds to hold data sets open — adjust to match your test interval
        time_datasets_open = 600

        print(f"--- Starting {job_x} ---")
        print(f"Submitting: {job_to_run}")

        # ------------------------------------------------------------------
        # Step 1: Submit the job that opens the data sets.
        #
        # jobs.submit() submits a JCL member by data set name and returns
        # a job object (similar to a process handle) that you can use to
        # track status, wait for completion, and inspect the return code.
        # ------------------------------------------------------------------
        job_running = jobs.submit(job_to_run)
        print(f"Submitted {job_x} — waiting {time_datasets_open} seconds")

        # ------------------------------------------------------------------
        # Step 2: Sleep to simulate the application actively using the data sets.
        #
        # time.sleep() can be replaced with any wait logic that suits your
        # use case — polling an event, reading from a queue, waiting on an
        # external trigger, etc.
        # ------------------------------------------------------------------
        time.sleep(time_datasets_open)

        # ------------------------------------------------------------------
        # Step 3: Issue a z/OS Modify command to signal the job to
        # close its data sets and terminate.
        #
        # opercmd.execute() routes the command through the z/OS operator
        # command interface — equivalent to typing "F jobname,CLOSE" at
        # an operator console or in SDSF.
        # ------------------------------------------------------------------
        command_to_run = f"F {job_x},CLOSE"
        print(f"Issuing: {command_to_run}")
        response = opercmd.execute(command_to_run)

        # ------------------------------------------------------------------
        # Step 4: Wait for end-of-job before moving to the next iteration.
        #
        # job_running.wait() blocks until the job reaches end-of-job status.
        # job_running.refresh() updates the job object with final status/RC.
        # ------------------------------------------------------------------
        job_running.wait()
        job_running.refresh()
        print(f"{job_x} ended — RC: {job_running.rc}")

    # -----------------------------------------------------------------------
    # After all jobs in the cycle complete, submit the next-cycle job.
    #
    # APP1NXT uses a JES SCHEDULE card to defer execution until the next
    # scheduled interval (e.g., the following day), simulating the wait
    # between application invocation cycles.
    # -----------------------------------------------------------------------
    print("--- All jobs complete. Submitting next-cycle job ---")
    job_to_run = f"HLQ.APPXRUN.JCL(APP1NXT)"
    job_next = jobs.submit(job_to_run)
    print(f"Submitted next-cycle job: {job_to_run}")


if __name__ == "__main__":
    run_app1()
