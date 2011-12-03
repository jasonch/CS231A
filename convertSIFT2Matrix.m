% convert sift in object for to a Nx128 matrix, where N is the total
% number of SIFT features in all images
function siftMatrix = convertSIFT2Matrix(siftsObj)

  % compute the total number of features so we can preallocate the siftMatrix
  numFeatures =0;
  for i=1:size(siftsObj,1)
    numFeatures = numFeatures + size(siftsObj(i).vldsift.desc, 2);
  end
  numFeatures
  siftMatrix = zeros(numFeatures, 128);

  lower_bound = 1;
  for i=1:size(siftsObj,1)

    upper_bound = lower_bound + size(siftsObj(i).vldsift.desc,2) - 1;
    siftMatrix(lower_bound:upper_bound,:) = siftsObj(i).vldsift.desc';
    lower_bound = upper_bound + 1;

    if mod(i, 50) == 0
        i
    end
  end
end
