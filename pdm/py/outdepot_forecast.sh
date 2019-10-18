
#!/bin/bash
for i in {1..20}
do
	echo /home/bidata/pdm/py/outdepot_forecast.py $i
	python /home/bidata/pdm/py/outdepot_forecast.py $i
done
