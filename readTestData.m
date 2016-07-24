function [struct_data, complete_data_matrix, common_dates] = readTestData(stocks)

  struct_data = struct;
  common_dates = false;
  for iStock = 1:length(stocks)
    stock_name = stocks{iStock};
    fileName = [stock_name, '_data.csv'];
    fileID = fopen(fileName);
    C = textscan(fileID,'%d %s %s %f32 %f32 %f32 %f32 %d %f','HeaderLines',1,'Delimiter',',');
    dates = C{1}; close = C{7};
    stockdata = struct('dates', dates, 'close',close);
    struct_data = setfield(struct_data, stock_name, stockdata);
    if common_dates
      common_dates = intersect(common_dates, dates);
    else
      common_dates = dates;
    end
  end
  complete_data_matrix = zeros(length(common_dates), length(stocks));
  for iStock = 1:length(stocks)
    stock = stocks{iStock};
    dates = struct_data.(stock).dates;
    close = struct_data.(stock).close;
    for iDate = 1:length(common_dates)
      date = common_dates(iDate);
      complete_data_matrix(iDate, iStock) = close(dates == date);
    end
  end
  
end
