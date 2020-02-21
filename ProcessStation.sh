## !/bin/bash

## Mingda Lu

## 3-part script for processing the data given in ./StationData


## PART 1

HE=HigherElevation
OD=StationData  # Original data is stored in the folder, namely, StationData

# check if HigherElevation folder exists

if [ -d ./$HE ]
then
	echo HigherElevation Exist
else
	mkdir $HE
	echo $HE added to current directory

fi

# check if any file have elev. >= 200ft

for file in $OD/*
do
	filename=`basename "$file"`
	if
	grep 'Altitude: [>=200]' $file
	then cp $OD/$filename $HE/$filename
	fi
done

echo files copied and pasted to HigherElevation

## PART 2

echo loading GMT...
module load gmt

echo GMT loaded

# lat&long data processing

awk '/Longitude/ {print -1*$NF}' $OD/Station_*.txt > Long.list
awk '/Latitude/ {print $NF}' $OD/Station_*.txt > Lat.list
paste Long.list Lat.list > AllStation.xy

awk '/Longitude/ {print -1*$NF}' $HE/Station_*.txt > Long1.list
awk '/Latitude/ {print $NF}' $HE/Station_*.txt > Lat1.list
paste Long1.list Lat1.list > HEStation.xy

echo 'lat&long data processing completed'

# add block provided

gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Ia/blue -Cl/blue -Dh[+] -Na/orange -P -K -V > SoilMoistureStations.ps
gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
gmt psxy HEStation.xy -J -R -Sc0.05 -Gred -O -V >> SoilMoistureStations.ps

gv SoilMoistureStations.ps & # show plot

## PART 3

# convert .ps to .epsi

ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi

gv SoilMoistureStations.epsi & # show epsi image

# convert .epsi to .tif with density 150

convert SoilMoistureStations.epsi -density 150 SoilMoistureStations.tif

echo DONE
