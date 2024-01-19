#!/bin/bash
python ../../reading_pcap_files/pcap_samples_to_csv.py 50Hz_3phase_harm.pcapng  50Hz_3phase_harm_only_samples.csv
python ../../reading_pcap_files/pcap_samples_to_csv.py 50Hz_3phase_harm2.pcapng 50Hz_3phase_harm2_only_samples.csv
python ../../reading_pcap_files/pcap_samples_to_csv.py 50Hz_3phase.pcapng       50Hz_3phase_only_samples.csv

