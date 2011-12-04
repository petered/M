classdef CatParliament < Statistician & Viewer
% This class collects statistics on cats.
%
% Just Run: A=CatInTheStat.go; in command line and everything will
% magically work.
    
    
    properties
        
        C=MinistersCat.empty;  % Array of Cats
        
        actions=struct('name',{},'fun',{});
        
    end
    
    
    methods
        
        function A=CatParliament
            
            A.actions=struct(...
            'name',{
                'Raster'
                'All Signals'
                'Trial Correlations'
                'Variance vs Mean'
                'Poissonity'
                'Activity'
                'Fano-Factors'
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
                @(C)C.selCat.S.Plot_Raster 
                @(C)C.selCat.S.Plot_EveryThing
                @(C)C.selCat.S.Plot_TrialCorr
                @(C)C.selCat.S.Plot_MeanVarHist
                @(C)C.selCat.S.Plot_Poissonity  
                @(C)C.selCat.S.Plot_Activity
                @(C)C.selCat.S.Plot_FanoFactory
                @(C)C.selCat.S.Plot_NeuronCorr
                @(C)C.selCat.S.Plot_Renewal
                @(C)C.selCat.S.Plot_Stats
                @(C)C.selCat.FC.View_Stimulus
                @(C)C.selCat.Shoe_RFs
                @(C)C.selCat.S.FC.View
                @(C)C.selCat.S.FC.View_Spikes
                @(C)C.selCat.S.Plot_FileSummary
                }...
            );
            
        end
        
        function success=loadCats(A)
            
            C_=MinistersCat.GiveMeCats(true);
            if isempty(C_)
                success=false;
            else
                A.C=C_;
                success=true;
            end
                
            
        end
        
        function splitCells(A)
            % Split the ministers cats experiments by cell. 
            
            C_=MinistersCat.empty;
            for i=1:length(A.C)
               C_=[C_ A.C(i).splitCells]; %#ok<AGROW>
            end
            A.C=C_;
            
            
        end
        
        function splitTypes(A)
            C_=MinistersCat.empty;
            for i=1:length(A.C)
               C_=[C_ A.C(i).splitTypes]; %#ok<AGROW>
            end
            A.C=C_;
            
        end
        
        function minSpikesFilter(A,count)
            % Allow experiments inwhich for all stimuli, there is at least
            % one cell which has, on average >= "count" spikes per trial.
            
            included_=true(size(A.C));
            for i=1:length(A.C)
                included_(i)=all(arrayfun(@(S)any(mean(S.nS,2)>=count),A.C(i).S));
            end
            A.included=included_;
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