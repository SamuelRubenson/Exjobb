function [structured_data, stocks_data_matrix, index_data_matrix, common_dates] = readTestData(stocks, index)

  if nargin < 2
    index = {};
  end

  all_assets = [stocks, index];

  [structured_data, common_dates] = readFromFiles(all_assets);

  if ~isempty(stocks)
    stocks_data_matrix = getDataForCommonDates(stocks, structured_data, common_dates);
  else
    stocks_data_matrix = [];
  end

  if ~isempty(index)
    index_data_matrix = getDataForCommonDates(index, structured_data, common_dates);
  else
    index_data_matrix = [];
  end

  function [struct_data, common_dates] = readFromFiles(assets)
    struct_data = struct;
    common_dates = false;
    for iStock = 1:length(assets)
      stock_name = assets{iStock};
      fileName = [stock_name, '_data.csv'];
      fileID = fopen(fileName);
      C = textscan(fileID,'%d %s %s %f32 %f32 %f32 %f32 %d %f','HeaderLines',1,'Delimiter',',');
      fclose(fileID);
      dates = C{1}; close = C{7};
      stockdata = struct('dates', dates, 'close',close);
      struct_data = setfield(struct_data, stock_name, stockdata);
      if common_dates
        common_dates = intersect(common_dates, dates);
      else
        common_dates = dates;
      end
    end
  end

  function [complete_data_matrix] = getDataForCommonDates(assets, structured_data, common_dates)
    complete_data_matrix = zeros(length(common_dates), length(assets));
    for iStock = 1:length(assets)
      stock = assets{iStock};
      dates = structured_data.(stock).dates;
      close = structured_data.(stock).close;
      for iDate = 1:length(common_dates)
        date = common_dates(iDate);
        complete_data_matrix(iDate, iStock) = close(dates == date);
      end
    end
  end
  
end
