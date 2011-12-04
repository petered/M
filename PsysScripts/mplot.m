function [h spacing]=mplot(varargin)
% Like plot, except gives the plotted signals vertical offsets.  Nice if
% you have a whole lot of signals and don't really care about their
% DC-values.
%
%



%% Setup numeric inputs
yD=varargin{1};
if isvector(yD), yD=yD(:); end

if length(varargin)>1 && isnumeric(varargin{2}) % x-data included
   if ~isvector(yD)
       disp 'iplot doesn''t work for non-vector x-data yet..plotting normally'
       hP=plot(varargin{:});
       if nargout>0, varargout{1}=hP; end
       return;
   end
   if ~issorted(yD) % Ach this is O(N), I know, but for consumer-protection's sake.
       disp 'iplot doesn''t work for unsorted x-data yet...plotting normally'
       hP{:}=plot(varargin{:});
       if nargout>0, varargout{1}=hP; end
       return;
   end
   
   xD=yD;
   yD=varargin{2};
   if isvector(yD), yD=yD(:); end
      
   varargin=varargin(3:end);
else                      % x-data not included
   xD=(1:size(yD,1))';
   varargin=varargin(2:end);
end




%%  Setup 


ix=find(strcmpi(varargin,'spacing'),1);
if ~isempty(ix), spacing=varargin{ix+1};
    varargin(ix:ix+1)=[];
else
    q=quickclip(yD(:));
    spacing=diff(q);
end

spacing=-(0:spacing:(size(yD,2)*spacing-.00000000001));

yD=yD+repmat(spacing,[size(yD,1),1]);



hP=plot(xD,yD,varargin{:});
if nargout>0, h=hP; end



end