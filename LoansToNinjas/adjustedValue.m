function adjVal=adjustedValue(cost,discountRate)
% Value is a vector, inwhich each step is the payment made at a certain
% time.  
%
% Discount rate is a scalar, indicating the fraction of decrease in 
% percieved value of a cost paid at each step in the future.
%
% If dt is included, discountRate is taken to be per dt steps,
% eather than per 1-step


multipliers=(1-discountRate).^(0:length(cost)-1);

adjVal=cost(:)'*multipliers(:);



end