function ebar(data,err)
% data and err should be m x n, where m is the number of groups on the x
% axis, and n is the number of bars in each group

ngroups = size(data, 1);
nbars = size(data, 2);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    for j = 1:length(x)
        errorbar_ez('line_simple',x(j),data(j,i),err(j,i),0,'k')
    end
    %errorbar(x', data(:,i), err(:,i), 'k.','MarkerSize',.1);
end
end