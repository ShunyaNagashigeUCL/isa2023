%%
clear
clc
close all

load rankByScore.mat %あらかじめcalcScore.mを実行しておく

tbl_result.PredictionByScore=nan(size(tbl_result.Home));
tbl_result.ActualWin=nan(size(tbl_result.Home));
tbl_result.isPredictionCorrect=nan(size(tbl_result.Home));

matchDates=unique(tbl_result.Date);     %試合が行われた日付

predictionFrom=datetime(2018,11,1,0,0,0)

% 一時的な得点割合・勝率を記載するテーブルの作成
teamName=tbl_teams.teamName;
ScoreFor=zeros(size(tbl_teams.teamName));
ScoreAgainst=zeros(size(tbl_teams.teamName));
ScoreRatio=zeros(size(tbl_teams.teamName));
Win=zeros(size(tbl_teams.teamName));
Lose=zeros(size(tbl_teams.teamName));
WinRatio=zeros(size(tbl_teams.teamName));
tmp_tbl_ranking=table(teamName,ScoreFor,ScoreAgainst,ScoreRatio,Win,Lose,WinRatio);

% categoricalを文字列にする
strTeamName=string(tmp_tbl_ranking.teamName);

for predictionTargetDate=matchDates'

    % if predictionTargetDate == datetime(2019,6,13,0,0,0) % デバッグ用

    if predictionTargetDate >= predictionFrom
        predictionTargetDate
        
        % 指標計算用のテーブルを抽出
        idx=(tbl_result.Date< predictionTargetDate); %予測対象日以前のインデックスを取得
        tmp_tbl_result=tbl_result(idx,:);
        
        % 初期化の実施
        tmp_tbl_ranking.ScoreFor=zeros(size(tbl_teams.teamName));
        tmp_tbl_ranking.ScoreAgainst=zeros(size(tbl_teams.teamName));
        tmp_tbl_ranking.ScoreRatio=zeros(size(tbl_teams.teamName));
        tmp_tbl_ranking.Win=zeros(size(tbl_teams.teamName));
        tmp_tbl_ranking.Lose=zeros(size(tbl_teams.teamName));
        tmp_tbl_ranking.WinRatio=zeros(size(tbl_teams.teamName));

        % TODO:指標(その時点での各チームの勝率)を計算する

        for j=1:size(tmp_tbl_result.Home)
            homeIdx=contains(strTeamName,string(tmp_tbl_result.Home(j,:)));
            awayIdx=contains(strTeamName,string(tmp_tbl_result.Away(j,:)));
            
            % 各チームの得点数に対して
            tmp_tbl_ranking(homeIdx,:).ScoreFor=tmp_tbl_ranking(homeIdx,:).ScoreFor+tmp_tbl_result.HomeScore(j,:);
            tmp_tbl_ranking(awayIdx,:).ScoreFor=tmp_tbl_ranking(awayIdx,:).ScoreFor+tmp_tbl_result.AwayScore(j,:);

            % 各チームの失点数に対して
            tmp_tbl_ranking(homeIdx,:).ScoreAgainst=tmp_tbl_ranking(homeIdx,:).ScoreAgainst+tmp_tbl_result.AwayScore(j,:);
            tmp_tbl_ranking(awayIdx,:).ScoreAgainst=tmp_tbl_ranking(awayIdx,:).ScoreAgainst+tmp_tbl_result.HomeScore(j,:);

            % 各チームの得点割合
            tmp_tbl_ranking(homeIdx,:).ScoreRatio=...
                tmp_tbl_ranking(homeIdx,:).ScoreFor/(tmp_tbl_ranking(homeIdx,:).ScoreFor+tmp_tbl_ranking(homeIdx,:).ScoreAgainst);
            tmp_tbl_ranking(awayIdx,:).ScoreRatio=...
                tmp_tbl_ranking(awayIdx,:).ScoreFor/(tmp_tbl_ranking(awayIdx,:).ScoreFor+tmp_tbl_ranking(awayIdx,:).ScoreAgainst);

            % 引き分けは考慮しないものとする
            if tmp_tbl_result.HomeScore(j,:)>tmp_tbl_result.AwayScore(j,:)
                tmp_tbl_ranking(homeIdx,:).Win=tmp_tbl_ranking(homeIdx,:).Win+1;
                tmp_tbl_ranking(awayIdx,:).Lose=tmp_tbl_ranking(awayIdx,:).Lose+1;
            else
                tmp_tbl_ranking(awayIdx,:).Win=tmp_tbl_ranking(awayIdx,:).Win+1;
                tmp_tbl_ranking(homeIdx,:).Lose=tmp_tbl_ranking(homeIdx,:).Lose+1;
            end

            % 各チームの勝率
            tmp_tbl_ranking(homeIdx,:).WinRatio=...
                tmp_tbl_ranking(homeIdx,:).Win/(tmp_tbl_ranking(homeIdx,:).Win+tmp_tbl_ranking(homeIdx,:).Lose);
            tmp_tbl_ranking(awayIdx,:).WinRatio=...
                tmp_tbl_ranking(awayIdx,:).Win/(tmp_tbl_ranking(awayIdx,:).Win+tmp_tbl_ranking(awayIdx,:).Lose);
        end
        
        idx=(tbl_result.Date== predictionTargetDate); %予測対象日の試合全てのインデックスを取得
        tbl_result.PredictionByScore(idx,:)=0;
        tbl_result.ActualWin(idx,:)= ...
            (tbl_result.HomeScore(idx,:)>tbl_result.AwayScore(idx,:));
        tbl_result.isPredictionCorrect(idx,:)=0;

        % TODO:予測対象試合について，上で求めた指標に基づき
        % 予測結果を算出する．
        
        % target_tbl_result=tbl_result(idx,:);

        for k=1:size(idx)
            if idx(k,:)~=0
                homeIdx=contains(strTeamName,string(tbl_result.Home(k,:)));
                awayIdx=contains(strTeamName,string(tbl_result.Away(k,:)));
                
                if tmp_tbl_ranking.ScoreRatio(homeIdx,:)~=tmp_tbl_ranking.ScoreRatio(awayIdx,:)
                    tbl_result.PredictionByScore(k,:)=tmp_tbl_ranking.ScoreRatio(homeIdx,:)>tmp_tbl_ranking.ScoreRatio(awayIdx,:);
                else
                    tbl_result.PredictionByScore(k,:)=tmp_tbl_ranking.WinRatio(homeIdx,:)>tmp_tbl_ranking.WinRatio(awayIdx,:);
                end

                % 予測結果が正しいか判定
                tbl_result.isPredictionCorrect(k,:)=tbl_result.PredictionByScore(k,:)==tbl_result.ActualWin(k,:); 
            end
        end

        % 予測対象試合でのホームチームとアウェイチームについて，tmp_tbl_rankingにおけるインデックスを取得
        % homeIdx=contains(strTeamName,string(tbl_result.Home(idx,:)));
        % awayIdx=contains(strTeamName,string(tbl_result.Away(idx,:)));
        % 
        % tmp_tbl_ranking.ScoreRatio(homeIdx,:)
        % tmp_tbl_ranking.ScoreRatio(awayIdx,:)
        % if tmp_tbl_ranking.ScoreRatio(homeIdx,:)~=tmp_tbl_ranking.ScoreRatio(awayIdx,:)
        %     tbl_result.PredictionByScore(idx,:)=tmp_tbl_ranking.ScoreRatio(homeIdx,:)>tmp_tbl_ranking.ScoreRatio(awayIdx,:);
        % else
        %     tbl_result.PredictionByScore(idx,:)=tmp_tbl_ranking.WinRatio(homeIdx,:)>tmp_tbl_ranking.WinRatio(awayIdx,:);
        % end
        % 
        % % 予測結果が正しいか判定
        % tbl_result.isPredictionCorrect(idx,:)=tbl_result.PredictionByScore(idx,:)==tbl_result.ActualWin(idx,:);
    end
end


%%
predictionPerformance.matches=size(rmmissing( tbl_result.isPredictionCorrect),1);
predictionPerformance.corrects=sum(rmmissing( tbl_result.isPredictionCorrect),1);
predictionPerformance.accuracy= ...
    predictionPerformance.corrects/predictionPerformance.matches;

predictionPerformance