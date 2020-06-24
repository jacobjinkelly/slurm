#!/bin/bash
dir=$(date "+%F-%H-%M-%S")

partition=$1
j_name=$2
file=$3
# args=$4 too hard to specify no args
q=$4

# lam sweeps
# TODO: reg name!
reg=r2
r_lam_file=${reg}_lams.txt

mkdir -p vaughan2/$dir/$j_name
cp $r_lam_file vaughan2/$dir/$j_name  # TODO: check this, and also this is hardcoded!

# fixed grid solver sweeps
reg_type=fin
lam_fro=0.01
lam_kin=0.01
# lam_fro=0.0001 # TODO: for MNIST classification
# lam_kin=0.0001
# lams=(5.754399373371566406e-04 1.000000000000000021e-03 1.737800828749376265e-03 3.019951720402013103e-03)
# lams=(6.309573444801929300e-05)  # TODO: for MNIST classification
# lams=(0)
# lams=(7.585775750291819941e-01)
lams=(3.311311214825907764e-04)  # TODO: for MNIST FFJORD
nums_steps=(8)
reg=r2  # TODO: should be r2 unless you want to reg nothing or not report r2
# for num_steps in ${nums_steps[@]}; do
#     for lam in ${lams[@]}; do
#         # for plotting
#         # eval_dir=vaughan2/2020-05-31-23-59-34/${j_name}_${reg_type}_${lam}_${lam_fro}_${lam_kin}_${num_steps}
#         # ./launch_job.sh $dir $partition ${j_name}_${reg_type}_${lam}_${lam_fro}_${lam_kin}_${num_steps} $file "--reg_type=${reg_type} --reg=${reg} --lam=${lam} --lam_fro=${lam_fro} --lam_kin=${lam_kin} --num_steps=${num_steps} --eval --eval_dir=${eval_dir}" $q
#         # for running
#         ./launch_job.sh $dir $partition ${j_name}_${reg_type}_${lam}_${lam_fro}_${lam_kin}_${num_steps} $file "--reg_type=${reg_type} --reg=${reg} --lam=${lam} --lam_fro=${lam_fro} --lam_kin=${lam_kin} --num_steps=${num_steps}" $q
#     done
# done

# ad-hoc eval of models
#./launch_job.sh $dir $partition ${j_name} $file "--reg_type=our --reg=r2 --lam=0 --lam_fro=0.01 --lam_kin=0.01 --num_steps=2 --eval --eval_dir=vaughan2/2020-05-24-18-40-42/mnist"

# ad-hoc fine-tuning of our models
./launch_job.sh $dir $partition ${j_name} $file "--lr=3e-3 --reg_type=${reg_type} --reg=${reg} --lam=3.311311214825907764e-04 --lam_fro=0.01 --lam_kin=0.01 --num_steps=2 --fine --fine_dir=vaughan2/2020-06-03-21-01-19/mnist_fin_3.311311214825907764e-04_0.01_0.01_8"
# ./launch_job.sh $dir $partition ${j_name} $file "--lr=3e-3 --reg_type=${reg_type} --reg=${reg} --lam=3.311311214825907764e-04 --lam_fro=0.01 --lam_kin=0.01 --num_steps=2 --fine --fine_dir=vaughan2/2020-06-03-21-01-11/mnist_our_3.311311214825907764e-04_0.01_0.01_8"

# ad-hoc fine-tuning of fin models
# ./launch_job.sh $dir $partition ${j_name} $file "--lr=1e-4 --reg_type=our --reg=r2 --lam=3.311311214825907764e-04 --lam_fro=0.01 --lam_kin=0.01 --num_steps=2 --fine --fine_dir=vaughan2/2020-05-29-11-51-31/mnist_fin_3.311311214825907764e-04_0.01_0.01_8"

# train finlay with adaptive
# while IFS= read -r lam
# do
#     ./launch_job.sh $dir $partition ${j_name}_${lam}_${lam} $file "--reg_type=fin --reg=r2 --lam=0 --lam_fro=${lam} --lam_kin=${lam} --num_steps=2"
# done < "fin_lams.txt"

# training sweep
# while IFS= read -r lam
# do
#     ./launch_job.sh $dir $partition ${j_name}_${reg}_${lam} $file "--lam=$lam --reg=$reg" $q
# done < "$r_lam_file"

# plot solver sweep
# TODO: make sure launch_job is correct as well!
# regs=(none)
# dirnames=(2020-05-01-12-02-58)
# regs=(r2 r3 r4 r5)
# dirnames=(2020-05-02-22-08-30 2020-05-01-12-02-58 2020-05-15-23-34-14 2020-05-17-10-34-06)
# solvers=(tanyam)
# for i in "${!regs[@]}"; do
#   reg=${regs[i]}
#   dirname=$(pwd)/${dirnames[i]}
#   for solver in ${solvers[@]}; do
#     # TODO: for "none" reg
#     # lam=0
#     # ./launch_job.sh $dir $partition ${j_name}_${reg}_${lam}_${solver} $file "--lam=$lam --reg=$reg --dirname=$dirname --method=$solver" $q
#     while IFS= read -r lam
#     do
#       ./launch_job.sh $dir $partition ${j_name}_${reg}_${lam}_${solver} $file "--lam=$lam --reg=$reg --dirname=$dirname --method=$solver" $q
#     done < "${reg}_lams.txt"
#   done
# done

# plot reg sweep
# TODO: make sure _lams.txt are correct
# regs=(none)
# dirnames=(2020-05-01-12-02-58)
# # regs=(r2 r3 r4 r5)
# # dirnames=(2020-05-02-22-08-30 2020-05-01-12-02-58 2020-05-15-23-34-14 2020-05-17-10-34-06)
# # regs=(r5)
# # dirnames=(2020-05-18-19-59-49)
# regs_result=(r6)
# for i in "${!regs[@]}"; do
#   reg=${regs[i]}
#   dirname=$(pwd)/${dirnames[i]}
#   for reg_result in ${regs_result[@]}; do
#     lam=0
#     ./launch_job.sh $dir $partition ${j_name}_${reg}_${lam}_${reg_result} $file "--lam=$lam --reg=$reg --dirname=$dirname --reg_result=$reg_result" $q
#     # while IFS= read -r lam
#     # do
#     #   ./launch_job.sh $dir $partition ${j_name}_${reg}_${lam}_${reg_result} $file "--lam=$lam --reg=$reg --dirname=$dirname --reg_result=$reg_result" $q
#     # done < "${reg}_lams.txt"
#   done
# done

# TODO: train vanilla!
# ./launch_job.sh $dir $partition $j_name $file "" $q
