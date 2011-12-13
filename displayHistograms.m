function displayHistograms(histograms)
    for i=1:size(histograms, 2)
        figure;
        plot(histograms(:,i));
        pause;
        close;
        i
    end
end