clear
clc
close all

tbl_result=readtable('example_Chap4.xlsx');
tbl_result.TeamA=categorical(tbl_result.TeamA);
tbl_result.TeamB=categorical(tbl_result.TeamB);

teams=unique([tbl_result.TeamA;tbl_result.TeamB]);

X=zeros(size(tbl_result,1), size(teams,1));
y=tbl_result.ScoreA-tbl_result.ScoreB;

for n1=1:size(tbl_result,1)
    taNum = find(tbl_result.TeamA(n1)==teams);
    tbNum = find(tbl_result.TeamB(n1)==teams);
    X(n1,taNum)=1;
    X(n1,tbNum)=-1;
end

X
y

pinv(X)*y

M=X'*X
p=X'*y

M(end,:)=1
p(end)=0

r=inv(M)*p