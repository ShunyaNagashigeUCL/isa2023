% calcScore

clear
clc
close all

%%
[num,txt,raw]=xlsread('../data/nbaResult20182019.xlsx','result');
tbl_result=array2table(raw);
tbl_result.Properties.VariableNames=txt(1,:);
tbl_result(1,:)=[];
tbl_result.Home=categorical(tbl_result.Home);
tbl_result.Away=categorical(tbl_result.Away);
tbl_result.HomeScore=cell2mat(tbl_result.HomeScore);
tbl_result.AwayScore=cell2mat(tbl_result.AwayScore);
tbl_result.isRegular=cell2mat(tbl_result.isRegular);
tbl_result.isPlayoff=cell2mat(tbl_result.isPlayoff);

%% 日付の変換
for n1=1:size(tbl_result,1)
    tmpStr=tbl_result.Date{n1};
    tmpStrs=strsplit(tmpStr,{',',' '});
    tmpStr=[tmpStrs{4} '-' tmpStrs{2} '-' tmpStrs{3}];
    tbl_result.Date{n1}=datetime(tmpStr,'InputFormat' ,'yyyy-MMM-dd','Locale','en_US');
end
cell2table(tbl_result.Date);
tbl_result.Date=ans.Var1;

%%
[num,txt,raw]=xlsread('../data/nbaResult20182019.xlsx','teams');
tbl_teams=array2table(raw);
tbl_teams.Properties.VariableNames=txt(1,:);
tbl_teams(1,:)=[];
tbl_teams.teamName=categorical(tbl_teams.teamName);
tbl_teams.Confefence=categorical(tbl_teams.Confefence);
tbl_teams.Division=categorical(tbl_teams.Division);
tbl_teams.Abb=categorical(tbl_teams.Abb);

%% 勝敗数の集計
tbl_ranking=tbl_teams;
tbl_ranking.Win=zeros(size(tbl_teams.teamName));
tbl_ranking.Lose=zeros(size(tbl_teams.teamName));
tbl_ranking.WinRatio=zeros(size(tbl_teams.teamName));

for n1=1:size(tbl_result,1)
    if tbl_result.isRegular(n1)==1
        if tbl_result.HomeScore(n1)>tbl_result.AwayScore(n1)
            winTeam=tbl_result.Home(n1);
            loseTeam=tbl_result.Away(n1);
        else
            winTeam=tbl_result.Away(n1);
            loseTeam=tbl_result.Home(n1);
        end
        tbl_ranking.Win(tbl_ranking.teamName==winTeam) ...
            =        tbl_ranking.Win(tbl_ranking.teamName==winTeam) +1;
        tbl_ranking.Lose(tbl_ranking.teamName==loseTeam) ...
            =        tbl_ranking.Lose(tbl_ranking.teamName==loseTeam) +1;
        
    end
end

tbl_ranking.WinRatio=tbl_ranking.Win./(tbl_ranking.Win+tbl_ranking.Lose);
tbl_ranking;

%% Conference, Division内順位の算出

%% 得失点の集計
tbl_ranking.ScoreFor=zeros(size(tbl_teams.teamName));
tbl_ranking.ScoreAgainst=zeros(size(tbl_teams.teamName));
tbl_ranking.ScoreRatio=zeros(size(tbl_teams.teamName));

for n1=1:size(tbl_result,1)
    if tbl_result.isRegular(n1)==1
        homeTeam=tbl_result.Home(n1);
        awayTeam=tbl_result.Away(n1);
        homeScore=tbl_result.HomeScore(n1);
        awayScore=tbl_result.AwayScore(n1);
        
        tbl_ranking.ScoreFor(tbl_ranking.teamName==homeTeam) ...
            =tbl_ranking.ScoreFor(tbl_ranking.teamName==homeTeam)+homeScore;
        tbl_ranking.ScoreAgainst(tbl_ranking.teamName==homeTeam) ...
            =tbl_ranking.ScoreAgainst(tbl_ranking.teamName==homeTeam)+awayScore;
        
        tbl_ranking.ScoreFor(tbl_ranking.teamName==awayTeam) ...
            =tbl_ranking.ScoreFor(tbl_ranking.teamName==awayTeam)+awayScore;
        tbl_ranking.ScoreAgainst(tbl_ranking.teamName==awayTeam) ...
            =tbl_ranking.ScoreAgainst(tbl_ranking.teamName==awayTeam)+homeScore;
        
    end
end

tbl_ranking.ScoreRatio=tbl_ranking.ScoreFor./(tbl_ranking.ScoreFor+tbl_ranking.ScoreAgainst);
tbl_ranking


%% 図示
figure
hold on
scatter(tbl_ranking.ScoreRatio, tbl_ranking.WinRatio);
set(gca,'FontName','arial','FontSize',12);
grid on;
axis([-0.03 0.03 -0.3 0.3]+0.5)
xlabel('Scoreing ratio')
ylabel('Win ratio');

figure
plotCount=1;
markerStr='o^sdv<';
for divName=categories(tbl_teams.Division)'
    plotX=tbl_ranking.ScoreRatio(tbl_ranking.Division==divName);
    plotY=tbl_ranking.WinRatio(tbl_ranking.Division==divName);
    scatter(plotX, plotY, 50,markerStr(plotCount),'LineWidth',2);
    hold on
    plotCount=plotCount+1;
end
set(gca,'FontName','arial','FontSize',12);
grid on;
axis([-0.03 0.03 -0.3 0.3]+0.5)
xlabel('Scoreing ratio')
ylabel('Win ratio');

%% 線形回帰

mdl=fitlm( tbl_ranking.ScoreRatio,tbl_ranking.WinRatio)
plotX=sort(tbl_ranking.ScoreRatio);
plot(plotX, predict(mdl,plotX),'k:','LineWidth',1)
legend(categories(tbl_teams.Division)','Location','best')
save('rankByScore')
saveas(gca,'./fig/scoreRatioAndWinRatio201819','epsc')

%% 相関係数
corr(tbl_ranking.ScoreRatio, tbl_ranking.WinRatio)

corr(tbl_ranking.ScoreRatio, tbl_ranking.WinRatio,'type','Kendall')
