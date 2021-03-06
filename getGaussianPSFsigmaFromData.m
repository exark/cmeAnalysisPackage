%[sigma] = getGaussianPSFsigmaFromData(imageList) returns the s.d. of the Gaussian PSF estimated from the input data.
% The estimation is performed by running pointSourceDetection() with 'sigma' as a free parameter.
%
% Inputs:
%    imageList : single image, cell array of images, or cell array of image path strings
%
% Options:
%    'Display' : {true}|false displays the distribution of 'sigma' values
%
% Output:
%        sigma : standard deviation of the Gaussian PSF estimated from point sources in input data

% Francois Aguet, September 2010

function sigma = getGaussianPSFsigmaFromData(imageList, varargin)

ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('imageList');
ip.addOptional('frameRange', []);
ip.addParamValue('Display', true, @islogical);
ip.parse(imageList, varargin{:});

if ~iscell(imageList)
    imageList = {imageList};
end
frameRange = ip.Results.frameRange;

if isempty(frameRange)
    nd = numel(imageList);
else
    nd = numel(frameRange);
end
svect = cell(1,nd);
parfor i = 1:nd
    if isempty(frameRange)
        if ischar(imageList{i})
            img = double(imread(imageList{i}));
        else
            img = imageList{i};
        end
    else
        img = double(readtiff(imageList{1}, frameRange(i)));
    end
    % First pass with fixed sigma
    pstruct = pointSourceDetection(img, 1.5, 'Mode', 'xyac');
    if ~isempty(pstruct)
        pstruct = fitGaussians2D(img, pstruct.x, pstruct.y, pstruct.A, 1.5*ones(1,length(pstruct.x)), pstruct.c, 'xyasc');
        isPSF = ~[pstruct.hval_AD] & [pstruct.pval_Ar] < 0.05;
        svect{i} = pstruct.s(~isnan(pstruct.s) & isPSF);
    end
end
svect = [svect{:}];

opts = statset('maxIter', 200);
BIC = zeros(1,3);
sigma = zeros(1,3);
try
    w = warning('off', 'stats:gmdistribution:FailedToConverge');
    for n = 1:3
        obj = gmdistribution.fit(svect', n, 'Options', opts);
        BIC(n) = obj.BIC;
        sigma(n) = obj.mu(obj.PComponents==max(obj.PComponents));
    end
    warning(w);
    sigma = sigma(BIC==min(BIC));
    if ip.Results.Display
        ds = 0.2;
        si = -1:ds:10;
        ni = hist(svect, si);
        ni = ni/sum(ni*ds);
        figure;
        h = bar(si,ni);
        set(h, 'BarWidth', 1);
        
        hold on;
        plot(si, pdf(obj,si'), 'r');
    end
catch
    fprintf('Could not determine distribution, potentially due to insufficient samples.');
    sigma = mean(svect);
end
