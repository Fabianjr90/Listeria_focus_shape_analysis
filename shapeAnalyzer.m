clc;clear;close all;
% this code assigns n mass dots to an image of L. monocytogenes
% spreading (still image) using fluorescence to assign each entry of
% the matrix the appropriate mass.

%% Load image and convert from integer to double
arrImg_raw = fnImRead('test.tif');
arrImg_raw = double(arrImg_raw);
arrImg_raw = imgaussfilt(arrImg_raw, 5);
norm_raw = mat2gray(arrImg_raw);

% create a mask for dot assignment,
% and set threshold level for blurred img
level = 0.04;     
bw = imbinarize(norm_raw,0.04);

% check that your mask (in red) looks good
[B,L] = bwboundaries(bw,'noholes');
figure,imshow(norm_raw)
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end

% clean image, so that dots will only be assigned inside mask
cleanNormRawImg = norm_raw.*bw;

% totalNumDots should ideally be set to the estimated number of bacteria
% at this time point. Use an exponential function (1st or 2nd order) to
% get this number.
totalNumDots = 1e5;

% scale image, so that fluor intensity sums to totalNumDots
imgScaleFactor = totalNumDots/sum(cleanNormRawImg(:));
scaledImg = cleanNormRawImg.*imgScaleFactor;
finalImg = round(scaledImg);
figure,imshow(finalImg,[])

% convert intensity of each pixel into coordinates (~totalNumDots)
[row,col,weight] = find(finalImg);
bactpos = zeros(sum(weight),2);
indexCounter = 1;
for ii = 1:length(weight)
    if weight(ii) == 1
        bactpos(indexCounter,:) = [row(ii),col(ii)];
        indexCounter = indexCounter + 1;
    elseif weight(ii) > 1  
        repDots = repmat( [row(ii),col(ii)],[weight(ii) 1] );
        bactpos(indexCounter:indexCounter+weight(ii)-1,:) = repDots;
        indexCounter = indexCounter + weight(ii);
    end
end



%% we perform a series of statistical test and extract outermost contour
[univarPercent,bvnPercent] = normalityTest(bactpos);
x = bactpos(:,1);
y = bactpos(:,2);
xmax = max(x);
ymax = max(y);
if xmax > ymax
    myLimit = round(xmax+2);
else
    myLimit = round(ymax+2);
end

% Reconstruct the assigned masses into an image and get contours
nContours = 10;
myImage = fnMass2Image([y,x]',[myLimit myLimit]);

[arrFilledContours, arrContourLevels,contourX,contourY] = ...
    fnExtractContours(myImage, nContours);
% hold on
% plot(contourX,contourY,'Linewidth',5,'color','m')
% hold off

% export image of largest contour (to be processed further)
figure,plot(contourX,-contourY,'Linewidth',5,'color','k')
axis equal;
axis off;
fig = gcf;
fig.PaperPositionMode = 'auto';
print('FinalContour','-dtiff','-r0')

% this code uses a .tiff image of the contour to analyze properties
% such as accentricity, perimeter, and area.
% It uses the image processing toolbox (i.e. regionprops)

I = imread('FinalContour.tif');
I2 = double(I(:,:,1));
I3 = mat2gray(I2);
bw = imcomplement(imbinarize(I3));
figure,imshow(bw)

ecc = regionprops(bw,'Eccentricity');
perim = regionprops(bw,'Perimeter');
area = regionprops(bw,'Area');
circularity = (perim.Perimeter^2)/(4*pi*area.Area);
eAnswer = ['eccentricity: ',num2str(ecc.Eccentricity)];
disp(eAnswer)
cAnswer = ['circularity: ',num2str(circularity)];
disp(cAnswer)
