% Finds path to the tshark binary and returns full path and name. Works on both
% unix and windows systems.

function tsharkPath = get_tshark_binary_path(verbose)
    % Initialization ---------------------- %<<<1
    % verbose variable is not mandatory:
    if not(exist('verbose', 'var'))
        verbose = 0;
    end
    verbose = not(not(verbose));    % ensure logical

    % Constants ---------------------- %<<<1
    % binary of tshark in windows:
    winTsharkBinaryFilename = 'tshark.exe';
    % registry keys to search for Wireshark installation in windows:
    winWiresharkRegisteryKeys = {
        'HKLM\SOFTWARE\Wireshark', ...
        'HKLM\SOFTWARE\WOW6432Node\Wireshark'
    };

    tsharkPath = '';  % Default to empty if not found

    % Find tshark path  ---------------------- %<<<1
    if isunix
        % unix/linux case. Simply check if tshark binary is in PATH
        [status, output] = system('which tshark');
        if status == 0
            output = strtrim(output);  % Remove trailing newline
            % check if found path is really correct:
            if exist(output, 'file') == 2
                tsharkPath = output;
            end % if exist
        end % if status
    else % isunix
        % windows case, much more complex due to nonfunctioning/unused PATH. Register query must be done.
        for i = 1:length(winWiresharkRegisteryKeys)
            % Properly format registry query
            cmd = sprintf('reg query "%s" /v InstallDir 2>NUL', winWiresharkRegisteryKeys{i});
            % use command reg to query register if wireshark registry keys exist
            [status, output] = system(cmd);

            if status == 0
                % Match "InstallDir    REG_SZ    C:\Path\To\Wireshark"
                tokens = regexp(output, 'InstallDir\s+REG_SZ\s+([^\r\n]+)', 'tokens');
                if ~isempty(tokens)
                    installDir = strtrim(tokens{1}{1});
                    possiblePath = fullfile(installDir, winTsharkBinaryFilename);
                    % check if binary file really exist
                    if exist(possiblePath, 'file') == 2
                        tsharkPath = possiblePath;
                        return;
                    end % if exist
                end % if ~isempty
            end % if status
        end % for
    end % if isunix

    if isempty(tsharkPath)
        disp('tshark.exe not found in registry.');
    else
        if verbose disp(sprintf('Found tshark.exe at: %s\n', tsharkPath)), end
    end % if isempty

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
