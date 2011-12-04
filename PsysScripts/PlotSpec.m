function h=PlotSpec(x,fs,window,color)
% A handy spectum plotter for your basic spectum plotting needs.  If x is a
% matrix, it'll be read columnwise.
% Example function calls:
% PlotSpec(x,fs)
% PlotSpec(x,fs,window)
% PlotSpec(x,fs,window,color)
% PlotSpec(x,fs,[],color)
% h=PlotSpec(x,fs,...)

dim=find(size(x)~=1,1); 
if isempty(dim),dim=1;end

if ~exist('fs','var')||isempty(fs), fs=2; xlab='frequency (normalized to Nyquist)'; 
else xlab='frequency (Hz)'; 
end % Representing 2*nyquist

if (sum(size(x)>1)>1)
    x=(x-repmat(mean(x),[size(x,1) 1]))./repmat(std(x),[size(x,1) 1]);
end
X=abs(fftshift(fft(x),dim));

f=((1:length(X))-1-length(X)/2)*fs/length(X);

if exist('color','var')&&~isempty(color)
    h=plot(f,X,'color',color);
else
    h=plot(f,X);
end



if exist('window','var')&&~isempty(window), 
    if strcmpi(window,'+'), set(gca,'XLim',[0 fs/2]); 
    else set(gca,'XLim',window); 
    end
end


xlabel(xlab)
ylabel('normalized magnitide')
end 

