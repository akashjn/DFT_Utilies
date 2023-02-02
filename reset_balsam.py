from balsam.launcher.dag import BalsamJob
run_timeout = BalsamJob.objects.filter(state='RUN_TIMEOUT')
run_failed = BalsamJob.objects.filter(state='FAILED')
#run_running = BalsamJob.objects.filter(state='RUNNING')
run_error = BalsamJob.objects.filter(state='RUN_ERROR')
#run_opt = run_timeout.filter(name__icontains='iterm') # optional; additional filters
BalsamJob.batch_update_state(run_failed, 'RESTART_READY')
#BalsamJob.batch_update_state(run_running, 'RESTART_READY')
BalsamJob.batch_update_state(run_timeout, 'RESTART_READY')
BalsamJob.batch_update_state(run_error, 'RESTART_READY')

##run_RESTART_READY = BalsamJob.objects.filter(state='RESTART_READY')
##BalsamJob.batch_update_state(run_RESTART_READY, 'RUNNING')
