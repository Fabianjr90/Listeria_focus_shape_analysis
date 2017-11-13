function [arrImage] = fnMass2Image(argMassCoords, argImageSize)

% Reconstruct an image given a representation in the form of masses (dots).
% Location of the masses are provided in the form of XY coordinates
  %
  % Arguments:
  %
  %   argMassCoords = XY coordinates of the masses (dots) (2xN matrix)
  %   argImageSize = size of the image to be reconstructed (e.g. [1024 1024])
  %   optScaleFactor = 
  %
  % Author: Caleb Chan (1/2015)
  % Modified by: Fabian Ortega(2/2016)
  
  
  intNumMasses = length(argMassCoords);
  
  % Since the XY coordinates contain decimal points, we may need to scale up
  % the image resolution in order to preserve that information. Otherwise,
  % rounding up the coordinates to integers may result in many overlapping
  % points
  
  % ***NOTE: Turns out scaling up the image even just by a factor of 10 will
  %          slow things down significantly, possibly due to high memory
  %          usage?
  
  optScaleFactor = 1;  % Stay with no scaling for now
  intEnhancedRowSize = argImageSize(1) * optScaleFactor;  % x = col = width, y = row = height
  intEnhancedColSize = argImageSize(2) * optScaleFactor;  % x = col = width, y = row = height
  
  arrImage = zeros(intEnhancedRowSize, intEnhancedColSize);
  intNumOverlappedMasses = 0;
  
  % Loop through each mass (XY coordinate) in the embedding and place
  % the mass in the image. The coordinates need to be rounded up since
  % image pixel coordinates must be in integers
  for intMass = 1:intNumMasses
    intX = argMassCoords(1, intMass) * optScaleFactor;
    intY = argMassCoords(2, intMass) * optScaleFactor;
    intXRounded = round(intX);
    intYRounded = round(intY);
    
    % Detect for overlapping masses (either from original mass coordinates
    % or from rounding up). Turns out even without rounding or if we scale
    % up the image resolution, there will always be some overlapping
    % masses (masses with weights > 1). For those masses we depend on the
    % EMD algorithm to take care of them
    if (arrImage(intYRounded, intXRounded) > 0)
      intNumOverlappedMasses = intNumOverlappedMasses + 1;

    end
    
    % Accumulate masses at specific image pixels (pixel value > 1 if there are
    % overlapping masses)
    arrImage(intYRounded, intXRounded) = arrImage(intYRounded, intXRounded) + 1;
  end
  
  
end