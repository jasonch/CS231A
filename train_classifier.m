function image_labels = train_classifier( sift_descriptors, bow_dictionary )

%given descriptors of an image, return the bow 

[hist_len, ~] = size(bow_dictionary);

image_labels = zeros(1, hist_len);
sift_comp_dists = zeros(1, hist_len);

for i=1:hist_len
    sift_desc = sift_descriptors(i,:);
    
    for j=1:hist_len
        word_mean = bow_dictionary(j,:);
        sift_comp_dists(j) = norm(word_mean - sift_desc, 2);
    end
    
    [~, min_idx] = min(sift_comp_dists);
    
    image_labels(min_idx) = image_labels(min_idx) + 1; 
end

end



%1) find multiple synsets to train on 
%2) for each image in a synset, get SIFT features matrix 

