close all
% clear all
colordef black %Makes it look awesome

%% Description of variables (for my own benifit mainly)


% layer(i).map(j).neur(n,m)  % Is the output of the neuron at position
                             % (n,m) in the jth map of layer(i).  layer(1)
                             % is the input layer.  Neurons within a map
                             % are indexed by (row,column).
                             
% layer(i).map(j).back(n,m)  % Is the backpropagating output (f'(u)) of the
                             % neuron.  This is calculated on the feed-
                             % forward pass to make things faster
                             
% layer(i).map(j).blame(n,m) % Is the "blame" for error of that particular
                             % neuron.  Used in back-propagation
                             
% layer(i).map(j).W(y,x)     % Is the Weight vector of all neurons in
                             % map(j) of layer(i).  Recall that in
                             % convolutional networks, all these neurons
                             % within map(j) share the same weight vector.
                             % I'm calling it a vector even though it's 2-D
                             % so as not to confuse it with a weight
                             % matrix, inwhich a vector of inputs is mapped
                             % onto a vector of outputs, this matrix is 
                             % just a 2-D representation of the weight 
                             % vector.  It maps multiple inputs onto a 
                             % single output.
                             
% layer(i).map(j).b          % The bias of all neurons in map(j) of 
                             % layer(i).  All neurons in a single map also
                             % share the same bias.
                             
% layer(i).map(j).cnx(s)     % Indicates which maps in layer(i-1) the
                             % present map is connected to.  Obviously no
                             % value of s may exceed the number of maps in
                             % layer(i-1).
                             
% RFconv                     % The receptive field size of neurons in
                             % convolutional layers.  It is assumed that
                             % all neurons in convolutional layers have the
                             % same RF size.  This may change.  Note that
                             % adjacent convolution neurons have
                             % overlapping RF's (shifted by 1 unit).
                             
% RFsub                      % The receptive field size of all neurons in
                             % subsampling layers. Fields are adjacent but
                             % nonoverlapping.
                             
% Types                      % String Indicating ordering of different
                             % types of layers (input, convolution,
                             % subsampling)
                             
% MapNum                     % Number of maps in the input and each 
                             


%% Setup

% Directory
%Directory='F:\Writing\';        % What folder is the training file in?
                                 %(Get it from http://yann.lecun.com/exdb/mnist/, unzip with 7-zip)
Directory='C:\Documents and Settings\tobi\Desktop\MNIST\';

Rate=.005;

% Receptive Field Sizes
RFconv=[5 5];
RFsub=[2 2];
RFfull=[1 10];

% Network size and shape
Types={'Input','Conv','Sub','Conv','Sub','Full'};
MapNum=[1 6 6 12 12 10];     % Must be consitent with length of "Types"

% Training/Testing Parameters
samples=50;                    % Number of samples in training set (they'll be randomized)
trials=1000;                     % Number of trials to work with
tests=200;                      % Number of tests
decay=0.000;

% Display
peek=20;                       % peek every "peek" iterations

% Translation
shift=0;                        % Add jitter to position (1=y,0=n)

     
% Transfer Function
siggy=0;                            % Which transfer function to use?
if siggy
    f=@(I) 1./(1+exp(-I));          % Transfer Function
    df=@(I) 1./(2+exp(I)+exp(-I));  % Derivative (Matlab should really be able to figure this one out)
else
    f=@(I) atan(I);                % Alternate Transfer Function 
    df=@(I) 1./(1+I.^2);           %  
end



% Get Training and Test Data
input=lowlevelreading([Directory 'train-images.idx3-ubyte'], samples, 0);
answers=lowlevelreading([Directory 'train-labels.idx1-ubyte'], samples);
testdat=lowlevelreading([Directory  't10k-images.idx3-ubyte'], tests, 0);
testans=lowlevelreading([Directory 't10k-labels.idx1-ubyte'], tests);


% Connection Map from 3 to 4
Conex{4}= [ ...
1 0 0 0 1 1 1 0 1 1 1 1 0 1 1; 
1 1 0 0 0 1 1 1 0 1 1 1 1 0 1; 
1 1 1 0 0 0 1 1 1 0 1 0 1 1 1; 
0 1 1 1 0 0 1 1 1 1 0 1 0 1 1;
0 0 1 1 1 0 0 1 1 1 1 0 1 0 1;
0 0 0 1 1 1 0 0 1 1 1 0 1 1 1  ]; 



%% Initialize           

% This stops the compiler from bitching (don't know if it helps speed).
layer=struct('map',struct('neur',[]', 'blame',[], 'back',[], 'W',{}, 'b',[], 'cnx',[], 'u',[]));

% Initialize All sorts of matrices
Teacher=zeros(samples,10);         % Must be consistant with size of output layer
Examiner=zeros(tests,10);
Error=zeros(trials+tests,10);
Correct=zeros(trials+tests,1);
MagErr=zeros(trials+tests,1);

layers=length(Types);   
training=1;

% Set up your grandmother teaching team

    for i=1:size(Teacher,1)
        Teacher(i,mod(answers(i)-1,10)+1)=1;
    end
    for i=1:tests
        Examiner(i,mod(testans(i)-1,10)+1)=1;
    end
if siggy==0
 Teacher=pi*Teacher-pi/2;  % For arctan transfer function
 Examiner=pi*Examiner-pi/2;
end
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
            layer(i).map(j).W{j}=0.5;
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
            for s=1:length(cnx), layer(i).map(j).W{cnx(s)}=5*randn(RFconv)/(RFconv(1)*RFconv(2)*length(cnx));
            end
        elseif strcmp(Types(i),'Full')
            layer(i).map(j).cnx=1:MapNum(i-1);
            cnx=layer(i).map(j).cnx;
            for s=1:length(cnx), layer(i).map(j).W{cnx(s)}=30*randn(Mold)/((prod(Mold))*length(cnx));            end
        end
        layer(i).map(j).b=0; 
        
        % Initialize Variables
        layer(i).map(j).neur=zeros(Msize);
        layer(i).map(j).blame=zeros(Msize);
        layer(i).map(j).back=zeros(Msize);
        layer(i).map(j).u=zeros(Msize);
    end
end


figure('Position',[20 400 1200 450]);

tic
time=0;



%% Go Time
%t=1:
for  t=1:trials+tests   % Sample Number
    
    
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
            
            if strcmp(Types(i), 'Sub')
                    umap=zeros(fix(size(layer(i-1).map(j).neur)./RFsub));
                    % Will need to change this if we change shape size of RFsub
                    k=1:2:size(umap,1)*2;
                    for m=0:1
                        for n=0:1
                            umap=umap+layer(i-1).map(j).neur(k+m,k+n);
                        end
                    end
                    layer(i).map(j).u=umap;
                    layer(i).map(j).neur=f(layer(i).map(j).W{j}*umap+layer(i).map(j).b);
                    layer(i).map(j).back=df(layer(i).map(j).W{j}*umap+layer(i).map(j).b);
                
            else
                    umap=zeros(size(layer(i-1).map(1).neur)-RFconv+[1 1]);
                    for s=1:length(cnx)
                        umap=umap+conv2(layer(i-1).map(cnx(s)).neur,layer(i).map(j).W{cnx(s)},'valid');
                    end
                    layer(i).map(j).neur=f(umap+layer(i).map(j).b);
                    layer(i).map(j).back=df(umap+layer(i).map(j).b);    
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
    
    MagErr(t)=sum(Error(t,:).^2);
        
    if ind==Number, Correct(t)=1; end;
    
    
    %% Display          
    
       
    
    % Text Ouput
    if 0
    if training, title(['TRIAL ' num2str(t)]);
    else title (['TEST  ' num2str(sample)]);
    end
    
    disp(['ITERATION ' num2str(t)]);
    
    disp('Output:')
    disp(output)
    
    disp('Teacher:')
    Granny;
    
    %disp('Blame:')
    %[layer(layers).map(1:10).blame]
    end
    
    
    % Graphs
    if mod(t,peek)==1;
    %if t==trials+tests
        % Draw Input
        subplot(2,layers+1,1)
        imagesc(layer(1).map(1).neur);
        if training, title(['Input: Training Number ' num2str(t)]);
        else title (['Input: Test Number ' num2str(sample)]);
        end
        axis off

        % Draw Selected Layer's Weights
        for i=2:layers-1
            subplot(2,layers+1,i)
            imagesc(layer(i).map(1).neur); 
            axis off
            colorbar('location','southoutside');
            subplot(2,layers+1,i+layers+1)
            imagesc(layer(i).map(1).W{1}); 
            axis off
            colorbar('location','southoutside');
            
        end
        
        % Draw Output
        subplot(2,layers+1, layers)
        imagesc(output'); 
        axis off
        title(['Output: ' num2str(ind)]);
        colorbar('location','southoutside');
        subplot(2,layers+1, 2*layers+1)
        imagesc([layer(layers).map(1).W{1}]);
        axis off
        colorbar('location','southoutside');
        
        
        % Draw Granny
        subplot(2,layers+1, layers+1)
        imagesc(Granny');
        title(['Teacher: ' num2str(Number)]);
        axis off
        colorbar('location','southoutside');
        
        
        getframe;
        
    end
    
    
    %% Backpropagation (Learning) 
    
    if training==1;
        
    % Assign Initial Blame
    for j=1:MapNum(layers)
        layer(layers).map(j).blame=(Teacher(sample,j)-layer(layers).map(j).neur)*layer(layers).map(j).back;
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
           
           
          
           
           
           % -------------------------------------------
           
           
           
           % Distribute Blame to lower level
           
           if strcmp(Types(i), 'Sub')
               % Distribute to previous convolutional layer
               layer(i-1).map(j).blame = layer(i).map(j).W{j}*kron(layer(i).map(j).blame,ones(2)).*layer(i-1).map(j).back; % kron upsamples
               
               % Find energy Gradient
               dE=sum(sum(layer(i).map(j).u.*layer(i).map(j).blame))/layer(i).map(j).W{j};
           
               dEb=sum(sum(layer(i).map(j).blame));
               
           else
               
               
               dE=zeros(size(layer(i).map(j).W{cnx(1)}));
               for s=1:length(cnx);
                   
                   % Distribute to previous subsampling layer
                   if i>2
                    layer(i-1).map(cnx(s)).blame = ... 
                     layer(i-1).map(cnx(s)).blame + xcorr2(blame,layer(i).map(j).W{cnx(s)}).*layer(i-1).map(cnx(s)).back;
                   end

                   % Find energy Gradient
                   dE = dE+rot90(rot90(conv2(layer(i-1).map(cnx(s)).neur, rot90(rot90(blame)),'valid')));
                    % All the rot90's are because the xcorr2 doesn't a 'valid' thing
                    
                   dEb=sum(sum(layer(i).map(j).blame));
                    
               end      
               
               
           end
           
               
           
           
           % Change Weights
           for s=1:length(cnx);
               layer(i).map(j).W{cnx(s)}=layer(i).map(j).W{cnx(s)}+Rate*dE-decay*layer(i).map(j).W{cnx(s)};
           end
           
           % Change the thresholds so that shit stays linear.
           layer(i).map(j).b=layer(i).map(j).b+Rate*dEb;
           
           
           layer(i).map(j).blame=zeros(M);          % Reset blame for next iteration
           
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





