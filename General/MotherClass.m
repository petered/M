classdef MotherClass < Viewer
% This very generic class has the task of sorting through a bunch of
% experiments, running some kind of procedure on them, and saving the
% results to file.  
%
% The first step is to load a list of files using the "Get_Files" method.
% This will allow you to specify a search path, and find files within that
% path.
%
% Next you can partition the fileset into groups using the "Get_Groups"
% method.  These groups will be used as the basis for comparing different
% experiment types.
%
% "Edit_Procedure" allows you to create, edit or load a procedure file. The
% Procedure file is a special M-file with takes an element of the "Info"
% Structure as an input and creates an elecment of the "Ex" structure as an
% output.  
%
% "Run" allows you to select groups and run the procedure on them.  It does
% this by going through the elements of the "Info" structure array and
% feeding them into each procedure.  (See More on Info Structure below)
%
% "View_Output" allows the results of the analysis to be viewed.  
%
% "save" saves this MotherClass object, with all files, results, etc
% stored in it.
%
% "load" loads a previously saved object of this class.
%
% --------------------------------
% 
% Properties
%
% files  : List of files in this object
%
% Info   : Structure array containing info for this object.  Each element 
%          of this array corresponds to a file.  By default, 
%          this will contain "file", the filename, as one of its fields.  
%          "Add Info" allows you to add additional fields to the Info.
%
% Procedure: String or function handle specifying the procedure to be run
%          in analysis.  It must be made according to a specific template,
%          taking an element of the Info Structure as an Input, and
%          producing a structure output, which will become an element of
%          the "Ex" structure.
%
% Ex:      Structure array containing results of running Procedure on Info
%          array.  Again, each element of this array corresponds to a file.
%
% groups:  Array of indeces representing the group number for each file.
%          Each element of groups corresponds to a file.
%
% names:   Names of each group in "groups".  Length of names should be the 
%          length of unique(M.groups).
%
    
    properties
                        
        files;              % Cell array of file names, same length as PF.
        
        Info;               % Structure array containing experiment Info
        
        InfoProcedure       % Procedure for loading additional info from files.
        
        Ex=struct([]);      % Structure array of experiments, same length as PF.
        
        Procedure;          % Function describing procedure to run.
        
        groups;             % Array the same length as files, indicating condition groups
        names;              % Names corresponding to each group
        
    end
      
    methods % Main Methods
                
        function M=MotherClass(GUI)
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
            
            M.Ex=struct('whatajoke',repmat({[]},[1 length(M.files)]));
            M.Ex=rmfield(M.Ex,'whatajoke');
            
            
            
            % Check for existing results and clear Ex
            if ~isempty(M.Ex)
                switch questdlg(['Warning: There are existing results in '...
                        'your "Ex" structure.  If you proceed now without '...
                        'saving these will be lost'],'Warning','Proceed Anyway',...
                        'Save Existing','Cancel','Proceed Anyway');
                    case 'Save Existing'
                        M.save;
                        return;
                    case 'Cancel'
                        return;
                end
            end
            M.Ex=struct([]);
            
                        
            % Check for Procedure
            if isempty(M.Procedure)
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
                    
                    Exp=M.Procedure(M.Info(i));

                    % Copy fields to structure.
                    fld=fields(Exp);
                    for j=1:length(fld)
                       M.Ex(i).(fld{j})=Exp.(fld{j}); 
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
          
        function save(M)
            % Save this object
            
            [filename pathname]=uiputfile('*.mat');
            if ~filename, return; end
            
            save([pathname filename],'M');
            
        end
        
        function load(M)
            % Load an object from file.
            
            [filename pathname]=uigetfile('*.mat','Open MAT-file containing MotherClass Object');
            S=uiimport(filename);
            
            fld=fields(S);
            if length(fld)>1
                error('You can only select one object');
            end
            
            
            if strcmp(class(S.(fld{1})),class(M))
               s=dbstack;
               S=superclasses(M);
               if strfind(s(2).name,S{1}), close all hidden, reopen=true;
               else reopen=false;
               end
               delete(M); 
               evalin('base',['load ''' filename ''' ' fld{1} ]);
               if reopen
                  pause(1);
                  evalin('base',[fld{1} '.TheMenu']); 
               end
            else
                error('The object loaded must be of class %s',class(M));
               
            end
                        
            
            
%             evalin('base','M=S.M);
            
%             fld=fields(S);
%             if ~strcmp(class(S.(fld{1})),class(M))
%                 errordlg('This is not an object of class %s.',class(M));
%                 return;
%             end
%             
%             sss=superclasses(M);
%             P=setdiff(properties(M),properties(sss{1}));
%             for i=1:length(P)
%                 M.(P{i})=S.(fld{1}).(P{i});
%             end
                        
        end
        
    end
    
    methods % Get/set
        
        function set.files(A,val)
            % When files is reset, so everything else
            if ~isempty(val);
                A.Info=cell2struct(val,'file',2);
            else A.Info=[];
            end
            A.groups=zeros(length(val),1);
            A.names={'Default Group'};
            A.Ex=[];
            A.files=val;            
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