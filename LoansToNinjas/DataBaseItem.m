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
                    
        copies=struct; % Links to next copies.
                    
    end
    
    methods
        
        
%         function delete(A)
%            
%             p=properties(A);
%             for i=1:length(p)
%                 if ~isobject(A.(p{i}))||isempty(A.(p{i})), continue; end
%                 pi=properties(A.(p{i}));
%                 for j=1:length(pi)
%                     if ~isempty(A.(p{i}).(pi{j}))
%                         [A.(p{i}).(pi{j})]=deal([]);
%                     end
%                 end
%             end
%             
%         end
        
        
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
                copyCode=['c' num2str(typecast(rand,'uint64'))]; 
                
            elseif isa(Ob,'DataBaseItem')
                if isfield(Ob.copies,copyCode),   % If it's been copied already, return the copy
                    B=Ob.copies.(copyCode);
                    return; 
                end
            end
            
            meta=metaclass(Ob);
            pnames=cellfun(@(x)x.Name,meta.Properties,'uniformoutput',false);

            B=eval(class(Ob));
            warning off MATLAB:structOnObject
            S=struct(Ob);
            warning on MATLAB:structOnObject
            pB=fields(S);
            
            Ob.copies.(copyCode)=B;
            B.copyCode=copyCode;
            
            for i=1:length(pB)

                if any(ismember(pB{i},{'copies','copyCode'})), continue; end
                
                whichone=strcmp(pB{i},pnames);

                % Do not copy Transient or Dependent Properties
                if any(whichone) && (meta.Properties{whichone}.Transient || meta.Properties{whichone}.Dependent)
                    continue; 
                end

                val=S.(pB{i});

                if ~isempty(val) && isa(val,'handle')
                    B.(pB{i})=eval(class(val));
                    B.(pB{i})(length(val))=eval(class(val)); % God damn ugly matlab
                    for j=1:length(val)
                        B.(pB{i})(j)=A.copy(val(j),copyCode);
                    end
                else
                    B.(pB{i})=val;
                end      
            end
            
            

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
                
                val=S.(fld{i});
                
                B.distribute(fld{i},val);
                
%                 if isa(val,'function_handle')
%                     temp=S.(fld{i})(N);
%                     temp=num2cell(temp);
%                 elseif isnumeric(val) || islogical(val)
%                     if isscalar(val),
%                         temp=repmat({val},[1 N]);
%                     else
%                         temp=num2cell(S.(fld{i}));
%                     end
%                 elseif iscell(val)
%                     temp=repmat(val,[1 N]);
%                 end
%                 
%                 if ~isempty(temp)
%                     [B.(fld{i})]=temp{:};
%                 end
            end            
        end
        
        function correlate(A,prop1,vec,c,skewed)
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
            
            redrawn=corrLink([A.(prop1)],vec,c,skewed);

            if length(A)==1 && A.initer % If it's an initialization object
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
                assert(any(length(A)==[1 length(B)]),'Seems you''re trying to link %g %ss to %g %ss.  If you''re indending to do it randomly, you''ll need to specify shuffle=true',length(A),class(A),length(B),class(B));
                Asub=A;
                Bsub=B;
            else
                % Randomize A, select subset to link
                count=ceil(f*length(A));
                Asub=permrand(A,count);

                % Get subset of B to link
                if repeatsAllowed
                    ix=ceil(length(B)*rand(1,count));   
                    Bsub=B(ix);
                else
                    assert(count<=length(B),sprintf('You''ve requested %g unique "%s" objects, but only %g are available',count,class(B),length(B)));
                    Bsub=permrand(B,count);
                end
            end
            
            % Make links
            if length(A)==1;
                Asub.(propA)=[Asub.(propA) Bsub];
                if ~isempty(propB)
                    for i=1:length(Bsub)
                        Bsub(i).(propB)=[Bsub(i).(propB) Asub];
                    end
                end
            else
                Bs=num2cell(Bsub);
                [Asub.(propA)]=Bs{:};
                if ~isempty(propB)
                    As=num2cell(Asub);
                    [Bsub.(propB)]=As{:};
                end
            end
            
        end
        
        function A=initializer(A,varargin)
            assert(length(A)==1,'Initializer must be a scalar object!');
            A.initer=true;
            
        end
        
        function distribute(A,prop,varargin)
            % A is an array of objects
            % prop is a property name
            % val is a scalar, vector, or function handle returning a
            %   distrubution of values to be distributed to A.prop
            
            if ischar(prop),prop={prop}; end
            
            assert(length(prop)==length(varargin),'You listed %g properties to fill, but provided %g arguments to fill them with',length(prop),length(varargin));
            
            for i=1:length(prop)
                val=varargin{i};
                if isa(val,'function_handle')
                    temp=val(N);
                    temp=num2cell(temp);
                elseif iscell(val)
                    temp=repmat(val,[1 length(A)]);
                elseif isscalar(val),
                    temp=repmat({val},[1 length(A)]);
                else
                    temp=num2cell(val);
                end

                assert(length(A)==length(temp),'It seems you''re tring to fill a %g-element "%s" array with %g values',length(A),class(A),length(temp));
                if ~isempty(temp)
                    [A.(prop{i})]=temp{:};
                end
            end
            
        end
        
    end
    
    
    
    
    
end