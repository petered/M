classdef CatInTheStat < Statistician & Viewer
    % This class collects statistics on cats.
    %
    % Just Run: A=CatInTheStat.go; in command line and everything will
    % magically work.
    
    
    properties
        
        C=StimCat.empty;  % Array of Cats
        
        actions=struct('name',{},'fun',{});
        
    end
    
    
    methods
        
        function A=CatInTheStat
            
            A.actions=struct(...
            'name',{
                'Raster'
                'Poissonity'
                'All Signals'
                'Activity'
                'Fano-Factors'
                'Trial Correlations'
                'Neuron Correlations'
                'Renewal Process?'
                'Stats'
                'View Stimulus'
                'Rev-Corr RF Map'
                'Raw Data'
                'Spike Profiles'
                'Files'
                },...
            'fun',{
                @(C)C.S.Plot_Raster 
                @(C)C.S.Plot_Poissonity  
                @(C)C.S.Plot_EveryThing
                @(C)C.S.Plot_Activity
                @(C)C.S.Plot_FanoFactory
                @(C)C.S.Plot_TrialCorr
                @(C)C.S.Plot_NeuronCorr
                @(C)C.S.Plot_Renewal
                @(C)C.S.Plot_Stats
                @(C)C.FC.View_Stimulus
                @(C)C.Shoe_RFs
                @(C)C.S.FC.View
                @(C)C.S.FC.View_Spikes
                @(C)C.S.Plot_FileSummary
                }...
            );
            
        end
        
        function success=loadCats(A)
            
            FC=FelineFileFinder.go('multi');
            
            if FC==0
                success=false;
                return;
            end
            
            k=1;
            hB=waitbar(0,'Loading Cats...');
            for i=1:length(FC)
                try
                    S_=StimCat();
                    S_.GrabCat(FC(i));
                    A.C(k)=S_;           
                    waitbar(k/length(FC),hB,S_.name);
                    k=k+1;
                catch ME
                    fprintf('Loading FileCat "%s" failed with message: \n%s',FC(i).catName,getReport(ME,'extended'));
                    
                end
            end
            delete(hB);
            success=true;         
        end
        
        
        
        
        
    end
    
    
    
    methods (Static)
        
        function A=go
           
            A=CatInTheStat;
            A.loadCats;
            A.GUI;
            
        end
        
    end
    
end