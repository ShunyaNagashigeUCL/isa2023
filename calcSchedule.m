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

%% 対戦相手の集計
tbl_teams_sorted=sortrows(tbl_teams, [2,3])
scheduleMat=zeros(size(tbl_teams,1),size(tbl_teams,1));

for n1=1:size(tbl_result,1)
    if tbl_result.isRegular(n1)==1
        homeTeam=tbl_result.Home(n1);
        awayTeam=tbl_result.Away(n1);
        indHome= (tbl_teams_sorted.teamName==homeTeam);
        indAway= (tbl_teams_sorted.teamName==awayTeam);
        scheduleMat=scheduleMat+   indHome*(indAway');
    end
end

imagesc(scheduleMat)
colorbar
set(gca,'fontName','Arial','fontsize',10)
axis equal
set(gca,'YTick',1:size(tbl_teams,1));
set(gca,'YTickLabel',tbl_teams_sorted.Abb)
set(gca,'XTick',1:size(tbl_teams,1));
set(gca,'XTickLabel',tbl_teams_sorted.Abb,'XTickLabelRotation',90)
xlabel('Away')
ylabel('Home')
hold on;
for n1=0:5:30
    xline(n1+0.5)
    yline(n1+0.5)
end