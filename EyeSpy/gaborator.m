function z=gaborator(edge,angle,stretch)
            
    % Defaults
    range=1.5;
    if nargin<3, stretch=3; end

    % Setup transforms
    range=linspace(-range,range,edge);
    [x y]=meshgrid(range,range);
    R=[cosd(angle) -sind(angle); sind(angle) cosd(angle)];

    % First transform
    X=R*[x(:)'; y(:)'];
    C=[1 0; 0 stretch];

    % Then gaussify
    z=reshape(X(2,:).*exp(-sum(X.*(C*X))),size(x));

    % Center and normalize
    z(:)=z(:)-mean(z(:));
    z(:)=z(:)./sum(z(:).^2);

end