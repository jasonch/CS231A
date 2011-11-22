% this file descirbes a detector using BoW histograms with SIFT features....
  K = 300;
  global display_sift; 
  display_sift = true;
  global hist_threshold;
  hist_threshold = 0.8;
  norm_threshold = 0.3;
  num_chair_images = 1000;
  
  teapotWnid = 'n04398044';
  chairWnid  = 'n03376595';

   %%
  image_vldsift = loadSifts(teapotWnid); 

   %%
  % segment images
  addpath('normalized_cut\');
  disp('Segmenting images...');
  segmentSynSet('images/', 'segLabels/', teapotWnid);
 
  
  %%
  % filter to only images we want and only features in the segment
  % and discard bottom 30% of the features by norm magnitude
  disp('Filtering unwanted sift features...');
  filteredSifts = cleanImagesFilter(teapotWnid, image_vldsift);
  filteredSifts = filterSIFTs(filteredSifts, norm_threshold, false, teapotWnid);
  
  
  %%
  disp('Filtering noisy image sift features...');
  noisyImageSifts = filterNoisySift(teapotWnid, image_vldsift);
  noisyImageSifts = filterSIFTs(noisyImageSifts, norm_threshold, false, '');

  %% load negative images  
  image_vldsift = loadSifts(chairWnid);
  chairSifts = image_vldsift(floor(rand(num_chair_images,1).*size(image_vldsift,1)) + 1);
  chairSifts = filterSIFTS(chairSifts, norm_threshold, false, '');

  %%
  % compute vocabulary set
  disp('Compute vocab set');
  vocab = computeVocabularySet([filteredSifts], 0.5, true);

 
  %%
  disp('Compute histograms of sifts');
  trainHistograms = sparse(computeHistograms(filteredSifts, vocab));
  trainPosLabels = ones(size(trainHistograms,2), 1);
  
  testHistograms = sparse(computeHistograms(noisyImageSifts, vocab));
  testPosLabels = ones(size(testHistograms,2), 1);

  %%
  % compute histogram for negative examples
  chairHistograms = sparse(computeHistograms(chairSifts, vocab));
  trainChairHists = chairHistograms(:,1:138);
  trainNegLabels = zeros(138, 1);  
  testChairHists = chairHistograms(:,139:num_chair_images);
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
  
  
  
  
  
  
  
