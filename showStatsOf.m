function [] = showStatsOf( collection, field, isInResult )
% show the histogram of "field". if it is aircraft property, isInReport is
% true if the field is in report.

stats = ones(1,length(collection));
for i = 1:length(collection)
    if isInResult == 1
        stats(i) = eval(['collection(i).result.', field]);
    else
        stats(i) = eval(['collection(i).airCraft.', field]);
    end
end
hist(stats);
title(['Histogram of ', field]);
xlabel(['Values of "', field,'"'])
ylabel('number of samples');


