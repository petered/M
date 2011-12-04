classdef CatMaster < Viewer

    properties
                        
        getEx;              % Procedure to get the experiment list
        
        Ex;                 % Array of experiments to run
        
        isvalid;            % Boolean function taking Ex as an input, testing validity
        Ex2Rs;              % Function describing procedure to run.  Must take in and put out an object/struct
        
        Rs;                 % Array of results
        
        groups;             % Array the same length as files, indicating condition groups
        names;              % Names corresponding to each group
        
        storemode='cell';   % How to store results: cell or struct
        
        
    end
      
    
    methods % Inter-cat experiment comparison
        
        function CVScript(A)
            
            % Get List
            len=MinistersCat.ListLength;
            for i=1:len
                M(i)=MinistersCat;
                M(i).GrabCat(i);    
            end
            A.Ex=M;
            A.names={M.name};
            
            % Validation Procedure
            conds={'movies' 'tuning'};
            function valid=validate(M)
                valid=all( ismember(conds,{M(i).E.type}) );
            end
            A.isvalid=@validate;
            
            % Experiment Procedure
            function CV=ExpProc(M)
                % Find coefficient of variation for strongest spiking cell
                % in each condition
                CV=nan(1,length(conds));
                for j=1:length(conds)
                   
                    % Get Experiment for this condition
                    thisone=find(strcmpi({M.E.type},conds{j}),1);

                    % Get index of strognest-spiker
                    powcell=M(i).SpikerRank(true);
                    
                    % Load into Cell
                    CV2=M(i).E(thisone).S.CV2;
                    CV2=median(CV2(:,all(~isnan(CV2))),2);
                    CV(j)=CV2(powcell);
                 end
            end
            A.Ex2Rs=@ExpProc;
            
            
            
            
            
            
            
            
            
        end
        
        
        
        
    end
    
    
    
    
    methods % Main Methods
        
        function M=CatMaster(GUI)
            if exist('GUI','var') && GUI, 
                M.TheMenu; 
            end            
        end
        
        function TheMenu(M)
            
            colordef black
            
            options={'Get_Files','Get_Groups','Get_Info_Procedure','Run_Info','Get_Procedure','Run','View_Output','save','load','help'};
            
            M.menu4('MotherClass Options',options);
            
            
        end
        
        function Get_Files(M,rootpath)
            % Search for files within a directory.
            
            if ~isempty(M.files)
                switch questdlg('This object already contains files.  Clear them?','More files!','Yes','No (add more)','Cancel','No (add more)')
                    case 'Yes'
                        M.files=[];
                    case 'No (add more)'
                        
                    case 'Cancel'
                        return;
                end
            end
            
            if ~exist('rootpath','var'), rootpath=[]; end
            
            files=getfiles(rootpath);
            if isempty(files), return; end
%             
            files=[M.files; files];

            [s ok]=superlistdlg('ListString',files,...
                'PromptString','Select Files of interest',...
                'ListSize',[500 500]);
            
            if ~ok; return; end
            
            M.files=files(s);
                        
        end  
        
        function Get_Info_Procedure(M)
            
            txt=@(name)sprintf([...
                'function Info=%s(files)\n'...
                '%% This file takes in "files", a cell array of file names, and spits\n'...
                '%% out Info, a structure the same length as "files" that will be fed\n'...
                '%% in to the Procedure function.  An example use of this function would\n'...
                '%% be to add ROIs to the input structure before loading files.\n'...
                '%% \n'...
                '%% By default, Info contains one field, ''file'', specifying the filename.\n'...
                '%% The code for this is included below.\n'...
                '\n'...
                'Info=cell2struct(files,''file'',2);\n'...
                '\n'...
                'end'],name);
            
            nameo=M.Edit_Procedure(M.InfoProcedure,txt);
            
            if isempty(nameo), return; end
            
            M.InfoProcedure=str2func(nameo);
            
            
        end
        
        function Run_Info(M)
            
            if isempty(M.InfoProcedure)
                switch questdlg('No Info Procedure exists yet.  Get one now?',...
                        'Info Procedure Needed','Yes','No','Yes')
                    case 'Yes'
                        M.Get_Info_Procedure;
                    case 'No'
                        return;
                end
            end
            
            
                Info=feval(@M.InfoProcedure,M.files);
            
            M.Info=Info;
            if length(M.Info)~=length(M.groups) &&~isempty(M.groups)
                warndlg(['Warning: Your Info structure was not the same '...
                    'length as your list of filenames.  You''ll need to '...
                    'redefine your groups to match the info array.']);
                
                M.groups=[];
            end
            
            
        end
        
        function Get_Groups(M)
            % Partition your set of files into different experimental
            % groups
            
            if isempty(M.Info)
                list=M.files;
            elseif isequal(fields(M.Info),'file');
                % If just the file field exists...
                list={M.Info.file};
            else                
                list=UIfieldselect(M.Info,'Select which field (should contain all strings), you''d like to use to define your files.');
            end
            
            [M.groups M.names]=UImakegroups(list,M.groups,M.names);
            
        end
        
        function Get_Procedure(M)
            
            nl=sprintf('\n');
            txt=@(name)sprintf([...
                'function Ex=%s(In)' nl ...
                '%% The purpose of this function is to extract information from some ' nl...
                '%% existing file, corresponding to one experiment, and return it in ' nl...
                '%% a structure so that the results can be compared to those of other ' nl...
                '%% experiments. ' nl nl...
                '%% "In" is a structure of information coming in.  It can be created ' nl...
                '%%    using MotherClasses "add_input" method.  The field In.file ' nl...
                '%%    will always exist, and will contain the filename for this ' nl...
                '%%    experiment.' nl...
                '%% "Ex" is a structure of information going out.  For easy comparison, ' nl...
                '%%    make fields of Ex 1-D.' nl nl...
                '%% Eg: ' nl ...
                '%% Data=load(In.file,''Data'');  %% Load already-saved data matrix from file.' nl...
                '%% Ex.basemeanmax=max(mean(Data(:,1:10),2),1);' nl nl nl nl nl ...
                'end'],name);
            
            nameo=M.Edit_Procedure(M.Procedure,txt);
            if isempty(nameo), return; end
            
            M.Procedure=str2func(nameo);
                        
        end
        
        function Run(M)
            % Run your selected procedure on the full experiment list or a
            % subset of groups.
                       
            
            % Check for Procedure
            if isempty(M.Ex2Rs)
               errordlg('Can''t Run - you haven''t specified a procedure!'); 
               return;
            end
            
            % Select which groups to run
            if ~isempty(M.groups) && length(M.names)~=1
                [s ok]=listdlg( 'ListString',M.names,...
                                'PromptString','Select groups to run');
                grps=unique(M.groups);
                runners=ismember(M.groups,grps(s));
            else % RUN 'EM ALL!
                runners=true(1,length(M.Info));
            end
            
            % Main loop... runs all experiments
            count=0; errcount=0; total=nnz(runners); 
            warning off 'MATLAB:tex'
            hW=waitbar(0,'Loading files','CreateCancelBtn','setappdata(gcbf,''canceling'',1);');
            valid=nan(1,length(find(runners(:))));
            for i=find(runners(:))'
                
                disp =======================================
                disp(['STARTING FILE ' M.files{i}])  
                disp ------------------------------

                if getappdata(hW,'canceling')
                    delete(hW);
                    error('You, user, decided to quit');
                end
                
                try
                    hW=waitbar(count/total,hW,M.files{i});
                    drawnow;
                    
                    % Test validity
                    if isa(M.isvalid,'function_handle')
                        valid(i)=M.isvalid(Ex(i));
                    end
                    
                    
                    if valid==false
                        fprintf('"%s" was determined to be invalid\.n',M.names{i});
                    else
                        % Get Results
                        Res=M.Ex2Rs(M.Ex(i));
                        % Copy fields to structure.
                        fld=fields(Exp);
                        for j=1:length(fld)
                           M.Rs(i).(fld{j})=Res.(fld{j}); 
                        end
                    
                    end
                                        
                catch ME
                   errcount=errcount+1;
                   disp ==============================
                   disp('Analysis failed:');
                   disp ------------------------------
                   disp(getReport(ME,'extended'))
                   disp ------------------------------
                   disp('We`ll try the next block')
                   disp ==============================
                end
                count=count+1;
                disp =======================================
                
            end
            waitbar(1,hW,sprintf('Completed %g files with %g errors',count,errcount));
            pause(.5);
            delete(hW);
%          
        end
                    
        function View_Output(M)
            % View the results of the Run.
            
            % Data can be represented differently according to type
            C=M.UIgetResults;
            
            % Funciton that will distinguish types
            function T=typedisc(val)
                if ischar(val),
                    T='T';
                elseif isnumeric(val)
                    if isempty(val)
                        T='E';
                    elseif isscalar(val)
                        T='S';
                    elseif isvector(val)
                        T='V';
                    elseif ndims(val)==2
                        T='A';
                    else
                        T='M';
                    end
                else 
                    T='?';
                end
            end
            
            T=cellfun(@typedisc,C);
            
            if any(T=='T')
                disp(C{:});
            elseif ~any(ismember(T,{'V' 'M'})) && any(ismember(T,'S'));
                grouphist(C,M.groups,M.names);
            elseif any(isvector(T))
                vecdiff(C,M.groups,M.names);
            end
            
        end
        
        function [C groups]=UIgetResults(M,form)
            
            if ~exist('form','var'), form='cell'; end
            
            if isempty(M.Ex) || isempty(fields(M.Ex))
                errordlg('No Output is available yet.  Click "Run" to run the data analysis');
                return;
            end
            
            C=UIfieldselect(M.Ex);
            close (gcf);
            
            groups=M.groups;
            
            switch form
                case 'cell', % do nothing
                case 'mat', [C groups]=makecellmat(C,groups);
                case 'struct', C=M.Ex;
                
            end
            
        end
        
        function addInfo(M,arr)
            % Add any info to the Info Structure.  This structure contains
            % all the input to the procedure.  
            
            if ~isempty(M.Info)&& length(M.Info)~=length(arr)
                error('The new info thing must have the same length as the existing Info array!');
            else
                for i=1:length(arr)
                   M.Info(i).(inputname(2))=arr(i);
                end
            end
            
            
        end
        
        function help(M)
            
            help(class(M))
            
            disp =============================
            disp 'Current State of Object:'
            disp -----------------------------
            disp (M)
            disp =============================
            
        end
          
    end
        
    methods (Static=true)
        
        function nameo=Edit_Procedure(Procedure,txt)
            % Find, create, or modify a procedure to run on your dataset.
                
            % txt is a weird little sprintf function that will return the
            % full file text when given filename as the input.
            
            if isempty(Procedure) % If it's empty
                res=questdlg('No procedure exists.','Procedure','Make One','Find One','Cancel','Make One');
            else
                if ischar(Procedure)
                    nameo=Procedure;
                else
                    nameo=func2str(Procedure);
                end
                res=questdlg(['Current Procedure function:' nameo],'Procedure','Edit Current','Find Another','Cancel','Edit Current');
            end

            switch res
                case 'Make One'
                    % Choose a place to put file
                    [file path]=uiputfile('*.m','Place your Procedure file','something_unique');

                    nameo=file(1:find(file=='.')-1);
                    file=[path file];
                    if ~file, nameo=[]; return; end


                    % Open a file at specified location
                    fid=fopen(file,'w');
                    if fid==-1, error(['The system isn''t letting us write to ' fileparts(nameo) '.  Strange']); end

                    

                    fwrite(fid,txt(nameo));

                    fclose(fid);

                    disp 'There.  Now you can build your procedure.  Have fun';

                    


                case 'Find One'
                    file=uigetfile('*.m','Load Procedure');
                    nameo=file(1:find(file=='.')-1);

                    if ~nameo, return; end


                case 'Edit Current'
                    nameo=func2str(Procedure);

                case 'Cancel'
                    nameo=[];
                    return;
            end
            
            if ~isempty(nameo), edit(nameo); end
            
            
        end
        
    end
    
end