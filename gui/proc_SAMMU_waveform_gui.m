function proc_SAMMU_waveform_gui() %<<<1
% main function. checks environment, runs gui
    % Globals
    global GUIname; % name of the GUI
    global udata;    % structure with user input data

    % Define constants
    GUIname = 'proc_SAMMU_waveform_gui';
    udata.available_algorithms = {'SplineResample & FFT'}; % XXX remove? will be as an input?
    udata.alg = ''; % selected algorithm id
    udata.datafile = ''; % file with sampled data
    udata.split = ''; % data split period
    udata.fs = ''; % sampling frequency
    udata.fest = ''; % signal frequency estimate

    % Ensure system is working
    % ensure qwtb path
    qwtb_user_action = ensure_qwtb_path();
    % ensure digit algorithms are available in qwtb
    digit_user_action = ensure_digit_algs();

    if any([qwtb_user_action digit_user_action])
        msgbox(sprintf('Both QWTB and DigitalIT algorithms now seems to be working.\nIn the GUI window, you can press button `Calculate` and the example data will be processed.'));
    end

    % Run the GUI
    make_gui();
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
    setpref (GUIname, 'qwtb_path', qwtb_path)
end % function add_qwtb_path_to_pref

function qwtb_path = get_qwtb_path_from_pref() %<<<2
    global GUIname
    if ispref(GUIname, 'qwtb_path')
        qwtb_path = getpref (GUIname, 'qwtb_path');
        addpath(qwtb_path)
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
        addpath(qwtb_path)
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
        copyfile(fullfile(downloaded_extracted_zip_path, 'gui/testdata_fs=4000_f=49.9-50.csv'), ...
            fullfile(pwd, 'testdata_fs=4000_f=49.9-50.csv'));
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
function make_gui() %<<<2
    %% define globals %<<<3
    global GUIname; % defined in proc_SAMMU_waveform_gui()
    global udata;    % structure with user input data


    %% Define grid for uicontrols and gui dimensions %<<<3
    % grid properties for the uicontrols:
    uig.row_step = 3; % grid size of rows of ui controls
    uig.row_off = 1; % offset of rows of ui controls
    uig.col_step = 20; % grid size of columns of ui controls
    uig.col_off = 1; % offset of columns of ui controls
    uig.total_width = 81; % total width of the gui window
    uig.total_height = 14; % total height of the gui window
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
    uig.row = 1;
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
    uig.row = uig.row + 1;
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
    tmp = find(strcmpi(udata.alg, udata.available_algorithms));
    if isempty(tmp); tmp = 1; end
    p_alg = uicontrol(f_main, ...
                        'tag',      'p_alg', ...
                        'Style',    'popupmenu', ...
                        'string',   udata.available_algorithms, ...
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
    uig.row = uig.row + 1;
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
                        'string',   sprintf('Signal frequency (Hz)\n (estimate)'), ...
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

    uig.row = uig.row + 1;
    uig.col = 1;
    % button Calculate
    b_calc = uicontrol (f_main, ...
                        'tag',      'b_calc', ...
                        'string',    'Calculate', ...
                        'callback',  @b_calc_callback, ...
                        'units',     'characters', ...
                        'tooltipstring', sprintf('Start the calculations.\nFill all inputs before pushing this button.'), ...
                        'position',  uigrid_position(uig, 4));
end

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
    global GUIname
    global udata

    if ispref(GUIname, 'udata')
        udata = getpref(GUIname, 'udata');
    end
    if not(isfield(udata, 'alg'))
        udata.alg = 'SplineResample';
    end
    if not(isfield(udata, 'datafile'))
        udata.datafile = 'testdata_fs=4000_f=49.9-50.csv';
    end
    if not(isfield(udata, 'split'))
        udata.split = 1;
    end
    if not(isfield(udata, 'fs'))
        udata.fs = 4000;
    end
    if not(isfield(udata, 'fest'))
        udata.fest = 50;
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
    [fname, fpath, ~] = uigetfile(DIR, ...
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
    udata.alg = udata.available_algorithms{algvalue};
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

    %% All ok, save gui setup & run calculation
    set_udata_to_pref();
    proc_SAMMU_waveform(udata)

end % function b_calc_callback

function h = find_h_by_tag(tag) %<<<2
% finds handle to uicontrol defined by a value in tag
    f_main = gcbf();
    children = get(f_main, 'children');
    for j = 1:numel(children)
        ch_tag = get(children(j), 'tag');
        if strcmp(ch_tag, tag)
            h = children(j);
            return
        end
    end
    error(['GUI error: uicontrol with specified tag `' tag '` was not found!'])
end % function

%% functions for data processing %<<<1
function proc_SAMMU_waveform(udata) %<<<2
    %% Globals %<<<2
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
    try
        y = load(udata.datafile);
    catch ERR
        errormsg = sprintf('Error: Trying to load data file `%s` resulted in following error:\n%s', udata.datafile, ERR.message);
        errmsg(errormsg);
        error(errormsg);
    end % try_catch
    % check input data:
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
    % set other properties:
    DI.fs.v = udata.fs;
    DI.fest.v = udata.fest;
    % test data, only for DEBUG:
    % split = 3/50 % in seconds
    % DI.fs.v = 4e3;
    % t = [0:1/4000:5];
    % f = linspace(49.9, 50.1, numel(t));
    % y = 1.3.*sin(2.*pi.*f.*t + 0.2.*pi);
    % y = y + normrnd(0, 1e-1, size(y));
    % DI.fest.v = 50;

    %% Process the data %<<<3
    samples_in_period = DI.fs.v./DI.fest.v;
    % check if signal got at least one period of the sample:
    if numel(y) < samples_in_period
        errormsg = sprintf('Error: Data does not contain even single period of the signal, aborting. Samples in data file: %d. Samples in one period of the signal: %d', numel(y), samples_in_period);
        errmsg(errormsg);
        error(errormsg);
    end

    % data will be split into this number of sections: 'split_sections'
    if udata.split == 0
        % no splitting
        samples_in_section = numel(y);
        split_sections = 1; % only one section with whole signal
    else
        % splitting
        samples_in_section = floor(DI.fs.v .* udata.split);
        split_sections = ceil(numel(y) ./ samples_in_section);
        % check if last section got at least one period of the signal:
        if mod(numel(y), samples_in_section) < samples_in_period
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
        % update waitbar
        waitbar(j./split_sections, h_wb, sprintf('Calculating section %d / %d. %s', j, split_sections, comment));
        % indexes of the data start/end of the actual section:
        st = 1 + (j-1).*samples_in_section;
        en = j.*samples_in_section;
        if (st > numel(y))
            % some error, stop for loop:
            break
        end
        if (en > numel(y))
            % last section can contain less data than all other sections:
            en = numel(y);
        end
        % cut the data:
        DI.y.v = y(st : en);
        % calculate
        DO{j} = calculate(DI, udata.alg);
        % if canceled (user_cancel can be called by a waitbar callback
        % function):
        if user_cancel
            % quit this script
            % in matlab, close(waitbar_handle) does not work. One have to use delete.
            delete(h_wb);
            return
        end
    end

    % close waitbar:
    % in matlab, close(waitbar_handle) does not work. One have to use delete.
    delete(h_wb);

    % plot estimated amplitudes, phases, frequencies of the main component:
    present_results(DO, DI, y, udata);

end % function proc_SAMMU_waveform

function waitbar_cancel_callback(varargin) %<<<2
    global user_cancel
    user_cancel = 1;
end % function

function DO = calculate(DI, algid) %<<<2
% Calculate result
        % XXX disable qwtb checks for all loops but first one

    % do resampling:
    ResampledSignal = qwtb('SplineResample', DI); % XXX somehow set other algorithms 

    % get resampled spectrum using simple FFT (rectangle window):
    ResampledSignal.window.v = 'rect';
    ResampledSignalSpectrum = qwtb('SP-WFFT', ResampledSignal);

    % Find highest peak and record amplitudes evaluated by rectangular FFT:
    idx = find(ResampledSignalSpectrum.A.v == max(ResampledSignalSpectrum.A.v));
    DO.A.v = ResampledSignalSpectrum.A.v(idx);
    DO.ph.v = ResampledSignalSpectrum.ph.v(idx);
end % function calculate

function present_results(DO, DI, y, udata) %<<<2
% Show figures with calculated data
    [DIR, NAME, ~] = fileparts(udata.datafile);
    % save results
    save([fullfile(DIR, NAME) '-results.mat'], 'DO', 'DI', 'y', 'udata');
    
    % make figures
    famp = figure;
    % becuase of dumb matlab, one have to do it part by part:
    tmp = [DO{:}];
    tmp = [tmp.A];
    tmp = [tmp.v];
    plot(tmp, '-x');
    title(sprintf('Main signal amplitude\n%s', udata.datafile), 'interpreter', 'none');
    xlabel('section index');
    ylabel('amplitude (V)');

    fph = figure;
    % becuase of dumb matlab, one have to do it part by part:
    tmp = [DO{:}];
    tmp = [tmp.ph];
    tmp = [tmp.v];
    plot(tmp, '-x');
    title(sprintf('Main signal phase\n%s', udata.datafile), 'interpreter', 'none');
    xlabel('section index');
    ylabel('phase (rad)');

    % save figures
    saveas(fph, [fullfile(DIR, NAME) '-amplitude.fig']);
    saveas(fph, [fullfile(DIR, NAME) '-phase.fig']);
end % function present_results

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
