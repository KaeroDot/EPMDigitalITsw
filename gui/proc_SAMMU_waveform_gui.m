function proc_SAMMU_waveform_gui() %<<<1
% main function. checks environment, runs gui
    % Globals
    global GUIname; % name of the GUI
    global udata;    % structure with user input data

    % Define constants
    GUIname = 'process SAMMU waveform';
    udata.CONST_available_algorithms = {'PSFE>SplineResample>FFT', 'PSFE>resampleSVstream>FFT'}; % Must be a constant - if changed, change also function calculate()!
    udata.CONST_srmethod = {'keepN', 'minimizefs', 'poweroftwo'}; % if changed, change also function calculate()!
    % this is order in which quantities are in pcap files:
    udata.CONST_pcap_quantities = {'I0', 'I1', 'I2', 'I3', 'U0', 'U1', 'U2', 'U3'};
    udata.alg = ''; % selected algorithm id (default value see get_udata_from_pref)
    udata.datafile = ''; % file with sampled data (default value see get_udata_from_pref)
    udata.split = ''; % data split period (default value see get_udata_from_pref)
    udata.fs = ''; % sampling frequency (default value see get_udata_from_pref)
    udata.fest = ''; % signal frequency estimate (default value see get_udata_from_pref)
    udata.srmethod = ''; % SplineResample method (default value see get_udata_from_pref)
    udata.srd = ''; % SplineResample denominator (default value see get_udata_from_pref)
    udata.rsmaxaerr = ''; % resamplingSVstream maximum relative amplitude error (default value see get_udata_from_pref)
    udata.rsspp = ''; % resamplingSVstream samples per period (default value see get_udata_from_pref)

    % Ensure system is working
    % ensure qwtb path
    qwtb_user_action = ensure_qwtb_path();
    % ensure digit algorithms are available in qwtb
    digit_user_action = ensure_digit_algs();

    if any([qwtb_user_action digit_user_action])
        welcome_message = 1;
    else
        welcome_message = 0;
    end

    % Run the GUI
    make_gui(welcome_message);
end % function

%% functions for QWTB & DigitalIT installation %<<<1
function q = qwtb_in_path %<<<2
    q = exist('qwtb', 'file');
end % function qwtb_in_path

function q = digit_algs_in_qwtb %<<<2
    algs = qwtb();
    digit_alg = 'SplineResample';
    q = any(strcmp({algs.id}, digit_alg));
end % function qwtb_in_path

function add_qwtb_path_to_pref(qwtb_path) %<<<2
    global GUIname
    % function adds qwtb path to a user preferences
    setpref(GUIname, 'qwtb_path', qwtb_path);
end % function add_qwtb_path_to_pref

function qwtb_path = get_qwtb_path_from_pref() %<<<2
    global GUIname
    if ispref(GUIname, 'qwtb_path')
        qwtb_path = getpref (GUIname, 'qwtb_path');
        addpath(qwtb_path);
    end
end % function get_qwtb_path_from_pref

function was_user_action = ensure_qwtb_path() %<<<2
% function ensures the qwtb is available and in the octave/matlab path
% returns info if there was interacion with user
    was_user_action = 0;
    global GUIname
    % do nothing if qwtb already in path:
    if qwtb_in_path
        return
    end
    % try to load setting from preferences
    if ispref(GUIname,'qwtb_path')
        qwtb_path = getpref (GUIname, 'qwtb_path');
        addpath(qwtb_path);
        if qwtb_in_path
            return
        end
    end
    % all failed, ask user to find qwtb path and save it to preferences, or
    % automatically download qwtb and required algs:
    was_user_action = 1; % note to outer function that user had to setup QWTB
    message = sprintf('QWTB was not found in octave path.\n Do you want to automatically download and setup? If you already have got QWTB, you can select an existing directory in your computer with the QWTB.');
    btn1 = 'Automatically download and setup';
    btn2 = 'Select existing directory';
    btn3 = 'Abort';
    res = questdlg (message, 'QWTB was not found', btn1, btn2, btn3, btn1);
    if strcmp(res, btn1)
        download_QWTB();
    elseif strcmp(res, btn2)
        qwtb_path = uigetdir('', 'Select directory with QWTB');
        if not(ischar(qwtb_path))
            % user pressed cancel on ui dialog
            error('User aborted')
        end
        % user selected a directory
        addpath(qwtb_path)
        if qwtb_in_path
            add_qwtb_path_to_pref(qwtb_path)
            return
        else
            % qwtb still not found
            errmsg = 'QWTB not found in the selected directory.'; % list input arguments
            errordlg(errmsg, GUIname)
            error(errmsg)
        end % if
    else
        error('User aborted')
    end % if strcmp
end % function ensure_qwtb_path

function was_user_action = ensure_digit_algs() %<<<2
% function ensures the digitalit algorithms are available in QWTB
% returns info if there was interacion with user
    was_user_action = 0;
    % do nothing if algs already in path:
    if digit_algs_in_qwtb()
        return
    end
    % ask user to add algorithms by himself or automatically download algs:
    was_user_action = 1;
    btn1 = 'Automatically download and add';
    btn2 = 'I will do it by myself - script will now quit';
    message = sprintf('DigitalIT algorithms were not found in QWTB.\nDirectories with these algorithms have to be copied into QWTB directory. Do you want to automatically download DigitalIT repository and setup?');
    res = questdlg(message, 'DigitalIT algorithms not found', btn1, btn2, btn1);
    if strcmp(res, btn1)
        download_Digital_IT();
    else
        error('User aborted')
    end
end

function download_QWTB() %<<<2
    global GUIname
    % Zip url: 
    qwtb_url = 'https://github.com/qwtb/qwtb/archive/refs/heads/master.zip';
    h_msgbox = msgbox(sprintf('Downloading and setting up QWTB, please wait.\nThis message will close when finished.\n(If you use Matlab, please wait very long time.)\nQWTB url is:\n%s', qwtb_url));
    try
        download_and_unzip(qwtb_url);
        qwtb_path = fullfile(pwd, 'qwtb-master', 'qwtb');
        addpath(qwtb_path)
        if qwtb_in_path
            add_qwtb_path_to_pref(qwtb_path)
        else
            error('QWTB not found on path.')
        end
    catch ERR
        % qwtb still not found
        errmsg = sprintf('Cannot download/unzip/add QWTB... Ask author to fix it. The error message was:\n%s', ERR.message);
        errordlg(errmsg, GUIname)
        error(errmsg)
    end % try_catch
    
    if ishandle(h_msgbox)
        close(h_msgbox);
    end
end % function download_QWTB()

function download_Digital_IT() %<<<2
    global GUIname
    % Zip url: 
    digit_url = 'https://github.com/KaeroDot/EPMDigitalITsw/archive/refs/heads/main.zip';
    h_msgbox = msgbox(sprintf('Downloading additional algorithms from DigitalIT repository, please wait.\nThis message will close when finished.\n(If you use Matlab, please wait very long time.)\nUrl is:\n%s', digit_url));
    try
        download_and_unzip(digit_url);
        downloaded_extracted_zip_path = fullfile(pwd, 'EPMDigitalITsw-main');
        digit_path = fullfile(downloaded_extracted_zip_path, 'algorithms_for_QWTB');
        % (because of matlab incompetence, one cannot copy directory as
        % 'path/dir'->'path2', because it only copies all files in dir to a
        % path2. One must copy 'path/dir'->'path2/dir')
        copyfile(fullfile(digit_path, 'alg_SplineResample'), fullfile(get_qwtb_path_from_pref(), 'alg_SplineResample'));
        if not(digit_algs_in_qwtb)
            error('DigitalIT algorithms not found in QWTB.')
        end
        % copy demo data file:
        copyfile(fullfile(downloaded_extracted_zip_path, 'gui/testdata_simple_csv_fs=4000_f=49.9-50.csv'), ...
            fullfile(pwd, 'testdata_simple_csv_fs=4000_f=49.9-50.csv'));
    catch ERR
        % qwtb still not found
        errmsg = sprintf('Cannot download/unzip/add DigitalIT algorithms... Ask author to fix it. The error message was:\n%s', ERR.message);
        errordlg(errmsg, GUIname)
        error(errmsg)
    end % try_catch

    if ishandle(h_msgbox)
        close(h_msgbox);
    end
end % function download_Digital_IT

function download_and_unzip(url) %<<<2
% this function exists only because Matlab does not work properly according their documentation
% Downloads file & unzip content into working directory
    if isOctave
        % simple version, because Octave works:
        unzip(url, pwd);
    else
        % unzip in matlab does not work for direct download (but should according
        % to the documentation), so downloading and saving into temporary file is
        % needed. Also, matlab requires special treatment for writing binary data:
        temporary_file_path = 'temporary.zip';
        tmp = webread(url, weboptions('ContentType', 'raw'));
        fh = fopen(temporary_file_path, 'w');
        fwrite(fh, tmp);
        fclose(fh);
        unzip(temporary_file_path, pwd)
        delete(temporary_file_path);
    end
end % function download_and_unzip

function retval = isOctave() %<<<2
% checks if GNU Octave or Matlab
% according https://www.gnu.org/software/octave/doc/v4.0.1/How-to-distinguish-between-Octave-and-Matlab_003f.html
  persistent cacheval;  % speeds up repeated calls
  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end
  retval = cacheval;
end % function isOctave

%% functions for GUI %<<<1
function make_gui(welcome_message) %<<<2
% constructs gui. if welcome_message set to nonzero, welcome message about
% successful installation is shown.
    %% define globals %<<<3
    global GUIname; % defined in proc_SAMMU_waveform_gui()
    global udata;   % structure with user input data
    global f_main;  % main GUI figure handle

    %% Define grid for uicontrols and gui dimensions %<<<3
    % grid properties for the uicontrols:
    uig.row_step = 3; % grid size of rows of ui controls
    uig.row_off = 1; % offset of rows of ui controls
    uig.col_step = 28; % grid size of columns of ui controls
    uig.col_off = 1; % offset of columns of ui controls
    uig.total_width = 113; % total width of the gui window
    uig.total_height = 23; % total height of the gui window
    uig.row = 1; % index of row of ui controls
    uig.col = 1; % index of column of ui controls

    %% load settings %<<<3
    get_udata_from_pref()

    %% create gui window
    % Because of matlab, figure instead of uifigure must be used
    % (matlab cannot set property units in uifigure)
    f_main = figure('name',          GUIname, ...
                        'tag',          'f_main', ...
                        'toolbar',      'none', ...
                        'menubar',      'none', ...
                        'units',        'characters');
    % Set size of the GUI without changing the initial position given by
    % operating system:
    pos = get(f_main, 'position');
    set(f_main, 'position', [pos(1) ...
                             pos(2)-(uig.total_height - pos(4)) ...
                             uig.total_width ...
                             uig.total_height]);

    %% Create ui controls %<<<3
    % All controls must be children of f_main, otherwise automatic searching for
    % handles of uicontrols find_h_by_tag() will not work!
    uig.row = 1; % --------------- row 1 convert from pcap
    uig.col = 1;
    % button pcap convert
    b_datafile = uicontrol (f_main, ...
                        'tag',      'b_pcapconvert', ...
                        'string',   'Convert pcap file to csv...', ...
                        'callback', @b_pcapconvert_callback, ...
                        'units',    'characters', ...
                        'tooltipstring', 'Open dialog to convert pcap file into a csv that can be processed by this GUI.', ...
                        'position', uigrid_position(uig, 4));
    uig.row = uig.row + 1; % --------------- row 2 file input
    uig.col = 1;
    % button Filename
    b_datafile = uicontrol (f_main, ...
                        'tag',      'b_datafile', ...
                        'string',   'Select datafile..', ...
                        'callback', @b_datafile_callback, ...
                        'units',    'characters', ...
                        'tooltipstring', 'Open file dialog to select a file with the sampled data.', ...
                        'position', uigrid_position(uig));
    uig.col = uig.col + 1;
    % label for filename
    t_datafile = uicontrol(f_main, ...
                        'tag',      't_datafile', ...
                        'Style',    'text', ...
                        'string',   udata.datafile, ...
                        'units',    'characters', ...
                        'horizontalalignment',  'left', ...
                        'tooltipstring', 'File with the sampled data.', ...
                        'position',  uigrid_position(uig, 3));
    uig.row = uig.row + 1; % --------------- row 3 algorithms and split
    uig.col = 1;
    % label for listbox with algorithms
    t_alg = uicontrol(f_main, ...
                        'tag',      't_alg', ...
                        'Style',    'text', ...
                        'string',   'Algorithm:', ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % listbox with algorithms
    tmp = find(strcmpi(udata.alg, udata.CONST_available_algorithms));
    if isempty(tmp); tmp = 1; end
    p_alg = uicontrol(f_main, ...
                        'tag',      'p_alg', ...
                        'Style',    'popupmenu', ...
                        'string',   udata.CONST_available_algorithms, ...
                        'callback', @b_alg_callback, ...
                        'value',    tmp, ...
                        'units',    'characters', ...
                        'tooltipstring', 'Select algorithm that will be used to calculate the results.', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % label for input split per seconds
    t_split = uicontrol(f_main, ...
                        'tag',      't_split', ...
                        'Style',    'text', ...
                        'string',   sprintf('Split by (s):\n(0 for no split)'), ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % input split per seconds
    i_split = uicontrol(f_main, ...
                        'tag',      'i_split', ...
                        'Style',    'edit', ...
                        'string',   num2str(udata.split), ...
                        'units',    'characters', ...
                        'tooltipstring', sprintf('Write here a time in seconds. The data will be split into sections of this length.\nResults will be calculated for every section independently.\nIf value is set to zero, no splitting will be done and whole data will be calculated as one record.'), ...
                        'position',  uigrid_position(uig));

    uig.row = uig.row + 1; % --------------- row 4 sampling f and fest
    uig.col = 1;
    % label for input sampling frequency
    t_fs = uicontrol(f_main, ...
                        'tag',      't_fs', ...
                        'Style',    'text', ...
                        'string',   'Sampling f (Hz):', ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % input sampling frequency
    i_fs = uicontrol(f_main, ...
                        'tag',      'i_fs', ...
                        'Style',    'edit', ...
                        'string',   num2str(udata.fs), ...
                        'units',    'characters', ...
                        'tooltipstring', 'Write here a value of the sampling frequency used to obtain the samples.', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % label for input signal estimate frequency
    t_fest = uicontrol(f_main, ...
                        'tag',      't_fest', ...
                        'Style',    'text', ...
                        'string',   sprintf('Signal frequency (Hz)\n (basic estimate)'), ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % input signal estimate frequency
    i_fest = uicontrol(f_main, ...
                        'tag',      'i_fest', ...
                        'Style',    'edit', ...
                        'string',   num2str(udata.fest), ...
                        'units',    'characters', ...
                        'tooltipstring', sprintf('Write here a number with an estimate of the signal frequency, that is used in the calculation algorithms.\nE.g. for power measurement 50 Hz is sufficient estimate.'), ...
                        'position',  uigrid_position(uig));

    uig.row = uig.row + 1; % --------------- row 5 splineresample relative
    uig.col = 1;
    % label for input splineresample method
    t_srmethod = uicontrol(f_main, ...
                        'tag',      't_srmethod', ...
                        'Style',    'text', ...
                        'string',   'Method:', ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % input splinreesample method
    tmp = find(strcmpi(udata.srmethod, udata.CONST_srmethod));
    if isempty(tmp); tmp = 1; end
    p_srmethod = uicontrol(f_main, ...
                        'tag',      'p_srmethod', ...
                        'Style',    'popupmenu', ...
                        'string',   udata.CONST_srmethod, ...
                        'value',    tmp, ...
                        'units',    'characters', ...
                        'tooltipstring', sprintf('Select a method used in SplineResample algorithm.\nThis is relevant only for SplineResample algorithm. For other algorithms, this value is ignored.'), ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % label for input splineresample denominator
    t_srd = uicontrol(f_main, ...
                        'tag',      't_srd', ...
                        'Style',    'text', ...
                        'string',   'Denominator:', ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % input spinreesample denominator
    i_srd = uicontrol(f_main, ...
                        'tag',      'i_srd', ...
                        'Style',    'edit', ...
                        'string',   num2str(udata.srd), ...
                        'units',    'characters', ...
                        'tooltipstring', sprintf('Write here a value of denominator to reduce resampled bandwidth.\nThis is relevant only for SplineResample algorithm. For other algorithms, this value is ignored.'), ...
                        'position',  uigrid_position(uig));

    uig.row = uig.row + 0; % --------------- row 5 again resamplingSVstream relative
    uig.col = 1;
    t_rsmaxaerr = uicontrol(f_main, ...
                        'tag',      't_rsmaxaerr', ...
                        'Style',    'text', ...
                        'string',   'Maximum relative amplitude error:', ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % input resamplingSVstream method
    i_rsmaxaerr = uicontrol(f_main, ...
                        'tag',      'i_rsmaxaerr', ...
                        'Style',    'edit', ...
                        'string',   num2str(udata.rsmaxaerr), ...
                        'units',    'characters', ...
                        'tooltipstring', sprintf('Write here a maximum relative amplitude error (V/V).\nThis is relevant only for resamplingSVstream algorithm. For other algorithms, this value is ignored.'), ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % label for input resamplingSVstream samples per period
    t_rsspp = uicontrol(f_main, ...
                        'tag',      't_rsspp', ...
                        'Style',    'text', ...
                        'string',   'Samples per period of the signal:', ...
                        'units',    'characters', ...
                        'tooltipstring', sprintf('Required number of samples per period of the signal.\nThis is relevant only for resamplingSVstream algorithm. For other algorithms, this value is ignored.'), ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % input resamplingSVstream samples per period
    i_rsspp = uicontrol(f_main, ...
                        'tag',      'i_rsspp', ...
                        'Style',    'edit', ...
                        'string',   num2str(udata.rsspp), ...
                        'units',    'characters', ...
                        'tooltipstring', sprintf('Write here a value of the required number of samples per period of the signal.\nThis is relevant only for resamplingSVstream algorithm. For other algorithms, this value is ignored.'), ...
                        'position',  uigrid_position(uig));

    uig.row = uig.row + 1; % --------------- row 6 calc+help
    uig.col = 1;
    % button Calculate
    b_calc = uicontrol (f_main, ...
                        'tag',      'b_calc', ...
                        'string',    'Calculate', ...
                        'callback',  @b_calc_callback, ...
                        'units',     'characters', ...
                        'tooltipstring', sprintf('Start the calculations.\nFill all inputs before pushing this button.'), ...
                        'position',  uigrid_position(uig, 3));

    uig.col = uig.col + 3;
    % button Help
    b_help = uicontrol (f_main, ...
                        'tag',      'b_help', ...
                        'string',    'Help', ...
                        'callback',  @b_help_callback, ...
                        'units',     'characters', ...
                        'tooltipstring', sprintf('Show help in web browser.'), ...
                        'position',  uigrid_position(uig));
    uig.row = uig.row + 1; % --------------- row 7 acknowledgement
    uig.col = 1;
    t_ack = uicontrol(f_main, ...
                        'tag',      't_ack', ...
                        'Style',    'text', ...
                        'string',   sprintf('The project 21NRM02 Digital-IT has received funding from the European Partnership on Metrology,\nco-financed from the European Union’s Horizon Europe Research and Innovation Programme and by the Participating States.'), ...
                        'units',    'characters', ...
                        'fontsize', 8, ...
                        'horizontalalignment', 'left', ...
                        'position', uigrid_position(uig, 3));
    uig.col = uig.col + 3;

    % show welcome message about successful install if required:
    if welcome_message
        msgbox(sprintf('Both QWTB and DigitalIT algorithms now seems to be working.\nIn the GUI window, you can press button `Calculate` and the example data will be processed.'));
    end

    %% list ui elements to be shown for actual algorithms %<<<3
    udata.show_for_alg{1} = [...
        t_srmethod, ...
        p_srmethod, ...
        t_srd, ...
        i_srd, ...
        ];
    udata.show_for_alg{2} = [...
        t_rsmaxaerr, ...
        i_rsmaxaerr, ...
        t_rsspp, ...
        i_rsspp, ...
        ];

    %% show/hide ui elements depending on selected algorithm %<<<3
    algvalue = find(strcmpi(udata.alg, udata.CONST_available_algorithms));
    if isempty(algvalue); algvalue = 1; end
    vis = {'off' 'on'};
    for j = 1:numel(udata.show_for_alg)
        for k = 1:numel(udata.show_for_alg{j})
            set(udata.show_for_alg{j}(k), 'visible', vis{(j == algvalue) + 1});
        end
    end
end % function make_gui

function position = uigrid_position(uig, varargin) %<<<2
% calculates proper values for position of ui elements.
% first input - See definition of uig structure in make_gui()
% second input - optional multiplier for width
    if nargin == 1
        width_multiple = 1;
    else
        width_multiple = varargin{1};
    end
    left   = uig.col_off + (uig.col - 1).*uig.col_step;
    bottom = uig.total_height - (uig.row_off + uig.row.*uig.row_step);
    width  = width_multiple.*uig.col_step - uig.col_off;
    height = uig.row_step - uig.row_off;
    position = [left, bottom, width, height];
end % function uigrid_position

function set_udata_to_pref() %<<<2
% saves user data structure to user preferences
    global GUIname
    global udata
    setpref(GUIname, 'udata', udata);
end % function

function get_udata_from_pref() %<<<2
% loads user data structure from user preferences and ensure all fields exists
% with at least nominal values
% default values are also defined here
    global GUIname
    global udata

    if ispref(GUIname, 'udata')
        % load user preferences
        udataprefs = getpref(GUIname, 'udata');
        fnames = fieldnames(udata);
        % go through all fieldnames that:
        %   1, does not start with CONST prefix
        %   2, are present in both udata and udataprefs
        for j = 1:numel(fnames)
            fname = fnames{j};
            if not(strcmp(fname( 1:min(5, numel(fname)) ), 'CONST'))
                if and(isfield(udata, fname), isfield(udataprefs, fname))
                    % user preference exist, use it:
                    udata.(fname) = udataprefs.(fname);
                else
                    % user prefence does not exist, set to empty string:
                    udata.(fname) = '';
                end
            end
        end % for
    end % if ispref

    % default values if empty data:
    if isempty(udata.alg)
        udata.alg = udata.CONST_available_algorithms{1};
    end
    if isempty(find(strcmpi(udata.alg, udata.CONST_available_algorithms)))
        % in case of bad data in preferences
        udata.alg = udata.CONST_available_algorithms{1};
    end
    if isempty(udata.datafile)
        udata.datafile = 'testdata_simple_csv_fs=4000_f=49.9-50.csv';
    end
    if not(isnumeric(udata.split))
        udata.split = 1;
    end
    if not(isnumeric(udata.fs))
        udata.fs = 4000;
    end
    if not(isnumeric(udata.fest))
        udata.fest = 50;
    end
    if not(isnumeric(udata.srd))
        udata.srd = 1;
    end
    if isempty(udata.srmethod)
        udata.srmethod = udata.CONST_srmethod{1};
    end
    if isempty(find(strcmpi(udata.srmethod, udata.CONST_srmethod)))
        % in case of bad data in preferences
        udata.srmethod = udata.CONST_srmethod{1};
    end
    if not(isnumeric(udata.rsmaxaerr))
        udata.rsmaxaerr = 50e-6;
    end
    if not(isnumeric(udata.rsspp))
        udata.rsspp = 256;
    end
end % function

function b_datafile_callback(~, ~) %<<<2
% What happens when button 'Select datafile..' is pressed
% show filepath dialog

    t_datafile = find_h_by_tag('t_datafile');
    datafile = get(t_datafile, 'string');

    if not(isempty(datafile))
        [DIR, ~, ~] = fileparts(datafile);
    else
        DIR = pwd;
    end
    fn = fullfile(DIR, '*.*'); % open all types of files
    [fname, fpath, ~] = uigetfile(fn, ...
                                       'Select file with sampled data', ...
                                       datafile, ...
                                       'MultiSelect', 'off');
    if ischar(fname)
        % cancel was not selected
        set(t_datafile, 'string', fullfile(fpath, fname))
    end
end % function

function b_calc_callback(~, ~) %<<<2
% What happens when button Calculate is pressed
% get inputs, check inputs, runs calculation if inputs ok
    global udata

    % check inputs
    % udata.alg
    algvalue = get(find_h_by_tag('p_alg'), 'value');
    udata.alg = udata.CONST_available_algorithms{algvalue};
    % udata.datafile
    datafile = get(find_h_by_tag('t_datafile'), 'string');
    if not(exist(datafile, 'file'))
        msgbox(['The filename `' datafile '` does not exist!'], ...
               'Input error', ...
               'modal');
        return
    end
    udata.datafile = datafile;
    % udata.split
    split = str2num(get(find_h_by_tag('i_split'), 'string'));
    if (isempty(split) || split < 0)
        msgbox('The input `Split by (s)` must contain a non-negative real number!', ...
               'Input error', ...
               'modal');
        return
    end
    udata.split = split;
    % udata.fs
    fs = str2num(get(find_h_by_tag('i_fs'), 'string'));
    if (isempty(fs) || fs < 0)
        msgbox('The input `Sampling f (Hz)` must contain a positive real number!', ...
               'Input error', ...
               'modal');
        return
    end
    udata.fs = fs;
    % udata.fest
    fest = str2num(get(find_h_by_tag('i_fest'), 'string'));
    if (isempty(fest) || fest <= 0)
        msgbox('The input `Signal frequency (Hz)` must contain a positive real number!', ...
               'Input error', ...
               'modal');
        return
    end
    udata.fest = fest;
    % udata.srmethod
    srmethodvalue = get(find_h_by_tag('p_srmethod'), 'value');
    udata.srmethod = udata.CONST_srmethod{srmethodvalue};
    % udata.srd
    srd = str2num(get(find_h_by_tag('i_srd'), 'string'));
    tmperr = 0;
    if (isempty(srd) || srd <= 0)
        tmperr = 1;
    end
    if srd > 0
        if fix(srd) ~= srd
            tmperr = 1;
        end
    end
    if tmperr
        msgbox('The input `Denominator` must contain a positive real integer!', ...
               'Input error', ...
               'modal');
        return
    end
    udata.srd = srd;
    % udata.rsmaxaerr
    rsmaxaerr = str2num(get(find_h_by_tag('i_rsmaxaerr'), 'string'));
    if (isempty(rsmaxaerr) || rsmaxaerr < 0)
        msgbox('The input `Maximum relative amplitude error` must contain a non-negative real number!', ...
               'Input error', ...
               'modal');
        return
    end
    udata.rsmaxaerr = rsmaxaerr;
    % udata.rsspp
    rsspp = str2num(get(find_h_by_tag('i_rsspp'), 'string'));
    tmperr = 0;
    if (isempty(rsspp) || rsspp <= 0)
        tmperr = 1;
    end
    if rsspp > 0
        if fix(rsspp) ~= rsspp
            tmperr = 1;
        end
    end
    if tmperr
        msgbox('The input `Samples per period of the signal` must contain a positive integer number!', ...
               'Input error', ...
               'modal');
        return
    end
    udata.rsspp = rsspp;

    %% All ok, save gui setup & run calculation
    set_udata_to_pref();
    proc_SAMMU_waveform(udata)

end % function b_calc_callback

function b_help_callback(~, ~) %<<<2
% What happens when button Help is pressed
% open web page, hardcoded
    web('https://github.com/KaeroDot/EPMDigitalITsw/blob/main/gui/proc_SAMMU_waveform_gui_help.md', '-browser')
end % function b_help_callback

function b_alg_callback(~, ~) %<<<2
    % used to show/hide ui elements depending on selected algorithm
    global udata
    vis = {'off' 'on'};
    algvalue = get(find_h_by_tag('p_alg'), 'value');
    for j = 1:numel(udata.show_for_alg)
        for k = 1:numel(udata.show_for_alg{j})
            set(udata.show_for_alg{j}(k), 'visible', vis{(j == algvalue) + 1});
        end
    end
end % function b_alg_callback(~, ~)

function b_pcapconvert_callback(~, ~) %<<<2
    % shows subGUI for conversion of pcap files
    global udata
    create_pcap_GUI();
end % function b_pcapconvert_callback(~, ~)

function h = find_h_by_tag(tag, fig) %<<<2
% finds handle to uicontrol defined by a value in tag
% if second input is ommited, current figure is supposed
    if not(exist('fig', 'var'))
        % search in current figure
        fig = gcbf();
    end
    children = get(fig, 'children');
    for j = 1:numel(children)
        ch_tag = get(children(j), 'tag');
        if strcmp(ch_tag, tag)
            h = children(j);
            return
        end
    end
    error(['GUI error: uicontrol with specified tag `' tag '` was not found!'])
end % function

%% functions for subGUI pcap conversion %<<<1
function create_pcap_GUI() %<<<2
% subGUIfunction
    % globals
    global pcapGUIname; % name of the GUI
    global udata;    % structure with user input data
    global f_main;   % main GUI figure handle
    global f_pcap;   % subGUI figure handle

    % Define constants
    pcapGUIname = 'pcap converter';
    udata.pcap_datafile = '50Hz.pcapng'; % pcap file with sampled data

    %% Define grid for uicontrols and gui dimensions %<<<3
    % grid properties for the uicontrols:
    uig.row_step = 3; % grid size of rows of ui controls
    uig.row_off = 1; % offset of rows of ui controls
    uig.col_step = 28; % grid size of columns of ui controls
    uig.col_off = 1; % offset of columns of ui controls
    uig.total_width = 113; % total width of the gui window
    uig.total_height = 14; % total height of the gui window
    uig.row = 1; % index of row of ui controls
    uig.col = 1; % index of column of ui controls

    %% create gui window %<<<3
    % Because of matlab, figure instead of uifigure must be used
    % (matlab cannot set property units in uifigure)
    f_pcap = figure('name',        pcapGUIname, ...
                        'tag',          'f', ...
                        'toolbar',      'none', ...
                        'menubar',      'none', ...
                        'units',        'characters', ...
                        'windowstyle',  'normal');
    % Logically this subGUI window should be modal, but it interferes with open
    % file dialog that is also modal but 'lesser modal'

    % Set size of the GUI without changing the initial position given by
    % operating system:
    pos = get(f_pcap, 'position');
    set(f_pcap, 'position', [pos(1) ...
                             pos(2)-(uig.total_height - pos(4)) ...
                             uig.total_width ...
                             uig.total_height]);

    %% Create ui controls %<<<3
    % All controls must be children of f_pcap, otherwise automatic searching for
    % handles of uicontrols find_h_by_tag() will not work!
    uig.row = 1; % --------------- row 1 file input
    uig.col = 1;
    % button Filename
    b_pcap_datafile = uicontrol (f_pcap, ...
                        'tag',      'b_pcap_datafile', ...
                        'string',   'Select pcap datafile..', ...
                        'callback', @b_pcap_datafile_callback, ...
                        'units',    'characters', ...
                        'tooltipstring', 'Open file dialog to select a pcap file with the sampled values.', ...
                        'position', uigrid_position(uig));
    uig.col = uig.col + 1;
    % label for filename
    t_pcap_datafile = uicontrol(f_pcap, ...
                        'tag',      't_pcap_datafile', ...
                        'Style',    'text', ...
                        'string',   udata.pcap_datafile, ...
                        'units',    'characters', ...
                        'horizontalalignment',  'left', ...
                        'tooltipstring', 'pcap file with the sampled data.', ...
                        'position',  uigrid_position(uig, 3));
    uig.row = uig.row + 1; % --------------- row 2 button read MAC addresses button
    uig.col = 1;
    % button read MAC
    b_pcap_readmac = uicontrol (f_pcap, ...
                        'tag',      'b_pcap_readmac', ...
                        'string',   'Read MAC addresses from pcap file..', ...
                        'callback', @b_pcap_readmac_callback, ...
                        'units',    'characters', ...
                        'tooltipstring', 'Read MAC addresses from the selected pcap file.', ...
                        'position', uigrid_position(uig, 3));
    uig.row = uig.row + 1; % --------------- row 3 source destinations lists
    uig.col = 1;
    % label for source MACs
    t_pcap_sourcemac = uicontrol(f_pcap, ...
                        'tag',      't_pcap_sourcemac', ...
                        'Style',    'text', ...
                        'string',   'Source MAC address:', ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % listbox with source MACs
    p_pcap_sourcemac = uicontrol(f_pcap, ...
                        'tag',      'p_pcap_sourcemac', ...
                        'Style',    'popupmenu', ...
                        'string',   '', ...
                        'callback', @b_pcap_source_callback, ...
                        'value',    1, ...
                        'units',    'characters', ...
                        'tooltipstring', 'Select source MAC address.', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % label for destination MAC
    t_pcap_destmac = uicontrol(f_pcap, ...
                        'tag',      't_pcap_destmac', ...
                        'Style',    'text', ...
                        'string',   sprintf('Destination MAC address:'), ...
                        'units',    'characters', ...
                        'position',  uigrid_position(uig));
    uig.col = uig.col + 1;
    % listbox with destination MACs
    p_pcap_destmac = uicontrol(f_pcap, ...
                        'tag',      'p_pcap_destmac', ...
                        'Style',    'popupmenu', ...
                        'string',   '', ...
                        'callback', @b_pcap_dest_callback, ...
                        'value',    1, ...
                        'units',    'characters', ...
                        'tooltipstring', 'Select source MAC address.', ...
                        'position',  uigrid_position(uig));
    uig.row = uig.row + 1; % --------------- row 4 quantity list, convert button
    uig.col = 1;
    % button Convert
    b_pcap_convert = uicontrol (f_pcap, ...
                        'tag',      'b_pcap_convert', ...
                        'string',    'Convert', ...
                        'callback',  @b_pcap_convert_callback, ...
                        'units',     'characters', ...
                        'tooltipstring', sprintf('Convert pcap file to csv'), ...
                        'position',  uigrid_position(uig, 3));
    uig.col = uig.col + 3;
    % button Help
    b_pcap_help = uicontrol (f_pcap, ...
                        'tag',      'b_pcap_help', ...
                        'string',    'Help', ...
                        'callback',  @b_pcap_help_callback, ...
                        'units',     'characters', ...
                        'tooltipstring', sprintf('Show help in web browser'), ...
                        'position',  uigrid_position(uig));

    % finalize subGUI window %<<<3
    % change color of the figure background to distinct from main GUI window
    set(f_pcap, 'color', '#FFF5DA');
    % force f_pcap window to be shown on top of main GUI figure
    figure(f_pcap)

end % function create_pcap_GUI()

function b_pcap_datafile_callback(~, ~) %<<<2
% What happens when button 'Select pcap datafile..' is pressed
% show filepath dialog

    t_datafile = find_h_by_tag('t_pcap_datafile');
    datafile = get(t_datafile, 'string');

    if not(isempty(datafile))
        [DIR, ~, ~] = fileparts(datafile);
    else
        DIR = pwd;
    end
    fn = fullfile(DIR, '*.*'); % open all types of files
    [fname, fpath, ~] = uigetfile(fn, ...
                                       'Select pcap file with sampled data', ...
                                       datafile, ...
                                       'MultiSelect', 'off');
    if ischar(fname)
        % cancel was not selected
        set(t_datafile, 'string', fullfile(fpath, fname))
    end
end % function b_pcap_datafile_callback

function b_pcap_readmac_callback(~, ~) %<<<2
% What happens when user selects button read MAC addresses
    % find tshark binary
    tsharkPath = get_tshark_binary_path();
    if isempty(tsharkPath)
        msgbox(sprintf('tshark was not found.\nWireshark has to be installed on your computer to get this working.'));
    end

    pcapPath = get(find_h_by_tag('t_pcap_datafile'), 'string');
    if not(exist(pcapPath, 'file'))
        msgbox(['The filename `' pcapPath '` does not exist!'], ...
               'Input error', ...
               'modal');
        return
    end

    % load MAC addresses
    h_msgbox = msgbox(sprintf('Running tshark to scan for all MAC addresses in the pcap file, please wait.\nThis can take MANY minutes for pcap files of GB size!\nThis message will close when finished.'));
    [sourceMacsCell, destMacsCell] = get_macs_from_pcap(pcapPath, tsharkPath, 1, 1);
    if ishandle(h_msgbox)
        close(h_msgbox);
    end
    if isempty(sourceMacsCell)
        msgbox('Source MAC addresses were not found.')
    end
    if isempty(destMacsCell)
        msgbox('Destination MAC addresses were not found.')
    end

    % fill in MAC addresses into listboxes
    set(find_h_by_tag('p_pcap_sourcemac'), 'string', sourceMacsCell)
    set(find_h_by_tag('p_pcap_destmac'), 'string', destMacsCell)

end % function b_pcap_readmac_callback(~, ~)

function b_pcap_source_callback(~, ~) %<<<2
% What happens when user select source MAC address
end % function b_pcap_souce_callback(~, ~)

function b_pcap_dest_callback(~, ~) %<<<2
% What happens when user select destination MAC address
end % function b_pcap_souce_callback(~, ~)

function b_pcap_quant(~, ~) %<<<2
% What happens when user select a quantity
end % function b_pcap_quant(~, ~)

function b_pcap_convert_callback(~, ~) %<<<2
% What happens when user selects button Convert pcap file
    global udata;    % structure with user input data
    global f_main;   % main GUI figure handle
    global f_pcap;   % subGUI figure handle

    % find tshark binary
    tsharkPath = get_tshark_binary_path();
    if isempty(tsharkPath)
        msgbox(sprintf('tshark was not found.\nWireshark has to be installed on your computer to get this working.'));
    end

    % get pcap file name and check if exist
    pcapPath = get(find_h_by_tag('t_pcap_datafile'), 'string');
    if not(exist(pcapPath, 'file'))
        msgbox(['The filename `' datafile '` does not exist!'], ...
               'Input error', ...
               'modal');
        return
    end

    % get MAC addresses
    sourceMAC = get(find_h_by_tag('p_pcap_sourcemac'), 'string');
    destMAC = get(find_h_by_tag('p_pcap_destmac'), 'string');
    % multiple - get cell
    if not(isempty(sourceMAC))
        sourceMAC = sourceMAC(get(find_h_by_tag('p_pcap_sourcemac'), 'value'));
    end
    if not(isempty(destMAC))
        destMAC = destMAC(get(find_h_by_tag('p_pcap_destmac'), 'value'));
    end

    % check if MACs are not empty
    if or(isempty(sourceMAC), isempty(destMAC))
        msgbox('The source or destination MAC address is empty! You have first to "Read MAC addresses from pcap file".')
        return
    end

    % All ok, save gui setup
    set_udata_to_pref();

    % run conversion using tshark
    h_msgbox = msgbox(sprintf('Running tshark to convert pcap format into csv, please wait.\nThis can take many minutes for pcap files of GB size!\nThis message will close when finished.'));
    [Time, Counters, Data, tmpPath] = get_data_from_pcap(pcapPath, sourceMAC{1}, destMAC{1}, tsharkPath, 1, 1);
    if isempty(Time)
        msgbox('Conversion failed.')
        return
    end

    % Write all quantities to csv sheets:
    filenametomain = '';        % filename that will be put into main GUI data file input
    for j = 1:size(Data, 2)
        ASDUnumber = floor((j-1)/8) + 1;
        quantity = udata.CONST_pcap_quantities{rem(j, 8) + 1};

        [DIR, NAME, EXT] = fileparts(tmpPath);
        fn = fullfile(DIR, NAME);
        fn = [fn '.ASDU_' num2str(ASDUnumber) '_' quantity '.csv'];
        dlmwrite(fn, Data(:, j));
        if strcmp(quantity, 'U1')
            filenametomain = fn;
        end
    end % for

    % close message box:
    if ishandle(h_msgbox)
        close(h_msgbox);
    end

    % message finished:
    msgbox(sprintf('pcap file was converted.\nFor selected MAC addresses, %d ASDU units were found. Each quantity (I0, I1, ..., U3) was saved into a separate .csv file. File for the U1 voltage will be preselected in the main window.', ...
        ASDUnumber));

    % add U1 file to the main GUI:
    set(find_h_by_tag('t_datafile', f_main), 'string', filenametomain);

    % close subGUI
    close(f_pcap)
end % function b_pcap_convert_callback(~, ~)

function b_pcap_help_callback(~, ~) %<<<2
% What happens when button Help is pressed
% open web page, hardcoded
    web('https://github.com/KaeroDot/EPMDigitalITsw/blob/main/gui/proc_SAMMU_waveform_gui_help.md', '-browser')
    % XXX fix to proper section of the help
end % function b_pcap_help_callback(~, ~)

%% functions for data processing %<<<1
function y = load_datafile(filename) %<<<2
% loads data from a datafile. several types supported.

    % Try to find out datafile type %<<<3
    % extension:
    [DIR, NAME, EXT] = fileparts(filename);
    % if mat - just load
    % if simple csv - just load
    % if csv from pcap file exported by wireshark - csvload, and remove all lines where only zeros
    try
        if strcmpi(EXT, '.mat')
            % mat file
            disp('Identified simple mat file.')
            y = load(filename);
        elseif strcmpi(EXT, '.csv')
            % csv file
            pcapfile = 0; % flag if csv comes from pcap file exported by wireshark
            % Read first line, if contains proper header, consider as pcap
            % output, otherwise consider as simple csv:
            fid = fopen(filename);
            l = fgetl(fid);
            fclose(fid);
            H = textscan(l, '%s', 'Delimiter', ',');
            if not(isempty(H{1}))
                % pcap file exported from Wireshark starts with sequence: "No."
                if strcmpi(H{1}{1}, '"No."')
                    pcapfile = 1;
                end
            end
            if pcapfile
                disp('Identified csv file with output from Wireshark.')
                y = load_pcap_csv_file(filename);
                % datafile records must be in rows - one row is one record, more rows means
                % more signals! however csv files are in collumns, so make transposition:
                y = y';
            else
                % csv file is not output from pcap file exported by wireshark, it is
                % probably simple csv file
                disp('Identified simple csv file.')
                y = load(filename);
                % datafile records must be in rows - one row is one record, more rows means
                % more signals! however csv files are in collumns, so make transposition:
                y = y';
            end
        else
            error('Type of the datafile not supported. Please read documentation.')
        end % if strcmpi(EXT,
    catch ERR
        errormsg = sprintf('Error: Trying to load data file `%s` resulted in following error:\n%s', udata.datafile, ERR.message);
        errmsg(errormsg);
        error(errormsg);
    end % try_catch

    % check loaded data:
    if isempty(y)
        errormsg = sprintf('Error: No data in data file `%s`.', udata.datafile);
        errmsg(errormsg);
        error(errormsg);
    end
    if not(isnumeric(y))
        errormsg = sprintf('Error: data in data file `%s` are not numeric.', udata.datafile);
        errmsg(errormsg);
        error(errormsg);
    end

    disp(sprintf('Size of data is: % d waveform(s), %d samples in each waveform.', size(y, 1), size(y, 2)))
end % function load_datafile

function y = load_pcap_csv_file(filename) %<<<2
% loads csv file generated by wireshark exporting pcap file to csv
    % load as csv:
    d = csvread(filename);
    % remove all lines that contains only zeros
    sums = sum(d, 2); % sums by rows
    idx = sums ~= 0; % indexes of rows with zero sum
    d = d(idx, :); % remove lines with zero sum
    % get only waveforms:
    y = d(:, 12:end); % XXX is 12 correct value? what if empty?
end

function proc_SAMMU_waveform(udata) %<<<2
    %% Globals %<<<3
    global user_cancel; % flag that user canceled calculations
    user_cancel = 0;

            % %% Check inputs  %<<<3
            % XXX maybe elsewhere. Inputs from GUI are already checked
            % errmsg = '';
            % if not(ischar(datafile))
            %     error('proc_SAMMU_waveform: The first input argument must be a string with valid file path to the measured data!');
            % end
            % if not(exist(datafile))
            %     error('proc_SAMMU_waveform: The data file not found!');
            % end
            %
            % % check algorithm? this can delay everything XXX
            %
            % if not(isnumeric(split))
            %     error('proc_SAMMU_waveform: Split must be a number!')
            % end
            % if split < 0
            %     error('proc_SAMMU_waveform: Split must be a non-negative number!')
            % end

    %% load datafile %<<<3
    % (datafile records must be in rows - one row is one record, more rows means
    % more signals!)
    y = load_datafile(udata.datafile);
        % % test data, only for DEBUG:
        % split = 3/50 % in seconds
        % DI.fs.v = 4e3;
        % t = [0:1/4000:5];
        % f = linspace(49.9, 50.1, numel(t));
        % y = 1.3.*sin(2.*pi.*f.*t + 0.2.*pi);
        % y = y + normrnd(0, 1e-1, size(y));
        % y = [y; 1.*sin(2.*pi.*f.*t)];
        % DI.fest.v = 50;

    waveforms = size(y, 1); % number of waveforms in the data
    samples = size(y, 2); % number of samples in the record
    udata.waveforms = waveforms;
    % set other properties:
    DI.fs.v = udata.fs;
    DI.Ts.v = 1./udata.fs;
    DI.fest.v = udata.fest;
    DI.method.v = udata.srmethod;
    DI.D.v = udata.srd;
    DI.max_rel_A_err.v = udata.rsmaxaerr;
    DI.SPP.v = udata.rsspp;

    %% Process the data %<<<3
    samples_in_period = DI.fs.v./DI.fest.v;
    % check if signal got at least one period of the sample:
    if samples < samples_in_period
        errormsg = sprintf('Error: Data does not contain even single period of the signal, aborting. Samples in the record: %d. Samples in one period of the signal: %d', samples, samples_in_period);
        errmsg(errormsg);
        error(errormsg);
    end

    % data will be split into this number of sections: 'split_sections'
    comment = '';
    if udata.split == 0
        % no splitting
        samples_in_section = samples;
        split_sections = 1; % only one section with whole signal
    else
        % splitting
        samples_in_section = floor(DI.fs.v .* udata.split);
        split_sections = ceil(samples ./ samples_in_section);
        % check if last section got at least one period of the signal:
        if mod(samples, samples_in_section) < samples_in_period
            % Last section got less samples than one period of the signal
            comment = sprintf('\nLast section got less samples than one signal period and will be discarded.');
            split_sections = split_sections - 1;
        else
            comment = '';
        end
    end

    % create wait bar to visualize progress of the calculations
    h_wb = waitbar(0, ...
                   sprintf('Calculating section %d / %d.%s', 0, split_sections, comment), ...
                   'createcancelbtn', ...
                   @waitbar_cancel_callback);

   %% for all sections calcualte %<<<3
    for j = 1 : split_sections
       % for all waveforms calcualte
       for k = 1 : waveforms
            % update waitbar
            waitbar(j./split_sections, h_wb, sprintf('Calculating section %d / %d. %s', j, split_sections, comment));
            % indexes of the data start/end of the actual section:
            st = 1 + (j-1).*samples_in_section;
            en = j.*samples_in_section;
            if (st > samples)
                % some error, stop for loop:
                break
            end
            if (en > samples)
                % last section can contain less data than all other sections:
                en = samples;
            end
            % cut the data:
            DI.y.v = y(k, st : en);
            DI.y.v = DI.y.v(:)';
            DIcell{k, j} = DI; % store inputs for reference
            % calculate
            [DOmain{k, j}, DOspectrum{k, j}] = calculate(DI, udata.alg);
            % if canceled (user_cancel can be called by a waitbar callback
            % function):
            if user_cancel
                % quit this script
                % in matlab, close(waitbar_handle) does not work. One have to use delete.
                delete(h_wb);
                return
            end
        end % for k
    end % for j

    % close waitbar:
    % in matlab, close(waitbar_handle) does not work. One have to use delete.
    delete(h_wb);

    % plot estimated amplitudes, phases, frequencies of the main component:
    present_results(DOmain, DOspectrum, DIcell, y, udata);

end % function proc_SAMMU_waveform

function waitbar_cancel_callback(varargin) %<<<2
    global user_cancel
    user_cancel = 1;
end % function

function [main, ResampledSignalSpectrum] = calculate(DI, algid) %<<<2
% Calculate result
        % XXX disable qwtb checks for all loops but first one

    % First make proper estimate using the PSFE
    FrequencyEstimate = qwtb('PSFE', DI);
    DI.fest.v = FrequencyEstimate.f.v;

    if strcmp(algid, 'PSFE>SplineResample>FFT')
        ResampledSignal = qwtb('SplineResample', DI);
    elseif strcmp(algid, 'PSFE>resampleSVstream>FFT')
        ResampledSignal = qwtb('resamplingSVstream', DI);
    elseif
        error('proc_SAMMU_waveform_gui: mismatch in selected algorithm. Please ask author to fix this.')
    end

    % get resampled spectrum using simple FFT (rectangle window):
    ResampledSignal.window.v = 'rect';
    ResampledSignalSpectrum = qwtb('SP-WFFT', ResampledSignal);

    % Find highest peak and record amplitudes evaluated by rectangular FFT for
    % all available harmonics:
    idx = find(ResampledSignalSpectrum.A.v == max(ResampledSignalSpectrum.A.v));
    if isempty(idx)
        main.f.v = NaN;
        main.A.v = NaN;
        main.ph.v = NaN;
    end
    idx = idx(1);
    main.f.v = FrequencyEstimate.f.v;
    main.A.v = ResampledSignalSpectrum.A.v(idx);
    main.ph.v = ResampledSignalSpectrum.ph.v(idx);
end % function calculate

function present_results(DOmain, DOspectrum, DI, y, udata) %<<<2
% Show figures with calculated data and save results to a file
    [DIR, NAME, ~] = fileparts(udata.datafile);
    % save results
    save([fullfile(DIR, NAME) '-results.mat'], 'DOmain', 'DOspectrum', 'DI', 'y', 'udata');

    % make figures
    % prepare legend:
    for j = 1:udata.waveforms
        leg{j} = sprintf('wavewform %d', j);
    end % for j

    ffreq = figure;
    % becuase of dumb matlab, one have to do it part by part:
    tmp = [DOmain{:}];
    tmp = [tmp.f];
    tmp = [tmp.v];
    tmp = reshape(tmp, udata.waveforms, []);
    % prepare xaxis:
    % (add half of the split time to plot values in the 'middle' of the split
    % time region)
    t = udata.split .* [0 : 1 : size(tmp, 2) - 1] + udata.split./2;
    t = repmat(t, udata.waveforms, 1);
    plot(t', tmp', '-x');
    title(sprintf('Main signal frequency\n%s\n%s', udata.datafile, udata.alg), 'interpreter', 'none');
    xlabel('time (s)');
    ylabel('frequency (Hz)');
    legend(leg);

    famp = figure;
    % becuase of dumb matlab, one have to do it part by part:
    tmp = [DOmain{:}];
    tmp = [tmp.A];
    tmp = [tmp.v];
    tmp = reshape(tmp, udata.waveforms, []);
    plot(t', tmp', '-x');
    title(sprintf('Main signal amplitude\n%s\n%s', udata.datafile, udata.alg), 'interpreter', 'none');
    xlabel('time (s)');
    ylabel('amplitude (V)');
    legend(leg);

    fph = figure;
    % becuase of dumb matlab, one have to do it part by part:
    tmp = [DOmain{:}];
    tmp = [tmp.ph];
    tmp = [tmp.v];
    tmp = reshape(tmp, udata.waveforms, []);
    plot(t', tmp', '-x');
    title(sprintf('Main signal phase\n%s\n%s', udata.datafile, udata.alg), 'interpreter', 'none');
    xlabel('time (s)');
    ylabel('phase (rad)');
    legend(leg);

    % save figures
    saveas(ffreq, [fullfile(DIR, NAME) '-frequency.fig']);
    saveas(ffreq, [fullfile(DIR, NAME) '-frequency.png']);
    saveas(famp, [fullfile(DIR, NAME) '-amplitude.fig']);
    saveas(famp, [fullfile(DIR, NAME) '-amplitude.png']);
    saveas(fph, [fullfile(DIR, NAME) '-phase.fig']);
    saveas(fph, [fullfile(DIR, NAME) '-phase.png']);
end % function present_results

%% functions for pcap converting %<<<1

function [Time, Counters, Data, tmpFile] = get_data_from_pcap(pcapPath, sourceMac, destMac, tsharkPath, skip_if_exist, verbose) %<<<1
% Read sampled values from pcap file for selected source and destination.
% Returns Time vector, Counters matrix with numner of collumns equal to the
% number of ASDUs (Application Specific Data Unit), Data with current and
% voltage collumns for each ASDU (I0, I1, I2, I3, U0, U1, U2, U3), and file path
% of the temporary file with all data as exported by tshark.

    % Comment on functionality ---------------------- %<<<2
    % One could process output of tshark command directly without using
    % temporary files, unfortunately a large output can fail, mostly when
    % done second time. Therefore temporary files are always used.

    % Initialization ---------------------- %<<<2
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

    % Create a name of the temporary file
    tmpFile = sprintf('%s.data_src_%s_dst_%s.txt', ...
        pcapPath, ...
        strrep(sourceMac, ':', ''), ...
        strrep(destMac, ':', ''));

    % tshark data covnerting ---------------------- %<<<2
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

    % loading temporary file ---------------------- %<<<2
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

end % function

function [sourceMacsCell, destMacsCell]= get_macs_from_pcap(pcapPath, tsharkPath, skip_if_exist, verbose) %<<<1
% Scan pcap file for MAC addresses of sources and destinations using tshark.
% Return MAC addresses as cell of strings. The MAC addresses are saved into
% temporary files and can be retrieved again by setting skip_if_exist to
% positive value. The reason is the tshark can take up to 5 minutes of scanning
% for 1.5 GB long pcap file, and this has to be done twice for sources and
% destinations.

    % Initialization ---------------------- %<<<2
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

    % Comment on functionality ---------------------- %<<<2
    % One could process output of tshark command directly, as in following
    % commented lines, uncfortunately such a large output can fail, mostly when
    % done second time. Therefore temporary files are used.
        % cmd = sprintf('"%s" -r "%s" -Y "eth.type == 0x88ba" -T fields -e eth.src > aaa.txt', ...
        %     tsharkPath, ...
        %     pcapPath);
        % [status, output] = system(cmd);
        % sourceMacsCell = strsplit(strtrim(output), sprintf('\n')); % parse output XXX this takes too long for 1.5 GB files - more than 5 minutes
        % sourceMacsCell = unique(sourceMacsCell, 'stable');  % get only unique values and keep order

    % Search for MACs ---------------------- %<<<2
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

    % create outputs ---------------------- %<<<2
    sourceMacsCell = macsCell{1};
    destMacsCell = macsCell{2};

end % function

function tsharkPath = get_tshark_binary_path(verbose) %<<<1
% Finds path to the tshark binary and returns full path and name. Works on both
% unix and windows systems.

    % Initialization ---------------------- %<<<2
    % verbose variable is not mandatory:
    if not(exist('verbose', 'var'))
        verbose = 0;
    end
    verbose = not(not(verbose));    % ensure logical

    % Constants ---------------------- %<<<2
    % binary of tshark in windows:
    winTsharkBinaryFilename = 'tshark.exe';
    % registry keys to search for Wireshark installation in windows:
    winWiresharkRegisteryKeys = {
        'HKLM\SOFTWARE\Wireshark', ...
        'HKLM\SOFTWARE\WOW6432Node\Wireshark'
    };

    tsharkPath = '';  % Default to empty if not found

    % Find tshark path  ---------------------- %<<<2
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
