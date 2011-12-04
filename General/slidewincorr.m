function [C tvec lvec]=slidewincorr(x,y,win,maxlags,tstep,cstep)
% Normalized Correlation coefficient between signals x,y in a sliding 
% window with optional lags.
%
% Usage..
% [C tvec lvec]=slidewincorr(x,y,win);
% [C tvec lvec]=slidewincorr(x,y,win,maxlags,tstep,cstep)
%
% Graphically, 
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
% j--->yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
% i------->|========|
% C(i,j) is the normalized correlation coefficient at window-position 
% tvec(i), when the y-signal is shifted by lvec(j).
%
% Inputs
% x,y are the input signals (1-d vectors)
% win is the window width over which to correlate.
% maxlags is the maximum lag to look at (defaults to 0)
% tstep is the number of indeces to jump with each time-step (defaults to 1)
% cstep is the number of indeces to jump with each lag-step (defaults to 1)
%
% Outputs
% C is a matrix where each row is the correlation between a given time 
%   window on and an array of lagged windows on y. and each column is the 
%   correlation of the moving time window for a given lag.  
%   size(C)=[length(tvec) length(lvec)].  C will be nan in places where 
%   there is no valid window (eg if the window is in position 1 on x and 
%   it's a negative lag, it would be outside of the range of y so could not
%   be computed).
% tvec is this array of time-window center positions.
% lvec is this array of lags
%
% example ...
% xx=randn(10000,1);
% yy=[xx(3:5002); randn(5000,1)];
% [C t l]=slidewincorr(xx,yy,1000,10,1);
% imagesc(l,t,C)
% xlabel lag
% ylabel time

%% Setup

if ~isvector(x) || ~isvector(y)
    error('X and Y inputs must be vectors!  What are you doing?');
end

if win<2 || win~=round(win)
    error('input "win" must be an integer greater than 1');
end

x=x(:);
y=y(:);

if ~exist('maxlags','var'), maxlags=0; end
if ~exist('tstep','var'), tstep=1; end
if ~exist('cstep','var'), cstep=1; end


if size(x)~=size(y)
    error('Inputs x and y must be the same size.');
end


tvec=1:tstep:length(x)-win;
lvec=-maxlags:cstep:maxlags;

C=nan(length(tvec),length(lvec));


%% Get 'er done

% Compute pre-steps
[xm xmag]=meanmag(x,win);
[ym ymag]=meanmag(y,win);

fprintf 'Computing slide-win-corr mat...'
ctr=0.1;
for i=1:length(tvec) % For each time-step
    
    % Get a normalized x-vector
    xvec=(x(tvec(i):tvec(i)+win-1)-xm(tvec(i)))/xmag(tvec(i));
    
    for j=1:length(lvec) % For each lag...
        if tvec(i)+lvec(j)>0 && tvec(i)+lvec(j) <= length(y)-win % If lag can go back that far
            
            % Get a normalized y-vector
            yvec= (y(tvec(i)+lvec(j):tvec(i)+win-1+lvec(j))-ym(tvec(i)+lvec(j))) / ymag(tvec(i)+lvec(j));
            
            % Find the correlation
            C(i,j)=sum( xvec .* yvec );
        end
    end
    
    % Indicate progress
    if i/length(tvec)>ctr
        fprintf('%g%%..',ctr*100);
        ctr=ctr+.1;        
    end
    
end

disp Done;

% For the user it's more intuitive for tvec to be the vector of window
% CENTER positions
if nargout>1
    tvec=tvec+ceil(win/2);
end


end

function [mn mag]=meanmag(x,n)
    % Computes roaming mean and magnitude of roaming-mean subtracted
    % vector.  Useful as a pre-step to xcorr measurements.
    
    mn=movsum(x,n)/n;
    
    if nargin>1
        mag=nan(1, length(mn));
        for i=1:length(mn)
            mag(i)=sqrt(sum((x(i:i+n-1)-mn(i)).^2));
        end
    end


end


function x=movsum(x,n)
% Retuurns a block of length length(x)-n+1
% It's just the moving sum on the last n samples.

        
    x=cumsum(x);
        
    x=x(n:end)-[0; x(1:end-n)];

end