classdef BetterThanGlasses < handle
% Code by Peter O'Connor and Gabriela Michel
%
% Simulation of Visual Prosthesis
%
% Usage
% R=BetterThanGlasses.go;      % And that's it.
%
% .. Or just run the file
%
% For this code we chose to present it using
% the Graphical User Interface (GUI).
%
%
% We can upload an image and we applied the filters
% in order to simulate either Simple cells or Ganglion cells.
%
% In this case we used the famous Lena image.
    
       
    
    properties 
        
        im;
        
        retim;
        
        gang;
        
        v1;
        
        
        gangfilt;
        
        v1filt;
        
        hh;
        
    end
    
    methods
        
        
        function A=BetterThanGlasses(dontlaunch)
            if (~exist('dontlaunch','var')), dontlaunch=false; end
            
            if ~dontlaunch
                A.GUI;
            end
        end
        
        function GUI(A)
            
            
            h=retgui;
            
            set(h.pushbutton1,  'callback', @(e,s)putim);
            
            set(h.edit1,        'callback', @(e,s)putretim);
            set(h.pushRGCfilt,  'callback', @(e,s)putgangfilt);
            set(h.pushV1filt,   'callback', @(e,s)putv1filt);
            
            A.hh=h;
            
            colormap(h.axes11,gray);
            
            % Default RGC Parameters
            onCen=3;
            offSur=15;
            
            % Default V1 Parameters
            edge=50;
            angle=90;
            stretch=3;
            
            initfilt;
            
            close;
            
            
            function C=pack(varargin)
                C=cellfun(@num2str,varargin,'uniformoutput',false);
            end
            
            function varargout=unpack(C)
            	varargout=cellfun(@str2double,C,'uniformoutput',false);                
            end
            
            function initfilt
                putgangfilt(true);
                putv1filt(true);
            end
            
            
            
            function putim
                A.getim;
                
                subplot(h.axes1);edge=50;
                angle=90;
                stretch=3;
                A.makev1cell(edge,angle,stretch);
                imagesc(A.im);
                
                putretim;
            end
            
            
            function putretim
                
                b=str2double(get(h.edit1,'string'));
                
                if isnan(b) || b<=0
                    errordlg('Concentricity must be a single positive number!');
                    return; 
                elseif isempty(A.im)
                    errordlg('Select an image first!');
                    return; 
                end
                
                
                A.retim=retinafy(A.im,b);
                
                subplot(h.axes5);
                imagesc(A.retim);
                
                putgang;
            end
            
            
            function putgangfilt(init)
                if nargin<1, init=false; end
                if ~init
                    res=inputdlg({'On-Center size','Off Surround Size'},'Ganglion cell parameters',1,pack(onCen, offSur));
                    if isempty(res), return; end
                    [onCen,offSur]=unpack(res);
                end
                
                
                
                dims=4*[offSur offSur];
                A.makergc(onCen,offSur,dims);
                
                imagesc(A.gangfilt,'parent',h.axes10,'hittest','off');
                
                if ~init
                    putgang;
                end
                
            end
                        
            function putgang
                         
                A.gang=conv2(A.retim,A.gangfilt,'same');
                
                subplot(h.axes6);
                imagesc(A.gang);
                                
                putv1;
                               
            end
            
            function putv1filt(init)
                
                if nargin<1, init=false; end
                
                if ~init
                    res=inputdlg({'Size','Angle','Stretch Ratio'},'Simple Cell (gabor filter) paramiters',1,pack(edge,angle,stretch));
                    if isempty(res), return; end
                    [edge,angle,stretch]=unpack(res);
                end
                
                
                A.makev1cell(edge,angle,stretch);
                                
                imagesc(A.v1filt,'parent',h.axes11,'hittest','off');
                
                if ~init
                    putv1;
                end
                
                
            end
            
            function putv1
                
                A.v1=conv2(A.retim,A.v1filt,'same');
                
                subplot(h.axes7);
                imagesc(A.v1);
                
            end
            
            
        end
        
        
        
        function getim(A,im)
           
            cd(fileparts(mfilename('fullpath')));
            
            if ~exist('im','var'),
                [f p]=uigetfile('*');
                im=[p f];
            end
            if isnumeric(im)
                A.im=mean(im,3); return;
            else
                im=imread(im);
                im=mean(im,3);
            end            
            A.im=im;
                       
        end
        
        function makergc(A,ri,ro,dim)
            
            % Retinal Gangion Cell filter
            [x y]=meshgrid((1:dim(1))-dim(1)/2,(1:dim(2))-dim(2)/2);
            d=x.^2+y.^2;
            A.gangfilt=exp(-d/(2*ri^2))/ri-exp(-d/(2*ro^2))/ro;
                        
        end
        
        function makev1cell(A,edge,angle,stretch)

            A.v1filt=A.rotgabor(edge,angle,stretch);
            
        end
                              
        function prop(A)
            
            A.gang=conv2(A.im,A.gangfilt);
                     
            A.v1=conv2(A.im,A.v1filt);
            
        end
        
        
        
        
        
    end
    
    methods (Static)
                
        function z=rotgabor(edge,angle,stretch)
            
            % Defaults
            range=1.5;
            if nargin<3, stretch=3; end
            
            % Setup transforms
            range=linspace(-range,range,edge);
            [x y]=meshgrid(range,range);
            R=[cosd(angle) -sind(angle); sind(angle) cosd(angle)];
            
            % First transform
            X=R*[x(:)'; y(:)'];
            C=[1 0; 0 stretch];

            % Then gaussify
            z=reshape(X(2,:).*exp(-sum(X.*(C*X))),size(x));
            
            % Center and normalize
            z(:)=z(:)-mean(z(:));
            z(:)=z(:)./sum(z(:).^2);
                        
        end
                
        function A=go
%             
              A=BetterThanGlasses;
              A.GUI;

%             A=retina;
%             
%             A.getim;
%             
%             onCen=3;
%             offSur=30;
%             dims=[60 60];
%                                  
%             A.makergc(onCen,offSur,dims);
%             
%             edge=50;
%             angle=90;
%             stretch=3;
%             
%             A.makev1(edge,angle,stretch);
%             
%             
%             A.prop;
%             
%             A.view;
            
            
            
        end
        
    end
    
    
end