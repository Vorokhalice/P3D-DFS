#!/bin/bash -l

# Configuration of Chapel for distributed experiments on the Luxembourg national
# MeluXina cluster (https://docs.lxp.lu/). Computer nodes are interconnected
# through an InfiniBand (IB) HDR high-speed fabric.

module load GCC/11.3.0
module load CMake/3.23.1-GCCcore-11.3.0
module load OpenMPI/4.1.4-GCC-11.3.0

export CHPL_VERSION=$(cat CHPL_VERSION)
export CHPL_HOME="$PWD/chapel-${CHPL_VERSION}D"

# Download Chapel if not found
if [ ! -d "$CHPL_HOME" ]; then
  wget -c https://github.com/chapel-lang/chapel/releases/download/$CHPL_VERSION/chapel-${CHPL_VERSION}.tar.gz -O - | tar xz
  mv chapel-$CHPL_VERSION $CHPL_HOME
fi

CHPL_BIN_SUBDIR=`"$CHPL_HOME"/util/chplenv/chpl_bin_subdir.py`
export PATH="$PATH":"$CHPL_HOME/bin/$CHPL_BIN_SUBDIR:$CHPL_HOME/util"

export CHPL_HOST_PLATFORM="linux64"
export CHPL_HOST_COMPILER="gnu"
export CHPL_LLVM="none"
export CHPL_RT_NUM_THREADS_PER_LOCALE=$SLURM_CPUS_PER_TASK

export CHPL_COMM='gasnet'
export CHPL_COMM_SUBSTRATE='ibv'
export CHPL_LAUNCHER="gasnetrun_ibv"
export CHPL_TARGET_CPU='native'
# export HFI_NO_CPUAFFINITY="1"

export GASNET_IBV_SPAWNER="mpi"
export GASNET_PHYSMEM_MAX='64 GB'

cd $CHPL_HOME
patch -p1 < ../meluxina_gasnet.patch # see Chapel issue #22800 on Github
make -j $SLURM_CPUS_PER_TASK
cd ../..
