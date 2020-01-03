% traindata - sample X features
% class - class X 1
% w - class X feat
% c - class X 1

function [w,c,muClass,C] = trainLDAtest(traindata, class)
% dimensions
nFeat = size(traindata,2);
uClass = unique(class);
nClass = length(uClass);

% initialize mean and pooled covariance
mu = mean(traindata);
C = zeros(nFeat,nFeat);
muClass = zeros(nClass,nFeat);

% calculate mean and pooled covariance
for i = 1:nClass
    ind = class == uClass(i);
    muClass(i,:) = mean(traindata(ind,:));
    C = C + cov(traindata(ind,:));
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