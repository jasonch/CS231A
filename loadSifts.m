function newSifts = loadSifts(dataLoc, synsetId)
  % image_vldsift = %
  load(strcat(dataLoc, synsetId, '.vldsift.mat'));
  newSifts = image_vldsift;
  
end
