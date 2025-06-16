% Scan pcap file for MAC addresses of sources and destinations using tshark.
% Return MAC addresses as cell of strings. The MAC addresses are saved into
% temporary files and can be retrieved again by setting skip_if_exist to
% positive value. The reason is the tshark can take up to 5 minutes of scanning
% for 1.5 GB long pcap file, and this has to be done twice for sources and
% destinations.

function [sourceMacsCell, destMacsCell]= get_macs_from_pcap(pcapPath, tsharkPath, skip_if_exist, verbose)
    % Initialization ---------------------- %<<<1
    % skip_if_exist variable not mandatory:
    if not(exist('skip_if_exist', 'var'))
        skip_if_exist = 0;
    end
    skip_if_exist = not(not(skip_if_exist));    % ensure logical

    % verbose variable not mandatory:
    if not(exist('verbose', 'var'))
        verbose = 0;
    end
    verbose = not(not(verbose));    % ensure logical

    % Comment on functionality ---------------------- %<<<1
    % One could process output of tshark command directly, as in following
    % commented lines, uncfortunately such a large output can fail, mostly when
    % done second time. Therefore temporary files are used.
        % cmd = sprintf('"%s" -r "%s" -Y "eth.type == 0x88ba" -T fields -e eth.src > aaa.txt', ...
        %     tsharkPath, ...
        %     pcapPath);
        % [status, output] = system(cmd);
        % sourceMacsCell = strsplit(strtrim(output), sprintf('\n')); % parse output XXX this takes too long for 1.5 GB files - more than 5 minutes
        % sourceMacsCell = unique(sourceMacsCell, 'stable');  % get only unique values and keep order

    % cycle for two targets: sources and destinations.
    target = {'src', 'dst'};
    targetlong = {'source', 'destination'};
    macsCell = {};
    for t = 1:numel(target)
        % create name of temporary file:
        tmpFile = [pcapPath '.' targetlong{t} '_MAC_addresses.txt'];

        % check if temporary file with MAC addresses already exist and if user wants
        % to skip tshark processing:
        load_directly = 0;
        if skip_if_exist
            if exist(tmpFile, 'file')
                load_directly = 1;
            end
        end

        if load_directly
            % temporary file already exist, load MAC addresses from the file.
            fid = fopen(tmpFile, 'r');
            macsCell{t} = textscan(fid, '%s');
            fclose(fid);
            macsCell{t} = unique(macsCell{t}{1}, 'stable');  % get only unique, keep order, just to be sure
            if verbose disp(['Reading ' targetlong{t} ' unique MAC addresses from already existing temporary file finished.']), end
        else
            % Call tshark, write addresses to temporary file.
            cmd = sprintf('"%s" -r "%s" -Y "eth.type == 0x88ba" -T fields -e eth.%s > "%s"', ...
                tsharkPath, ...
                pcapPath, ...
                target{t}, ...
                tmpFile); % this command can take e.g. 5 minutes for 1.5 GB file!
            if verbose disp(['Calling tshark to read ' targetlong{t} ' MAC addresses ...']), end
            [status, output] = system(cmd);
            if verbose disp(['tshark finished reading all ' targetlong{t} ' MAC addresses.']), end

            % load temporary file with MAC addresses
            fid = fopen(tmpFile, 'r');
            macsCell(t) = textscan(fid, '%s');
            macsCell(t) = {unique(macsCell{t}, 'stable')};  % get only unique, keep order
            fclose(fid);
            if verbose disp(['Finding unique ' targetlong{t} ' MAC addresses finished.']), end

            % write unique MAC addresses back to the temporary file for future
            % use.
            fid = fopen(tmpFile, 'w');
            fprintf(fid, '%s\n', macsCell{t}{:});
            fclose(fid);
        end % if skip
        if verbose
            disp(['Following unique ' targetlong{t} ' MAC addresses obtained:'])
            disp(macsCell{t})
        end % if verbose
    end % for t = 1:numel(target)

    % create outputs:
    sourceMacsCell = macsCell{1};
    destMacsCell = macsCell{2};

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
