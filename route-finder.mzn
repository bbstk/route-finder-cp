%
% Given a set of students produce teams
% Each student is one team and one team only
% A team must be of size lwb to upb inclusive
% There are some pairs of students who must be in the same team together
% There are some pairs of students who must not be in the same team together
%
% There are two parts to the exercise
%
%  (a) Produce T teams, i.e. produce a satisfactory allocation of students to teams
%  (b) Minimize the number of teams produced
%
include "globals.mzn"; 

enum move = {right, left, up, down, stay};

% int: m = 3;
% int: n = 5;
% array[1..m,1..n] of int: map = [|0,1,1,0,0
%                                                |0,1,1,0,0
%                                                |0,0,0,0,0|];
                                               

int: m = 13;
int: n = 20;
array[1..m,1..n] of int: map = [|0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,1,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,1,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,1,1,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
                                               |0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|];                                             
                                                                                                                                       
                                               
int: cX = 0 ;
int: cY = 0;

int: tX = 0;
int: tY = 4;                                                                          

int: steps = 15;

% decision variables
array[1..steps, 0..1] of var -1..1: moves; % which move to take

% in the end we should have reached the target
constraint sum(col(moves,0))=tX-cX;
constraint sum(col(moves,1))=tY-cY;

% constraint forall(step in 1..steps)(
%                                               forall());

array[1..steps+1, 0..1] of var int: currentPositions; 
array[1..steps+1] of var int: distances; 

% update the current positions with each move
constraint currentPositions[1,0] = cX;
constraint currentPositions[1,1] = cY;
constraint forall(step in 1..steps)(currentPositions[step+1,0] = currentPositions[step,0] + moves[step,0]);
constraint forall(step in 1..steps)(currentPositions[step+1,1] = currentPositions[step,1] + moves[step,1]);

% calculate distances according to positions
constraint forall(step in 1..steps+1)(distances[step] = max([abs(tX - currentPositions[step,0]), abs(tY - currentPositions[step,1]) ]));

% the direct distance ignoring obstacles cannot be bigger than the number of steps
%constraint forall(step in 1..steps)(if distances[step] > steps then false else true endif);

% you cant go into an obstacle
constraint forall(step in 1..steps+1)(if map[currentPositions[step,0] + 1,currentPositions[step,1] + 1] == 0 then true else false endif);

% once we got to the target - stop moving
constraint forall(step in 1..steps)(if (currentPositions[step, 0] = tX /\ currentPositions[step, 1] = tY) then (currentPositions[step+1, 0] = tX /\ currentPositions[step + 1, 1] = tY) else true endif);

% constraint forall(step in 1..steps)(sum([moves[o,0] |o in 1..step ]) >= m -> false | where);

% constraint forall(step in 1..steps)(map[sum([moves[o,0] |o in 1..step ]) , sum([moves[o,1] |o in 1..step ])] == 1 -> false);

solve satisfy;

output[show([show(fix(row(moves,k))) | k in 1..steps]) ];
output["\n Current X: " ++ show(fix(cX)) ++ "\n"];
output["Current Y:" ++ show(fix(cY))];
output["\n\nCurrent positons: " ++ show([show(fix(row(currentPositions,k))) | k in 1..steps+1]) ];
output["\n\nDistances: " ++ show(distances) ];
% output["number of teams = " ++ show(numberOfTeams) ++ "\n"];
% output["team sizes: " ++ show(teamSizes) ++ "\n" ];
% output[(if fix(teamSizes[t]) > 0  then "team " ++ show(t) ++ ":" ++ show([show(s) | s in STUDENTS where fix(teamAllocation[s,t])==true]) ++"\n" else"" endif)| t in TEAM];
