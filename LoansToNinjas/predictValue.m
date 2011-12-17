function pred=predictValue(history,memory,steps,discount)
    % Make a prediction of an asset value.  Given a timeseries come up with
    % an expected value and expected standard deviation.
    %
    % history is a vector of past values
    % memory is the time-constant of memory
    % steps is the number of steps to predict
    % discount (optional) is the discount rate to apply to these future values.
    %
    % Basically, the prediction is that the asset will keep increasing in
    % value by the geometric mean.  
    
    gd=history(2:end)./history(1:end-1);
    
    w=exp((-length(gd)+1:0)/memory);
    
    meanrate=exp(sum(w.*log(gd))/sum(w));

    pred=history(end)*meanrate.^(1:steps);
    
    if exist('discount','var')
        pred=pred./(1+discount).^(1:steps);
    end
    
end