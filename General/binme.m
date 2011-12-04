function TS=binme(T,res,range)

if ~exist('range','var'), range=[min(T)-eps,max(T)+eps]; end

bins=range(1):res:range(2);

TS=histc(T,bins);