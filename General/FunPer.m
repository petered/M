function T=FunPer(x)
% Should hopefully find the fundamental period of a signal (in samples).
% If x is a matrix, it will be read columnwise, with periods of each column
% returned as a row vector.
%
% The fundamental period is defined as the the period corresponding the the
% maximum frequency component which does not have a subharmonic with at
% least half the of the amplitude of that frequency component.
   
%% XCorr Method (not so great)
% maxlag=length(x)/100;
% while 1
%     Xx=xcov(x,maxlag);
%     [bull PK]=findpeaks(Xx(fix(end/2):end));
% 
%     plot(Xx(fix(end/2):end))
%     addline(PK);
% 
%     if length(PK)==1
%         maxlag=2*maxlag;
%     else
%         T=PK(2);
%         break
%     end
% end

%% FFT method (pretty great)
Fx=abs(fft(x));
Fx=Fx(1:floor(end/2));

if isvector(x)&&size(x,2)>2, Fx=Fx'; end

% Remove DC Bias
if size(x,2)>1;
    Fx(1,:)=0;
else % To keep compatibility with single row input.
    Fx(1)=0;
end

% plot(Fx)

bull=max(Fx); 
ix=peakseek(Fx,1,bull/2);
FK=ix(find(ix>median(diff(ix))/2,1));
% 
% while 1
%     if Fx(ceil(FK/2))>Fx(FK)/2
%         FK=ceil(FK/2);
%     else
%         break;
%     end
% end
% 

T=round(length(x)./(FK-1));
    
end