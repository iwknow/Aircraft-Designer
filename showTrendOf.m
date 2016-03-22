function [ ] = showTrendOf( collection, field, isInResult, topPercentage  )
% show the trend of a certain 'field' of the 'topPercentage' of 'collection'
if (nargin == 3)
    topPercentage = 0.3;
end
y = ones(1,int32(length(collection)*topPercentage));
for i = 1:(int32(length(collection)*topPercentage));
    if isInResult == 1
        y(i) = eval(['collection(i).result.', field]);
    else
        y(i) = eval(['collection(i).airCraft.', field]);
    end
end
avg = ones(1,length(y)) * mean(y);
SD = ones(1,length(y)) * std(y);
plot(y);
hold on 
plot(avg,'--');
plot((avg+SD),'k:');
plot((avg-SD),'k:');
hold off
title(['Trend of ', field]);
xlabel(['Position of "', field,'" in the sorted list'])
ylabel(['value of', field]);
end

