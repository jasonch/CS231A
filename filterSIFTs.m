function filtered_sift = filterSIFTs(synset, allSIFTs, normThresh, shouldFilterSegment)

  filtered_sift = allSIFTs;
  siftImageIDs = IDstructToVector(filtered_sift, synset);

  % cleamImageIDs = %
    load('cleanImages.mat'); 
 
  allSiftIndicesWeCareAbout = zeros(size(cleanImageIDs, 1),1); 
  for i = 1:size(cleanImageIDs,1)
    siftIndex = find(siftImageIDs == cleanImageIDs(i));
    allSiftIndicesWeCareAbout(i) = siftIndex;

    % filter out features with low norm
    threshold = max(filtered_sift(siftIndex).vldsift.norm) * normThresh;
    normFilter = (filtered_sift(siftIndex).vldsift.norm > threshold);
    filtered_sift(siftIndex).vldsift.x = filtered_sift(siftIndex).vldsift.x(normFilter);
    filtered_sift(siftIndex).vldsift.y = filtered_sift(siftIndex).vldsift.y(normFilter);
    filtered_sift(siftIndex).vldsift.scale = filtered_sift(siftIndex).vldsift.scale(normFilter);
    filtered_sift(siftIndex).vldsift.norm = filtered_sift(siftIndex).vldsift.norm(normFilter);
    filtered_sift(siftIndex).vldsift.desc = filtered_sift(siftIndex).vldsift.desc(:,normFilter);

    % filter out features with low norm
    if (shouldFilterSegment)
      % segLabels = %
        load(['segLabels/' synset '_' num2str(cleanImageIDs(i)) '_segmented.mat']);
  

      % convert to pixel locations on segLabels
      width = size(segLabels,2);
      height = size(segLabels,1);
      foregroundIndex = getForegroundIndex(segLabels);
      locations = [round(filtered_sift(siftIndex).x * width); round(filtered_sift(siftIndex).y*height)]';

      % find where seLabels is the foreground
      [rowInd, colInd, ~] = find(segLabels == foregroundIndex);
      % use the indices to contruct a filter that removes other points
      segFilter = ismember(locations, [colInd, rowInd], 'rows');

      filtered_sift(siftIndex).vldsift.x = filtered_sift(siftIndex).vldsift.x(segFilter);
      filtered_sift(siftIndex).vldsift.y = filtered_sift(siftIndex).vldsift.y(segFilter);
      filtered_sift(siftIndex).vldsift.scale = filtered_sift(siftIndex).vldsift.scale(segFilter);
      filtered_sift(siftIndex).vldsift.norm = filtered_sift(siftIndex).vldsift.norm(segFilter);
      filtered_sift(siftIndex).vldsift.desc = filtered_sift(siftIndex).vldsift.desc(:,segFilter);

    end
  end
  filtered_sift = filtered_sift(allSiftIndicesWeCareAbout);
  save('filteredSift.mat', 'filtered_sift');

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

