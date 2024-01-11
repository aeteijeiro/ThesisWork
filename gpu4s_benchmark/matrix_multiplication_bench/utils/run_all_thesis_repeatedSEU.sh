#!/bin/bash

rm results/*7.txt results/*7_1000.parquet 
CWD=$(pwd)
cd ..
#L0 tests
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=lts__t_requests_aperture_device_evict_normal_lookup_miss INJECTION_TARGET=L0 STARTING_POINT=1 SM_COUNT=7
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=l1tex__t_bytes_pipe_lsu_lookup_miss INJECTION_TARGET=L0 STARTING_POINT=1 SM_COUNT=7
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=fbpa__dram_write_bytes INJECTION_TARGET=L0 STARTING_POINT=1 SM_COUNT=7


#LSU tests
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=lts__t_requests_aperture_device_evict_normal_lookup_miss INJECTION_TARGET=LSU STARTING_POINT=1 SM_COUNT=7
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=l1tex__t_bytes_pipe_lsu_lookup_miss INJECTION_TARGET=LSU STARTING_POINT=1 SM_COUNT=7
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=fbpa__dram_write_bytes INJECTION_TARGET=LSU STARTING_POINT=1 SM_COUNT=7

#ALU tests
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=lts__t_requests_aperture_device_evict_normal_lookup_miss INJECTION_TARGET=ALU STARTING_POINT=1 SM_COUNT=7
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=l1tex__t_bytes_pipe_lsu_lookup_miss INJECTION_TARGET=ALU STARTING_POINT=1 SM_COUNT=7
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=fbpa__dram_write_bytes INJECTION_TARGET=ALU STARTING_POINT=1 SM_COUNT=7

#FMA test
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=sm__pipe_fma_cycles_active INJECTION_TARGET=fma STARTING_POINT=1 SM_COUNT=7

#ADU test
make tests EVENTS_PER_FILE=1 TOTAL_EVENTS=50 SAMPLES_PER_EVENT=1000 EVENT_TYPE=sm__pipe_fma_cycles_active INJECTION_TARGET=predicates STARTING_POINT=1 SM_COUNT=7

cd $CWD
echo "L0 i-Cache Results:\n\n" > results/L0_results_7.txt
python3 analysis.py no no svm L0 lts__t_requests_aperture_device_evict_normal_lookup_miss 7 1000 >> results/L0_results_7.txt
python3 analysis.py no no svm L0 l1tex__t_bytes_pipe_lsu_lookup_miss 7 1000 >> results/L0_results_7.txt
python3 analysis.py no no svm L0 fbpa__dram_write_bytes 7 1000 >> results/L0_results_7.txt
python3 analysis.py no no LOF L0 lts__t_requests_aperture_device_evict_normal_lookup_miss 7 1000 >> results/L0_results_7.txt
python3 analysis.py no no LOF L0 l1tex__t_bytes_pipe_lsu_lookup_miss 7 1000 >> results/L0_results_7.txt
python3 analysis.py no no LOF L0 fbpa__dram_write_bytes 7 1000 >> results/L0_results_7.txt


echo "LSU Results:\n\n" > results/LSU_results_7.txt
python3 analysis.py no no svm LSU lts__t_requests_aperture_device_evict_normal_lookup_miss 7 1000 >> results/LSU_results_7.txt
python3 analysis.py no no svm LSU l1tex__t_bytes_pipe_lsu_lookup_miss 7 1000 >> results/LSU_results_7.txt
python3 analysis.py no no svm LSU fbpa__dram_write_bytes 7 1000 >> results/LSU_results_7.txt
python3 analysis.py no no LOF LSU lts__t_requests_aperture_device_evict_normal_lookup_miss 7 1000 >> results/LSU_results_7.txt
python3 analysis.py no no LOF LSU l1tex__t_bytes_pipe_lsu_lookup_miss 7 1000 >> results/LSU_results_7.txt
python3 analysis.py no no LOF LSU fbpa__dram_write_bytes 7 1000 >> results/LSU_results_7.txt


echo "ALU Results:\n" > results/ALU_results_7.txt
python3 analysis.py no no svm ALU lts__t_requests_aperture_device_evict_normal_lookup_miss 7 1000 >> results/ALU_results_7.txt
python3 analysis.py no no svm ALU l1tex__t_bytes_pipe_lsu_lookup_miss 7 1000 >> results/ALU_results_7.txt
python3 analysis.py no no svm ALU fbpa__dram_write_bytes 7 1000 >> results/ALU_results_7.txt
python3 analysis.py no no LOF ALU lts__t_requests_aperture_device_evict_normal_lookup_miss 7 1000 >> results/ALU_results_7.txt
python3 analysis.py no no LOF ALU l1tex__t_bytes_pipe_lsu_lookup_miss 7 1000 >> results/ALU_results_7.txt
python3 analysis.py no no LOF ALU fbpa__dram_write_bytes 7 1000 >> results/ALU_results_7.txt

echo "FMA Results:\n\n" > results/FMA_results_7.txt
python3 analysis.py no no svm fma sm__pipe_fma_cycles_active 7 1000 >> results/FMA_results_7.txt
python3 analysis.py no no LOF fma sm__pipe_fma_cycles_active 7 1000 >> results/FMA_results_7.txt

echo "ADU Results:\n\n" > results/ADU_results_7.txt
python3 analysis.py no no svm predicates sm__pipe_fma_cycles_active 7 1000 >> results/ADU_results_7.txt
python3 analysis.py no no LOF predicates sm__pipe_fma_cycles_active 7 1000 >> results/ADU_results_7.txt
