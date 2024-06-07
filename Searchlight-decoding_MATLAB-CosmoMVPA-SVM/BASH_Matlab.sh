#!/bin/bash
#PBS -N MATLAB-BetCat_5waydecoding_perm_AI
#PBS -l nodes=4:ppn=16
#PBS -l mem=25gb
#PBS -l walltime=25:00:00
#PBS -m abe
#
# Example (single-core) MATLAB job script
# see http://hpcugent.github.io/vsc_user_docs/
#

# make sure the MATLAB version matches with the one used to compile the MATLAB program!
module load MATLAB/2022b

# use temporary directory (not $HOME) for (mostly useless) MATLAB log files
# subdir in $TMPDIR (if defined, or /tmp otherwise)
export MATLAB_LOG_DIR=/scratch/gent/473/vsc47358/CombiEmo_script/temporary_dir

# configure MATLAB Compiler Runtime cache location & size (1GB)
# use a temporary directory in /dev/shm (i.e. in memory) for performance reasons
export MCR_CACHE_ROOT=/scratch/gent/473/vsc47358/CombiEmo_script/temporary_dir
export MCR_CACHE_SIZE=1024MB
# change to directory where job script was submitted from
cd /scratch/gent/473/vsc47358/CombiEmo_script

# run compiled example MATLAB program 'example', provide '5' as input argument to the program
# $EBROOTMATLAB points to MATLAB installation directory

#./run_setup_libsvm.sh $EBROOTMATLAB 
./run_Decoding_WithinModality_CombiEmo.sh $EBROOTMATLAB 
