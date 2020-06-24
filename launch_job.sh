#!/bin/bash

d=$1
partition=$2
j_name=$3
file=$4
args=$5 # specify params for sweep
q=$6  # high, deadline (need account), normal
resource=1
ssd=$(pwd)  # directory where jobs will be stored
j_dir=$ssd/$d/$j_name

mkdir -p $j_dir/scripts

# build slurm script
# CPU num and GPU mem can probably be lowered
mkdir -p $j_dir/log
echo "#!/bin/bash
#SBATCH --job-name=${j_name}
#SBATCH --output=${j_dir}/log/%j.out
#SBATCH --error=${j_dir}/log/%j.err
#SBATCH --partition=${partition}
#SBATCH --cpus-per-task=$[4 * $resource] 
#SBATCH --ntasks-per-node=1
#SBATCH --mem=$[32*$resource]G
#SBATCH --gres=gpu:${resource}
#SBATCH --nodes=1

bash ${j_dir}/scripts/${j_name}.sh
" > $j_dir/scripts/${j_name}.slrm

# build bash script

echo -n "#!/bin/bash
. /h/jkelly/new_jet_nodes.env
touch /checkpoint/$USER/\$SLURM_JOB_ID/DELAYPURGE
python $file $args --seed=0 --dirname=${j_dir} --ckpt_path=/checkpoint/$USER/\$SLURM_JOB_ID/ck.pt

" > $j_dir/scripts/${j_name}.sh

cp $file $j_dir/scripts/

# TODO: fix this to automatically add the deadline account when needed
# sbatch $j_dir/scripts/${j_name}.slrm --qos $q --account deadline
sbatch $j_dir/scripts/${j_name}.slrm --qos $q
