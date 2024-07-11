function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm windowedRMS.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% Find out which data were supplied:
is_y = isfield(datain, 'y');
is_u = isfield(datain, 'u');
is_i = isfield(datain, 'i');

if all([is_y is_u is_i])
    if calcset.verbose
        disp('QWTB: windowedRMS wrapper: supplied sampled waveforms for both |y| and |u| with |i|. Using |u| and |i|.')
    end
    use_y = 0;
    Record = [datain.u.v(:)'; datain.i.v(:)'];
elseif all([is_u is_i])
    use_y = 0;
    Record = [datain.u.v(:)'; datain.i.v(:)'];
elseif is_y
    use_y = 1;
    Record = datain.y.v;
else
    error('QWTB: windowedRMS wrapper: missing either |y| quantity or both |u| and |i| quantities.')
end

if isfield(datain, 'window')
    win = datain.window.v;
    % all available windows:
    avail_windows = {'hann', 'rect', 'bartlett', 'welch', 'hann', 'hamming', 'blackman', 'BH92', 'flattop', 'HFT70', 'HFT90D', 'HFT95', 'HFT116D', 'HFT144D', 'HFT169D', 'HFT196D', 'HFT223D', 'HFT248D'};
    % check for correct window:
    if ~any( cellfun(@strcmpi, avail_windows, repmat({win}, size(avail_windows))) )
        error(['QWTB: windowedRMS wrapper: unknown window `' win '`. Available windows are: ' strjoin(avail_windows, ', ')]);
    end
else
    datain.window.v = 'blackman';
end

% Call algorithm ---------------------------  %<<<1
% [Result] = GetRMSPw(Record,window_name,SNR)
Result = GetRMSPw(Record, datain.window.v);

% Format output data:  --------------------------- %<<<1
if use_y
    dataout.A.v = Result.Uw;
else
    dataout.U.v = Result.Uw;
    dataout.I.v = Result.Iw;
    dataout.P.v = Result.Pw;
    dataout.S.v = Result.Sw;
    dataout.phi_ef.v = Result.phase;
    dataout.PF.v = cos(dataout.phi_ef.v);
end

end % function
