# devops-sandbox
What is a CronJob in Kubernetes?
A CronJob creates Jobs on a repeating schedule.

When creating the manifest for a CronJob resource, make sure the name you provide is a valid DNS subdomain name. The name must be no longer than 52 characters. This is because the CronJob controller will automatically append 11 characters to the job name provided and there is a constraint that the maximum length of a Job name is no more than 63 characters.

Cron schedule syntax


  # ┌───────────── minute (0 - 59)
  # │ ┌───────────── hour (0 - 23)
  # │ │ ┌───────────── day of the month (1 - 31)
  # │ │ │ ┌───────────── month (1 - 12)
  # │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
  # │ │ │ │ │                                   7 is also Sunday on some systems)
  # │ │ │ │ │                                   OR sun, mon, tue, wed, thu, fri, sat
  # │ │ │ │ │
  # * * * * *

  
Entry	Description	Equivalent to
@yearly (or @annually)	Run once a year at midnight of 1 January	0 0 1 1 *
@monthly	Run once a month at midnight of the first day of the month	0 0 1 * *
@weekly	Run once a week at midnight on Sunday morning	0 0 * * 0
@daily (or @midnight)	Run once a day at midnight	0 0 * * *
@hourly	Run once an hour at the beginning of the hour	0 * * * *
For example, the line below states that the task must be started every Friday at midnight, as well as on the 13th of each month at midnight:

0 0 13 * 5
----

job:
Ejecutar el Job:
kubectl apply -f job.yaml



Ver el resultado:
kubectl get jobs
kubectl logs <pod-name>

cronjob:
Tip rápido para validar
Cuando lo apliques:
Shell:
kubectl apply -f cronjob.yamlkubectl get cronjobkubectl get jobs --watch
Y para ver el log del Pod creado por el Job:
Shellkubectl get podskubectl logs <nombre-del-pod>