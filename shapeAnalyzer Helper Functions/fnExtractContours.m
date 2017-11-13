function [arrFilledContours, arrContourLevels, x, y] = fnExtractContours(argImg, optNumLevels)
% Omega is the contour number to extract (1 = lowest level. Higher it is,
% the hiher you get to the peak of the mountain

% Extract a filled contour map from an intensity image so that regions of
% the same contour level can be extracted for processing
  %
  % Arguments:
  %
  %   argImg = any intensity image
  %   optNumLevels = number of contour levels used (optional)
  %
  % Author: Caleb Chan (1/2015)
  % Modified by: Fabian Ortega(2/2016)
  
  
  % Default contour levels = 8
  if (~exist('optNumLevels', 'var'))
    optNumLevels = 8;
  end
  
  display(fprintf('  Number of contour levels = %d', optNumLevels));
  
  %% Extract contours from the image
  intImgSize = size(argImg, 1);

  figure
  [arrContour,h] = imcontour(argImg, optNumLevels);
  h.LineWidth = 3;
  axis equal;
  axis off;
  s = contourdata(arrContour);
  
  myLens = zeros(length(s),1);
  for ii = 1:length(s)
      myLens(ii) = length(s(ii).xdata);
  end
  omega = find(myLens==max(myLens));
  
  x = s(omega).xdata;
  y = s(omega).ydata;

  %% Extract contour data from the contour objects
  
  % Initialize cell arrays for storing contour coordinates (xy) and
  % levels (z)
  zdata = num2cell(extractfield(s, 'level'))';
  num_patches = length(zdata);
  xdata = cell(num_patches,1);
  ydata = cell(num_patches,1);

  for ii = 1:num_patches
      xdata{ii} = s(ii).xdata;
      xdata{ii} = round(xdata{ii});
      ydata{ii} = s(ii).ydata;
      ydata{ii} = round(ydata{ii});
  end

  arrContourLevels = sort(unique(cell2mat(zdata)), 1, 'ascend');  % Created sorted level list
  intNumLevels = length(arrContourLevels);  % Get number of levels
  
  %% Initialize contour image stack
  
  arrImgs = double(zeros(intImgSize, intImgSize, intNumLevels));
  arrImg = double(zeros(intImgSize, intImgSize));    
    
  %% Loop over each contour, fill them up, and merge contours of the same
  %  level onto the same image
    
  for intContour = 1:num_patches
    
    % Create a binary mask of the contour
    arrImg(:, :) = 0;
    arrImg(sub2ind([intImgSize intImgSize], ydata{intContour}, xdata{intContour})) = 1; % y = row, x = col    
    intContourLevelIdx = find(arrContourLevels == zdata{intContour});  % Find the level index
    
    % Perform a bitwise merge of this contour with the other contours of
    % the same level
    arrImgs(:, :, intContourLevelIdx) = bitor(arrImgs(:, :, intContourLevelIdx), arrImg);
    
  end
  
  %% Fill each contour region with their contour level values and extract
  %  these regions
  
  % Sum contours with different levels into one image, with contour
  % outline values reflecting their levels
  arrImgsSumWithLevels = sum(arrImgs .* ...
    repmat(reshape(arrContourLevels, 1, 1, length(arrContourLevels)), intImgSize, intImgSize), 3);
  
  %arrImgsSumWithLevels(find(arrImgsSumWithLevels > max(arrContourLevels))) = min(arrContourLevels);
  
  % Fill the contours. Areas with the same level will be filled with values
  % that is the same as their contour levels
  arrImgsSumWithLevelsFilled = imfill(arrImgsSumWithLevels);
  
  % TODO: Summing up the different contours will result in pixel values
  %       that are much higher than the original contour levels, since
  %       rounding up the xy coordinates will result in overlapping pixels
  %       betweeb different contour levels
  %
  %       For now, I set all pixel values that are over the limit to the
  %       max contour level value
  arrImgsSumWithLevelsFilled(find(arrImgsSumWithLevelsFilled > max(arrContourLevels))) = max(arrContourLevels);
  
  %% Return the filled contour regions in the form of a stack, with each
  %  image in the stack corresponding to one contour level
  
  for intContourLevelIdx = 1:intNumLevels
    arrImg(:, :) = 0;
    intContourLevel = arrContourLevels(intContourLevelIdx);
    
    arrImg(find(arrImgsSumWithLevelsFilled == intContourLevel)) = intContourLevel;
    arrImgs(:, :, intContourLevelIdx) = arrImg;
  end
  
  arrFilledContours = arrImgs;
  
end
