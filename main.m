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
  noisyImageSifts = filterNoisySift(teapotWnid, image_vldsift);
  
  %%
  % compute vocabulary set
  disp(size(filteredSifts, 1));
  disp(size(filteredSifts, 2)); 
  disp('Compute vocab set');
  vocab = computeVocabularySet(filteredSifts, 0.70, true);
  % vocab = computeVocabularySet(filteredSifts, K, false);
  
  %%
  disp('Compute histograms of sifts');
  trainHistograms = sparse(computeHistograms(filteredSifts, vocab));
  trainPosLabels = ones(size(trainHistograms,2), 1);
  
  testHistograms = sparse(computeHistograms(noisyImageSifts, vocab));
  testPosLabels = ones(size(testHistograms,2), 1);

  %%
  % compute histogram for negative examples
  % image_vldsift = %
  load([chairWnid  '.vldsift.mat']);
  chairSifts = image_vldsift(floor(rand(1000,1).*size(image_vldsift,1)) + 1);
  chairHistograms = sparse(computeHistograms(chairSifts, vocab));

  trainChairHists = chairHistograms(:,1:138);
  trainNegLabels = zeros(138, 1);  
  testChairHists = chairHistograms(:,139:1000);
  testNegLabels = zeros(862, 1);
%%
  %randomly permute training data:
  [training_data, training_labels] = randomizeTrainingData([trainHistograms trainChairHists], [trainPosLabels; trainNegLabels]);
  
  % plug into liblinear - train
  addpath('liblinear-1.8\liblinear-1.8\matlab\');
  model = train(training_labels , training_data'); 
  %%
  %randomly permute test data:
  [test_data, test_labels] = randomizeTrainingData([testHistograms testChairHists], [testPosLabels; testNegLabels]);
  [predicted_label, accuracy, decision_vals] = predict(test_labels, test_data', model);
  accuracy
  
  
  
  
  
  
  
