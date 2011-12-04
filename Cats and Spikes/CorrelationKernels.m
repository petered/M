% [xcorr(conv(x,h),conv(y,h)) conv(xcorr(x,y),xcorr(h,h))]


clear;

M=MinistersCat.go;

names={M.E.name};


type=questdlg('Which type of correlation?','Correlation-Type','cells','trials','cells-untrialed','Cancel');



switch type
    case 'trials'
        f=XX('kerncorrTrials');
    case 'cells'
        f=XX('kerncorr');
    case 'cells-untrialed'
        f=XX('kerncorr');
        
        
        for i=1:length(M.E)
            [sp id]=M.E(i).FC.loadSpikeInfo;
            M.E(i).S.T={sp(id==1);sp(id==2)}; 
        end
        begin=max([M.S.starttime]);
        fin=min([M.S.endtime]);
        
        arrayfun(@(SS)SS.cropTimes([begin fin]),M.S);
        
        
        
    otherwise
        disp 'Cancelled'
        return;
end


% f=XX('kerncorr');

figure;
hold all;
widths=logspace(log10(0.001),log10(2),40);

for i=1:length(M.E)
    
    if M.E(i).S.nT==1 && (strcmp(type,'trials') ),
        continue; end
    
%     try

    [r{i} wid{i}]=f(M.S(i),widths);
    
    plot(wid{i},r{i});
%     catch ME
%         disp(getReport(ME));
%     end
end
        
xlabel 'Smoothing Kernel width (s)'

switch type
    case {'cells','cells-untrialed'}
        ylabel 'Correlation';
        title([M.name ' Inter-Cellular Correlation']);
        set(gca,'xscale','log');
    case 'trials'
        ylabel('Correlation');
        title([M.name ' Inter-Trial Correlation']);
        set(gca,'xscale','log');
end

legend(names);