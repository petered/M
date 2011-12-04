function mutantLena=cartIM2polIM(Lena)
% Transforms an image from cartesian to polar, mapping from the center.

C=size(Lena(:,:,1))/2+.5;
D=min(C);

% Set up the transformation
radii=(linspace(0,1,D+1).^2)*D-1;
angles=linspace(0,2*pi*(D-1)/D,D);
[r ang]=meshgrid(radii,angles);
x=r.*cos(ang)+C(1);
y=r.*sin(ang)+C(2);


% Make the mapping
if size(Lena,3)==1
    mutantLena=interp2(Lena,x,y);
else
    mutantLena=nan([size(x) size(Lena,3)]);
    for i=1:size(Lena,3)
        mutantLena(:,:,i)=interp2(Lena(:,:,i),x,y);
    end
end


end