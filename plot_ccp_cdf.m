function [ecdf_res, epdf_res, edf_res, t_res] = plot_ccp_cdf(resStruct, varargin)
% plot_ccp_cdf prints a graph of the cumulative lifetime distribution of
% the passed resStruct, in the desired color.
%
% Inputs:
%           resStruct : the results structure returned from cmeAnalysis
%
% Options:
%           Color : color of line to be drawn
%           Graph : axis to draw line on (defaults to current figure)
%           Floor : Smallest lifetime to include in CDF
%       Normalize : Normalize lifetime counts to cell area (px)
%
% Outputs:
%           ecdf_res : the empirical cumulative distribution generated for the graph
%           epdf_res : the empirical probability distribution generated for the graph
%           edf_res  : the absolute empirical distribution generated for the graph
%           t_res    : the lifetime values corresponding with the edf data points

p = inputParser;
p.addOptional('Color', 'b');
p.addOptional('Graph', {});
p.addOptional('Floor', 0, @isscalar);
p.addOptional('Normalize',false, @islogical);
p.parse(varargin{:});

graphColor = p.Results.Color;
graphAxis = p.Results.Graph;
edfFloor = p.Results.Floor;
isNormalized = p.Results.Normalize;


% find the floor
t_res = resStruct.lftRes.t;
startIdx = find(t_res>=edfFloor,1);
t_res = resStruct.lftRes.t(startIdx:end);

lftHist_total = resStruct.lftRes.lftHist_total;

% normalize to cell area
if isNormalized
  cellArea = resStruct.lftRes.cellArea;
  lftHist_total = bsxfun(@rdivide, lftHist_total, cellArea);
end

edf_res = sum(lftHist_total(:,startIdx:end),1);
epdf_res = edf_res/sum(edf_res);
ecdf_res = cumsum(epdf_res);
plot(t_res, ecdf_res, graphColor);

end
