function output = MCrandom( base, range )
% generate a random number around base in specified range
if (nargin == 1)
    range = 0.2;
end
output = ((rand - 0.5) * 2  * range + 1) * base;  


end

