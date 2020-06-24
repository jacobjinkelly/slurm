#!/bin/bash
dir=$(date "+%F-%H-%M-%S")

partition=$1
j_name=$2
file=$3
# args=$4 too hard to specify no args
q=$4

# does a sweep over each line of ${r_lam_file}
# job name should include the values being swept over

# lam sweeps
reg=r2
r_lam_file=${reg}_lams.txt

mkdir -p vaughan2/$dir/$j_name
cp $r_lam_file vaughan2/$dir/$j_name  # TODO: check this, and also this is hardcoded!

# training sweep
while IFS= read -r lam
do
    ./launch_job.sh $dir $partition ${j_name}_${reg}_${lam} $file "--lam=$lam --reg=$reg" $q
done < "$r_lam_file"

# TODO: train vanilla!
./launch_job.sh $dir $partition $j_name $file "" $q
