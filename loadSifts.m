function newSifts = loadSifts(synsetId)
  % image_vldsift = %
   load([synsetId '.vldsift.mat']);

  newSifts = image_vldsift;

  % they should be normalized already
  %for i=1:size(image_vldsift,1)
  %  newSifts(i).vldsift.desc = normc(image_vldsifts(i).vldsift.desc');
  %end
  
end
