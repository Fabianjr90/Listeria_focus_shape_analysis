function [arrMassCoords] = fnParticleApproximation(argImg, argNumMasses, ...
  argContourLevels, argMassAssignment, optMethod)

% Assign a specific number of masses (points) to an image with distribution
% based on the image's intensity contour map as a means to represent the
% image with reduced dimensionality. More assignment strategies can be
% included in the future as different ways to assign masses over an image
  %
  % Arguments:
  %
  %   argImg = any intensity image
  %   argNumMasses = number of masses to be assigned
  %   optMethod = which assignment algorithm to use (optional)
  %
  % Author: Caleb Chan (1/2015)
  % Modified by: Fabian Ortega(2/2016)

  
%   display(sprintf('  Number of masses = %d', argNumMasses));
  
  switch optMethod
    % Assign masses based on contour levels of the intensity image
    case 'contour'
    
      %-----------------------------------------------------------------
      % ***NOTE: The code in this section is based on the original code
      %          labelled 'Initialize based on contour levels (CC)' in
      %          img2pts_Lloyd.m (under ~/Dropbox/LOT/Codes/Particle)
      %-----------------------------------------------------------------
      
      % Extract contours from image as a stack
      [arrFilledContours, arrContourLevels,~,~] = fnExtractContours(argImg, argContourLevels);
      
      intNumLevels = length(arrContourLevels);
      arrContourSizes = zeros(intNumLevels, 1);
      
      for intContourLevelIdx = 1:intNumLevels
        % Find the number of pixels at each contour level
        arrContourSizes(intContourLevelIdx) = nnz(arrFilledContours(:, :, intContourLevelIdx));
      end
      
      % *** REMARKS ***
      %
      % The non-linear distribution of Nmasses may lead to two effects:
      %
      % (1) The number of Nmasses will need to be increased (the exact number to
      %     be determined empirically in order for the K-means algorithm to
      %     converge in about the same number of loops as before (~5 loops)
      %
      %     Alternatively, one can increase the stopLloyd value so the loop can
      %     terminate at a higher threshold
      %
      % (2) If the scale up factor (the third matrix) pushes up the number of
      %     assigned number of masses by too much, the number of masses assgined
      %     may exceed the number of pixels for that particular contour level.
      %     This problem tends to occur in conjunction to (1), when the number of
      %     masses are increased
      
      % *** BUGS ***
      %
      % (1) Current binning mechanism for different contour levels will lead to
      %     rounding such that the total number of masses assigned does not
      %     equal to Nmasses (Fixed - 20150122)
      %
      %     Suggested fix: calculate the ratio, subtract it from Nmasses, and
      %                    leave the remainder for the remaining levels. This
      %                    will leave the highest or lowest levels always
      %                    getting the short end of the stick (depending on
      %                    whether I subtract from the highest or lowest levels
      %                    first), but this will always guarantee that the
      %                    allocation is exactly Nmasses
      %
      % (2) Looks like the P array (encoding the intensities/weights of the
      %     Nmasses) is screwed up when the contour mechanism is applied (the
      %     weights at the leading edge is very low, and the weights at the
      %     uropod is very high, as revealed by plotting P and Pl with
      %     scatter3()
      %
      % (3) With the contour assignment the original algorithm also seems to be
      %     removing Nmasses for some images, leaving the number of Nmasses
      %     smaller than specified
      %
      %       -> Found out this is due to some points in res_P having NaN
      %          values and res_c of those points having zero values
      
      % Calculate the weight of each contour level, potentially adding
      % non-linear factors for assignment
      
      strAssignmentMethod = argMassAssignment{1};
      
      if (length(argMassAssignment) > 1)
        dblStep = argMassAssignment{2};
      else
        dblStep = 0.0;
      end
      
%       display(sprintf('  Mass assignment = %s/%0.2f', strAssignmentMethod, dblStep));
      
      switch strAssignmentMethod
        case 'Sz'
          arrWeightedContourSizes = arrContourSizes;
        case 'SzLv'
          arrWeightedContourSizes = arrContourSizes .* arrContourLevels;
        case 'SzLvSe'
          % Start = 1, Op = Mult, Step = 1
          arrAssignmentFactor = [];
          for intContourLevelIdx = 1:intNumLevels
            arrAssignmentFactor = [arrAssignmentFactor intContourLevelIdx * dblStep];
          end
          arrWeightedContourSizes = arrContourSizes .* arrContourLevels .* arrAssignmentFactor';
        case 'SzLvEx2e'
          % Start = 0, Op = Exp, Base = 2, Step = 0.5
          arrAssignmentFactor = [];
          for intContourLevelIdx = 1:intNumLevels
            arrAssignmentFactor = [arrAssignmentFactor 2^((intContourLevelIdx - 1) * dblStep)];
          end
          arrWeightedContourSizes = arrContourSizes .* arrContourLevels .* arrAssignmentFactor';
      end
      
      % Sum and calculate the ratio of the total weight for each contour level
      intTotalContourSize = sum(arrWeightedContourSizes);
      arrWeightedContourRatios = arrWeightedContourSizes / intTotalContourSize;
      
      arrOutputIndex = [];
      intRemainingMasses = argNumMasses;
      intTotalNumMasses = 0;
      
      totalDots = 0;
      % Loop through each contour level and find the indices of all pixels with
      % intensities for each contour level
      for intContourLevelIdx = 1:intNumLevels
        % Find all pixels with intensities for this contour level
        arrContourIdx = find(arrFilledContours(:, :, intContourLevelIdx) > 0);
        
        
        % Calculate the number of masses assigned to this contour level
        intLevelMasses = round(argNumMasses * arrWeightedContourRatios(intContourLevelIdx));
        totalDots = totalDots + intLevelMasses;
        
        % However, if we are at the last contour level to assign, we need to
        % consider whether we're over- or under-assigning
        if (intContourLevelIdx == intNumLevels)

          
          % Regardless of whether there are not enough masses left to assign
          % from the bucket, or if there are more than enough, just assign what
          % is left
          intLevelMasses = intRemainingMasses;
        end
        
        intRemainingMasses = intRemainingMasses - intLevelMasses;

        
        % Collect the random assignments
        newAssignment = fnRandSampling(arrContourIdx, intLevelMasses);
        [m,n] = size(newAssignment);
        if n>m
            newAssignment = newAssignment';
        end
        arrOutputIndex = [arrOutputIndex; newAssignment];

        intTotalNumMasses = intTotalNumMasses + intLevelMasses;
      end
      
      [arrRowCoords, arrColCoords] = ind2sub(size(argImg), arrOutputIndex);
      
    otherwise
      
      arrImageIdx = find(arrImg > 0);
      [arrRowCoords, arrColCoords] = fnRandSampling(arrImageIdx, min([argNumMasses, length(arrImageIdx)]));  % Pick argNumMasses number of points by random within pixels with intensities (CC)
      
  end
  arrMassCoords = [arrColCoords'; arrRowCoords'];  % x = col = width, y = row = height
  
end