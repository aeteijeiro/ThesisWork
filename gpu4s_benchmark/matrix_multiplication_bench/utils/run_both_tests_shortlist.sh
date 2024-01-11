#!/bin/bash

CWD=`pwd`
#without injections
cd ..
make clean_runs
make golden DATATYPE=INT BLOCKSIZE=16 &&
cd $CWD
#echo "NUM_EVENTS: $1"
rm cuda_events/*
python3 extract_shortlist_events.py $1 $2 $4 $5
for i in $(seq 1 $3)
do
	for eventsfile in cuda_events/*
	do
		events_in_file=`wc -w $eventsfile | awk '{print $1}'`
		sudo ./benchmark_command.sh golden_runs/profiler/golden_run$i.out $events_in_file $eventsfile golden_runs/benchmark/golden_run$i.out
	done
done
cd ..

#with injections
make injected_errors DATATYPE=INT BLOCKSIZE=16
cd $CWD
for i in $(seq 1 $3)
do
	for eventsfile in cuda_events/*
	do
		events_in_file=`wc -w $eventsfile | awk '{print $1}'`
		sudo ./benchmark_command.sh injector_runs/profiler/injector_run$i.out $events_in_file $eventsfile injector_runs/benchmark/injector_run$i.out
	done
done
