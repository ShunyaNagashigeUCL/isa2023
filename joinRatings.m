clear
clc
close all

load rankByScore.mat
tbl_ranking_all=tbl_ranking;

load rankByMassey.mat
tbl_ranking_all=join(tbl_ranking_all, tbl_ranking)

load rankByColley.mat
tbl_ranking_all=join(tbl_ranking_all, tbl_ranking)

load rankByMarkov.mat
tbl_ranking_all=join(tbl_ranking_all, tbl_ranking)

load rankByElo.mat
tbl_ranking_all=join(tbl_ranking_all, tbl_ranking)

load rankByEloOnScore.mat
tbl_ranking_all=join(tbl_ranking_all, tbl_ranking)

load rankByBTOnScore.mat
tbl_ranking_all=join(tbl_ranking_all, tbl_ranking)

%%
plotData=[tbl_ranking_all.WinRatio, ...
    tbl_ranking_all.ScoreRatio, ...
    tbl_ranking_all.Massey, ...
    tbl_ranking_all.Colley, ...
    tbl_ranking_all.Markov, ...
    tbl_ranking_all.Elo, ...
    tbl_ranking_all.EloOnScore, ...
    tbl_ranking_all.BTOnScore];

corr(plotData,'type','Spearman')
figure
colormap('cool')
imagesc(corr(plotData,'type','Spearman'))
set(gca,'Ydir','reverse','FontName','Arial','FontSize',10)
axis equal
axis square
colorbar
set(gca,'XTick',1:size(plotData,2))
set(gca,'XTickLabel',  tbl_ranking_all.Properties.VariableNames([7 10:16]), ...
    'XTickLabelRotation',90)
set(gca,'YTickLabel',  tbl_ranking_all.Properties.VariableNames([7 10:16]))

hoge
figure
plotmatrix(plotData)