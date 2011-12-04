
function ix=ChineseRestaurant(vec,discount,strength)
% Takes a random draw from a vector, with chances corresponding to
% size of each element

people=cumsum(vec);
tables=length(vec);

if rand <  (strength+tables*discount)/(people(end)+strength)
    ix=0; % New table
else
    ix=find(rand*people(end)-people < 0,1);
end



end