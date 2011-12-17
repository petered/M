function X=gammaDraw(average,sharpness,N)
% Reparamitrization of gamrnd
%  average defines the mean of the distribution
%  spread defines the shape


X=gamrnd(sharpness,average/sharpness,[1 N]);


end