clear, clc
stocks = {'volvo', 'swedbank', 'skf', 'skanska', 'nordea', 'HM', 'ericsson', 'autoliv'};

[struct_data, matrix_data, common_dates] = readTestData(stocks);

figure(2),
plot(matrix_data(:,1))

