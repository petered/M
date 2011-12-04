A=Nodelings();

sz=[40 40];
[x y]=meshgrid(1:sz(1),1:sz(2));
A.loc=[x(:) y(:)];

ix=sub2ind(sz,x(:),y(:));
for i=1:sz(1)-1
    for j=1:sz(2)-1
       ix=sub2ind(sz,i,j);
       below=sub2ind(sz,i+1,j);
       right=sub2ind(sz,i,j+1);
       A.settarg(ix,1,[below right]);
    end
end
A.settarg(1,0,1);   % Ignition...
A.settarg(1,1,[1; A.gettarg(1,1)]);   % Gas...

A.count=zeros(prod(sz),1);