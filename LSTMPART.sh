#!/usr/bin/env bash
DIR=$1
EXNAME=$2

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

EXT="csv"
array=()
lengths=()
x=0
kfolds=$3

if [ $# != 3 ]; then
	echo "***ERROR*** Use: $0 <directory> <execution_name> <K_folds>"
	exit -1
fi

# Create folders
mkdir $EXNAME
mkdir $EXNAME/filtered

# Copy all once since we will be removing
cp $DIR/* $EXNAME
rm $EXNAME/*.raw.csv

# Get names
for elem in $(ls -d $EXNAME/*.$EXT | awk -F "/" '{print $NF}' | awk -F ".$EXT" '{print $1}')
do
	array[$x]=$elem
	x=`expr $x + 1`
	#echo "$elem"
done

# Get lengths
x=0
for elem in $(ls -d $DIR/*.$EXT)
do
	lengths[$x]=$(wc -l $elem | awk '{print $1}')
	#echo "${lengths[$x]}"
	x=`expr $x + 1`
done

# Find minimum
min=${lengths[0]} 

for i in ${lengths[@]}; do
    (( $i < min )) && min=$i
done
echo "min=$min"

# Cut length to minimum
for ((i=0 ; i < ${#array[@]} ; i++))
do
	head -$min $DIR/${array[$i]}.csv > $EXNAME/filtered/${array[$i]}_f.csv
done

# Create folders for k-fold

rate=$(( $min / ${kfolds} ))

for ((i=0 ; i < ${kfolds} ; i++))
do
	CURRENT=$EXNAME/kfold_${i}
	mkdir $CURRENT
	
	# Get ranges for k-fold building
	from=$(($i * $rate + 1))
	x=`expr $i + 1`
	to=$(($x * $rate + 1))
	
	#echo "$from - $to"
	
	# For each name in the array names
	for j in ${array[@]}; do
	    
	    	# Create folders with the names that do not have "_"
		if echo "$j" | grep -v "_"; then
			#echo "no match at $j";
			mkdir $CURRENT/$j
			mkdir $CURRENT/$j/cojo
			mkdir $CURRENT/$j/cojo/train
			mkdir $CURRENT/$j/cojo/test			
			mkdir $CURRENT/$j/no_cojo
			mkdir $CURRENT/$j/no_cojo/test
			mkdir $CURRENT/$j/no_cojo/train
		fi	    
	    
	done 	
	
	# For each name, take the corresponding shuffled percentage and put into correct folder

	for j in ${array[@]}; do
	
		if echo "$j" | grep -v "_"; then
		
			# Check 
			if (( $from > 1 )); then
				head -1 ${EXNAME}/filtered/${j}_f.csv > $CURRENT/$j/no_cojo/test/test.csv	
			else
				head -1 ${EXNAME}/filtered/${j}_f.csv > $CURRENT/$j/no_cojo/train/train.csv				
			fi
			head -$to ${EXNAME}/filtered/${j}_f.csv | tail -n +$from >> $CURRENT/$j/no_cojo/test/test.csv
			

			sed -e "${from},${to}d" $EXNAME/filtered/${j}_f.csv >> $CURRENT/$j/no_cojo/train/train.csv
		else
			aux=$(echo "$j" | cut -d '_' -f 1)

			if (( $from > 1 )); then
				head -1 ${EXNAME}/filtered/${j}_f.csv > $CURRENT/$aux/cojo/test/test.csv
			else
				head -1 ${EXNAME}/filtered/${j}_f.csv > $CURRENT/$aux/cojo/train/train.csv				
			fi
			

			head -$to ${EXNAME}/filtered/${j}_f.csv | tail -n +$from >> $CURRENT/$aux/cojo/test/test.csv

			sed -e "${from},${to}d" $EXNAME/filtered/${j}_f.csv >> $CURRENT/$aux/cojo/train/train.csv

		fi	    		
		
	done

	
done
