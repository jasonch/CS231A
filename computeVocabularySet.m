% this function accepts SIFTs as a Nx128 matrix, where each row is a SIFT feature
% and uses K-means to compute K-clusters on the matrix
% returns the centroids of each cluster in the Kx128 result

% Note parameter k is the number of clusters if using kmeans, but is the
% bandwidth if using meanshift

function vocabulary = computeVocabularySet(sifts,k, useMeanshift)
  siftMatrix = convertSIFT2Matrix(sifts);
  % print out size of sift matrix
  size(siftMatrix)
  % normalize sift matrix
  for i=1:size(siftMatrix,1)
      siftMatrix(i,:) = siftMatrix(i,:) ./ sum(siftMatrix(i,:));
  end

  if (useMeanshift)
      [vocabulary, ~, ~] = MeanShiftCluster(siftMatrix', k, false);
      vocabulary = vocabulary';
  else
      [~, vocabulary] = kmeans(siftMatrix, k, 'emptyaction', 'drop');
      % remove dropped clusters
      vocabulary = vocabulary(~isnan(vocabulary(:,1)));
  end
  
  % print out size of vocabulary
  size(vocabulary)
  
end

% convert sift in object for to a Nx128 matrix, where N is the total
% number of SIFT features in all images
function siftMatrix = convertSIFT2Matrix(siftsObj)
  siftMatrix = [];
  for i=1:size(siftsObj,1)
    normc(siftsObj(i).vldsift.desc');
    siftMatrix = [siftMatrix; siftsObj(i).vldsift.desc'];
  end
end
