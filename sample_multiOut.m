% sample_multiOut
clear
clc
close all

%%
load sample_multiOut.mat
histogram(rateDiff);
bins=(-0.25:0.025:0.25)/0.25*2.5;
nCounts=[];

for winVal=unique(actualWin)'
    
    nCounts=[nCounts; ...
        hist( rateDiff(actualWin==winVal),bins)];
end

figure
subplot(2,1,1)
bar(bins,nCounts,'stacked','BarWidth',1,'EdgeColor','w','FaceAlpha',0.5)
grid on;
set(gca,'FontName','arial','FontSize',12)
ylabel('Frequency')
set(gca,'XTickLabel',[])
legend(num2str(unique(actualWin)),'Location','best')

subplot(2,1,2)
bar(bins,nCounts./(sum(nCounts)), ...
    'stacked','BarWidth',1,'EdgeColor','w','FaceAlpha',0.5)
grid on;
set(gca,'FontName','arial','FontSize',12)
ylabel('Ratio')
xlabel('Rating diffefence')

%% glm fit

mdl=[];
for winVal=unique(actualWin)'
    mdl=[mdl ...
        glmfit(rateDiff, actualWin<=winVal,'binomial','logit')];
end
subplot(2,1,2)
hold on
for n1=1:size(mdl,2)-1
    plot(bins, ...
        glmval(mdl(:,n1),bins,'logit'),'k-','LineWidth',2)
end

saveas(gca,'./fig/sample-multiOut','epsc');
