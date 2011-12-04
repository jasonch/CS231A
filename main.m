% this file descirbes a detector using BoW histograms with SIFT features....
   %% constants
   % CHECK ALL THESE BEFORE RUNNING!!
  global display_sift; 
  display_sift = false;
  global hist_threshold;
  hist_threshold = 0.8;
  global data_path; % top level path to where SIFT matrices images, and segLabels are stored
  %data_path = '/tmp/';
  data_path = './';

  useMeanshift = false; K = 500; % K for kmeans
  useMeanshift = true;  K = 0.68; % bandwidth for meanshift
  norm_threshold = 0.3; % percentage of maximum norm
  num_chair_images = 1000;
  num_vocab_images = 2000;
  
  teapotWnid = 'n04398044';
  chairWnid  = 'n03376595';

   %%
  % segment images
  if (ispc)
    addpath('normalized_cut\');
  else
    addpath('normalized_cut/');
  end
  disp('Segmenting images...');
  %segmentSynSet([data_path 'images/'], [data_path 'segLabels/'], teapotWnid);
 
  
  %%
  % filter to only images we want and only features in the segment
  % and discard bottom 30% of the features by norm magnitude
  image_vldsift = loadSifts(data_path, teapotWnid); 

  disp('Filtering clean and noisy sift features...');
  [filteredSifts, noisySifts] = cleanImagesFilter(teapotWnid, image_vldsift);
  filteredSifts = filterSIFTs(filteredSifts, norm_threshold, false, teapotWnid);
  noisySifts    = filterSIFTs(noisySifts   , norm_threshold, false, '');
  
  %% load negative images  
  chairSifts = loadSifts(data_path, chairWnid);
  chairSifts = chairSifts(randsample(size(chairSifts,1), num_chair_images));
  chairSifts = filterSIFTs(chairSifts, norm_threshold, false, '');

  %%
  % compute vocabulary set
  disp('Compute vocab set');
  allSifts = [filteredSifts; noisySifts; chairSifts];
  size(allSifts)
  randomSiftDescs = allSifts(randsample(size(allSifts,1), num_vocab_images));
  size(randomSiftDescs);
  vocab =   computeVocabularySet(randomSiftDescs, K, useMeanshift);
  %load('vocabPoint50WindowSize.mat');
 
  %%
  disp('Compute histograms of sifts');
  trainHistograms = sparse(computeHistograms(filteredSifts, vocab));
  trainPosLabels = ones(size(trainHistograms,2), 1);
  
  testHistograms = sparse(computeHistograms(noisySifts, vocab));
  testPosLabels = ones(size(testHistograms,2), 1);
  
  %%
  % compute histogram for negative examples
  % use unrelated synset for negative examples. Use the same number of negative examples
  % as positive exapmles
  num_pos_examples = size(trainHistograms,2);
  chairHistograms = sparse(computeHistograms(chairSifts, vocab));
  trainChairHists = chairHistograms(:,1:num_pos_examples);
  trainNegLabels = zeros(num_pos_examples, 1);  
  testChairHists = chairHistograms(:, (1+num_pos_examples):num_chair_images);
  testNegLabels = zeros(num_chair_images-num_pos_examples, 1);
%%
  %randomly permute training data:
  [training_data, training_labels] = randomizeTrainingData([trainHistograms trainChairHists], [trainPosLabels; trainNegLabels]);

  % plug into liblinear - train
  if (ispc)
    addpath('liblinear-1.8\liblinear-1.8\matlab\');
  else
    addpath('liblinear-1.8/liblinear-1.8/matlab/');
  end 
  %model = train(training_labels , training_data'); 
  model = train(training_labels(1:20) , training_data(1:20)', '-e 0.1 -v 15 -s 2 -B 1'); 
  size(trainHistograms)
  size(trainChairHists)
  
  %%
  %randomly permute test data:
  [test_data, test_labels] = randomizeTrainingData([testHistograms testChairHists], [testPosLabels; testNegLabels]);
  [predicted_label, accuracy, decision_vals] = predict(test_labels, test_data', model);
  accuracy
  
