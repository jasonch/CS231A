
function segmentSynSet(image_dir_path, seg_label_dir_path, synset_id)

load('cleanImages-small.mat');

files = dir(image_dir_path);

if image_dir_path(length(image_dir_path)) ~= '/'
    image_dir_path = strcat(image_dir_path, '/');
end

if seg_label_dir_path(length(seg_label_dir_path)) ~= '/'
    seg_label_dir_path = strcat(seg_label_dir_path, '/');
end

for i=1:length(files)
    filehandle = files(i);
    
    bad_image = true;
    for j=1:length(cleanImageIDs)
        if strcmp(filehandle.name, strcat(synset_id, '_', num2str(cleanImageIDs(j)), '.JPEG'))
            bad_image = false;
        end
    end
    
    if (bad_image)
        continue;
    end
    
    if ( ~(strcmp(filehandle.name, '.') || strcmp(filehandle.name, '..')))
        disp(strcat(image_dir_path, filehandle.name));
        segmentImage(image_dir_path, filehandle.name, seg_label_dir_path);
    end
end
