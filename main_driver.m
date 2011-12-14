
kmeans_clusters=[300];
spatial_levels=[3];
norm_threshold=[4.3];
num_vocab_images=[2500];
jitter_grid_size=[3; 5];
jitter_amount=[0.0625];

for k=1:size(kmeans_clusters,1)
  nK = kmeans_clusters(k);

  for lv=1:size(spatial_levels,1)
    nLV = spatial_levels(lv);

    for n=1:size(norm_threshold,1)
      nN = norm_threshold(n);

      for v=1:size(num_vocab_images,1)
        nV = num_vocab_images(v);

        for js=1:size(jitter_grid_size,1)
          nJS = jitter_grid_size(js);

          for ja=1:size(jitter_amount,1)
            nJA = jitter_amount(ja);
            disp(['k:' num2str(nK) ' lv:' num2str(nLV) ' n:' num2str(nN) ' v:' num2str(nV) ' js:' num2str(nJS) ' ja:' num2str(nJA)]);
            main(nK, nLV, nN, nV, nJS, nJA)
          end
        end
      end
    end
  end
end
