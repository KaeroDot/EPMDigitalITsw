
% Read sampled values from pcap file for selected source and destination.
function [Time, Counters, Data]= get_data_from_pcap(pcapPath, sourceMac, destMac, tsharkPath, skip_if_exist, verbose)
    % Comment on functionality ---------------------- %<<<1
    % One could process output of tshark command directly without using
    % temporary files, unfortunately a large output can fail, mostly when
    % done second time. Therefore temporary files are always used.

    % Initialization ---------------------- %<<<1
    % skip_if_exist variable is not mandatory:
    if not(exist('skip_if_exist', 'var'))
        skip_if_exist = 0;
    end
    skip_if_exist = not(not(skip_if_exist));    % ensure logical

    % verbose variable is not mandatory:
    if not(exist('verbose', 'var'))
        verbose = 0;
    end
    verbose = not(not(verbose));    % ensure logical

    % temp file jako mat
    % soubor? XXXXXXXXXXXXXXXXXX

    % Create a name of the temporary file
    tmpFile = sprintf('%s.data_src_%s_dst_%s.txt', ...
        pcapPath, ...
        strrep(sourceMac, ':', ''), ...
        strrep(destMac, ':', ''));

    % tshark data covnerting ---------------------- %<<<1
    % check if temporary file with data already exist and if user wants to skip
    % the tshark processing:
    if or(not(exist(tmpFile, 'file')), not(skip_if_exist))
        % Export data using tshark
        cmd = sprintf('"%s" -r "%s" -Y "eth.type == 0x88ba" -Y "eth.src == %s " -Y "eth.dst == %s " -T fields -e frame.time_relative -e sv.smpCnt -e sv.meas_value > "%s"', ...
        tsharkPath, ...
        pcapPath, ...
        sourceMac, ...
        destMac, ...
        tmpFile);
        if verbose disp('Calling tshark to convert pcap file ...'), end
        [status, output] = system(cmd);
        if verbose disp('tshark finished converting pcap file.'), end
        % output contains data in following format:
        % Every single line is a single packet, with the following format:
        %   "Time TAB Counter TAB MeasuredValue1,MeasuredValue1,...,MeasuredValue8 NEWLINE"
        % where:
        %   Time - frame.time_relative,
        %   TAB - tab character,
        %   Counter - a sample counter values (sv.smpCnt), that overflows at some
        %       count and starts again from 0. Up to 8 counters can be here, that
        %       represents up to 8 ASDU (Application Specific Data Unit) values in
        %       this data line. Usually only one ASDU is present.
        %   TAB - tab character,
        %   MeasuredValue1,...,MeasuredValueN - a string of measured values,
        %       (sv.meas_value) separated by commas. There is 8 emasured values [I0,
        %       I1, I2, I3, V0, V1, V2, V3] for each ASDU, so for maximum of 8 ASDU
        %       values there can be up to 64 measured values. Each measured value is
        %       represented as 32-bit (4 bytes) signed integer (int32)
        %   NEWLINE - dependent on the operating system.
    end % if or()

    % loading temporary file ---------------------- %<<<1
    % from the first line of the temporary file, get the number of ASDUs and
    % check that number of measured data is correct:
    fid = fopen(tmpFile, 'r');
    line = fgetl(fid);                      % get first line
    fclose(fid);
    C = strsplit(line, {'\t'});             % separate values to Time, Counter, and MeasuredValues
    num_of_ASDUs = length(str2num(C{2}));   % number of sample counter values
    all_meas_data = str2num(C{3});          % get all measured data of one packet
    % check if number of ASDU is consistent with number of measured values:
    if not(8*num_of_ASDUs == numel(all_meas_data))
        error('Number of ASDUs (%d) is not consistent with number of measured values (%d). Number of measured values should be 8 times the number of ASDUs',...
            num_of_ASDUs, ...
            numel(all_meas_data));
    end % end if

    fid = fopen(tmpFile, 'r');
    C = textscan(fid,'%f', 'Delimiter', {sprintf('\t'), ','}); % 19 seconds for 1.5 GB pcap file
    fclose(fid);
    Data = cell2mat(C);
    clear C;
    Data = reshape(Data, 1 + num_of_ASDUs + 8*num_of_ASDUs, [])';  % 1 is for time column
    Time = Data(:, 1);        % time: frame.time_relative
    Counters = Data(:, 1 + 1 : 1 + num_of_ASDUs);
    Data(:, 1 : 1 + num_of_ASDUs) = [];

    if verbose disp(['Number of ASDUs in the data is: ' num2str(num_of_ASDUs)]), end
    if verbose disp(['Number of loaded packets is: ' num2str(size(Data, 1))]), end

    % a rozdelit na jednotlive ASDU a cas atd. XXXXXXXXXXXXXXXXXX

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
