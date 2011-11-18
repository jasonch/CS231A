function d = chisquareDistance(h1, h2)
	d = sum((h1-h2).^2 ./(h1+h2))
end
