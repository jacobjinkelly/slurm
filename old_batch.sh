#!/bin/bash

partition=$1
j_name=$2
file=$3
# args=$4 too hard to specify no args
q=$4

# job name should include the values being swept over

dir=experiments/$(date "+%F-%H-%M-%S")

# copy script for checking job sweep
cp check.sh $dir
cp param_check.sh $dir

# save git state for reproducibility/debugging
git rev-parse HEAD >${dir}/commit.state
git diff >${dir}/diff.patch

# ./job.sh $dir $partition $j_name $file "" $q

# data_args="--data celeba --celeba_drop_infreq 13 --full_test --img_size 64 --img_sigma .01 --mode sup --model poj --small_mlp --small_mlp_nhidden 128 --n_f 64 --old_multi_gpu"  # DROP MOREE
data_args="--data celeba --celeba_drop_infreq 13 --full_test --img_size 64 --img_sigma .01 --unif_init_b --mode cond --model poj --poj_joint --small_mlp --small_mlp_nhidden 128 --n_f 64 --old_multi_gpu"
# data_args="--data celeba --celeba_drop_infreq 13 --full_test --img_size 64 --img_sigma .01 --unif_init_b --mode cond --model poj --small_mlp --small_mlp_nhidden 128 --n_f 64 --old_multi_gpu"
# data_args="--data celeba --celeba_drop_infreq 13 --full_test --dset_split_type zero_shot --img_size 64 --img_sigma .01 --mode sup --model poj --small_mlp --small_mlp_nhidden 128 --n_f 64 --multi_gpu"
# data_args="--data celeba --celeba_drop_infreq 13 --full_test --dset_split_type zero_shot --img_size 64 --img_sigma .01 --unif_init_b --mode cond --model poj --poj_joint --small_mlp --small_mlp_nhidden 128 --n_f 64 --old_multi_gpu"  # TODO: ZERO SHOT SPLIT OLDD MULTI
# data_args="--data celeba --celeba_drop_infreq 13 --full_test --img_size 64 --img_sigma .01 --mode uncond --model poj --poj_joint --uncond_poj --small_mlp --small_mlp_nhidden 128 --n_f 64"  # uncond

# data_args="--data utzappos --utzappos_drop_infreq 10 --full_test --img_size 64 --img_sigma .01 --mode sup --model poj --small_mlp --small_mlp_nhidden 128 --n_f 64 --old_multi_gpu"
# data_args="--data utzappos --utzappos_drop_infreq 10 --full_test --img_size 64 --img_sigma .01 --mode cond --model poj --small_mlp --small_mlp_nhidden 128 --n_f 64 --old_multi_gpu"
# data_args="--data utzappos --utzappos_drop_infreq 10 --full_test --img_size 64 --img_sigma .01 --mode cond --model poj --poj_joint --small_mlp --small_mlp_nhidden 128 --n_f 64 --old_multi_gpu"

# data_args="--data 8gaussians_hierarch_binarized --unif_init_b --mode cond"
# data_args="--data 8gaussians_hierarch_binarized --unif_init_b --mode cond --model poj --poj_joint"
# data_args="--data 8gaussians_hierarch_binarized --unif_init_b --mode cond --model poj"
# data_args="--data 8gaussians_hierarch_binarized --unif_init_b --mode sup --model poj"
# data_args="--data 8gaussians_hierarch --unif_init_b --mode cond --model poj"
# data_args="--data 8gaussians_hierarch --unif_init_b --mode sup --model poj"
# data_args="--data 8gaussians_hierarch_missing --unif_init_b --mode cond"
# data_args="--data 8gaussians_hierarch_missing --unif_init_b --mode cond --model poj"
# data_args="--data 8gaussians_struct --unif_init_b --mode cond"
# data_args="--data 8gaussians_struct --unif_init_b --mode cond --model poj"
# data_args="--data 8gaussians_struct --unif_init_b --mode sup --model poj"
# data_args="--data 8gaussians_struct_missing --unif_init_b --mode cond --model poj"

# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 10000 --lr 1e-5"  # mwa
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 1000 --lr 2e-4 --beta1 0 --beta2 .9"  # celeba
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 0 --lr 1e-4"  # celeba
# opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 1000 --lr 1e-4"  # celeba # TODO: faster?
# opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 1000 --lr 3e-5"  # celeba # TODO: STABLE??
# opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 10000 --lr 3e-5"  # celeba # TODO: MORE STABLE??
# opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 0 --lr 1e-4"  # celeba # TODO: SUPERVISED
# opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 0 --lr 1e-4"  # utzappos # TODO: supervised, stops early
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 10000 --lr 1e-5"  # utzappos # TODO: stable, but too slow
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 1000 --lr 1e-4"  # utzappos # TODO: faster?

# opt_args="--batch_size 10 --n_iters 1000000 --warmup_itrs 0 --lr 1e-4"  # TODO: SMALLLL for post-hoc
opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 0 --lr 1e-4"                                                                                                                                                                                                                                                             # utzappos # TODO: NO WARMUP

# opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 0 --lr 1e-4 --lr_at 3e-5 --lr_itr_at 23000"  # utzappos # TODO: NO WARMUP
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 0 --lr 1e-4 --lr_at 3e-5 --lr_itr_at 8000"  # utzappos # TODO: NO WARMUP, SCHEDULE
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 0 --lr 1e-4 --lr_at 3e-5 --lr_itr_at 10000"  # utzappos # TODO: NO WARMUP, SCHEDULE
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 0 --lr 1e-4 --beta1 0 --beta2 .9"  # utzappos # TODO: NO WARMUP, GAN params
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 1000 --lr 1e-4 --lr_at 3e-5 --lr_itr_at 15000"  # utzappos # TODO: LR schedule
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 1000 --lr 1e-4 --lr_at 1e-5 --lr_itr_at 15000"  # utzappos # TODO: LR schedule DROP IT MORE
# opt_args="--batch_size 100 --n_iters 25000 --warmup_itrs 1000 --lr 1e-4 --lr_at 1e-5 --lr_itr_at 15000"  # utzappos # TODO: LR schedule DROP IT MORE STOP EARLY TO SAVE SPACE
# opt_args="--batch_size 100 --n_iters 22000 --warmup_itrs 1000 --lr 1e-4 --lr_at 1e-5 --lr_itr_at 15000"  # utzappos # TODO: LR schedule DROP IT MORE STOP EARLY TO SAVE SPACE
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 10000 --lr 1e-4"  # utzappos OLD (but worked?)
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 10000 --lr 1e-5"  # dsprites
# opt_args="--batch_size 64 --n_iters 10000000 --warmup_itrs 10000 --lr 1e-4"  # dsprites
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 10000 --lr .0001 --beta1 0 --beta2 .9"  # mnist
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 0 --lr .0001 --beta1 0 --beta2 .9"  # mnist
# opt_args="--batch_size 100 --n_iters 10000000 --warmup_itrs 0 --lr .0001"  # mnist
# opt_args="--batch_size 1000 --n_iters 10000 --warmup_itrs 0 --lr .0001"  # toy

# opt_args="--batch_size 100 --n_iters 1000000 --warmup_itrs 0 --lr 1e-4 --lr_at 1e-5 --lr_itr_at 15000"  # CELEBA 13% FREQ sigma .001

# loss_args="--p_control 1e-4 --n_control 1e-4"  # mwa
# loss_args="--p_control 1 --n_control 1"  # celeba
# loss_args="--p_control 1 --n_control 1"  # celeba  # TODO: temp
# loss_args="--p_control 0 --n_control 0"  # dsprites
# loss_args="--p_control 1e-4 --n_control 1e-4"  # dsprites PN CONTROL
# loss_args="--p_control 1 --n_control 1"  # mnist
# loss_args=""  # mnist  NO PN CONTROL
# loss_args="--weighted_ce"  # utzappos supervised TODO: weighted CE
# loss_args=""  # toy
loss_args="--truncated_bp --bp 1"                                                                                                                                                                                                                                                                                                   # TODO: TRUNCATED
# loss_args="--truncated_bp --bp 1 --p_control 1 --n_control 1"  # TODO: TRUNCATED PN CONTROL
# loss_args=""  # utzappos
# loss_args="--p_control 1 --n_control 1"  # utzappos  TODO: PN CONTROL

# log_args="--print_every 5000 --plot_every 5000 --ckpt_every 5000 --return_steps 1 --plot_uncond_fresh"  # mwa
# log_args="--print_every 1000 --plot_every 5000 --ckpt_every 1000 --return_steps 1"  # celeba
# log_args="--print_every 1000 --plot_every 5000 --ckpt_every 700 --return_steps 1 --plot_uncond_fresh --save_at 100000"  # celeba, utzappos
# log_args="--print_every 1000 --plot_every 5000 --ckpt_every 500 --return_steps 1 --plot_uncond_fresh"  # celeba, utzappos
# log_args="--print_every 1000 --plot_every 1000 --ckpt_every 200 --return_steps 1 --plot_uncond_fresh --plot_cond_buffer"  # celeba, utzappos TODO: 64 FIL
# log_args="--print_every 1000 --plot_every 1000 --ckpt_every 200 --ckpt_recent_every 1000 --return_steps 1 --plot_uncond_fresh --plot_cond_buffer"  # celeba, utzappos TODO: 64 FIL CHECKPOINT!!!
# log_args="--print_every 10000 --plot_every 10000 --ckpt_every 1000 --ckpt_recent_every 1000 --save_best 10 --save_best_every 10000"  # celeba, utzappos TODO: supervised
# log_args="--print_every 5000 --plot_every 5000 --ckpt_every 5000 --return_steps 1 --plot_uncond_fresh"  # mnist
# log_args="--print_every 1000 --plot_every 1000 --ckpt_every 1000 --return_steps 1"  # mnist (often)
# log_args="--print_every 1000 --plot_every 5000 --ckpt_every 2000 --return_steps 1"  # dsprites (less)
# log_args="--print_every 10000 --plot_every 10000 --ckpt_every 1000 --return_steps 1 --plot_uncond_fresh --plot_temp --plot_ais --plot_when 80000"  # dsprites (less) COND
# log_args="--print_every 10000 --plot_every 10000 --ckpt_every 1000 --return_steps 1 --plot_uncond_fresh --plot_when 100000 --save_at 180000"  # dsprites TODO: fast boi
# log_args="--print_every 1000 --plot_every 1000 --ckpt_every 1000 --return_steps 1"  # dsprites (often)  TODO: switch
# log_args="--print_every 10000 --plot_every 10000 --ckpt_every 5000 --return_steps 1"  # mnist (less)
# log_args="--print_every 10000 --plot_every 10000 --ckpt_every 5000 --return_steps 1 --plot_when 100000 --save_at 110000 --full_test"  # mnist (less) TODO: lesss
# log_args="--print_every 100 --plot_every 100 --ckpt_every 5000 --return_steps 1 --save_at 110000 --full_test"  # mnist TODO DEBUG TEMPPPPPPPPPPPPPPPPPPPPP
# log_args="--print_every 500 --plot_every 500 --ckpt_every 10000 --plot_uncond_fresh --plot_cond_buffer --save_at 9500"  # toy TODO: SAVEE
# log_args="--print_every 500 --plot_every 500 --ckpt_every 10000 --plot_uncond_fresh --plot_cond_buffer --plot_same"  # toy

# TODO: EVAL LOG settings

# log_args="--print_every 1 --plot_every 1 --just_sampling --ckpt_every 100000007 --return_steps 1 --plot_uncond_fresh --plot_cond_buffer --plot_cond_continue_buffer --plot_cond_marginalize --plot_cond_continue_buffer_uncond --eval_filter_to_tst_combos"
# log_args="--print_every 1 --plot_every 1 --just_sampling --ckpt_every 100000007 --return_steps 1 --plot_uncond_fresh --plot_cond_buffer --plot_cond_continue_buffer --plot_cond_marginalize --plot_cond_filter 10"

log_args="--print_every 1 --plot_every 1 --just_sampling --ckpt_every 100000007 --plot_cond_continue_buffer --plot_cond_marginalize --eval_filter_to_tst_combos --eval_cond_acc"                                                                                                                                                    # EVAL COND ACC

# model_args="--ema .99 --sampling pcd --interleave --test_k 200 --gibbs_k_steps 10"  # mwa (interleave)
# model_args="--ema .99 --sampling pcd --test_k 200"  # mwa (uncond)
# model_args="--ema .999 --sampling pcd --test_k 150 --yd_buffer reservoir --transform --transform_every 100000"  # celeba (uncond)
# model_args="--ema .99 --sampling pcd"  # dsprite
# model_args="--ema .99 --sampling pcd --interleave --gibbs_k_steps 1 --test_k 200 --test_gibbs_steps 200 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --test_n_steps 50"  # dsprites (interleave)
# model_args="--ema .99 --sampling pcd --test_k 200 --gibbs_n_steps 1 --test_gibbs_n_steps 1 --test_n_steps 50"  # dsprites TODO NO INT
# model_args="--ema .99 --sampling pcd --mnist_act elu --interleave --gibbs_k_steps 1 --test_k 200 --test_n_steps 200"  # mnist (interleave)
# model_args="--ema .99 --sampling pcd --mnist_act elu"  # mnist
# model_args="--ema .999 --sampling pcd --interleave --gibbs_k_steps 1 --test_k 200 --test_gibbs_steps 200 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --test_n_steps 200 --yd_buffer reservoir"  # toy (interleave)
# model_args="--ema .999 --sampling pcd --test_k 200 --test_n_steps 200 --yd_buffer reservoir --interleave --gibbs_k_steps 1 --test_gibbs_steps 200 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1"  # toy (interleave) TODO: MORE
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data"  # (interleave) TODO: CELEBA RESERVOIR W CLAMPING
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: CELEBA RESERVOIR W CLAMPING AND GRAD NORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1"  # (interleave) TODO: UTZAPPOS RESERVOIR
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data"  # (interleave) TODO: UTZAPPOS RESERVOIR W CLAMPING
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data"  # (interleave) TODO: UTZAPPOS REPLAY W CLAMPING
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: UTZAPPOS REPLAY W CLAMPING CLIP GRAD NORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: UTZAPPOS RESERVOIR W CLAMPING AND GRAD NORM

# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --utzappos_blur_transform --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: UTZAPPOS RESERVOIR W CLAMPING AND GRAD NORM BLURRRRRRRRR TRANSFORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --celeba_all_transform --only_transform_buffer --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: CELEBA NOOOOOO COLOR

# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --only_transform_buffer --transform --transform_every 10000000 --gibbs_k_steps 2 --test_gibbs_steps 50 --test_gibbs_k_steps 2 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: CELEBA RESERVOIR NOO TRANSFORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --only_transform_buffer --transform --gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # POJ model

# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --celeba_no_color_transform --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: CELEBA REPLAY NOO TRANSFORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: UTZAPPOS REPLAY W CLAMPING AND GRAD NORM NOOO TRANSFORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 5 --test_gibbs_steps 20 --test_gibbs_k_steps 5 --test_gibbs_n_steps 1 --clamp_samples --clamp_data"  # (interleave) TODO: UTZAPPOS MULTIPLE STEPS INTERLEAVE CLAMP
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 5 --test_gibbs_steps 20 --test_gibbs_k_steps 5 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: UTZAPPOS MULTIPLE STEPS INTERLEAVE CLAMP CLIP GRAD NORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 10 --test_gibbs_steps 10 --test_gibbs_k_steps 10 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5"  # (interleave) TODO: UTZAPPOS MOREE MULTIPLE STEPS INTERLEAVE CLAMP CLIP GRAD NORM
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 5 --test_gibbs_steps 20 --test_gibbs_k_steps 5 --test_gibbs_n_steps 1"  # (interleave) TODO: UTZAPPOS MULTIPLE STEPS INTERLEAVE
# model_args="--ema .999 --sampling pcd --test_k 200 --test_n_steps 200 --yd_buffer replay --interleave --gibbs_k_steps 1 --test_gibbs_steps 200 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1"  # toy
# model_args="--ema .999 --sampling pcd --test_k 100000 --test_n_steps 100000 --yd_buffer replay --interleave --gibbs_k_steps 1 --test_gibbs_steps 100000 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1"  # toy # TODO: eval
# model_args="--ema .999 --sampling pcd --test_k 200 --test_n_steps 200 --yd_buffer replay --interleave --gibbs_k_steps 1 --test_gibbs_steps 200 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1"  # mnist
# model_args="--ema .999 --sampling pcd --test_k 200 --test_n_steps 200 --interleave --gibbs_k_steps 1 --test_gibbs_steps 200 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1"  # mnist TODO: no buffer
# model_args="--ema 0"  # TODO: UTZAPPOS/CELEBA SUPERVISED
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --transform --transform_every 100 --interleave --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data"  # (interleave) TODO: UTZAPPOS RESERVOIR W CLAMPING EVALLLLLLL

# TODO: RESTARTS MANUAL CONFIG

# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --resume /h/jkelly/zero-shot/restart/2021-05-14-08-40-54/recent_015000.pt"  # CELEBA 13% FREQ sigma .001
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer reservoir --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --resume /h/jkelly/zero-shot/restart/2021-05-13-18-09-54/recent_009000.pt --sgld_steps_itr_at 9000 --k_at 80 --gibbs_steps_at 80"  # CELEBA 10% FREQ sigma .001

# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --only_transform_buffer --transform --transform_every 10000000 --gibbs_k_steps 2 --test_gibbs_steps 50 --test_gibbs_k_steps 2 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --resume experiments/2021-05-24-08-01-12/c_40_1_20_.001_1_0_dis_2_.3/recent_023000.pt"

# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --resume restart/2021-05-15-14-28-43/b_40_1_40_.01_1_0_dis_2_.3/recent_009000.pt"  # CELEBA BLUR AND FLIP
# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --transform --transform_every 10000000 --gibbs_k_steps 1 --test_gibbs_steps 100 --test_gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --resume restart/2021-05-15-14-28-43/b_40_1_40_.01_1_0_dis_2_.3/recent_009000.pt --sgld_steps_itr_at 9000 --k_at 60 --gibbs_steps_at 60"  # CELEBA BLUR AND FLIP

# TODO: EVAL MANUAL CONFIG
# model_args="--ema .999 --sampling pcd --test_k 60 --test_n_steps 60 --yd_buffer reservoir --interleave --transform --utzappos_blur_transform --gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --eval experiments/2021-05-13-08-52-47/z2_40_1_40_.001_1_0_dis_2_.3/recent_014000.pt" # utzappos

# model_args="--ema .999 --sampling pcd --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --only_transform_buffer --transform --gibbs_k_steps 2 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --eval experiments/2021-05-24-08-01-12/c_40_1_20_.001_1_0_dis_2_.3/recent_023000.pt"  # celeba ZERO SHOT

# model_args="--ema .999 --sampling pcd --just_sampling --test_k 100 --test_n_steps 100 --yd_buffer replay --interleave --only_transform_buffer --transform --gibbs_k_steps 2 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --eval experiments/2021-05-24-08-01-12/c_40_1_20_.001_1_0_dis_2_.3/recent_023000.pt"  # celeba TUNE ZERO SHOT

# model_args="--ema .999 --sampling pcd --test_k 120 --test_n_steps 100 --yd_buffer replay --interleave --only_transform_buffer --transform --gibbs_k_steps 2 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --eval experiments/2021-05-19-19-19-32/gp_40_1_20_.001_1_0_dis_2_.3/recent_026000.pt"  # celeba TUNE ALL

model_args="--ema .999 --sampling pcd --test_k 120 --test_n_steps 100 --yd_buffer replay --interleave --only_transform_buffer --transform --gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --eval experiments/2021-05-28-14-56-39/j_40_1_40_.001_1_1_dis_2_.3_600000_120_2/best_028000.pt" # POJ model

# model_args="--ema .999 --sampling pcd --test_k 60 --test_n_steps 60 --yd_buffer reservoir --interleave --utzappos_blur_transform --transform --gibbs_k_steps 1 --test_gibbs_n_steps 1 --clamp_samples --clamp_data --clip_grad_norm .5 --eval experiments/2021-05-30-11-31-16/z_40_1_40_.001_1_1_dis_2_.3_600000_120_2/recent_021000.pt"  # POJ UTZAPPOS MODEL

# model_args="--ema 0 --eval experiments/2021-05-25-15-45-26/zw_40_1_20_.001_1_1_dis_2_0/best_690000.pt"  # celeba zero shot
# model_args="--ema 0 --eval experiments/2021-05-26-08-27-15/cu_40_1_20_.001_1_1_dis_2_0/best_520000.pt"  # celeba
# model_args="--ema 0 --eval experiments/2021-05-25-16-03-07/su_40_1_20_.001_1_1_dis_2_0/best_230000.pt"  # utzappos

fixed_args="${data_args} ${log_args} ${opt_args} ${loss_args} ${model_args}"

# for k in 20  # toy
# for k in 40  # toy  TODO more
# for k in 40  # mnist
# for k in 40  # dsprites
# for k in 40  # celeba
# for k in 60  # celeba  TODO: MOREE
for k in 40; do # utzappos
  # for k in 40  # mwa
  for n_steps in 1; do # normal
    # for n_steps in 1 2 4  # sweep
    # for gibbs_steps in 1
    # for gibbs_steps in 4  # interleave (toy)
    for gibbs_steps in 20; do # interleave (toy)  # TODO: MOREEE
      # for gibbs_steps in 4  # MORE GIBBS interleave (dsprites) INTERLEAVE
      # for gibbs_steps in 40  # interleave (dsprites) INTERLEAVE
      # for gibbs_steps in 1  # (dsprites) NOOOO INTERLEAVE
      # for gibbs_steps in 40  # interleave (mnist)
      # for gibbs_steps in 40  # interleave (celeba)
      # for gibbs_steps in 10  # interleave (celeba) TODO: MOREE
      # for gibbs_steps in 40  # interleave (utzappos)
      # for gibbs_steps in 8  # TODO: SET THIS IF LESS INTERLEAVE (utzappos)
      # for gibbs_steps in 5  # TODO: SET THIS IF LESS INTERLEAVE (utzappos)
      # for gibbs_steps in 4  # interleave (mwa)
      # for sigma in .1  # for circles
      # for sigma in .03  # for rings
      # for sigma in .1 .03 .01 .003 .001 .0003 .0001  # for rings (sweep w/ new hyperparams)
      # for sigma in .1  # 8gaussians
      # for sigma in .01 .003  # for mnist (final)
      # for sigma in .03 .01 .003 .001  # dsprites (sweep)
      # for sigma in .03 .01 .003 .001  # celeba (sweep)
      # for sigma in .01 .001  # celeba/utzappos (sweep)
      # for sigma in .01  # celeba/utzappos (sweep)  # TODO: TTEMP
      for sigma in .001; do # celeba/utzappos (sweep)  # TODO: CLASSIFICATION BOI
        # for sigma in .01 .003 .001  # mnist (sweep)
        # for sigma in .001  # celeba (yilundu)
        # for step_size in -1  # for circles
        # for step_size in .03 # for circles (tempered)
        # for step_size in .01  # for rings
        # for step_size in .1 .03 .01 .003 .001  # for rings (sweep w/ new hyperparams)
        # for step_size in .01  # 8gaussians
        # for step_size in 10 3 1  # for mnist (final)
        # for step_size in 100 30 10 3 1 .3 # dsprites (sweep)
        # for step_size in 10 3 1 # celeba/utzappos (reduced sweep)
        # for step_size in 3 1 # celeba/utzappos (reduced sweep)  # TODO: SMALL
        for step_size in 1; do # celeba/utzappos (reduced sweep)  # TODO: SINGLE
          # for step_size in 3 # TODO: ad hoc
          # for step_size in 300 100 30  # big boi steps
          # for step_size in -1  # TODO: CLASSIFICATION BOI
          # for step_size in 10 3 1  # mnist (new sweep boi)
          # for p_y_x in .1 .3 1  # TODO: for POJ BUDDY
          for p_y_x in 0; do # for p_y_x in 1  # TODO: for classification BOIIIII (OR POJ W NO JOINT)
            # cts can give good acc but unstable
            for first_gibbs in dis; do
              for temp in 2; do
                # for kl in .0001 .0003 .001 .003 .01 .03 .1 .3 1 3 10
                # for kl in 0 .3 1 3 10 30
                # for kl in 0 .3  # TODO: POJ and EBM BUD
                for kl in .3; do # for kl in 0  # TODO: for classification BOIII
                  # for test_gibbs_steps in 120 240 360
                  for test_gibbs_steps in 120; do # for test_gibbs_steps in 60
                    for transform_every in 60; do # for transform_every in 600000
                      # for test_gibbs_k_steps in 1 2 4 8
                      for test_gibbs_k_steps in 2; do # for test_gibbs_k_steps in 1
                        sgld_args="--k ${k} --n_steps ${n_steps} --sigma ${sigma} --step_size ${step_size}"
                        steps_args="--test_gibbs_steps ${test_gibbs_steps} --test_gibbs_k_steps ${test_gibbs_k_steps}"
                        steps_jname=${transform_every}_${test_gibbs_steps}_${test_gibbs_k_steps}
                        sweep_args="--gibbs_steps ${gibbs_steps} --p_y_x ${p_y_x} --first_gibbs ${first_gibbs} --temp ${temp} --kl ${kl} --transform_every ${transform_every}"
                        full_jname=${j_name}_${k}_${n_steps}_${gibbs_steps}_${sigma}_${step_size}_${p_y_x}_${first_gibbs}_${temp}_${kl}_${steps_jname}
                        ./job.sh $dir $partition ${full_jname} $file "${fixed_args} ${sgld_args} ${sweep_args} ${steps_args}" $q
                      done
                    done
                  done
                done
              done
            done
          done
        done
      done
    done
  done
done
