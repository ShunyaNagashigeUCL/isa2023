%%
clear
clc
close all

load rankByScore.mat %あらかじめcalcScore.mを実行しておく

tbl_result.PredictionByWin=nan(size(tbl_result.Home));
tbl_result.ActualWin=nan(size(tbl_result.Home));
tbl_result.isPredictionCorrect=nan(size(tbl_result.Home));

matchDates=unique(tbl_result.Date);     %試合が行われた日付

predictionFrom=datetime(2018,11,1,0,0,0)

for predictionTargetDate=matchDates'
    if predictionTargetDate >= predictionFrom
        predictionTargetDate
        
        % 指標計算用のテーブルを抽出
        idx=(tbl_result.Date< predictionTargetDate);
        tmp_tbl_result=tbl_result(idx,:);
        % TODO:指標(その時点での各チームの勝率)を計算する
        
        idx=(tbl_result.Date== predictionTargetDate);
        tbl_result.PredictionByWin(idx,:)=0;
        tbl_result.ActualWin(idx,:)= ...
            (tbl_result.HomeScore(idx,:)>tbl_result.AwayScore(idx,:));
        tbl_result.isPredictionCorrect(idx,:)=0;
        % TODO:予測対象試合について，上で求めた指標に基づき
        % 予測結果を算出する．
    end
end


%%
predictionPerformance.matches=size(rmmissing( tbl_result.isPredictionCorrect),1);
predictionPerformance.corrects=sum(rmmissing( tbl_result.isPredictionCorrect),1);
predictionPerformance.accuracy= ...
    predictionPerformance.corrects/predictionPerformance.matches;

predictionPerformance