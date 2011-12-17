
function B=deepCopy(A,O)
    % Make a deep copy of the object.  The enableDependency stuff is to
    % make sure you aren't running the dependency chain when just
    % trying to copy an object (which can screw things up).
    %
    % Peter O'Connor

    if ~exist('O','var'), O=A; end

%     oldstate=A.enableDependency;
%     A.enableDependency=false;

    meta=metaclass(O);

    pnames=cellfun(@(x)x.Name,meta.Properties,'uniformoutput',false);

    B=eval(class(O));
    warning off MATLAB:structOnObject
    S=struct(O);
    warning on MATLAB:structOnObject
    pB=fields(S);
%             pB=properties(O);
    for i=1:length(pB)

        whichone=strcmp(pB{i},pnames);
        
        % Do not copy Transient or Dependent Properties
        if any(whichone) && (meta.Properties{whichone}.Transient || meta.Properties{whichone}.Dependent)
            continue; 
        end

        val=S.(pB{i});

        if ~isempty(val) && isa(val,'handle')
            B.(pB{i})=eval([class(val) '.empty']); % God damn ugly matlab
            for j=1:length(val)
                B.(pB{i})(j)=A.copy(val(j));
            end
        else
            B.(pB{i})=val;
        end      
    end


%     A.enableDependency=oldstate;       

end
