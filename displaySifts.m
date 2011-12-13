function displaySifts(sifts)

  for i=1:20%size(sifts,1)
    filepath = [sifts(i).ID '.JPEG'];
    try 
        img = imread(filepath);
        [Inr, Inc, ~] = size(img);
        figure; imagesc(img); hold on;
        plot((sifts(i).vldsift.x' * Inc), (sifts(i).vldsift.y' * Inr), 'none.dr');
        features = [];
        features = [features (sifts(i).vldsift.x' * Inc)];
        features = [features (sifts(i).vldsift.y' * Inr)];
        features = [features ones(size(sifts(i).vldsift.x, 2),1)];%2.0.^(-1.0 * sifts(i).vldsift.scale(1:1000)')];%sifts(i).vldsift.scale(1:10)'];
        plotsiftdescriptor(sifts(i).vldsift.desc, features');
        hold off;
    catch e
      disp('image read didnt work');
    end
    pause;
  end
  
end

function displaySifts2(sifts)

  for i=1:20%size(sifts,1)
    img=imread([sifts(i).ID '.JPEG']);
    figure; imagesc(img); hold on;
    [Inr, Inc, ~] = size(img);
    plot(sifts(i).vldsift.x * Inc, sifts(i).vldsift.y * Inr, 'none.dr')%'b+')  
    hold off;
    pause;
    close;
  end
  
end

%{
img=imread('./images/n04398044_775.JPEG');
figure; imagesc(img); hold on;
[Inr, Inc, nb] = size(img);
plot(noisy_sifts(52).vldsift.x * Inc, noisy_sifts(52).vldsift.y * Inr, 'b+')
%}