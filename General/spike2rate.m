function [rate time]=spike2rate(sp,dt,endtime)
% This be-hatch tries to reconstruct the rate-signal from a series of
% spike times (sp).

isi=diff(sp);
isiloc=(sp(1:end-1)+sp(2:end))/2;

time=0:dt:endtime;

rate=interp1(isiloc,1./isi,time);

end