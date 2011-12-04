classdef Example < Viewer
    
   properties (SetObservable)
       foo='Ouch';
   end
   
   methods
       
       function A=Example
          % Insert constructor code here
           
          A.saveprompt=true;
           
       end
       
       
       function StartUp(A) % Do not change name.... called in method "Start" of superclass Viewer
           % Insert Startup options here
                      
           A.menu;
           
       end
       
       function menu(A)
           
           A.menu4([class(A) ' Options'], {'bar','Save','Save_As','Load','Close'});
           
       end
              
       
       function bar(A)
           
           h=helpdlg('Three guys walk into a bar');
           uiwait(h);
           
           h=helpdlg(A.foo);
           uiwait(h);
           
       end
       
       
   end
    
    
    
end