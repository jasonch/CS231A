function visualizeBBoxes(sifts, detected_labels, decision_vals, num, label)

  [rows, ~] = find(detected_labels == label);
  rows = unique(rows);

  for i=1:num

    [~, bbox_index] = max(decision_vals(rows(i),:,label))
    %bbox_index = max(find(detected_labels(rows(i),:) == 1));

    if (bbox_index == 1)
      lv = 1;
    elseif (bbox_index <= 5)
      lv = 2;
      bbox_index = bbox_index -1;
    elseif (bbox_index <= 14)
      lv = 3;
      bbox_index = bbox_index -5;
    else
      lv = 4;
      bbox_index = bbox_index -14;
    end
    x_ind = floor((bbox_index-1)/lv)+1;
    y_ind = mod(bbox_index-1,lv)+1;
 
    xbounds = linspace(0,1,lv+1);
    ybounds = 1 - linspace(0,1,lv+1);
    bbox_x = [xbounds(x_ind) xbounds(x_ind+1) xbounds(x_ind+1) xbounds(x_ind) xbounds(x_ind)];
    bbox_y = [ybounds(y_ind) ybounds(y_ind) ybounds(y_ind+1) ybounds(y_ind+1) ybounds(y_ind)];


    img=imread(['images/' sifts(rows(i)).ID '.JPEG']);
    figure; imagesc(img); hold on;
    [Inr, Inc, nb] = size(img);
    plot(bbox_x * Inc, bbox_y * Inr, 'b+', linewidth, 5);

  end

end
