function [stimulus] = stimulusN(trial,x)
            if trial >= 1 && trial <= x/9
            stimulus = 1;% Square on the left side and red
            elseif trial >= x/9+1 && trial <= 2*x/9
            stimulus = 2;% Square in the center and red
            elseif trial >= 2*x/9+1 && trial <= 3*x/9
            stimulus = 3;% Square on the right side and red
            elseif trial >= 3*x/9+1 && trial <= 4*x/9
            stimulus = 4;% Square on the left side and green
            elseif trial >= 4*x/9+1 && trial <= 5*x/9
            stimulus = 5;% Square in the center and green 
            elseif trial >= 5*x/9+1 && trial <= 6*x/9
            stimulus = 6;% Square on the right side and green
            elseif trial >= 6*x/9+1 && trial <= 7*x/9
            stimulus = 7;% Square on the left side and blue
            elseif trial >= 7*x/9+1 && trial <= 8*x/9
            stimulus = 8;% Square in the center and blue
            else trial >= 8*x/9+1 && trial <= x
            stimulus = 9;% Square on the right side and blue
            end;