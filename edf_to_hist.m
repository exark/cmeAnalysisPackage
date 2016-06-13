function [compressed_hist, bin_center] = edf_to_hist(resStruct, varargin)
% edf_to_hist takes the empirical distribution of lifetimes from
% cmeAnalysis and compresses it to an arbitrary number of bins
%
% Inputs:
%           resStruct : the results structure returned from cmeAnalysis
%
% Options:
%           NBins     : number of bins to use (default: 5)
%           BinBounds : Boundaries on bins
%           Floor     : Lowest lifetime included in bins
%
% Outputs:
%           compressed_hist : fractional representation around bin
%           boundaries
%           bin_centers : bin centers, for graphing

p = inputParser;
p.addOptional('NBins', 8, @isscalar);
p.addOptional('BinBounds', []);
p.addOptional('Floor', 0, @isscalar);
p.parse(varargin{:});

timings = resStruct.lftRes.t;
first_ind = find(timings >= p.Results.Floor,1);
timings = timings(first_ind:end);
sn_hist = sum(resStruct.lftRes.lftHist_total,1)/sum(sum(resStruct.lftRes.lftHist_total,1));
sn_hist = sn_hist(first_ind:end);


if isempty(p.Results.BinBounds)
    bin_bounds = linspace(min(timings),max(timings),p.Results.NBins);
    [counts, bin_map] = histc(timings, bin_bounds);
else
    [counts, bin_map] = histc(timings, p.Results.BinBounds);
end

compressed_hist = [];
bin_center = [];

for i = 1:length(counts)
    binMembers = (bin_map == i);
    compressed_hist(i) = sum(sn_hist(binMembers));
    bin_center(i) = mean(timings(binMembers));
end