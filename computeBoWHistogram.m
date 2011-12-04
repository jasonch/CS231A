function [bow_histogram, sift_to_word] = computeBoWHistogram( sift_descriptors, bow_dictionary )

%given descriptors of an image, return the bow 
global hist_threshold;

[hist_len, ~] = size(bow_dictionary);

bow_histogram = zeros(1, hist_len);
sift_comp_dists = zeros(1, hist_len);
%this is vector that maps each sift descriptor to the index of the word
%cluster in the vocabulary
sift_to_word = zeros(size(sift_descriptors, 1), 1);

for i=1:size(sift_descriptors,2)
    sift_desc = sift_descriptors(:,i)';
    %{
    for j=1:hist_len
        word_mean = bow_dictionary(j,:);
        sift_comp_dists(j) = norm(word_mean - sift_desc, 2);
    end
    %}
    ext_sift_desc = repmat(sift_desc, hist_len, 1);
    sift_comp_dists = sum((bow_dictionary - ext_sift_desc).^2, 2);
    
    [min_val, min_idx] = min(sift_comp_dists);
    if (min_val < hist_threshold^2)
        bow_histogram(min_idx) = bow_histogram(min_idx) + 1; 
        sift_to_word(i) = min_idx;
    end
end

if norm(bow_histogram) ~= 0
    bow_histogram = bow_histogram / norm(bow_histogram);
end

end



%1) find multiple synsets to train on 
%2) for each image in a synset, get SIFT features matrix 

