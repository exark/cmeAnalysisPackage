function [fractionDist, cumDist] = g4pLifetimeHistogram(theResStruct)
% g4pLifetimeHistogram takes lftHist_total from a results structure
% generated by cmeAnalysis. This outputs the data (initially generated as
% an absolute histogram) as both a fractional histogram and as a cumulative
% distribution.

theHist=theRes.lftRes.lftHist_total;
fractionDist=[];

for i=1:size(theHist,1)
    fractionDist(i,:) = theHist(i,:)/sum(theHist(i,:));
end

cumDist = cumsum(theHist,2);