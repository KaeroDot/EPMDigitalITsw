clear all; close all

pcapPath = 'VTT SV data/50Hz_3phase_harm.pcapng';

tic
tsharkPath = get_tshark_binary_path();
toc
if isempty(tsharkPath)
    disp('tshark.exe not found.');
else
    disp(sprintf('Found tshark.exe at: %s\n', tsharkPath))
end % if isempty

tic
[sourceMacsCell, destMacsCell] = get_macs_from_pcap(pcapPath, tsharkPath, 1, 1);
toc

% just use first and first mac address:
tic
[Time, Counters, Data]= get_data_from_pcap(pcapPath, sourceMacsCell{1}, destMacsCell{1}, tsharkPath, 1, 1);
toc

plot(Time, Data(:,1))
