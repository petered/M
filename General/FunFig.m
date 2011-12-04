function FunFig(x,y)

h=plot(x,y);


    function whichone(s,~)
        
        num=find(s==h);
        fprintf('You selected %g\n',num);
        
        
    end


arrayfun(@(x)set(x,'ButtonDownFcn',@whichone),h);




end