%%
clear
clc
close all

load rankByScore.mat %あらかじめcalcScore.mを実行しておく

tbl_result.PredictionByWin=nan(size(tbl_result.Home));
tbl_result.ActualWin=nan(size(tbl_result.Home));
tbl_result.isPredictionCorrect=nan(size(tbl_result.Home));

%以下，コロン要ります？
tbl_result.PredictionByWin(tbl_result.isPlayoff==1,:)=0; %PredictionByWin列の初期化

[tbl_result,iright] = join(tbl_result,tbl_ranking,'LeftKeys','Home','RightKeys','teamName'); %ホームチームの情報を結合(_tbl_result列)

[tbl_result,iright] = join(tbl_result,tbl_ranking,'LeftKeys','Away','RightKeys','teamName'); %アウェイチームの情報を結合(_tbl_ranking列)

for i=1231:1312
    if tbl_result(i,:).ScoreRatio_tbl_result~=tbl_result(i,:).ScoreRatio_tbl_ranking
        tbl_result.PredictionByWin(i,:)=tbl_result(i,:).ScoreRatio_tbl_result>tbl_result(i,:).ScoreRatio_tbl_ranking;
    else
        tbl_result.PredictionByWin(i,:)=tbl_result(i,:).WinRatio_tbl_result>tbl_result(i,:).WinRatio_tbl_ranking;
    end
end

tbl_result.ActualWin(tbl_result.isPlayoff==1,:) ...
    =(tbl_result.HomeScore(tbl_result.isPlayoff==1,:) ...
    > tbl_result.AwayScore(tbl_result.isPlayoff==1,:)); %実際の試合結果に基づく勝敗をActualWin列に記入

tbl_result.isPredictionCorrect(tbl_result.isPlayoff==1,:)=0; %isPredictionCorrect列の初期化


tbl_result.isPredictionCorrect(tbl_result.isPlayoff==1,:) ...
    =(tbl_result.PredictionByWin(tbl_result.isPlayoff==1,:) ...
    == tbl_result.ActualWin(tbl_result.isPlayoff==1,:)); %予測が正しいかどうか(isPredictionConnect)の記入

%%
predictionPerformance.matches=size(rmmissing( tbl_result.isPredictionCorrect),1);
predictionPerformance.corrects=sum(rmmissing( tbl_result.isPredictionCorrect),1);
predictionPerformance.accuracy= ...
    predictionPerformance.corrects/predictionPerformance.matches; %予測正解率の計算

predictionPerformance