
len=10000;
res=0.001;
nTrials=7;
synchloc=6000;


d=zeros(len,1); d(synchloc)=100;
f12=FiltFT(500*d,.5,1/res); 
f1=FiltFT(500*randn(len,1),.5,1/res)-f12; f1=f1-min(f1);
f2=FiltFT(500*randn(len,1),.5,1/res)-f12; f2=f2-min(f2);



S=SpikeBanhoff;
S.sType='gauss'; S.sWidth=0.02;
S.T=cell(2,nTrials);
for i=1:nTrials
    P1=PechePourPoisson(f1,res,4);
    P2=PechePourPoisson(f2,res,4);
    P12=PechePourPoisson(f12,res,4);

    S.T{1,i}=sort([P1; P12]);
    S.T{2,i}=sort([P2; P12]);
end
    
