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

  %useMeanshift = false; K = 500; % K for kmeans
  useMeanshift = true;  K = 0.7; %0.68; % bandwidth for meanshift
  norm_threshold = 0.3; % percentage of maximum norm
  %num_chair_images = 1000;
  num_vocab_images = 15;%2000
  
  wordnet_ids = {'n04398044', 'n03376595'};
  %teapotWnid = 'n04398044';
  %chairWnid  = 'n03376595';

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
  
  filtered_sifts = [];
  noisy_sifts = [];
  trainingLabels = [];
  testingLabels = [];
  
  disp('Filtering clean and noisy sift features...');
  for i=1:size(wordnet_ids, 2)
      image_vldsift = loadSifts(data_path, char(wordnet_ids(i)));
      [filteredSifts, noisySifts] = cleanImagesFilter(char(wordnet_ids(i)), image_vldsift);
      tmp =  filterSIFTs(filteredSifts, norm_threshold, false, wordnet_ids(i));%TODO: look inside filterSIFTs
      filtered_sifts = cat(1, filtered_sifts, tmp);
      trainingLabels = [trainingLabels; ((i-1) * ones(size(tmp), 1))];
      tmp = filterSIFTs(noisySifts, norm_threshold, false, '');%TODO change norm thresh
      noisy_sifts = cat(1, noisy_sifts, tmp);
      testingLabels = [testingLabels; ((i-1) * ones(size(tmp), 1))];
  end

  %%
  % compute vocabulary set
  disp('Compute vocab set');
  
  allSifts = [filtered_sifts; noisy_sifts];
  size(allSifts)
  randomSiftDescs = allSifts(randsample(size(allSifts,1), num_vocab_images));
  size(randomSiftDescs);
  vocab =   computeVocabularySet(randomSiftDescs, K, useMeanshift);
  %load('vocabPoint50WindowSize.mat');
 
  %%
  disp('Compute histograms of sifts');
  trainHistograms = sparse(computeHistograms(filtered_sifts, vocab));
  testHistograms = sparse(computeHistograms(noisy_sifts, vocab));

%%
  %randomly permute training data:
  [train_data, train_labels] = randomizeTrainingData(trainHistograms, trainingLabels);

  % plug into liblinear - train
  if (ispc)
    addpath('liblinear-1.8\liblinear-1.8\matlab\');
  else
    addpath('liblinear-1.8/liblinear-1.8/matlab/');
  end 
  svm_options = ['-e 0.1 -v 100 -s ' int2str(size(wordnet_ids, 2))];
  model = train(train_labels, train_data', svm_options); 
  %model = train([training_labels(1:15)' training_labels(1:15)' training_labels(1:15)']' , [training_data(:, 1:15) training_data(1:15) training_data(1:15)]', '-e 0.1 -v 50 -s 1'); 
  %model = train(repmat(training_labels(1:150), 1, 1), repmat(training_data(:,1:150)', 1, 1), '-e 0.1 -v 30 -s 1');
  size(trainHistograms)
  
  %%
  %randomly permute test data:
  [test_data, test_labels] = randomizeTrainingData(testHistograms, testingLabels);
  [predicted_label, accuracy, decision_vals] = predict(test_labels, test_data', model);
  accuracy
  
