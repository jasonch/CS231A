% this function accepts SIFTs as a Nx128 matrix, where each row is a SIFT feature
% and uses K-means to compute K-clusters on the matrix
% returns the centroids of each cluster in the Kx128 result

% Note parameter k is the number of clusters if using kmeans, but is the
% bandwidth if using meanshift

function vocabulary = computeVocabularySet(sifts, k, useMeanshift)

  % concat features from both the sift objects passed in
  siftMatrix = convertSIFT2Matrix(sifts);

  % down sample the data space to prevent memory issues
  if (size(siftMatrix,1) > 30000)
    siftMatrix = siftMatrix(randsample(size(siftMatrix,1), 30000), :);
  end

  %save('allSifts', 'siftMatrix');

  if (useMeanshift)
      [vocabulary, ~, ~] = MeanShiftCluster(siftMatrix', k, false);
      vocabulary = vocabulary';
  else
      [~, vocabulary] = kmeans(siftMatrix, k, 'emptyaction', 'drop');
      % remove dropped clusters
      vocabulary = vocabulary(~isnan(vocabulary(:,1)));
  end

  % normalize the centroids 
  vocabulary = normc(vocabulary')';

  % print out size of vocabulary
  size(vocabulary)
  
end
