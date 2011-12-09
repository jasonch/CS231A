function addPathByPlatform(path)
  if (ispc)
    addpath(strrep(path, '/', '\'));
  else
    addpath(strrep(path, '\', '/'));
  end
end
