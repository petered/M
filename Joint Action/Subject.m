classdef Subject < handle
   properties
       
       number;      % Note: If subject has not been added yet, this will be empty.
       birthday;
       gender;
       
       
       
   end
    
   methods
       
       
       function status=inputInfo(S,number)
           
           status=false;
               
           if ~isempty(S.number)
                res=questdlg(sprintf('Warning: Subject %g already exists! Overwrite?',number),'title','Yes','No','No');
                switch res
                    case 'No'
                        return;
                end
           end         

           fprintf('  --Subject %g, enter info:--\n',number);

           while true


               birth=S.enterfield('  Birthday',@(x)length(x)==6,'Birthday bust be 6-digit number');

               gen=S.enterfield('  Gender(m/f/?)',@(x)any(strcmpi(x,{'m','f','?'})), 'Gender must be m/f/?');

               txt=sprintf('Subject %g:\nBirthday: %s\nGender:%s\n',number,birth,gen);

               res=questdlg(txt,'Confirmation','Confirm','Re-Enter','Cancel','Confirm');
                switch res
                    case 'Re-Enter'
                        disp '--Re-Enter Subject Data:--'
                    case 'Cancel'
                        disp '  -- Cancelled --'
                        return;
                    case 'Confirm'
                        break;
                end 

           end              

           % Confirm!
           S.number=number;
           S.birthday=birth;
           S.gender=gen;
           fprintf('  --Subject %g created--\n',number);
           status=true;
       end
       
       
       function fld=enterfield(S,FieldName,CriterionFun,CriterionDesc)
           % Ensures Correct entering of field info
           good=false;
           while ~good
                fld=input([FieldName ': '],'s');
                if CriterionFun(fld)
                    good=true;
                else
                    disp(['xxx-' CriterionDesc '   Enter again!']);
                end
           end
           
           
       end
              
       
   end
    
    
end