
function invertcols(h,fun,leavelines)
    if ~exist('fun','var')||isempty(fun)
        fun=@switchunless; 
    else 
        fun=@(c)switchunless(c,fun);        
    end
    
    if ~exist('leavelines','var'), leavelines=false; end

    switch get(h,'type')
        case 'figure'
            props={'color'};
            kids=get(h,'children');
            kids=kids(strcmp(get(kids,'type'),'axes'));
        case 'axes'
            props={'color','xcolor','ycolor','zcolor','AmbientLightColor'};
            kids=cell2mat(cellfun(@(x)get(h,x),{'xlabel','ylabel','zlabel','title','children'},'uniformoutput',false)');
%             kids=[get(h,'xlabel') get(h,'ylabel') get(h,'zlabel') get(h,'title') get(h,'children')'];
        case 'line'
            if leavelines, return; end
            props={'MarkerFaceColor','MarkerEdgeColor','color'};
            kids={};
        case 'text'
            props={'color'};
            kids={};
        case 'hggroup'
            props={};
            kids=get(h,'children');
        case 'patch'
            if leavelines, return; end
%             props={'MarkerFaceColor','MarkerEdgeColor','EdgeColor'};
            props={'MarkerFaceColor','MarkerEdgeColor','EdgeColor'};
            kids={};
        otherwise 
            return;
    end
    
    
    cellfun(@(p)set(h,p,fun(get(h,p))),props);
    
    arrayfun(@(k)invertcols(k,fun,leavelines),kids);
    
    function c=switchunless(c,numfun)
        if nargin<2, numfun=@(c)1-c; end
        if isnumeric(c)
            c=numfun(c);
        end
        
    end
    
end
