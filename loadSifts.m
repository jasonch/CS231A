function newSifts = loadSifts(synsetId)
  % image_vldsift = %
  load(strcat(synsetId, '.vldsift.mat'));
  newSifts = image_vldsift;
  
end
