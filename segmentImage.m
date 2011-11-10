

function segmentImages(image_filename);

% read image, change color image to brightness image, resize to 240 by something
I = imread_ncut(image_filename,240,240);

%perform normalized cut
nbSegments = 2;
disp('computing Ncut eigenvectors ...');
%tic;
[SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,W,imageEdges]= NcutImage(I,nbSegments);

[filename file_ext] = strtok(image_filename, '.');
segmented_image_filename = strcat(filename, '_segmented');

SegLabel = SegLabel - 1;
save(segmented_image_filename, 'SegLabel');

