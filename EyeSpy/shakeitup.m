function sim=shakeitup(im,varargin)
% Modify the image set im by randomly translating/totating by the given
% amount.  

trans=0;    % Translation: 1 is the image size

rot=0;      % Rotation: 2 is randombly distrivuted about the circle

scale=0;    % Scale: 1 is a rendn

for i=1:2:length(varargin)
   switch varargin{i}
       case 'trans'
           trans=varargin{i+1};
       case 'rot'
           rot=varargin{i+1};
       case 'scale'
           scale=varargin{i+1};
       otherwise
           error ('What''s this "%s" shit?',varargin{i});
   end
end

sz=size(im);
[x y]=meshgrid(linspace(-sz(1)/2,sz(1)/2,sz(1)),linspace(-sz(2)/2,sz(2)/2,sz(2)));
xy=[x(:)';y(:)'];


R=@(ang)[cos(ang) -sin(ang);sin(ang) cos(ang)];
S=@(s)[s 0; 0 s];

sim=nan(size(im),class(im));
for i=1:sz(3)
    
    St=S(abs(1+scale*randn));
    Rt=R((rand-.5)*rot*2*pi);
    Tt=repmat([sz(1);sz(2)].*(rand(2,1)-.5)*trans,[1 sz(1)*sz(2)]);
    
    xyt=(St*Rt)*xy+Tt;
    
    
    sim(:,:,i)=interp2(x,y,im(:,:,i),reshape(xyt(1,:),sz(1:2)),reshape(xyt(2,:),sz(1:2)),...
                'linear',0);
    
end


end


function [xt,yt]=coordtrans(x,y,ang)
                
    if ang==0
        xt=x;
        yt=y;
        return;
    end

    R=[cosd(ang) -sind(ang);sind(ang) cosd(ang)];

    X=R*[x(:)';y(:)'];

    xt=reshape(X(1,:),size(x));
    yt=reshape(X(2,:),size(x));

end