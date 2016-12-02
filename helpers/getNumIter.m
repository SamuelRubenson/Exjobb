function numIter = getNumIter(j)
try
    fileName = which(j.Name);
    f=fopen(fileName);
    txt = fread(f,'*char')';
    fclose(f);
    varName = regexp(txt,'\n\s*parfor[^\=]+\=[^:]+:([^\s]+)','tokens');
    varName = varName{1}{1};
    if ~isnan(str2double(varName))
        numIter = str2double(varName);
    else
        numIter = regexp(txt,['\n\s*' varName '\s*\=\s*([^\s]+)'],'tokens');
        numIter = eval(numIter{1}{1});
    end
catch
    numIter = nan;
end
