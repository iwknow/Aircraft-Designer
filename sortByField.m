function output  = sortByField( collection, field )
% sort the given collection of aircrafts by given field
output = collection(1);
for i = 2:length(collection)
    outputLength = length(output);
    didAdd = 0;
    for j = 1:outputLength
        if ( eval(['output(j).result.',field, '> collection(i).result.',field]))
           output = [output(1:j-1), collection(i), output(j:end)];
           didAdd = 1;
           break;
        end
    end
    if (didAdd == 0)
        output = [output, collection(i)];
    end
end

end

