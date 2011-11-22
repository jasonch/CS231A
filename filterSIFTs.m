% this function filters SIFTS by discarding NORMTHRESH, which is [0,1], of the 
% features by norm magnitude
% If SHOULDFILTERSEGMENT, then looks up segmented matrix from 'segLabel/SYNSET_<imageID>_segmented.mat' and filters out all features outside the foreground segment

function filtered_sift = filterSIFTs(sifts, normThresh, shouldFilterSegment, synset)

  filtered_sift = sifts;

  for ind = 1:size(sifts,1)

    % filter out features with low norm
    threshold = max(filtered_sift(ind).vldsift.norm) * normThresh;
    normFilter = (filtered_sift(ind).vldsift.norm > threshold);
    filtered_sift(ind).vldsift.x = filtered_sift(ind).vldsift.x(normFilter);
    filtered_sift(ind).vldsift.y = filtered_sift(ind).vldsift.y(normFilter);
    filtered_sift(ind).vldsift.scale = filtered_sift(ind).vldsift.scale(normFilter);
    filtered_sift(ind).vldsift.norm = filtered_sift(ind).vldsift.norm(normFilter);
    filtered_sift(ind).vldsift.desc = filtered_sift(ind).vldsift.desc(:,normFilter);

    % filter out features with outside of segmented foreground 
    if (shouldFilterSegment)
      % segLabels = %
        load(['segLabels/' synset '_' num2str(filtered_sift(ind).ID) '_segmented.mat']);
  

      % convert to pixel locations on segLabels
      width = size(segLabels,2);
      height = size(segLabels,1);
      foregroundIndex = getForegroundIndex(segLabels);
      locations = [round(filtered_sift(ind).x * width); round(filtered_sift(ind).y*height)]';

      % find where seLabels is the foreground
      [rowInd, colInd, ~] = find(segLabels == foregroundIndex);
      % use the indices to contruct a filter that removes other points
      segFilter = ismember(locations, [colInd, rowInd], 'rows');

      filtered_sift(ind).vldsift.x = filtered_sift(ind).vldsift.x(segFilter);
      filtered_sift(ind).vldsift.y = filtered_sift(ind).vldsift.y(segFilter);
      filtered_sift(ind).vldsift.scale = filtered_sift(ind).vldsift.scale(segFilter);
      filtered_sift(ind).vldsift.norm = filtered_sift(ind).vldsift.norm(segFilter);
      filtered_sift(ind).vldsift.desc = filtered_sift(ind).vldsift.desc(:,segFilter);

    end
  end

end

