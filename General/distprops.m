function mom=distprops(x,nS,jump,rss)
% Returns dimensionless properties of a distrubution.
%
% Inputs:
% x : list of sequential draws from your distribution
% n : number of moments to take
% nS: number of samples of x to take in window
% (jump): number of samples to jump for each (default 1).
%
% Outputs:
% mom : nMoments x nWindows list of moments as they evolve over time.
%       The first moment is the mean, all other moments are moments about
%       the mean.


b=buffer(x(1:nS*floor(length(x)/nS)),nS,nS-jump,'nodelay');

if exist('rss','var')
    bn=nan([size(b),rss]);
    for i=1:size(b,2)
        bn(:,i,:)=reshape(randss(b(:,i),[nS rss]),[nS,1,rss]);
    end
    b=bn;
end

mom(1,:)=std(b)./mean(b);
mom(2,:)=kurtosis(b);
mem(3,:)=




end