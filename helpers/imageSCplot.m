[T,N] = size(outCome.General.dZ);
classes = unique(assetClasses);
nC = numel(classes);
cInd = nan(nC,N); 
for i = 1:nC
  cInd(i,:) = cellfun(@(c)strcmp(c,classes{i}), assetClasses);
end
%%
%close all
models = fieldnames(outCome.Models);


for iModel = 1:numel(models)
pos_ordered = [];
names_ordered = {};
for iC = 1:nC
  ind = logical(cInd(iC,:));
  classPos = outCome.Models.(models{iModel}).pos(:,ind);
  %[~, order] = sort(nanmean(abs(classPos),1)); 
  classPos = classPos./repmat(max(abs(classPos),[],1),T,1); % scale
  pos_ordered = [pos_ordered, classPos];
  names_ordered = [names_ordered, names(ind)];
end
figure(), hold on, title(models{iModel})
imagesc(pos_ordered')
colorbar
set(gca,'ytick',1:N,'yticklabel',regexprep(names_ordered,'\_','\\_'),'ylim',[0 length(names)+2],'ygrid','on');
end