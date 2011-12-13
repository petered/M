classdef DataBaseItem<handle
    % Contains a few properties and method useful when dealing with arrays 
    % of linked objects like one would in a relational database.
    %
    % The "init" and "correlate" function are useful for initialization-
    % object arrays.  
    %
    % "init" takes an 'initialization' object of arrays and turns it into 
    %   an array of objects.
    %
    % "correlate" takes arrays from one (or two) initialization objects and
    %   correlates them.
    
    
    properties
       
        id;         % Not used now;  Potentially could be used to reduce 
                    % lookup times for object indeces.  
                    % (because ix=find([A.H==H]) is slow)
        active;
        
        copyCode;   % This code ensures that when doing a deep copy, objects
                    % With cyclic references aren't copied in infinite
                    % loops.
        
        initer;     % Boolean: indicates whether object is an initialization
                    % object.
                    
    end
    
    methods
        
        function remove(A)
            
            
        end
        
        function add(A)
            
            
        end
        
        function B=copy(A,Ob,copyCode)
            % Make a deep copy of the object.  The copyCode stuff is there
            % to make sure circular references don't get copied in infinite
            % loops
            %
            % Peter O'Connor

            if ~exist('Ob','var'), Ob=A; end
            
            % If object's already been copied
            if ~exist('copyCode','var'), 
                Ob.copyCode=now; 
            elseif ismember('DataBaseItem',superclasses(Ob)) && A.copyCode==copyCode,
                B=Ob;
                return; 
            end
            
            
        %     oldstate=A.enableDependency;
        %     A.enableDependency=false;

            meta=metaclass(Ob);

            pnames=cellfun(@(x)x.Name,meta.Properties,'uniformoutput',false);

            B=eval(class(Ob));
            warning off MATLAB:structOnObject
            S=struct(Ob);
            warning on MATLAB:structOnObject
            pB=fields(S);
        %             pB=properties(Ob);
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
                        B.(pB{i})(j)=A.copy(val(j),copyCode);
                    end
                else
                    B.(pB{i})=val;
                end      
            end

            if ismember('DataBaseItem',superclasses(Ob))
                B.copyCode=copyCode;
            end

        %     A.enableDependency=oldstate;       

        end

        
        function A=DataBaseItem(varargin)
            
            if isempty(varargin), return; end
            
            if length(varargin)==1 && strcmp(varargin{1},'init')
                A.initer=true;
                return;
            end
                
                
                
            A.init(varargin{:});
        end
        
        function B=init(A,S,N)
            % S is a structure or object of class A that initializes an
            % object.
            %
            % The fields of S correspond to properties of A;
            % They can consist of:
            % - Scalars: in which case every object is initalized with this value 
            % - Vectors: in which case each element fills the value for a particular object 
            % - Single-argument functions with vector outputs: in which
            %   case values are drawn from these functions (which are PDFs)
            %
            % N is the number to create
            
            if isobject(A)
                cl=class(A);
            else
                cl=A; 
            end
            
            B(N)=eval(cl);
            
            fld=fields(S);
            
            ism=ismember(fld,properties(A));
            assert(all(ism),sprintf('"%s" is not a property of class "%s"',fld{find(ism,1)},cl));
            for i=1:length(fld)
               
                if isa(S.(fld{i}),'function_handle')
                    temp=S.(fld)(N);
                end
                
                if isnumeric(S.(fld{i}))
                    temp=num2cell(S.(fld{i}));
                end
                
                if ~isempty(temp)
                    [B.(fld{i})]=temp{:};
                end
            end            
        end
        
        function correlate(A,prop1,vec,c)
            % Induce a correlation between two properties of an inialization
            % object, by changing prop2 such that it's still pulled from
            % the same distribution, but is now correlated with prop1.
            %
            % This can be used for initialization objects - if two vectors
            % (eg savings and salary) should be correlated, you can enter
            % their name and do it.
            %
            % If the vectors belong to different objects (eg house value
            % and salary), include a second object B.
            %
            % The properties will still roughly the same marginal
            % distributions once this is done.
            
            
            assert(c<=1 && c>=-1,'Correlation must be between -1 and 1');
            
%             if ~exist('A2','var'), A2=A; end
            
            redrawn=corrDist([A.(prop1)],vec,c);

            if A.initer % If it's an initialization object
                A.(prop1)=redrawn;
            else        % If it's a fully matured object array
                redrawn=num2cell(redrawn);
                [A.(prop1)]=redrawn{:};                
            end
                
        end
        
        function Asub=link(A,propA,B,propB,shuffle,f,repeatsAllowed)
            % Randomly link A to B through property propA.  
            % Optionally, reverse-link B through property propB.
            %
            % Return the subset of A that was linked;
            %
            % f is the fraction of A to link.
            %
            % repeatsAllowed is a boolean defining whether to sample
            % linking objects from B with replacement or not.
            %
            % It is assumed that B is a vector of unique objects.
            %
            % 
            
            if ~exist('repeatsAllowed','var'),repeatsAllowed=false; end
            if ~exist('bias','var'), bias=[]; end
            if ~exist('f','var'), f=1; end
            if ~exist('shuffle','var'), shuffle=false; end
            if ~exist('propB','var'), propB=[]; end
            
            if ~shuffle,
                assert(length(A)==length(B));
                Asub=A;
                Bsub=B;
            else
                % Randomize A, select subset to link
                count=ceil(f*length(B));
                Asub=randperm(A,count);

                % Get subset of B to link
                if repeatsAllowed
                    ix=ceil(length(B)*rand(1,count));   
                    Bsub=Asub(ix);
                else
                    assert(length(Asub)>=length(B),'The total number of unique objects requested from B exceeds the available number of objects in B');
                    Bsub=permrand(B,count);
                end
            end
            
            % Make links
            Bs=num2cell(Bsub);
            [Asub.(propA)]=Bs{:};
            if ~isempty(propB)
                As=num2cell(Asub);
                [Bsub.propB]=As{:};
            end
            
        end
        
        function A=initializer(A,varargin)
            assert(length(A)==1,'Initializer must be a scalar object!');
            A.initer=true;
            
        end
        
    end
    
    
    methods (Static)
        
        
        
        
    end
    
    
    
    
end