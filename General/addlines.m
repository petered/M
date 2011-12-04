function h=addlines(pts,orient,varargin)

% To keep compatibility with older versions
if ~exist('orient','var')
    orient='v';
elseif exist('orient','var') && ~all(orient=='v'|orient=='h')
    varargin=[orient varargin];
    orient='v';
end

if isempty(pts), pts=nan; end % So it still returns a handle

    
pts=pts(:)';

v=[get(gca,'xlim'),get(gca,'ylim')];

pts=repmat(pts,[3 1]);

a=ishold;

hold all
switch orient
    case 'v'
        cycle=[v(3:4) nan]';
        axvals=repmat(cycle,size(pts,2),1);
        pts=pts(:);
        h=plot(pts,axvals,varargin{:});
    case 'h'
        cycle=[v(1:2) nan]';
        axvals=repmat(cycle,size(pts,2),1);
        pts=pts(:);
        h=plot(axvals,pts,varargin{:});
end

if ~a, hold off; end

end