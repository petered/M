function pred=predictValue(history,memory,steps)
    % Make a prediction of an asset value.  Given a timeseries come up with
    % an expected value and expected standard deviation.
    %
    % Basically, the prediction is that the asset will keep increasing in
    % value by the geometric mean.  
    
    gd=history(2:end)./history(1:end-1);
    
    w=exp((-length(gd)+1:0)/memory);
    
    meanrate=exp(sum(w.*log(gd))/sum(w));

    pred=history(end)*meanrate.^(1:steps);
    
end