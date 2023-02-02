'''Generic script to walk through a directory and create BalsamJobs for each
folder containing an input file.
The essential application parameters are given as module-level constants
(all-caps) below.
The script is called with a --top-dir argument, which causes it to recursively
visit each subfolder of top-dir and search for a file matching INPUTNAME.  If
this file exists, a BalsamJob is created for the subfolder.
'''
import argparse
import os
from glob import glob
from balsam.core.models import BalsamJob, ApplicationDefinition
from django.core.exceptions import ObjectDoesNotExist

EXE_PATH="/soft/gaussian/16-a.03/AVX2/g16/g16"
APPNAME="gaussian/16-a.03" # Any alias you want
NNODES = 1 # Number of nodes to run on
#RPN = 64 # Number of MPI ranks per node
#TPR = 1 # Number of OpenMP threads per MPI rank

def new_job(name, workdir, workflow_tag):
    '''Create a new BalsamJob object *without* saving it to DB'''
    return BalsamJob(
        name=name,
        user_workdir=workdir, # the job will run inside this directory
        workflow = workflow_tag,
        application = APPNAME,
        num_nodes=NNODES,
#        ranks_per_node=RPN,
	args=' <'+name+'.com >'+name+'.log',
#        threads_per_rank=TPR,
        cpu_affinity='depth',
    )

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--top-dir',
        help="This folder and its subfolders will be searched for input files, and a new job \
        will be created for each one", required=True
    )
    parser.add_argument('--wf-tag',
        help='A unique tag to categorize this batch \
        of jobs (for instance, "prod-batch_32")', required=True
    )
    return parser.parse_args()

def bootstrap_app():
    '''Ensure App is already in the DB'''
    try:
        app = ApplicationDefinition.objects.get(name=APPNAME)
        assert os.path.isfile(app.executable)
    except ObjectDoesNotExist:
        assert os.path.isfile(EXE_PATH)
        app = ApplicationDefinition(
            name=APPNAME,
            executable=EXE_PATH
        )
        app.save()

def main():
    args = get_args()
    wf_tag = args.wf_tag
    top_dir = os.path.abspath(os.path.expanduser(args.top_dir))
    assert os.path.isdir(top_dir)
    bootstrap_app()

    # Get a list of all user_workdirs *already* registered in the DB
    # This way, we will never double-create a BalsamJob for the same directory
    existing_job_paths = list(BalsamJob.objects.values_list('user_workdir', flat=True))

    # Recursively walk through all subdirectories of top_dir
    # Create a job for each .com file 
    pwd=os.getcwd()
    os.chdir(top_dir)
    comFiles = glob('*.com')
    os.chdir(pwd)
    for comFile in comFiles:
        comName = comFile.split('.')[0]
        workdir = top_dir
        job = new_job(
	      name=comName,
	      workdir=workdir,
	      workflow_tag=wf_tag
        )
        job.save()
        print('new job', job.cute_id, 'will run in:', workdir)

if __name__ == "__main__": main()
