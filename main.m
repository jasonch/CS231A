% this file descirbes a detector using BoW histograms with SIFT features....
  K = 500;
  teapotWnid = 'n04398044';
  chairWnid  = 'n03376595';

  % image_vldsift = %
   load([teapotWnid '.mat']);

  % segment images
  segmentSynset('images/', 'segLabels/');
 
  % filter to only images we want and only features in the segment
  filteredSifts = filterSIFTs(image_vldsift);
  
  % compute vocabulary set
  vocab = computeVocabularySet(filteredSifts, K);
  histograms = sparse(computeHistograms(filteredSifts, vocab));
  posLabels = ones(size(histogram,2), 1);

  % compute histogram for negative examples

  % image_vldsift = %
    load([chairWnid  '.mat']);
  chairSifts = image_vldsift(rand(1000,1)*size(chairSifts,1) + 1);
  chairHistograms = sparse(computeHistograms(chairSifts, vocab));
  negLabels = zeros(size(1000,1));

  % plug into liblinear - train
  addpath('liblinear-1.8\liblinear-1.8\matlab\');
  model = train([posLabels; negLabels] , [histograms chairHistograms], '-v 3'); 
