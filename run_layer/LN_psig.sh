#!/bin/bash

echo "1 data, 2 mask"
#get mean value
3dROIstats -mask $2 -1DRformat -quiet -nzmean $1 > layer_t.dat
#get standard deviation
#3dROIstats -mask $2 -1DRformat -quiet -sigma $1 >> layer_t.dat
#get number of voxels in each layer
#3dROIstats -mask $2 -1DRformat -quiet -nzvoxels $1 >> layer_t.dat
#format file to be in columns, so gnuplot can read it.
WRD=$(head -n 1 layer_t.dat|wc -w); for((i=2;i<=$WRD;i=i+2)); do awk '{print $'$i'}' layer_t.dat| tr '\n' ' ';echo; done > temp.txt


tr '\n' ',' <temp.txt  > temptemp.txt
cat temptemp.txt | sed 's/\(.*\),/\1 /' > psig.txt
#{ echo -e "layer1,layer2,layer3,layer4,layer5,layer6,layer7,layer8,layer9"; cat temp_psig.txt; } > psig.txt

rm layer_t.dat
rm temp*.txt