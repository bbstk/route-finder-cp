% Given a map with 0s meaning free space and 1s meaning obstacle
% Find the shortest route between a starting position and a target position

%include "globals.mzn";                                      

int: m;
int: n; 
array[1..m,1..n] of int: map;                                    
                                                                                                                                       
int: cX;
int: cY;

int: tX;
int: tY;                                                                       

int: steps;

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

% push [0,0] moves to the end
constraint forall(step in 1..steps-1)(currentPositions[step,0] == currentPositions[step+1,0] /\ currentPositions[step,1] == currentPositions[step+1,1] <-> currentPositions[step,0] == tX /\ currentPositions[step,1] == tY);

var int: actualMoves = steps - sum([1| k in 1..steps where moves[k,0] == 0 /\ moves[k,1] == 0 ]);

solve minimize actualMoves;
%solve::int_search([moves[g,d]| g in 1..steps, d in 0..1],smallest,indomain_max,complete) minimize actualMoves;
% solve satisfy;
%solve::int_search([moves[g,d]| g in 1..steps, d in 0..1],smallest,indomain_max,complete) satisfy;


output["Moves taken: " ++ show(fix(actualMoves)) ++ "\n"
            ++ "Moves: " ++ show([show(fix(row(currentPositions,k))) | k in 1..steps+1]) ];

% output[show([show(fix(row(moves,k))) | k in 1..steps]) ];
% output["\n Current X: " ++ show(fix(cX)) ++ "\n"];
% output["Current Y:" ++ show(fix(cY))];
% output["\n\nCurrent positons: " ++ show([show(fix(row(currentPositions,k))) | k in 1..steps+1]) ];
% output["\n\nDistances: " ++ show(distances) ];
% output["number of teams = " ++ show(numberOfTeams) ++ "\n"];
% output["team sizes: " ++ show(teamSizes) ++ "\n" ];
% output[(if fix(teamSizes[t]) > 0  then "team " ++ show(t) ++ ":" ++ show([show(s) | s in STUDENTS where fix(teamAllocation[s,t])==true]) ++"\n" else"" endif)| t in TEAM];
