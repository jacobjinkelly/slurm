#!/bin/bash

d=$1
partition=$2
j_name=$3
file=$4
args=$5 # specify params for sweep
q=$6    # high, deadline (need account), normal, nopreemption (for cpu)
resource=2
ssd=$(pwd) # directory where jobs will be stored
j_dir=$ssd/$d/$j_name

mkdir -p $j_dir/scripts

# build slurm script
# CPU num and GPU mem need to be adjusted
mkdir -p $j_dir/log
echo "#!/bin/bash
#SBATCH --job-name=${j_name}
#SBATCH --output=${j_dir}/log/%j.out
#SBATCH --error=${j_dir}/log/%j.err
#SBATCH --partition=${partition}
#SBATCH --cpus-per-task=$((4)) 
#SBATCH --ntasks-per-node=1
#SBATCH --mem=$((64))G
#SBATCH --nodes=1
#SBATCH --exclude=gpu089
#SBATCH --qos=${q}" >$j_dir/scripts/${j_name}.slrm

if [[ ${partition} != "cpu" ]]; then
  echo "#SBATCH --gres=gpu:${resource}" >>$j_dir/scripts/${j_name}.slrm
fi

if [[ ${q} == "deadline" ]]; then
  echo "#SBATCH --account=deadline" >>$j_dir/scripts/${j_name}.slrm
fi

echo "
bash ${j_dir}/scripts/${j_name}.sh
" >>$j_dir/scripts/${j_name}.slrm

# build bash script

echo -n "#!/bin/bash
. /h/jkelly/envs/torch.env
touch /checkpoint/$USER/\$SLURM_JOB_ID/DELAYPURGE
python $file $args --save_dir ${j_dir} --ckpt_path=/checkpoint/$USER/\$SLURM_JOB_ID/ck.pt

" >$j_dir/scripts/${j_name}.sh

cp $file $j_dir/scripts/

sbatch $j_dir/scripts/${j_name}.slrm
