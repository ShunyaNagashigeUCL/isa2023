% calcWins

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
tbl_ranking.RankInConf=zeros(size(tbl_teams.teamName));
tbl_ranking.RankInDiv=zeros(size(tbl_teams.teamName));

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
tbl_ranking

%% Conference, Division内順位の算出
confTeamNum=15;
divTeamNum=5;

tbl_ranking = sortrows(tbl_ranking,"WinRatio","descend");
tbl_ranking = sortrows(tbl_ranking,"Confefence","descend");

for n2=1:size(tbl_ranking,1)
    tbl_ranking.RankInConf(n2,:)=mod(n2-1,confTeamNum)+1;
end

tbl_ranking = sortrows(tbl_ranking,"WinRatio","descend");
tbl_ranking = sortrows(tbl_ranking,"Division","descend");
tbl_ranking = sortrows(tbl_ranking,"Confefence","descend");

for n3=1:size(tbl_ranking,1)
    tbl_ranking.RankInDiv(n3,:)=mod(n3-1,divTeamNum)+1;
end
%%