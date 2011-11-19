% this file descirbes a detector using BoW histograms with SIFT features....
  K = 300;
  teapotWnid = 'n04398044';
  chairWnid  = 'n03376595';
   %%
  % image_vldsift = %
   load([teapotWnid '.vldsift.mat']);

   %%
  % segment images
  addpath('normalized_cut\');
  disp('Segmenting images...');
  segmentSynSet('images/', 'segLabels/', teapotWnid);
 
  %%
  % filter to only images we want and only features in the segment
  disp('Filtering unwanted sift features...');
  filteredSifts = filterSIFTs(teapotWnid, image_vldsift, false);
  
  %%
  disp('Filtering noisy image sift features...');
  noisyImageSift = filterNoisySift(teapotWnid, image_vldsift);
  
  %%
  % compute vocabulary set
  disp(size(filteredSifts, 1));
  disp(size(filteredSifts, 2)); 
  disp('Compute vocab set');
  vocab = computeVocabularySet(filteredSifts, 0.70, true);
  % vocab = computeVocabularySet(filteredSifts, K, false);
  
  %%
  disp('Compute histograms of sifts');
  histograms = sparse(computeHistograms(filteredSifts, vocab));
  posLabels = ones(size(histograms,2), 1);

  %%
  % compute histogram for negative examples
  % image_vldsift = %
    load([chairWnid  '.vldsift.mat']);
  chairSifts = image_vldsift(floor(rand(1000,1).*size(image_vldsift,1)) + 1);
  chairHistograms = sparse(computeHistograms(chairSifts, vocab));
%%
  negLabels = zeros(1000,1);

  %randomly permute training data:
  [training_data, training_labels] = randomizeTrainingData([histograms chairHistograms], [posLabels; negLabels]);
  
  % plug into liblinear - train
  addpath('liblinear-1.8\liblinear-1.8\matlab\');
  model = train(training_labels , training_data', '-v 10'); 
  
  
  
  
  
  
  
  
  
  
  
