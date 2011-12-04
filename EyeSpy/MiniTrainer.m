close all
clear
colordef black

%% Setup

Rate=.06;

RFfull=[1 10];

Types={'Input','Full'};     

MapNum=[1 10];              % Must be consitent with length of "Types"

samples=1000;               % Number of samples in set (they'll be randomized)
trials=1200;                 % Number of trials to work with

tests=200;                  % Number of tests (will be same)

shift=false;                % Boolean indicating whether to shift          

Wconvinit=0;                % Initial size of random weightings

Wfullinit=0;               % Initial size of infully-connected randoms.


%f=@(I) atan(I);             % Transfer Function
%df=@(I) 1./(1+I.^2);        % Derivative (Matlab should really be able to figure this one out)

f=@(I) 1./(1+exp(-I));
df=@(I) 1./(2+exp(I)+exp(-I));


Directory='C:\Documents and Settings\tobi\Desktop\MNIST\';
%Directory='C:\Temp\Writing\'


input=lowlevelreading([Directory 'train-images.idx3-ubyte'], samples, 1);
input=MapCenterer(input);


answers=lowlevelreading([Directory 'train-labels.idx1-ubyte'], samples);

testdat=lowlevelreading([Directory  't10k-images.idx3-ubyte'], tests, 1);
testdat=MapCenterer(testdat);

testans=lowlevelreading([Directory 't10k-labels.idx1-ubyte'], tests);








%% Initialize           

%layer=struct('map',1:length(Types));

% Dependent Parameters
Teacher=zeros(samples,10);         % Must be consistant with size of output layer
Examiner=zeros(tests,10);
Error=zeros(trials+tests,10);
Correct=zeros(trials+tests,1);

layers=length(Types);
training=1;

% Set up your grandmother teaching team
for i=1:size(Teacher,1)
    Teacher(i,mod(answers(i)-1,10)+1)=1;
end
for i=1:tests
    Examiner(i,mod(testans(i)-1,10)+1)=1;
end

%Teacher=pi*Teacher-pi/2;

% Set up that monstrosity of a network
Msize=size(input(:,:,1));
for i=2:length(Types)
    
    %layer(2).map(1).W{1}=repmat([0 -.5 1 -.5 0]', [1 5]);
    
    
    layer(i).type=Types(i);         % Can't figure out how to input this just as a vector.
    Mold=Msize;
    
    % Set Map Size
    if strcmp(Types(i),'Conv')       % For convolution layers
         Msize=Msize-2*fix(RFconv/2);
    elseif strcmp(Types(i),'Sub')
         Msize=fix(Msize/2);        % For resampling layers
    elseif strcmp(Types(i),'Full')
         Msize=1;                   % Neurons each considered maps in fully interconnected layers.
    else
        error('Your "Type" vector contains a layer that isn`t actually a type.  Try retyping it!')
    end
    
    for j=1:MapNum(i)
        
        % Set up connectivity and network function
        if strcmp(Types(i),'Sub')   % For Subsampling Layers
            %layer(i).map(j).W{j}=randn/(numel(RFsub));
            layer(i).map(j).W{j}=0.25;
            
            layer(i).map(j).cnx=j;
        elseif strcmp(Types(i),'Conv')                           % For Other Convolution Layers
            %if ~exist('Conex{i}','var')
            %    error('Your maps! your maps!... must be connected; Else your digits, shan`t be detected.')
            %end
            if MapNum(i-1)==1;              % For first Convolution Layer
                layer(i).map(j).cnx=1;
            else
                layer(i).map(j).cnx=find(Conex{i}(:,j)==1)';
            end
            cnx=layer(i).map(j).cnx;
            for s=1:length(cnx), layer(i).map(j).W{cnx(s)}=Wconvinit*randn(RFconv)/(RFconv(1)*RFconv(2)*length(cnx));
            end
        elseif strcmp(Types(i),'Full')
            layer(i).map(j).cnx=1:MapNum(i-1);
            cnx=layer(i).map(j).cnx;
            for s=1:length(cnx), layer(i).map(j).W{cnx(s)}=Wfullinit*randn(Mold)/((prod(Mold))*length(cnx));            end
        end
        layer(i).map(j).b=0; 
        
        % Initialize Variables
        layer(i).map(j).neur=zeros(Msize);
        layer(i).map(j).blame=zeros(Msize);
        layer(i).map(j).back=zeros(Msize);
        layer(i).map(j).u=zeros(Msize);
    end
end


figure('Position',[0 400 1000 500])
colormap (gray);

tic
time=0;




%% Go Time


for t=1:trials+tests    % Sample Number
    
    
    %% Get Input        
    
    if t>trials
        training=0;
    end
        
    if training==1;
        sample=fix(rand*size(input,3))+1;
        layer(1).map(1).neur=input(:,:,sample);
    else
        sample=t-trials;
        layer(1).map(1).neur=testdat(:,:,sample);
    end
    
    if shift
        shifty=fix(2*(rand(1,2)-.5)*4);
        layer(1).map(1).neur=circshift(layer(1).map(1).neur,shifty);
    end
    
    %% Mapping          
    for i=2:layers  % Layer Number 
        for j=1:MapNum(i)     % Map Number
            
            % To make things more readable
            cnx=layer(i).map(j).cnx;
            
            for m=1:size(layer(i).map(j).neur,1)    % Neuron's receptive field (y)
                for n=1:size(layer(i).map(j).neur,2) % Neuron's receptive field (x)
                   
                    % Find input Neurons (for convolution or subsampling layer) 
                    
                    if strcmp(layer(i).type,'Conv')
                        RFy=m:m+RFconv(1)-1;
                        RFx=n:n+RFconv(2)-1;
                        rfs=RFconv;
                    elseif strcmp(layer(i).type,'Sub')
                        RFy=1+(m-1)*RFsub(1):m*RFsub(1);
                        RFx=1+(n-1)*RFsub(2):n*RFsub(2);
                        rfs=RFsub;
                    else 
                        rfs=size(layer(i-1).map(1).neur);
                        RFy=1:rfs(1);
                        RFx=1:rfs(2);
                    end
                    
                    clear X
                    for s=1:length(cnx)
                        
                        
                        %ess=s
                        %rfzone=[RFy,RFx]
                        
                        X(1:rfs(1),1+(s-1)*rfs(2):(s)*rfs(2))=layer(i-1).map(cnx(s)).neur(RFy,RFx);
                    end
                        %eyejay=[i j]
                        %emmenn=[m n]
                    
                        % Find Current (shifted with bias)  This is stored for use in learning                
                        u=sum(sum([layer(i).map(j).W{cnx}].*X))+layer(i).map(j).b;
                        
                        layer(i).map(j).u(m,n)=u;
                        % Here each neuron has a set of 2-D weight vectors
                        % which it takes inputs from.  cnx represents the
                        % indeces of the maps in the previous layer that are
                        % connected to the present neuron.

                        % Transfer Function
                        layer(i).map(j).neur(m,n)=f(u);
                        layer(i).map(j).back(m,n)=df(u);
                        
                    
                    
                end
            end
        end
    end


    %% Results          
    % Find error in result
    
    output=[layer(layers).map(1:MapNum(layers)).neur];
    [garb ind]=max(output);
    ind=mod(ind,10);
    
    if training
        Granny=Teacher(sample,:);
        Number=answers(sample);
    else
        Granny=Examiner(t-trials,:);
        Number=testans(t-trials);
    end
    
    Error(t,:)=Granny-output;
        
    if ind==Number, Correct(t)=1; end;
    
    
    %% Display  
    
        
    % Text Ouput
    if 0
    
    disp(['ITERATION ' num2str(t)]);
    
    disp('Output:')
    disp(output)
    
    disp('Teacher:')
    Granny
    
    %disp('Blame:')
    %[layer(layers).map(1:10).blame]
    end
    
    if mod(t,4)==0;
    % Graphs
    subplot(3,10,[1:5 11:15])
    imagesc(layer(1).map(1).neur);
    if training, title(['Input: Training Number ' num2str(t)]);
    else title (['Input: Test Number ' num2str(sample)]);
    end
        
    axis off
    
    % Output Plot
    subplot(3,10,6:10)
    imagesc([layer(layers).map(1:10).neur]); colorbar;
    addlines(ind,'Color',[1 1 1],'LineWidth',4);
    title(['Output: ' num2str(ind)]);
    
    % Teacher Ploe
    subplot(3,10,16:20)
    imagesc(Teacher(sample,:)); colorbar;
    title(['Teacher: ' num2str(Number)]);
    
    % Weight Plots
    for i=1:10
        subplot(3,10,i+20)
        imagesc(layer(2).map(i).W{1});
        axis off
    end
    
    getframe;
    end
    
    
    %% Learning (Backpropagation)
    
    if training==1;
        
    for j=1:MapNum(layers)
        layer(layers).map(j).blame=(Teacher(sample,j)-layer(layers).map(j).neur).*layer(layers).map(j).back;
        %layer(layers).map(j).blame=(Teacher(1,j)-layer(layers).map(j).neur).*df(layer(layers).map(j).u);
    end
    
        
        
    for i=layers:-1:2
       for  j=1:MapNum(i)
            
           % INITIALIZE MAP-----------------------------
           
           % Get Size and connections
           M=size(layer(i).map(j).neur);
           cnx=layer(i).map(j).cnx;
           
           % Make a blame map
           blame=layer(i).map(j).blame;             % Error signal
           layer(i).map(j).blame=zeros(M);          % Reset blame for next iteration
           
           % Find receptive field size
           if strcmp(layer(i).type,'Conv'), rfs=RFconv;
           elseif strcmp(layer(i).type,'Sub'),rfs=RFsub;
           else rfs=size(layer(i-1).map(1).neur);
           end
           
           % Initialize W's at zero
           for s=1:length(cnx)
               dW{cnx(s)}=zeros(rfs);
           end
          
           
           % -------------------------------------------
           
           
           for m=1:M(1)             % mth row in map
               for n=1:M(2)         % nth column in map

                   
                   
                   % Because for the three types of layers...
                   if strcmp(layer(i).type,'Conv')
                        RFy=m:m+RFconv(1)-1;
                        RFx=n:n+RFconv(2)-1;
                    elseif strcmp(layer(i).type,'Sub')
                        RFy=1+(m-1)*RFsub(1):m*RFsub(1);
                        RFx=1+(n-1)*RFsub(2):n*RFsub(2);
                    else 
                        
                        RFy=1:rfs(1);
                        RFx=1:rfs(2);
                   end

                   % Find the change in W
                   for s=1:length(cnx);         % For each [W] matrix
                    
                       
                    
                    
                       % To make things more readable
                       y=layer(i).map(j).neur(m,n);             % Output of this neuron
                       X=layer(i-1).map(cnx(s)).neur(RFy,RFx);  % Inputs to this neuron from map cnx(s) in lower layer
                       
                       % Modify weights based on blame.  Could be done
                       % outside loop to save time.  But whatevs.
                       
                       if strcmp(layer(i).type,'Sub')
                           %dW{cnx(s)}=dW{cnx(s)}+y*mean(mean(Rate*X*blame(m,n)/numel(X)));
                           dW{cnx(s)}=dW{cnx(s)}+y*mean(mean(Rate*X*blame(m,n)));
                       else
                           %dW{cnx(s)}=dW{cnx(s)}+y*Rate*X*blame(m,n)/numel(X);
                           dW{cnx(s)}=dW{cnx(s)}+Rate*X*blame(m,n);
                       end
                       
                       
                      
                       
                       
                       

                       
                       
                       
                       % Assign Blame to lower level 
                       if i>2, layer(i-1).map(cnx(s)).blame(RFy,RFx)= ...
                               layer(i-1).map(cnx(s)).blame(RFy,RFx)+blame(m,n)*layer(i).map(j).W{cnx(s)}*layer(i-1).map(cnx(s)).back(RFy,RFx);
                           
                           % Blame(i-1)=Blame(i-1)+Blame(i)*W*df(u(i-1))
                       end
                       
                    end
               end

           end   
           
           %{
           % Window in
           if i==6&&j==1
               disp('First W matrix')
               layer(i).map(j).W{1}
               disp('dW')
               dW{1}
               
           end
           %}
           
           % Change Weights
           for s=1:length(cnx);
               layer(i).map(j).W{cnx(s)}=layer(i).map(j).W{cnx(s)}+dW{cnx(s)}-0.001*layer(i).map(j).W{cnx(s)};
           end
           
           % Change the thresholds so that shit stays linear.
           %layer(i).map(j).b=layer(i).map(j).b+Rate*mean(mean(layer(i).map(j).blame));
           
       end
    end
    
    

    end
end

%% Display Error Results
 
dTrial=conv(Correct(1:trials),ones(1,20))/20;
dTest=conv(Correct(trials+1:end),ones(1,20))/20;

% Remove Edge Effects
dTrial(1:19)=[];
dTest(1:19)=[];
dTrial(end-19:end)=[];
dTest(end-19:end)=[];

% Plot
figure
subplot(1,3,1:2)
plot(dTrial,'g');
xlabel('Trial Window')
ylabel('Probability of being Correct')
set(gca,'YLim',[0 1]);

subplot(1,3,3)
plot(dTest,'r');
xlabel('Test Window')
set(gca,'YLim',[0 1]);





