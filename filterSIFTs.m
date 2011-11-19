function filteredSift = filterSIFTs(synset, allSIFTs, shouldFilterSegment)

  filteredSift = allSIFTs;
  siftImageIDs = IDstructToVector(filteredSift, synset);

  % cleamImageIDs = %
    load('cleanImages.mat'); 
 
  allSiftIndicesWeCareAbout = zeros(size(cleanImageIDs, 1),1); 
  for i = 1:size(cleanImageIDs,1)
    siftIndex = find(siftImageIDs == cleanImageIDs(i));
    allSiftIndicesWeCareAbout(i) = siftIndex;

    if (shouldFilterSegment)
      % segLabels = %
        load(['segLabels/' synset '_' num2str(cleanImageIDs(i)) '_segmented.mat']);
        foregroundIndex = getForegroundIndex(segLabels);
    
      % convert to pixel locations on segLabels
      width = size(segLabels,2);
      height = size(segLabels,1);
      locations = [round(filteredSift(siftIndex).x * width); round(filteredSift(siftIndex).y*height)]';
      for j = 1:size(locations,1)
        if (segLabels(locations(j, 1), locations(j, 2)) ~= foregroundIndex)
          % if seglabel is 0, remove the element from sift feature set
          filteredSift(siftIndex).vldsift.x(j) = [];
          filteredSift(siftIndex).vldsift.y(j) = [];
          filteredSift(siftIndex).vldsift.scale(j) = [];
          filteredSift(siftIndex).vldsift.norm(j) = [];
          filteredSift(siftIndex).vldsift.desc(j) = [];
        end
      end
    end % end if (shouldFilterSegment)
  end

  filteredSift = filteredSift(allSiftIndicesWeCareAbout);
  save('filteredSift.mat', 'filteredSift');

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

