function [n_block, n_trial, square_width]=JA_Configure

% Clear Workspace, Command Window and close all
rand('state', sum(100*clock)); % initialize random number generator

% Variabel definition
n_block      = 4; % here you can change the number of blocks
n_trial      = 108; % here you can change the number of trials per block
square_width = 100; % squarewidth



%% Configuration

% Display configuration
    mode              = 1; % window mode ( 0=window, 1=full screen ), you can let that like this
    resolution        = 3; % screen resolution (1=640x480, 2=800x600, 3=1024x768, 4=1152x864, 5=1280x1024, 6=1600x1200), you can change that, depending on the resolution of your screen and the size of the stimuli you want to hav
    bkrd_col          = [0.05,0.05,0.05]; % background colour dark grey in RGB-code [reg,green,blue], here you can change, if we need a brighter background for the children
    fore_col          = [1,1,1]; % foreground colour white in RGB-code [reg,green,blue], that means fixation cross and font
    fontname          = 'Arial narrow'; % name of font       
    fontsize          = 60; % size of font
    number_of_buffers = 20; % number of offscreen buffers, just let that like it is, we don't need more
    number_of_bits    = 32; % number of bits per pixel (8=palette mode, 16, 24, 32, or 0=Direct mode, maximum possible bits per pixel), don't know what that is and if we can change that
    config_display(mode, resolution, bkrd_col, fore_col, fontname, fontsize, number_of_buffers, number_of_bits);

% Keyboard configuration
    qlength           = 100; % maximum number of key events recorded between each keyboard read.
    resolution        = 1; % timing resolution in ms.
    mode              = 'nonexclusive'; % device mode (�exclusive� or �nonexclusive�), it's told to change that from �nonexclusive� to �exclusive� when running the experiment, but I prefer to tell the subjects and work with �nonexclusive�, 'cause abort is then easier           
    config_keyboard(qlength, resolution, mode);    

%--------------------------------------------------------------

end