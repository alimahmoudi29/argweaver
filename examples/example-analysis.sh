#!/usr/bin/bash
#
# This file demonstrates an example analysis using ARGweaver and its various
# utilities to infer ancestral recombination graphs.
#
# Don't execute this script all at once.  Instead try copying and pasting
# each command to the command line one at a time in order to learn how the
# commands work.
#
# For documentation on all of ARGweaver's file formats, see
# doc/dlcoal_manual.html
#

#=============================================================================
# Setup/install

# Make sure tools are compiled and installed before running the commands in
# this tutorial.  This can be done with this command:
cd ..
make install
cd examples

# or you can install ARGweaver into the prefix of your choice
cd ..
make install prefix=YOUR_INSTALL_PREFIX
cd examples

# or you can run from the source directory by just compiling the code with
cd ..
make
cd examples


#=============================================================================
# Make simulation data

# To generate simulated data containing a set of DNA sequences and an
# ARG describing their ancestry, the following command can be used:

../bin/arg-sim \
    -k 8 -L 100000 \
    -N 10000 -r 1.6e-8 -m 1.8e-8 \
    -o test1/test1

# This will create an ARG with 8 sequences each 100kb in length
# evolving in a population of effective size 10,000 (diploid), with
# recombination rate 1.6e-8 recombinations/site/generation and
# mutation rate 1.8e-8 mutations/generation/site. The output will be
# stored in the following files:

# test1/test1.arg   -- an ARG stored in *.arg format
# test1/test1.sites -- sequences stored in *.sites format

# To infer an ARG from the simulated sequences, the following command
# can be used:

../bin/arg-sample \
    -s test1/test1.sites \
    -N 10000 -r 1.6e-8 -m 1.8e-8 \
    --ntimes 20 --maxtime 200e3 -c 20 -n 100 \
    -o test1/test1.sample/out

# This will use the sequences in `example/example.sites`, assume the
# same population parameters as the simulation (i.e. `-N 10000 -r
# 1.6e-8 -m 1.8e-8`), and several sampling specific options (i.e. 20
# discretized time steps, a maximum time of 200,000 generations, a
# compression of 10bp for the sequences, and 100 sampling
# iterations. After sampling the following files will be generated:

# test1/test1.sample/out.log
# test1/test1.sample/out.stats
# test1/test1.sample/out.0.smc.gz
# test1/test1.sample/out.10.smc.gz
# test1/test1.sample/out.20.smc.gz
# ...
# test1/test1.sample/out.100.smc.gz

# `out.log` contains a log of the sampling procedure, `out.stats`
# contains various ARG statistics (e.g. number of recombinations, ARG
# posterior probability, etc), and `out.0.smc.gz` through
# `out.100.smc.gz` contain 11 samples of an ARG in *.smc file format.

# To estimate the time to most recent common ancestor (TMRCA) across
# these samples, the following command can be used:

../bin/arg-extract-tmrca test1/test1.sample/out.%d.smc.gz \
    > test1/test1.tmrca.txt

# This will create a tab-delimited text file containing six columns:
# chromosome, start, end, posterior mean TMRCA (generations),
# lower 2.5 percentile TMRCA, and upper 97.5 percentile TMRCA. The first
# four columns define a track of TMRCA across the genomic region in
# BED file format.

# To resume a previous sampling, you can use the --resume option to add
# additional sample or change options mid-sampling.

../bin/arg-sample \
    -s test1/test1.sites \
    -N 10000 -r 1.6e-8 -m 1.8e-8 \
    --ntimes 20 --maxtime 200e3 -c 20 -n 200 --resume \
    -o test1/test1.sample/out