function dock(cmd)

if nargin<1, cmd='in'; end

switch cmd
    case {'in' 'on'}, state='Docked';
    case {'out','off'}, state='Normal';
        
end

set(gcf,'WindowStyle',state);