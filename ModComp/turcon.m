
a=[...
'_0123456789xIO.~';
'1123456789x0O.I~';
'               H'
'>>>>>>>>>><><><<';
];



line=@(i,w,s,m)sprintf('%s-->(%s,%s,%s), ',i,w,s,m);

x=sprintf('start=oneandonly\n\n(oneandonly) ');

for i=1:size(a,2)
    x=[x line(a(1,i),a(2,i),a(3,i),a(4,i))];
end
        

disp(x)