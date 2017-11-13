function fnImWriteStack(argImages, argOutputFilename)

% Writes an array of images to a file as a stack
  %
  % Arguments:
  %
  %   argImages = a single image or a stack of images (in 3D)
  %   argOutputFilename = filename that the image will be written to
  %
  % Author: Caleb Chan (2012)

  [strPath, strName, strExt] = fileparts(argOutputFilename);
  
  % We only support TIFF files for now
  if ~strcmp(strExt, '.tif')
    error('Output filename must have a .tif extension');
  end
  
  % Delete the file if it already exists
  %
  % TODO: Isn't this really dangerous? Should probably add an optional
  %       argument to force delete - otherwise, if the option is not
  %       specified, a dialog box should pop up and ask for confirmation to
  %       overwrite. Better yet, add a locking mechanism to first write the
  %       new file, and only delete the old one if the file write is OK
  %
  if exist(argOutputFilename, 'file') == 2
    display(sprintf('File %s already exists. Overwiting...', argOutputFilename));
    delete(argOutputFilename);
  end
  
  % Loop and write each frame to the file
  for intIndex = 1:size(argImages, 3)
    arrFrame = argImages(:, :, intIndex);
    
    % The option 'Compression = none' causes binary/logical images to be
    % written as 8-bit images. Therefore, I left it out
    %
    %    imwrite(arrFrame, argOutputFilename, 'tif', ...
    %      'Compression', 'none', 'WriteMode', 'append');
    %
    imwrite(arrFrame, argOutputFilename, 'tif', 'WriteMode', 'append');
  end
  
end
