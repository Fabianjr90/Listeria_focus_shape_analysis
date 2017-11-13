function arrImage = fnImRead(argFilename)

% Returns a 3D array of images, with each image occupying the first 2
% dimensions. Accepts either a single frame TIFF file or TIFF stack
  %
  % Arguments:
  %
  %   argFilename = filename of image to be read
  %
  % Author: Caleb Chan (2012)

  structFileInfo = imfinfo(argFilename);  % Get file info
  intNumImages = numel(structFileInfo);   % Get number of images

  % Read in all 2D images and stack them into a 3D array
  for intIndex = 1:intNumImages
    arrImage(:, :, intIndex) = imread(argFilename, intIndex, 'Info', structFileInfo);
  end

end
