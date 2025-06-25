% Example how to extract data from pcap file.
% Unnecessary lines are INDENTED.

            clear all; close all

            % Define pcap or pcapng file to be converted
pcapPath = 'VTT SV data/50Hz_3phase_harm.pcapng';

            % Search for tshark binary (part of Wireshark)
            tic
tsharkPath = get_tshark_binary_path();
            disp('searching for tshark binary took:')
            toc
            if isempty(tsharkPath)
                disp('tshark binary not found.');
            else
                disp(sprintf('Found tshark binary at: %s\n', tsharkPath))
            end

            % Search MAC addresses of all devices that appears in the pcap file
            tic
[sourceMacsCell, destMacsCell] = get_macs_from_pcap(pcapPath, tsharkPath, 1, 1);
            disp('searching MAC addresses took:')
            toc

            % Select MAC addres of source and destination (just use first and
            % first mac address) and convert relevant packets to obtain sampled
            % values.
            tic
[Time, Counters, Data]= get_data_from_pcap(pcapPath, sourceMacsCell{1}, destMacsCell{1}, tsharkPath, 1, 1);
            disp('converting data took:')
            toc

            % Plotting
            % Sampling frequency, CT/VT ratios and order of quantities in Data is based on
            % apriori knowledge from 'VTT SV data/README.txt'.
            fs = 4000;      % sampling frequency
            CTratio = 1000; % current transducer ratio
            VTratio = 4000; % voltage transducer ratio
            t = [0 : size(Data, 1) - 1]'./fs;    % time vector
            % plot currents:
            figure
            plot(t, Data(:, 1:4)./CTratio)
            legend('I1', 'I2', 'I3', 'In')
            title(sprintf('Currents\n%s', pcapPath))
            xlabel('t / s')
            ylabel('current / A')
            % plot voltages:
            figure
            plot(t, Data(:, 5:8)./VTratio)
            legend('U1', 'U2', 'U3', 'Un')
            title(sprintf('Voltages\n%s', pcapPath))
            xlabel('t / s')
            ylabel('voltage / V')
