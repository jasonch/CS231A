function filteredSift = filterSIFTs()

  synset = 'n04398044';

  filteredSift = load([ synset '.vldsift.mat' ]);
  filteredSift = filteredSift.image_vldsift;
  siftImageIDs = IDstructToVector(filteredSift, synset);

  % cleamImageIDs = %
    load('cleanImages.mat'); 

  for i = 1:size(cleanImageIDs,1)
    siftIndex = find(siftImageIDs == cleanImageIDs(i));

    % segLabels = %
      load([num2str(cleanImageIDs(i)) '_segment.mat']);
    
    % convert to pixel locations on segLabels
    width = size(segLabels,2);
    height = size(segLabels,1);
    locations = [round(filteredSift(siftIndex).x * width); round(filteredSift(siftIndex).y*height)]';
    for j = 1:size(locations,1)
      if (segLabels(locations(j, 1), locations(j, 2)) == 0)
        % if seglabel is 0, remove the element from sift feature set
        filteredSift(siftIndex).vldsift.x(j) = [];
        filteredSift(siftIndex).vldsift.y(j) = [];
        filteredSift(siftIndex).vldsift.scale(j) = [];
        filteredSift(siftIndex).vldsift.norm(j) = [];
        filteredSift(siftIndex).vldsift.desc(j) = [];
      end
    end
  end

  save('filteredSift.mat', filteredSift);

end

function ids =  IDstructToVector(sift, synset)
  ids = zeros(size(sift,1),1);
  for i = 1:size(sift,1)
    % converts image IDs of the form 'synset_imageId' to numerical imageId
    % and store in the returning vector
    % note using str2double for speed, and rouding to get integer values
    ids(i) = str2double(strrep(sift(i).ID, [synset '_'], ''));
  end
end
