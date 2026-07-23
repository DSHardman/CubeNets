% load("classify.mat");

%1: 1touch
%2: 1conduct
%3: 1press
%4: 2touch
%5: 2conduct
%6: 2press

tokeep = [2 3 5 6];
inds = find(ismember(combis, tokeep));

responses = datas(inds, :) - baselines(inds, :);
% responses = datas(inds, :);
respcombis = combis(inds);

close all
subplot(1,2,1);
Y = tsne(responses);
gscatter(Y(:,1), Y(:,2), respcombis);

subplot(1,2,2);
ks = kmeans(responses, 4);
for i = 1:60
    scatter(respcombis(i), ks(i)+i*0.001);
    hold on
end

figure();
trainClassifier(responses, respcombis);