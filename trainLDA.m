% traindata - sample X features
% class - class X 1
% w - class X feat
% c - class X 1

function [w,c,muClass,C,C1,C2] = trainLDA(traindata, class)
% dimensions
nFeat = size(traindata,2);
uClass = unique(class);
nClass = length(uClass);

% initialize mean and pooled covariance
mu = mean(traindata);
C = zeros(nFeat,nFeat);
C1 = C;
C2 = C;
muClass = zeros(nClass,nFeat);

% calculate mean and pooled covariance
for i = 1:nClass
    ind = class == uClass(i);
    muClass(i,:) = mean(traindata(ind,:));
    C1 = C1 + cov(traindata(ind,:));
    C2 = C2 + (1/(sum(ind)-1))*(traindata(ind,:)-ones(sum(ind),1)*muClass(i,:))'*(traindata(ind,:)-ones(sum(ind),1)*muClass(i,:));%cov(traindata(ind,:)) - ones(sum(ind),1)*mu);
    %C = C + ((traindata(ind,:))'*traindata(ind,:))/(sum(ind)-1);%cov(traindata(ind,:)) - ones(sum(ind),1)*mu);

    tempM = zeros(1,nFeat);
    f_ind = find(ind);
    for j = 1:50
        tempM = ((j-1)/j)*tempM + (1/j)*traindata(f_ind(j),:);
        C = ((j-1)/j)*C + (1/j)*((traindata(f_ind(j),:)-tempM)'*(traindata(f_ind(j),:)-tempM));
        %C = C + ((traindata(ind,:))'*traindata(ind,:))/(sum(ind)-1);%cov(traindata(ind,:)) - ones(sum(ind),1)*mu);
    end
end

C = C./nClass;
prior = 1/nClass;

% initialize weight matrices
w = zeros(nClass,nFeat);
c = zeros(nClass,1);

% calculate weights
for i = 1:nClass
    w(i,:) = muClass(i,:)/C;
    c(i,:) = -.5 * muClass(i,:)/C * muClass(i,:)' + log(prior);
end

end