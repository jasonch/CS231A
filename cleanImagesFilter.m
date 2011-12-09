function [cleanSifts, noisySifts] = cleanImageFilter(synset, allsifts)


  sifts = allsifts;
  siftImageIDs = IDstructToVector(allsifts, synset);
 
  % cleanImageIDs = %
  load(strcat(synset, '_clean.mat')); 

  cleanFilter = ismember(siftImageIDs, cleanImageIDs);

  cleanSifts = sifts(cleanFilter); 
  noisySifts = sifts(~cleanFilter);
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

