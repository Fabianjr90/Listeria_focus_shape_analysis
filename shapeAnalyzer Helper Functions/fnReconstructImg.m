function [arrReconImg,arrMassCoords] = fnReconstructImg(argImage,thresholdLevel,...
    argNumMasses,argContourLevels,argMassAssignment,argFrameSize)

% Reconstruct an intensity-based image into a dot representation
  %
  % Arguments:
  %
  %   argImage          = any intensity-based image
  %   argBGThreshold    = threshold for background
  %   argFilterSize     = size of the smoothing filter
  %   argImgThreshold   = threshold for image
  %   argNumMasses      = number of masses to be assigned
  %   argContourLevels  = number of contour levels used
  %   argMassAssignment = which assignment algorithm to use
  %   argFrameSize      = the size of each image, assuming [Rows/Y Cols/X]
  %
  % Author: Caleb Chan (4/2015)
  % Modified by: Fabian Ortega(2/2016)

   
    arrImgNoBG = argImage;
    arrImgNoBG(arrImgNoBG < thresholdLevel) = 0;
    arrImgBlur = imfilter(arrImgNoBG,fspecial('disk', 3),'symmetric');
    arrImgNorm = mat2gray(arrImgBlur);
    arrBinMask = imbinarize(arrImgNorm,0.02);
    arrMaskedImage = argImage .* arrBinMask;

  % Apply particle approximation algorithm to the masked image
  arrMassCoords = fnParticleApproximation(arrMaskedImage,...
      argNumMasses, argContourLevels, argMassAssignment);

  % Reconstruct the assigned masses into an image
  arrReconImg = fnMass2Image(arrMassCoords, argFrameSize);
  
end
