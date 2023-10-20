% calcMassey

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

%% Massey ratingの計算

tbl_result_regular=tbl_result(tbl_result.isRegular==1,:);
r=zeros(size(tbl_teams,1),1); %レーティングベクトル
X=zeros(size(tbl_result_regular,1), size(r,1));
y=(tbl_result_regular.HomeScore-tbl_result_regular.AwayScore);  %得点差

for n1=1:size(tbl_result_regular,1)
    indHome=(tbl_teams.teamName==tbl_result_regular.Home(n1));
    indAway=(tbl_teams.teamName==tbl_result_regular.Away(n1));
    X(n1,:)=indHome'-indAway';
end
% 
M=X'*X;
p=X'*y;
M(end,:)=1;
p(end)=0;
rank(M) %フルランク＝逆行列を持つことの確認
r=inv(M)*p; %レーティングの計算

tbl_ranking=tbl_teams;
tbl_ranking.Massey=r;

save rankByMassey

