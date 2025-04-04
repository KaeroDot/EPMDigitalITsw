%performs resampling operation
% aleksander.lisowiec@itr.lukasiewicz.gov.pl, 10.07.2024
%takes into account that only every Nint-th sample is non zero and
%that only every Mdec-th sample has to be calculated, hence name fastresample
%inputs
%   x:          sample sequence to be resampled
%   bresampl:   resampling filter (e.g. calculated with dtfir1)
%   Nint:       interpolation coefficient
%   Mdec:       decimation coefficient
%output
%   ydownsample:  resampled x sequence
%   length(ydownsample)=ceiling((length(x)*Nint-length(bresampl))/Mdec)
function [ydownsample] = fastresample(x,bresampl,Nint,Mdec)
        yint=upsample(x,Nint);
        ydowns=[];
        Lbr = length(bresampl);
        outputlength = floor(((length(x)*Nint)-Lbr)/Mdec);
        k=0;
        while k < outputlength + 1
            dj=ceil(k*Mdec/Nint)*Nint-k*Mdec;
            s1 = 0;
            j=k*Mdec;
            indbresampl=1;
            while j < k*Mdec+Lbr-dj
	            s1=s1+yint(j+dj+1)*bresampl(indbresampl+dj);
	            j=j+Nint;
                indbresampl=indbresampl+Nint;
            end
            ydowns=[ydowns,s1];
            k=k+1;
        end
        ydownsample = Nint*ydowns;
end
