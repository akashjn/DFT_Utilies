from balsam.core.models import ApplicationDefinition as App
gaussian = App(
name="gaussian/16-a.03", # change applicaiton name 
executable="<path>/g16", # change path to the executable 
envscript="<path>/gaussian-envscript.sh" # change path
)
gaussian.save()
