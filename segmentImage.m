

function segmentImages(image_dir_path, image_filename, seg_label_dir_path);

% read image, change color image to brightness image, resize to 240 by something
I = imread_ncut(strcat(image_dir_path, image_filename),240,240);

%perform normalized cut
nbSegments = 2;
disp('computing Ncut eigenvectors ...');
%tic;
[SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,W,imageEdges]= NcutImage(I,nbSegments);

[filename file_ext] = strtok(image_filename, '.');
segmented_image_filename = strcat(filename, '_segmented');

SegLabel = SegLabel - 1;
save(strcat(seg_label_dir_path, segmented_image_filename), 'SegLabel');

