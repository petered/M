
cd(fileparts(mfilename('fullpath')));
close all hidden; clear; clc;

%% Enter Parameters
% Enter initial model parameters here

I=struct;                           % Initialization options

I.S.nSteps=80;                      % Number of Simulation Steps

% World Settings
I.W.houseIndex      = 200;          % Initial house price index
I.W.houseIXhist     = 100;          % Length of house index history to make.
I.W.fedInterest     = .08/12;       % Federal interest rate
I.W.pJobLoss        = .02;          % Probability of job loss
I.W.pJobGain        = .1;           % Probability of getting job
I.W.rent            = .9;           % Rent cost
I.W.pSell           = .03;          % Probability of spontaniously selling a house
I.W.priceMem        = 3;            % Time constant of houseIndex price memory


% Bank Settings
I.B.N               = 6;            % Number of Banks
I.B.liquidMean      = 10000;        % Mean Liquid assets owned by a bank
I.B.liquidShape     = 3;            % Shape of Liquid assets distribution
I.B.mortgageLengths = [15 20 30]*12;% Mortgage length options

% HomeOwner Settings
I.O.N               = 500;          % Number of HomeOwners
I.O.salaryMean      = 12/12;        % Mean salary for housing
I.O.salaryDev       = 2/12;         % Sharpness of salary distribution
I.O.cashMean        = 20;           % Mean salary for housing
I.O.cashDev         = 5;            % Sharpness of cash distribution
I.O.nHousesToSearch = 6;            % Number of houses to search
I.O.salcashCorr     = 0.8;          % Correlation between income and salary
I.O.LTVthresh       = 1.2;          % Loan-To-Value ratio before defaulting
I.O.fJobs           = .9;           % Fraction of people with jobs
I.O.foresight       = 36;           % Months to look in advace when deciding to buy
I.O.panicHorizon    = 12;           % Months to look in advance when deciding if you need to sell.
I.O.discount        = .04/12;       % Discount parameter
I.O.memory          = 25;           % Time constant of homeowner memory
I.O.americanDream   = 20;           % Cash value of the joy of having a house
I.O.saleMarkup      = .1;          % Fraction to mark-up a house when putting it up for sale
I.O.salePanic       = .03;          % How much to decrease the sale price each turn

% House Settings
I.H.N               = 400;          % Number of houses
I.H.worthMean       = 1;            
I.H.worthDev        = .3;           % Deviation of house worth distribution.
I.H.fPeopleOwned    = 0.95;         % Fraction of house owned by people (as opposed to banks)
I.H.salaryCorr      = 0.8;          % Correlation of salary to house price
I.H.fForSale        = .1;           % Fraction of people-owned houses initially for sale

% Mortgage Settings
I.M.fHousesHeld      = 0.7;         % Fraction of houses initially mortgaged (they'll be in random states of payoff)
I.M.term             = 20*12;          % Mortgage time (should eventually be made a distribution)
I.M.typesProb        = [0.5; 0.5];  % Fraction of existing mortgages that are adjustable.

% Mortgage Type settigns
I.MT(1).adjustable  = false;        %
I.MT(1).down        = 0.2;
I.MT(1).incomeBuf   = 1.2;
I.MT(1).ratePrem    = .02/12;
I.MT(2).adjustable  = true;
I.MT(2).down        = 0.03;
I.MT(2).incomeBuf   = .9;
I.MT(2).teaser      = 0.03*ones(1,12)/12;
I.MT(2).ratePrem    = .02/12; % Surplus rate to fed interest


%% Enter Statistics of interest

frac=@(x)nnz(x)/length(x);

ST=struct;
ST.housingIndex=@(W)W.houseIndex;
ST.fHomesForSale=@(W)frac([W.H.forSale]);

ST.fPeopleWithHouses=@(W)frac(arrayfun(@(x)~isempty(x.H),W.O));
ST.fHousesFree=@(W)frac(arrayfun(@(h)isempty(h.M),[W.H]));
ST.fHousesWithPeople=@(W)frac(arrayfun(@(x)isa(x.Owner,'HomeOwner'),W.H));

ST.fUnemloyment=@(W)frac(~[W.O.hasJob]);
ST.meanCash=@(W)mean([W.O.cash]);
% ST.keepCount=@(W)W.actions.keep;
% ST.sellCount=@(W)W.actions.sell;
% ST.defaultCount=@(W)W.actions.default;
% ST.rentCount=@(W)W.actions.rent;
% ST.buyCount=@(W)W.actions.buy;
ST.salePrice=@(W)mean([W.HforSale.price]);


%% Initialize world
% More advanced tinkering can be done here.
T=struct;       % Structure to store all the temporary initializers.

% A whole new world
W=World;
W.pJobLoss=I.W.pJobLoss;
W.pJobGain=I.W.pJobGain;
W.fedInterest=I.W.fedInterest;
W.houseIndex=I.W.houseIndex;
W.houseIndexHistory=I.W.houseIndex*ones(1,I.W.houseIXhist);
W.rent=I.W.rent;
W.pSell=I.W.pSell;
W.priceMem=I.W.priceMem;

% Generate Banks
T.Bi=Bank(); T.Bi.initializer;
W.B(I.B.N)=Bank;
W.B.distribute('liquid',gammaDraw(I.B.liquidMean,I.B.liquidShape,I.B.N));
W.B.distribute('Mlen',{I.B.mortgageLengths});

% Generate HomeOwners
W.O(I.O.N)=HomeOwner;
[T.sal T.cash]=skewedDraw([I.O.salaryMean I.O.cashMean],[I.O.salaryDev I.O.cashDev], I.O.N,I.O.salcashCorr,true);
W.O.distribute({'salary','cash'},T.sal,T.cash);
W.O.distribute('hasJob',I.O.fJobs>rand(1,I.O.N));
W.O.distribute('nHousesToSearch',I.O.nHousesToSearch);
W.O.distribute('LTVthresh',I.O.LTVthresh);
W.O.distribute('foresight',I.O.foresight);
W.O.distribute('panicHorizon',I.O.panicHorizon);
W.O.distribute('discount',I.O.discount);
W.O.distribute('memory',I.O.memory);
W.O.distribute('americanDream',I.O.americanDream);
W.O.distribute('saleMarkup',I.O.saleMarkup);
W.O.distribute('salePanic',I.O.salePanic);
W.O.distribute('tag',ceil(1000000*rand(1,I.O.N)));
W.O.link('B',W.B,[],true,1,true); % Link each Homeowner to 2 banks
W.O.link('B',W.B,[],true,1,true);

% Generate Houses   
W.H(I.H.N)=House;
W.H.distribute('worth',skewedDraw(I.H.worthMean,I.H.worthDev,I.H.N,[],true));   
W.H.distribute('price',[W.H.worth]*I.W.houseIndex); 

% Generate Mortgage Types
T.MT(length(I.MT)*I.B.N)=MortgageType;
W.MT=T.MT;
[W.MT(1:2:end).adjustable]   = deal(I.MT(1).adjustable);
[W.MT(1:2:end).down]         = deal(I.MT(1).down);
[W.MT(1:2:end).teaser]       = deal(I.MT(1).teaser);
[W.MT(1:2:end).ratePremium]  = deal(I.MT(1).ratePrem);
[W.MT(1:2:end).incomeBuffer] = deal(I.MT(1).incomeBuf);
[W.MT(2:2:end).adjustable]   = deal(I.MT(2).adjustable);
[W.MT(2:2:end).down]         = deal(I.MT(2).down);
[W.MT(2:2:end).teaser]       = deal(I.MT(2).teaser);
[W.MT(2:2:end).ratePremium]  = deal(I.MT(2).ratePrem);
[W.MT(2:2:end).incomeBuffer] = deal(I.MT(1).incomeBuf);
for i=1:length(W.B), link(W.B(i),'MT',W.MT(2*i-1:2*i),'B'); end              % Link mortgage types to banks such that each has one type
W.MT.distribute('W',W);

% Link Houses to owners
T.Hlinked=link(W.H,'Owner',W.O,'H',true,I.H.fPeopleOwned);                      % Link of homes to homeowners.
% T.Hlinked.correlate('worth',arrayfun(@(h)h.Owner.salary,T.Hlinked),I.H.salaryCorr,true); % Correlate house price to salary
T.Hlinked.distribute('forSale',I.H.fForSale>rand(size(T.Hlinked)));
W.H(arrayfun(@(h)isempty(h.Owner),W.H)).link('Owner',W.B,[],true,1,true);
W.H(arrayfun(@(h)isa(h.Owner,'Bank'),W.H)).distribute('forSale',true);

% Generate Mortgages for some percentage of linking houses
W.M(ceil(length(T.Hlinked)*I.M.fHousesHeld))=Mortgage;
W.M.link('MT',W.MT,[],true,1,true);                                       % Link Mortgages randomly to mortgage types
W.M.link('H',permrand(W.H),'M',true);                                     % Link Mortgages randomly to houses
for i=1:length(W.M), 
    W.M(i)=W.M(i).MT.realize(W.M(i).H,I.M.term); W.M(i).H.M=W.M(i); 
    W.M(i).startPeriod=ceil(rand(1,length(W.M(i).duration)));
    W.M(i).principal=W.M(i).principal-W.M(i).scheduleP(1:W.M(i).period);
end   % Make Mortgages "fo' real"
W.M.distribute('principal',rand(size(W.M)).*[W.M.principal]);            % Mortgages have paid off some random portion of their principal.

%% Initialize simulation
S=Simulation;
S.Stats=ST;
W.inTheBeginning;
S.W=W;
S.nSteps=I.S.nSteps;

S.runLink;

