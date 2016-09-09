info = dbc.GetBaseInstrumentInfo(names);
assetClasses = {};
for i = 1:length(info)
  assetClasses{end+1} = info(i).AssetClassName;
end