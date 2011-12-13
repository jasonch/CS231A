function displayClusters(vocab)
    for i=1:size(vocab, 1)
        figure;
        plot(vocab(i,:));
        pause;
        close;
        i
    end
end

