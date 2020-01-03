function [train_ind, test_ind] = crossval(class,fold,varargin)
if nargin == 1
    pos = varargin{1};
    class = class + (10.*(pos - 1));
end

if fold == 1
    train_ind = 1:length(class);
    test_ind = train_ind;
else
    c_size = sum(class == 1);            % number of samples per class
    c_n = length(unique(class));            % number of classes
    test_n = c_size/fold;                   % number of samples in each testing fold
    train_n = c_size - c_size/fold;         % number of samples in each training fold
    
    c_ind = zeros(c_n,c_size);              % indices for all samples in each class
    mix_ind = c_ind;                        % mixed indices
    
    test_ind = zeros(fold, test_n, c_n);            % testing indices
    train_ind = zeros(fold, train_n, c_n);          % training indices
    for i = unique(class)'                          % loop through each class
        c_ind(i,:) = find(class == i);                          % indices for current class
        mix_ind(i,:) = c_ind(i,randperm(c_size,c_size));             % permute the indices in this class
        for j = 1:fold                                          % loop through each fold
            test_ind(j,:,i) = mix_ind(i,1+(j-1)*test_n:1+(j-1)*test_n + test_n - 1);            % grab testing indices from mixed indices
            train_ind(j,:,i) = setdiff(mix_ind(i,:),test_ind(j,:,i));                           % grab training indices
        end
    end
    test_ind = reshape(test_ind,fold,[]);
    train_ind = reshape(train_ind,fold,[]);
end
end
