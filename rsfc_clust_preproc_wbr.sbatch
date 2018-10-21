#!/bin/bash -l 
#
#SBATCH --job-name=halle_preproc_8_11_18
#SBATCH --output=/home/wbreilly/parallel_sms_scan_batch_preproc/logs/halle_preproc_8_11_18.%j.%N.out
#SBATCH --error=/home/wbreilly/parallel_sms_scan_batch_preproc/logs/halle_preproc_8_11_18.%j.%N.err
#SBATCH --nodes=1
#SBATCH -c 47
#SBATCH -p bigmemm
#SBATCH --time=5-00:00:00
#SBATCH --mem-per-cpu=2500 # 3gb % spm max mem set at 2.1gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wbreilly@ucdavis.edu

date 
hostname
module load matlab/R2016a # load matlab module 

matlab -nodisplay < rsfc_cluster_parallel_preproc_wbr.m # run matlab script 
