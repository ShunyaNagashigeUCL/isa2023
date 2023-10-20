% calcMarkov

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

%% Markov ratingの計算例
tmpTeams=tbl_teams.teamName
tmpAbb=tbl_teams.Abb
ind= (ismember( tbl_result.Home, tmpTeams) & ...
    ismember( tbl_result.Away, tmpTeams) & ...
    tbl_result.isRegular);
tbl_result_div=tbl_result(ind,:);

V=zeros(size(tmpTeams,1));
S=zeros(size(tmpTeams,1));
for n1=1:size(tbl_result_div,1)
    homeNum= find(tbl_result_div.Home(n1) == tmpTeams);
    awayNum= find(tbl_result_div.Away(n1) == tmpTeams);
    if tbl_result_div.HomeScore(n1)>tbl_result_div.AwayScore(n1)
        V(homeNum, awayNum)=V(homeNum, awayNum)+1;
    else
        V(awayNum, homeNum)=V(awayNum, homeNum)+1;
    end
end
V

for n1=1:size(V,2)
    S(:,n1)=V(:,n1)/sum(V(:,n1));
end
S

b=0.85;
r=inv(eye(size(S))-b*S)*(1-b)*ones(size(tmpTeams))/size(tmpTeams,1)


tbl_ranking=tbl_teams;
tbl_ranking.Markov=r;

save rankByMarkov


