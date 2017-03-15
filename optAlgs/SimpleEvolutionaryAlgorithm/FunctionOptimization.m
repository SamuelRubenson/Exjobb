
t = 6000;
signal = signals(t,:);
Qt = Q(:,:,t);
activeI = logical(any(Qt).*(~isnan(signal)));


populationSize = 100;
numberOfGenes = sum(activeI);
crossoverProbability = 0.7;
mutationProbability = 0.025;
tournamentSelectionParameter = 0.75;
numberOfGenerations = 100;
fitness = zeros(populationSize,1);




population = InitializePopulation(populationSize, numberOfGenes);
population(1,:) = double(signal(activeI)>0);

for iGeneration = 1:numberOfGenerations

maximumFitness = 0.0;
xBest = 0;
bestIndividualIndex = 0;

for i = 1:populationSize
    x=population(i,:);
    fitness(i) = EvaluateIndividual(x, Qt(activeI,activeI), signal(activeI));
    if (fitness(i) > maximumFitness)
        maximumFitness = fitness(i);
        bestIndividualIndex = i;
        xBest = x;
    end
end

% Print
%disp('xBest')
%disp(xBest)
%disp('maximumFitness')
%disp(maximumFitness)


tempPopulation = population;

for i = 1:2:populationSize
    i1 = TournamentSelect(fitness,tournamentSelectionParameter);
    i2 = TournamentSelect(fitness,tournamentSelectionParameter);
    chromosome1=population(i1,:);
    chromosome2=population(i2,:);
    
    r=rand;
    if (r < crossoverProbability)
      newChromosomePair = Cross(chromosome1,chromosome2);
      tempPopulation(i,:) = newChromosomePair(1,:);
      tempPopulation(i+1,:) = newChromosomePair(2,:);
    else
      tempPopulation(i,:) = chromosome1;
      tempPopulation(i+1,:) = chromosome2;
    end
end

for i = 1:populationSize
    originalChromosome = tempPopulation(i,:);
    mutatedChromosome = Mutate(originalChromosome,mutationProbability);
    tempPopulation(i,:) = mutatedChromosome;
end

tempPopulation(1,:) = population(bestIndividualIndex,:);
population = tempPopulation;


%plotvector = get(bestPlotHandle, 'YData');
%plotvector(iGeneration) = maximumFitness;
% set(bestPlotHandle, 'YData', plotvector);
% set(textHandle, 'String', sprintf('best: %4.3f', maximumFitness));
% drawnow;

figure(1), hold on
plot(iGeneration, maximumFitness, '*')
drawnow;

end % Loop over generations

%Print final result
disp('xBest')
disp(xBest)
disp('maximumFitness')
disp(maximumFitness)

