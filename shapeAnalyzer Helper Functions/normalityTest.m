function [uniTest, biTest] = normalityTest(bactpos,k,allTrials)

% this function will sample bactpos (without replacement) k times
% for a total number of "allTrials," it will ask if normal or not
% uses Lilliefors test for univariate case
% uses Henze-Zirkler's test for bivariate case
% Author: Fabian Ortega(10/2017)

if nargin == 1
    k = 500;
    allTrials = 100;
end


isNormal = 0;
isBVN = 0;

for ii = 1:allTrials
    myDataSample = datasample(bactpos,k,'Replace',false);
    x = myDataSample(:,1);
    y = myDataSample(:,2);
    D = [x;y];
    
    if lillietest(D,'Alpha',0.05)==0
        isNormal = isNormal + 1;
    end
    
    if HZmvntest(myDataSample,1,0.05)==0
        isBVN = isBVN + 1;
    end
end
uniTest = (isNormal/allTrials)*100;
biTest = (isBVN/allTrials)*100;

end