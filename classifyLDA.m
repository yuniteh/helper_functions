% x - samples X features
% w - classes X features
% c - classes X 1

function [classOut,maxL] = classifyLDA(x,w,c,varargin)
f = w*x' + c*ones(1,size(x,1));
[~, classOut] = max(f);
classOut = classOut';
maxL = 0;

if size(varargin,2) >= 1
    classOut = varargin{1}(classOut);
    if size(varargin,2) > 1
        logl = like(x, varargin{2},varargin{3});
        maxL = min(logl,[],2);
    end
end
end