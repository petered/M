classdef Mortgage < handle
    
    properties
        
        outstanding;    % Amount outstanding
        
        downPayment;    % Fraction down.
        
        schedule;       % Payment schedule.  Must sum to 1.
                        % For fixed rate mortgage, payment will be
                        % calculated as 
        
        variable;       % Boolean: variable or fixed
        
        rate;           % Interest rate
        
        credit;         % Credit rating reqired for this type of mortgage.
        
    end
    
    methods
        
        
        
        
    end 
    
    
    
end