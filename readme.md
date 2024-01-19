# Description

Software developed in the scope of European Partnership on Metrology project 
[Digital-IT: Metrology for digital substation instrumentation](https://www.euramet.org/research-innovation/search-research-projects/details/project/metrology-for-digital-substation-instrumentation),
(21NRM02).

# Description of directories

## data
Example data measured on SAMU.

`pcap_samples_to_csv.py` - very naive python script to convert pcap files to csv with sampled values.

### VTT SV data
`README.txt` - measurement details
`convert_all.sh` - converts pcap files to csv files using script `pcap_samples_to_csv.py`
`process.m` - loads all output csv, make FFT, plots spectrums.

#algorithms_for_QWTB
Contains algorithms ready to be included in
[QWTB](https://github.com/qwtb/qwtb). Just copy directories starting with
`alg_` to your QWTB folder. Or do not copy, just make a symbolic link.

# Reports

## A2.2.1
Report for [A2.2.1 is on overlaf](https://www.overleaf.com/read/dgqgxkchtvmt).

## A2.2.2
Report for A2.2.2 is on overlaf, project id 651fb7ee9649e0143876d46d.


