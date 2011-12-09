function matrix=lowlevelreading(location, desired, show)
% Loads image and training data from the MNIST database.
%
% Output
% matrix: A 3-D image matrix, for the images, or a label vector, for the
%           labels
%
% Inputs (all optional)
% location: Path of the file (will prompt for search if left empty)
% desired:  Number of samples (images/labels) to read.
% show:  Show the resulting images (default: false)
%
% Example: 
% im=lowlevelreading;             % grab all 60000 images/labels
% im=lowlevelreading([],2000,1);  % Just grab 2000 images and how the pictures
%
%
%
% Enjoy,
% Peter
% poconn4.at.gmail




% if ~exist('image','var'), image=false;  end
if ~exist('show','var'), show=false;  end
if ~exist('desired','var')||isempty(desired), desired=inf;  end

if ~exist('location','var') || isempty(location)
    [f p]=uigetfile('*','Select MNIST file');
    cd(p);
    location=[p filesep f];
else
    assert(exist(location,'file')>0,sprintf('File: "%s" not found.',location));
end

%% Get Info About Data

% prod(sizdim)
file=fopen(location);


magic=fread(file,4);

switch magic(3)
    case 8
        le=1;
    case 9
        le=1;
    case 11
        le=2;
    case 12
        le=4;
    case 13
        le=4;
    case 14
        le=8;
    otherwise
        error('This ain`t right')
end

numdim=magic(4);

% Get sizes

sizes=fread(file,numdim*4);

sizdim=nan(1,numdim);
for i=1:numdim
    sizdim(i)=(2.^(24:-8:0))*sizes((1:4)+4*(i-1));
end
    

%% Get the Goods
if desired<sizdim(1)
    sizdim(1)=desired;
end

if length(sizdim)==1;
    sizdim=[sizdim,1];
end

data=fread(file,prod(sizdim));    

if le>1
    error('huh?');
else
    matrix=reshape(data,fliplr(sizdim));
end
    

if ~isvector(matrix) % Treat as image
    matrix=permute(matrix,[2 1 3])/2^(8*le);
%     matrix=padarray(matrix,[2 2]);
    
end

        
%% Show the pictures      
if show

    hF=figure(44);
    colormap gray;
    for i=1:size(matrix,3)
        imagesc(matrix(:,:,i));
        if ~ishghandle(hF), return; end
        drawnow;
        pause(.2);
    end
    
end

end