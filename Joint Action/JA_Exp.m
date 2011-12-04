classdef JA_Exp < Viewer
    
    properties (SetObservable)
        
        J=JointAction.empty; % Joint Action Experiment Array
        
        S=Subject.empty; % Subject Array
        
        info;   % General Info on file
        
        date;   % Date
                
    end
    
    
    methods % Menu Items
        
        function A=JA_Exp
            
            A.saveprompt=true;
            
        end
                        
        function StartUp(A)
            
            killprevious=false;
            while true
                res=inputdlg({'Filename:' 'Date:' 'Info:'},'New Experement Set',[1 1 2],{'' datestr(clock) ''});
                if isempty(res), return; end;

                % Pick where to save
                
                [defdir existsyet]=A.defaultDir;
                res4=questdlg(sprintf('Save in default directory?:\n  "%s"',defdir),'Where to save?','Yes, There','No, Somewhere Else','Cancel','Yes, There');
                switch res4
                    case 'Yes, There'
                        if ~existsyet, mkdir(defdir); end
                        direct=defdir;
                    case 'No, Somewhere Else'
                        if existsyet, cd(defdir); end
                        direct=uigetdir;
                        if isempty(direct), return; end
                    case 'Cancel'
                        return;
                end
                cd(direct);
                
                % Make sure you're not overwriting any previous files, or
                % if you are, you know about it.
                noflylist=strcat([direct filesep res{1}],{'.mat' '.xls'});
                if any(cellfun(@(x)exist(x,'file'),noflylist))
                    txt=['It Appears a file of the same name "' res{1} '" has previously '...
                        'been created in this directory.  The old file will be '...
                        'overwritten if you keep the same name!'];
                    res2=questdlg(txt,'File-Name Conflict','Overwrite','Change Name','Cancel','Change Name');
                    switch res2
                        case 'Overwrite'
                            res2=questdlg(sprintf('You Absolutely Sure?  If the old %s contained any data it''s gone after this.',res{1}),...
                                'Confirm Overwrite','Yes','No','No');
                            switch res2
                                case 'Yes', 
                                    killprevious=true;
                                    break;
                                case 'No', continue;
                            end
                        case 'Cancel';
                            return;                  
                    end
                else
                    break;
                end
            end
            
            % Set saving location (see superclass Viewer) and other info
            A.saveloc=[direct filesep res{1} '.mat'];
            A.date=res{2};
            A.info=res{3};
                        
            if killprevious 
                delete(A.MATurl);
                delete(A.XLSurl);
            end
            
            A.Save;
            
            A.menu;
            
        end
        
        function menu(A)
            A.menu4(sprintf('%s\nOptions',A.filename),{'New_Subject','View_Subjects','New_Experiment','View_Experiments','View_Spreadsheet','Show_Info','Regenerate_Spreadsheet','Add_Note','Edit_Config'}); 
            
        end
        
        function Show_Info(A)
            [direct file]=A.getDir;
            txt=sprintf('Name: %s\nCreated: %s\nDirectory: %s\n========\nFurther Info:\n--------\n%s\n',file,A.date,direct,A.info);
            helpdlg(txt,'Info');                
        end
        
        function New_Subject(A)
            
           N=find(cellfun(@(x)~isempty(x),{1 A.S.number}),1,'last');
           A.Make_Subjects(N);
            
        end
        
        function stillcool=Make_Subjects(A,numbers)
            stillcool=true;
            
            if ~exist('numbers','var') % Default to UI
                numbers=str2num(input('Subject number(s) to add: ','s'));
            end
            
            N=length(A.S);
            if max(numbers)>N
               A.S(max(numbers))=Subject;  % Extend array to accomidate
            end
                        
            for i=numbers
               stillcool=A.S(i).inputInfo(i);
               if ~stillcool, break; end
            end
            
            
        end
        
        function New_Experiment(A)
            %% Make it
            N=length(A.J)+1;
            Jt=JointAction;
            allisclair=Jt.New_Experiment(A,N);
            if ~allisclair, 
                fprintf '== Cancelled ==\n\n'
                return; 
            end
                                             
            %% Run It
            h = msgbox('Click to begin Experiment'); uiwait(h);
            try
                Jt.RunRun;
            catch ME
                disp '===Error in Running=='                
                disp(ME.getReport('extended'));
                disp =====================
                res=questdlg(sprintf('Error in running experiment %g\n---------------\n%s\n---------------\nYou can keep the results anyway or cancel the experiment',N,ME.message),...
                    'Error','Keep','Cancel','Keep');
                switch res
                    case 'Cancel'
                        fprintf('Experiment %g Cancelled.  Results not saved.\n',N);
                    	return;
                end
            end
            
            %% Write It
            
            Jt.WriteToExcel(A.S,A.XLSurl,A.XLSline);
%             while true
%                 [status M]=Jt.WriteToExcel(A.S,A.XLSurl,A.XLSline);
%                 if status, break;
%                 else
%                     txt=sprintf(['Write failed with message\n------\n%s\n-----\n'...
%                         'It may be that you have the excel file open in another window.  '...
%                         'If so, close the window and try again.  Otherwise, you can cancel '...
%                         'the write, or cancel the whole experiment (data won''t be recorded)'], M.message);
%                     res=questdlg(txt,'Write Failed','Try Again','Cancel Write','Cancel Experiment','Try Again');
%                     switch res
%                         case 'Cancel Write'
%                             break;
%                         case 'Cancel Experiment'
%                             fprintf ('== Experiment %g Cancelled ==\n\n',N);
%                             return;    
%                     end
%                 end
%             end
                
            %% Add it and save
            
            A.J(N)=Jt; 
            A.Save;
            
            fprintf ('== Experiment %g Complete ==\n\n',N)
            
            
        end
                
        function View_Experiments(A)
            A.F.viewStruct(A.J)
        end
        
        function View_Subjects(A)
            A.F.viewStruct(A.S)
        end
        
        function View_Spreadsheet(A)
           if ispc
               if ~exist(A.XLSurl,'file')
                   errordlg('The XLS file doesn''t exist yet.  Click "Reenerate Spreadsheet" to make it');
               else
                    winopen(A.XLSurl); 
               end
           else
               disp 'Sorry, this feature only works with Windows.  You''ll have to open it yourself.'
           end
        end
        
        function LoadUp(A)
            % Default Loading-startup function.  Called after load.
            
            A.menu;
                        
        end
                
        function Add_Note(A)
            
            res=inputdlg('Note','Notes can be viewed in "View Info',3);
            if isempty(res), return; end
            
            A.info=sprintf('%s\n%s',A.info,res{1});
            
            
        end
                
    end  
        
    methods % Output and I/O
                 
        function [dir file]=getDir(A)           
            
            [dir file]=fileparts(A.saveloc); % See Viewer Class
        end
                
        function Regenerate_Spreadsheet(A)
            Lines=cumsum([2 cellfun(@length,{A.J.SubjNo})]);
            
            if isempty(A.J)
                JJ=JointAction;
                JJ.WriteToExcel(A.S,A.XLSurl,2);
            end
            
            for i=1:length(A.J)
                status=A.J(i).WriteToExcel(A.S,A.XLSurl,Lines(i));
                if ~status, break; end
            end
            
        end
        
        function url=XLSurl(A)
            sloc=A.saveloc;
            if length(sloc)<4
                error('Seems something is wrong with the save location.  Ask Peter');
            end
            
            % Strip off the ".mat", change to ".xls"
            url=[sloc(1:end-4) '.xls'];
        end
        
        function url=MATurl(A)
            url=[A.dir filesep A.filename '.mat'];

        end
                
        function L=XLSline(A) % Next line to be filled
            L=length([A.J.SubjNo])+2;
        end
                
    end
    
    methods (Static)
        
        function [defdir existsyet]=defaultDir
            % Give default directory and determine whether it exists yet.
            
            defdir=fileparts(mfilename('fullpath'));
            defdir=[defdir(1:find(defdir==filesep,1,'last')) 'JA Experiments'];
            
            if isdir(defdir), existsyet=true;
            else existsyet=false;
            end
            
        end
        
        function Edit_Config
           
           disp 'Showing Configuration File.  Remember to save any changes before running!';
           edit JA_Configure;
            
        end
    end
    
    methods % Obselete, Scheduled for demolition
    
        function C=makeXLS(A)
            % Probably Obselete
            
            cd (A.dir);
                        
            [H titles]=MakeHeaderCell(A);
            D=MakeDataCell(A);
            
            if size(H,1)~=size(D,1)
                error 'Whoops! Header and data cells have different sizes.  Need to fix this'
            end
            
            
            disp 'Writing to Excel File....'
            
            cd(A.dir);
            xlsx_name=[A.filename '.xls'];
            
            
            sheetlist={'Reactiontimes' 'Stimuli' 'Blocknumber' 'Correct' 'Error' 'NoReaction'};
            
            
            for i=1:length(sheetlist)
                [SUCCESS,MESSAGE]=xlswrite(xlsx_name,titles,sheetlist{i});
                [SUCCESS,MESSAGE]=xlswrite(xlsx_name,[H D(:,:,1)],sheetlist{i},['A2:A',size(H,1)+1]);
                if SUCCESS==1, disp([sheetlist{i} ' OK!']); else disp([sheetlist{i} ' FAILED!']);end;
                
            end
            
            % Writing to Excel file and display message
            [SUCCESS,MESSAGE]=xlswrite(xlsx_name,[H D(:,:,1)],'Reactiontimes',['A',int2str(subject)]);
            if SUCCESS==1 disp('Reactiontimes OK!'); else disp('Reactiontimes FAILED!');end;
            [SUCCESS,MESSAGE]=xlswrite(xlsx_name,data(subject,:,2),'Stimuli',['A',int2str(subject)]);
            if SUCCESS==1 disp('Stimuli OK!'); else disp('Simuli FAILED!');end;
            [SUCCESS,MESSAGE]=xlswrite(xlsx_name,data(subject,:,3),'Blocknumber',['A',int2str(subject)]);
            if SUCCESS==1 disp('Blocknumber OK!'); else disp('Blocknumber FAILED!');end;
            [SUCCESS,MESSAGE]=xlswrite(xlsx_name,data(subject,:,4),'Correct',['A',int2str(subject)]);
            if SUCCESS==1 disp('Correct OK!'); else disp('Correct FAILED!');end;
            [SUCCESS,MESSAGE]=xlswrite(xlsx_name,data(subject,:,5),'Error',['A',int2str(subject)]);
            if SUCCESS==1 disp('Error OK!'); else disp('Error FAILED!');end;
            [SUCCESS,MESSAGE]=xlswrite(xlsx_name,data(subject,:,6),'NoReaction',['A',int2str(subject)]);
            if SUCCESS==1 disp('NoReaction OK!'); else disp('NoReaction FAILED!');end;

        
        end % Scheduled for demolition
                      
        function [C titles]=MakeHeaderCell(A)
            
            % Numbers of subjects in each
            
            nos=arrayfun(@(x) length(x.SubjNo),A.J);
            
            
            C=cell(sum(nos),7);
            ES=A.ExpSubjectList;
            for i=1:size(ES,1)
                
                e=ES(i,1);
                s=ES(i,2);
                
                Sij=A.S(ES(i,2));
%                 if ~isequal(Sij.number, A.J(e).SubjNo(s))
%                     error('Subject number does not match index!');
%                 end                    


                C(i,:)={A.J(e).ExpNo , A.J(e).cond , A.J(e).group , A.J(e).position , Sij.number, Sij.gender , Sij.birthday};                    
                titles={'Experiment' 'Condition' 'Group' 'Position' 'Subject' 'Gender' 'Birthdate'};
            end
            
        end % Scheduled for demolition
        
        function C=MakeDataCell(A)
            
            nos=arrayfun(@(x) length(x.SubjNo),A.J);
            
            
            ES=A.ExpSubjectList;
            C=cell(size(ES,1),length(A.J(1).times),6);
            for i=1:length(nos)
                JJ=A.J(ES(i,1));
                C(i:i+nos(i)-1,:,:)=num2cell(cat(3,JJ.times,JJ.stim,JJ.block,JJ.correct,JJ.error,JJ.noreaction));
            end
            
            
        end % Scheduled for demolition
        
        function ES=ExpSubjectList(A)
            % ES will be an Nx2 matrix,
            % 1st column: Experiment Number
            % 2nd Column: Subject Number
                        
            
            
            exps={A.J.ExpNo};
            subj={A.J.SubjNo};
            nos=cellfun(@(x) length(x),subj,'UniformOutput',false); % Numbers of subjects
            
            exps=cellfun(@(ex,no) repmat(ex,[1 no]), exps,nos,'UniformOutput',false);
            
            ES=cell2mat([exps; subj])';
            
            
        end % Scheduled for demolition
                  
    
    end
    
end