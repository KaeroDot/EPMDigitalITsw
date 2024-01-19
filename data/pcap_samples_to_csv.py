#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Converts pcap file to cs table with currents and voltages sampled by SAMU
# Usage:
#   python pcap_samples_to_csv.py input_file.pcap output_file.csv
# Output csv file contains 9 collumns:
# t, IA, IB, IC, IN, VA, VB, VC, VN
# where:
#   t is time of the packet arrival
#   IA is current
#   etc.

# READING TRIPLETS TYPE-LENGTH-VALUE is more complex than estimated. LENGTH is not fixed.
#  def read_triplet(bytelist)
#      # returns data and length of first triplet in the data
#      # secdond byte is length
#      length = bytelist[1]
#      # data in actual triplet:
#      data = bytelist[2:length]
#      # rest of bytes:
#      rest = bytelist[length+1:]
#      reurn data, rest

#  #  Only for debugging:
#  import pdb
#  pcapfile = '50Hz_3phase_harm.pcapng'
#  csvfile = 'test.csv'

import sys
pcapfile = sys.argv[1]
csvfile = sys.argv[2]

print('Will extract samples from file "' + pcapfile + '" and write to "' + csvfile + '"')

from kamene.all import rdpcap
import csv

packets = rdpcap(pcapfile)

print('File loaded, parsing and writing to csv started.')

# different for different devices!:
byte_positions = [[56,60], [64,68], [72,76], [80,84], [88,92], [96,100], [104,108], [112,116]]
noASDU_byte_position = 28 # can be 26, 28, I do not know what are bytes between reserved and noASDU


f = open(csvfile, 'w', encoding='UTF8')
writer = csv.writer(f)

for ind, pack in enumerate(packets):
    f = pack.fields
    if 'type' in f:
        # 35002 (0x88ba) is the type of IEC 61850-9-2 sampled values packet
        if f['type'] == 35002:
            bytelist = [ bytes(pack)[s:e] for s, e in byte_positions ]
            values = [ int.from_bytes(b, 'big', signed=True) for b in bytelist]
            # both currents and voltages are written in mA and mV as integer types (this is defined by IEC)
            realvalues = [x/1000 for x in values]
            writer.writerow([pack.time] + realvalues)

print('Parsing and writing finished.')

# old lines:
#  data = [[0.0]*9]*len(packets)
#  with open(csvfile, 'w', encoding='UTF8') as f:
#      writer = csv.writer(f)
#      writer.writerows(data)

print('Done.')
