%computes a whole M for which the nperperiod number of samples after resampling
%with Nint as interpolation coefficient best renders the whole period of the signal
% aleksander.lisowiec@itr.lukasiewicz.gov.pl, 10.07.2024
function output = factorM(Nint,fline,fs,nperperiod)
    output=round((Nint/nperperiod)*(fs/fline));
end
