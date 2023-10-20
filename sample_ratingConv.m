% sample_ratingConv
clear
clc
close all

%%
load sample_ratingConv.mat
histogram(rateDiff);
bins=(-0.25:0.025:0.25)*100;
winCounts=hist( rateDiff(actualWin==1),bins);
loseCounts=hist( rateDiff(actualWin==0),bins);

figure
subplot(2,1,1)
bar(bins,[winCounts;loseCounts],'stacked','BarWidth',1,'EdgeColor','w','FaceAlpha',0.5)
grid on;
set(gca,'FontName','arial','FontSize',12)
ylabel('Frequency')
set(gca,'XTickLabel',[])
legend({'Won','Lost'},'location','best')

subplot(2,1,2)
bar(bins,[winCounts;loseCounts]./(winCounts+loseCounts), ...
    'stacked','BarWidth',1,'EdgeColor','w','FaceAlpha',0.5)
grid on;
set(gca,'FontName','arial','FontSize',12)
ylabel('Ratio')
xlabel('Rating diffefence')

%% glm fit

mdl=glmfit(rateDiff, actualWin,'binomial','logit')
subplot(2,1,2)
hold on
plot(bins, glmval(mdl,bins,'logit'),'k-','LineWidth',2)
saveas(gca,'fig/sample-ratingConv','epsc')
