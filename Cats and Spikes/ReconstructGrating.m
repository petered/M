function [frames times]=ReconstructGrating(data,stimuli)
% Reconstruct the grating stimuli from the data
%
% data: data structure from eg,
%  'MastersThesis/RawData/cat1208/P4C1_tuning.mat'
%
% stimuli: stimulus structure from eg,
%  'MastersThesis/RawData/cat1208/stimuli/cat1208_P4C1_tuning.mat'
%
% frames: cell array of frames
% times:  onset times
%


times=data.channels.ch6.point1;

[x y]=meshgrid(1:stimuli(1).Width,1:stimuli(1).Height);


ixused=zeros(max([stimuli.Index]),1);    % Vector of first frame referring to index

frames=cell(length(stimuli),1);
for i=1:length(stimuli)
    if ~ixused(stimuli(i).Index) % If you have not yet come across this stimulus,
        ang=stimuli(i).Angle*2*pi/180;
        fS=stimuli(i).SpatialFreq;
        frames{i}=cos((cos(ang)*x+sin(ang)*y)*fS);
        ixused(stimuli(i).Index)=i;
    else % Else just point to the same stim that was used before (saves space)
        frames(i)=frames(ixused(stimuli(i).Index));        
    end
end

end