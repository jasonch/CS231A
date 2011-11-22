function noisyImageSift = filterNoisySift(synset, allSIFTs)

  noisyImageSift = allSIFTs;
  siftImageIDs = IDstructToVector(noisyImageSift, synset);

  % cleamImageIDs = %
  load('cleanImages.mat'); 
  
  noisyImagesSize = size(allSIFTs, 1) - size(cleanImageIDs, 1);
  idx = 1;
  allSiftIndicesWeCareAbout = zeros(noisyImagesSize,1); 
  for i = 1:size(allSIFTs, 1)
      
    siftIndex = find(cleanImageIDs == siftImageIDs(i));
    
    if (size(siftIndex, 1) == 0)
        allSiftIndicesWeCareAbout(idx) = i;
        idx = idx + 1;
    end
  end
  
  noisyImageSift = noisyImageSift(allSiftIndicesWeCareAbout);
  save('noisyImageSift.mat', 'noisyImageSift');   
  
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

