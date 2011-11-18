

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

figure(3);clf
bw = edge(SegLabel,0.01);
J1=showmask(I,imdilate(bw,ones(2,2))); imagesc(J1);axis off
saveas(gcf, segmented_image_filename, 'jpg');
close figure(3)

SegLabel = SegLabel - 1;
save(strcat(seg_label_dir_path, segmented_image_filename), 'SegLabel');

