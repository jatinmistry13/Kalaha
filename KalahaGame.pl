/*

JATIN NAVIN MISTRY

THE GAME OF KALAHA.
USES SWI-PROLOG.

*/

/*
Start game as ? - play(kalaha).
*/


/* 
--------------------------------------------------------------------------------
DEFAULT SETTINGS 
--------------------------------------------------------------------------------
*/

/* DEFINING A DYNAMIC METHOD WILL BE USED IN THE PROGRAM */
:- dynamic settings/2.

/* SETTING USER DEFINED VALUES FOR SOME VARIABLES */
set(Key, Value) :-
	settings_value(Key, Value), 
	!,
	retractall(settings(Key, _)), 
	assert(settings(Key, Value)).

/* USER ENTERED SOME INVALID INPUTS */
set(Key, Value) :-
	write('Unknown value: '), 
	write(set(Key, Value)), 
	nl.

/* DEFAULT SETTINGS */
settings(statespaceDepth, 3).
settings(stones, 6).
settings(player1, minimax).
settings(player2, minimax).
settings(pauseDuration, 0.25).

/* BOUNDED VALUES FOR SOME SETTINGS */
settings_value(statespaceDepth, X) :-
	between(1, 10, X).
settings_value(stones, X) :-
	between(1, 10, X).
settings_value(player1, Value) :-
	playerSettings(Value).
settings_value(player2, Value) :-
	playerSettings(Value).
settings_value(pauseDuration, X) :-
	between(-1, 10, X).

/* DEFAULT ALGORITHMS THAT ARE IMPLEMENTED */
/* MANUAL MOVE BY USER */
playerSettings(manual).

/* PROGRAM MAKES USES MINMAX ALGORITHM */
playerSettings(minimax).

/* PROGRAM MAKES USE OF ALPHA-BETA PRUNING ALGORITHM */
playerSettings(alphabeta).

/* 
--------------------------------------------------------------------------------
GAME PLAYING 
--------------------------------------------------------------------------------
*/

/* GAME PLAYING FRAMEWORK */
play(Game) :-
	initialize(Game, Pos, Player), 
	display(Pos, Player), 
	displayPlayerAlgorithms, 
	play(Pos, Player), 
	true.

/* CHECK GAME END CONDITIONS */
play([Own, OwnKalaha, Opp, OppKalaha], Player) :-
	Own = [0, 0, 0, 0, 0, 0], /* OWN OR OPPONENTS SIDE HAS 0(ZERO) STONES IN ALL OF THEIR HOLES */
	Opp = [0, 0, 0, 0, 0, 0], 
	!, 
	write('All stones moved to respective player kalaha..'), 
	nl, 
	write(Player), 
	write(':'), 
	write(OwnKalaha), 
	write('points'), 
	nl, 
	nextPlayer(Player, Opponent), 
	write(Opponent), 
	write(':'), 
	write(OppKalaha), 
	write('points'), 
	nl, 
	nl, 
	write('-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x- GAME OVER -x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-'), 
	nl, 
	noprotocol.

/* PLAY THE GAME */
play([Own, OwnKalaha, Opp, OppKalaha], Player) :-
	chooseMove(Player, [Own, OwnKalaha, Opp, OppKalaha], [N|RN]), 
	makeMove([NOwn, NOwnKalaha, NOpp, NOppKalaha], [Own, OwnKalaha, Opp, OppKalaha], MoreMoves, N), 
	display([NOpp, NOppKalaha, NOwn, NOwnKalaha], Player), 
	makeMoveAgain([NOwn, NOwnKalaha, NOpp, NOppKalaha], Player, MoreMoves, RN).

/* 
--------------------------------------------------------------------------------
CHOOSE A MOVE BASED ON ALGORITHMS 
--------------------------------------------------------------------------------
*/

/* CHOOSE A MOVE. IMPLEMENT MINIMAX ALGO OR ALPHA-BETA PRUNING */
chooseMove(Player, Board, LN) :-
	write('Player = '), 
	write(Player), 
	nl, 
	settings(Player, Alg), 
	algorithm(Alg, Board, LN).

algorithm(manual, Board, LN) :-
	!, 
	write('Make your move : '), 
	performSearch(manual, Board, [gamemove(_, _, LN)|_]).

algorithm(Alg, Board, LN) :-
	!, 
	write('just a moment please...'), 
	nl, 
	performSearch(Alg, Board, [gamemove(_, _, LN)|_]), 
	write('...ok ready...'), 
	nl, 
	nl, 
	LN=[N|_], 
	write('My Move: '), 
	write(N), 
	write('.'), 
	nl.

/* 
--------------------------------------------------------------------------------
SEARCH FOR MOVES
--------------------------------------------------------------------------------
*/

/*
CHECK FOR LEGALALITY OF A MOVE...
JUST MAKING SURE THAT THE HOLE IS NOT EMPTY.
*/
checkLegalMove([X, _, _, _, _, _], 1) :- X > 0.
checkLegalMove([_, X, _, _, _, _], 2) :- X > 0.
checkLegalMove([_, _, X, _, _, _], 3) :- X > 0.
checkLegalMove([_, _, _, X, _, _], 4) :- X > 0.
checkLegalMove([_, _, _, _, X, _], 5) :- X > 0.
checkLegalMove([_, _, _, _, _, X], 6) :- X > 0.

/* FIND ALL MOVES WITH THE TERMINAL POSITION */
findAllMoves(Board, Bag) :-
	findall(gamemove(_, BP, BLM), goalMove(Board, BP, BLM), Bag), 
	Bag \== [].

goalMove([A|RP], P, [N|RLM]) :-
	checkLegalMove(A, N), 
	makeMove(NP, [A|RP], F, N), 
	goalMoveTurn(NP, P, RLM, F).

goalMoveTurn(P, P, [], noMoreTurn).
goalMoveTurn(NP, P, LM, moreTurn) :-
	goalMove(NP, P, LM).

/* USER INPUT */
performSearch(manual, Board, [gamemove(unknown, _, [N])]) :-
	read(N), 
	Board = [A|_], 
	checkLegalMove(A, N), 
	!.

performSearch(manual, Board, List) :-
	!,								/* RETRY USER INPUT */
	nl, 
	write('Please try again : '), 
	performSearch(manual, Board, List).

/* PERFORM SEARCH USING MINIMAX ALGORITHM */
performSearch(minimax, Board, BestList) :-
	!,								/* THE MIN MAX ALGORITHM */
	settings(statespaceDepth, D), 
	settings(pauseDuration, PD), 
	sleep(PD), 
	findAllMoves(Board, Moves), 
	settings(stones, S), 
	MaxPts is S * 12, 
	MinWin is S * 12 + 2, 
	findMinimax(Moves, -1000000, D, MaxPts, MinWin), 
	sort(Moves, BestListR), 
	% reverze(BestListR, BestList).
	reverse(BestListR, BestList).

/* PERFORM SEARCH USING ALPHA-BETA PRUNING ALGORITHM */
performSearch(alphabeta, Board, BestList) :-
	!, 								/* THE ALPHA BETA ALGORITHM */
	settings(statespaceDepth, D), 
	settings(pauseDuration, PD), 
	sleep(PD), 
	findAllMoves(Board, Moves), 
	settings(stones, S), 
	MaxPts is S * 12, 
	MinWin is S * 12 + 2, 
	findAlphaBeta(Moves, -1000000, 1000000, D, MaxPts, MinWin), 
	sort(Moves, BestListR), 
	reverse(BestListR, BestList).

/* 
--------------------------------------------------------------------------------
IMPLEMENTATIONS OF ALGORITHMS 
--------------------------------------------------------------------------------
*/

/* MINIMAX ALGORITHM */
findMinimax([], _, _, _, _).

findMinimax([gamemove(NV, HP, _)|Moves], Pts, D, MP, MW) :-
	HP = [Own, OwnKalaha, Opp, OppKalaha], 			/* ROTATE THE BOARD */
	miniMax([Opp, OppKalaha, Own, OwnKalaha], D, -1000000, V, MW), 
	NV is -V, 
	findMinimaxcases(Moves, Pts, D, NV, MP, MW).

findMinimaxcases(Moves, Pts, D, NV, MP, MW) :-
	Pts < NV, 
	!, 												/* BETTER POINTS */
	findMinimax(Moves,  NV, D, MP, MW).

findMinimaxcases(Moves, Pts, D,  _, MP, MW) :-
	!, 
	findMinimax(Moves, Pts, D, MP, MW).

miniMax(P, D, Pts, V, MW) :-
	D > 0, 											/* NOT REACHED MAX DEPTH */
	P = [Own, OwnKalaha, _, OppKalaha], 
	OwnKalaha < MW, 
	OppKalaha < MW, 								/* NOT MORE THAN MinWin STONES */
	Own \== [0, 0, 0, 0, 0, 0], 					/* NOT REACHED THE END */
	!, 
	findAllMoves(P, Moves), 
	listMiniMax(Moves, D, Pts, V, MW).

miniMax(P, 0, _, V, _) :-
	!, 												/* REACHED MAXIMUM DEPTH */
	P = [_, OwnKalaha, _, OppKalaha], 
	V is OwnKalaha - OppKalaha.						/* STATIC EVALUATION FUNCTION */

miniMax(P, _, _, V, _) :-
	!, 												/* REACHED END POSITION OR... */
	P = [_, OwnKalaha, _, OppKalaha], 				/* ...MORE THAN MinWin STONES */
	V is 1000 * (OwnKalaha - OppKalaha).			/* STATIC EVALUATION FUNCTION */

listMiniMax([], _, Pts, Pts, _).

listMiniMax([gamemove(_, HP, _)|Moves], D, Pts, V, MW) :-
	ND is D - 1, 
	HP = [Own, OwnKalaha, Opp, OppKalaha], 			/* ROTATE THE BOARD */
	miniMax([Opp, OppKalaha, Own, OwnKalaha], ND, -1000000, TV, MW), 
	NV is - TV, 
	listMiniMaxCases(Moves, D, Pts, V, NV, MW).

listMiniMaxCases(Moves, D, Pts, V, NV, MW) :-
	Pts < NV, 
	!, 												/* BETTER POINTS */
	listMiniMax(Moves, D, NV, V, MW).

listMiniMaxCases(Moves, D, Pts, V,  _, MW) :-
	!, 
	listMiniMax(Moves, D, Pts, V, MW).

/* Alpha-Beta algorithm */
findAlphaBeta([], _, _, _, _, _).

findAlphaBeta([gamemove(NV, HP, _)|Moves], Alpha, Beta, D, MP, MW) :-
	NAlpha is - Beta, 
	NBeta is - Alpha, 
	HP = [Own, OwnKalaha, Opp, OppKalaha], 			/* ROTATE BOARD */
	alphaBeta([Opp, OppKalaha, Own, OwnKalaha], D, NAlpha, NBeta, V, MW), 
	NV is -V, 
	findAlphaBetaCases(Moves, Alpha, Beta, D, NV, MP, MW).

findAlphaBetaCases(Moves, Alpha, Beta, D, NV, MP, MW) :-
	Alpha < NV, 
	!, 												/* BETTER POINTS */
	findAlphaBeta(Moves, NV, Beta, D, MP, MW).

findAlphaBetaCases(Moves, Alpha, Beta, D,  _, MP, MW) :-
	!, 
	findAlphaBeta(Moves, Alpha, Beta, D, MP, MW).

alphaBeta(P, D, Alpha, Beta, V, MW) :-
	D > 0, 											/* NOT REACHED THE MAX DEPTH TO BE SEARCHED */
	P = [Own, OwnKalaha, _, OppKalaha], 
	OwnKalaha < MW, 
	OppKalaha < MW, 								/* NOT MORE THAN MinWin STONES STONES IN SPACE */
	Own \== [0, 0, 0, 0, 0, 0], 					/* NOT REACHED END */
	!, 
	findAllMoves(P, Moves), 
	listAlphaBeta(Moves, D, Alpha, Beta, V, MW).

alphaBeta(P, 0, _, _, V, _) :-
	!, 												/* REACHED MAXIMUM DEPTH */
	P = [_, OwnKalaha, _, OppKalaha], 
	V is OwnKalaha - OppKalaha.						/* STATIC EVALUATION FUNCTION */

alphaBeta(P, _, _, _, V, _) :-
	!, 												/* REACHED END POSITION OR... */
	P = [_, OwnKalaha, _, OppKalaha], 				/* ...MORE THAN MinWin STONES */
	V is 1000 * (OwnKalaha - OppKalaha).			/* STATIC EVALUATION FUNCTION */

listAlphaBeta([], _, Alpha, _, Alpha, _).

listAlphaBeta([gamemove(_, HP, _)|Moves], D, Alpha, Beta, V, MW) :-
	NAlpha is - Beta, 
	NBeta is - Alpha, 
	ND is D - 1, 
	HP = [Own, OwnKalaha, Opp, OppKalaha], 			/* ROTATE BOARD */
	alphaBeta([Opp, OppKalaha, Own, OwnKalaha], ND, NAlpha, NBeta, TV, MW), 
	NV is - TV, 
	listAlphaBetaCases(Moves, D, Alpha, Beta, V, NV, MW).

listAlphaBetaCases(_, _, _, Beta, V, NV, _) :-
	Beta =< NV, 
	!, 												/* BETA CUT OFF */
	V is NV + 1.

listAlphaBetaCases(Moves, D, Alpha, Beta, V, NV, MW) :-
	Alpha < NV, 
	!, 												/* BETTER POINTS */
	listAlphaBeta(Moves, D, NV, Beta, V, MW).

listAlphaBetaCases(Moves, D, Alpha, Beta, V,  _, MW) :-
	!, 
	listAlphaBeta(Moves, D, Alpha, Beta, V, MW).

/* 
--------------------------------------------------------------------------------
INITIALIZATION 
--------------------------------------------------------------------------------
*/

initialize(kalaha, [[S, S, S, S, S, S], 0, [S, S, S, S, S, S], 0], player1) :-
	settings(stones, S).

/* 
--------------------------------------------------------------------------------
DISPLAY BOARD ON THE SCREEN 
--------------------------------------------------------------------------------
*/

/* SWAPPING THE OPPONENTS STONES WITH OWN STONES AND KALAHA */
swap([OwnStones, OwnKalaha, OppStones, OppKalaha], [OppStones, OppKalaha, OwnStones, OwnKalaha]).

/* DISPLAYING THE CURRENT BOARD CONDITION */
display(Pos, player1) :-
	showgame(Pos).

/* FOR PLAYER2 WE NEED TO SWAP FIRST AND THEN DISPLAY THE BOARD. */
display(Pos, player2) :-
	swap(Pos, Pos1), 
	showgame(Pos1).

/* PRINTS OUT THE CURRENT BOARD CONDITION ON THE SCREEN */
showgame([OwnStones, OwnKalaha, OppStones, OppKalaha]) :-
	reverse(OwnStones, OwnStonesRev), 
	write('Player2  [6,5,4,3,2,1]'), 
	nl, 
	write('         '), 
	write(OwnStonesRev), 
	nl, 
	write(OwnKalaha), 
	write('                            '), 
	write(OppKalaha), 
	nl, 
	write('         '), 
	write(OppStones), 
	nl, 
	write('Player1  [1,2,3,4,5,6]'), 
	nl, 
	nl.

printAlgorithmName(alphabeta) :-
	write('Alpha-Beta Pruning Algorithm...').

printAlgorithmName(minimax) :-
	write('Minimax Algorithm...').

printAlgorithmName(manual) :-
	write('Manual : User makes his own moves...').

displayPlayerAlgorithms :-
	write('--------------------------------------------------'),
	nl,
	settings(player1, AlgPlayer1), 
	write('Player1 algorithm : '), 
	printAlgorithmName(AlgPlayer1), 
	nl, 
	settings(player2, AlgPlayer2), 
	write('Player2 algorithm : '), 
	printAlgorithmName(AlgPlayer2),
	nl,
	write('--------------------------------------------------'),
	nl, 
	nl.


/* 
--------------------------------------------------------------------------------
EXECUTING A MOVE 
--------------------------------------------------------------------------------
*/

/* EXECUTING A MOVE */
makeMove([NOwn, NOwnKalaha, NOpp, NOppKalaha], [Own, OwnKalaha, Opp, OppKalaha], MoreMoves, StartHole) :-
	pickStones(StartHole, Picked, TOwn, Own), 
	seedStones(Board, [TOwn, OwnKalaha, Opp, OppKalaha], TMoreMoves, Picked, StartHole), 
	finalCheck([NOwn, NOwnKalaha, NOpp, NOppKalaha], Board, MoreMoves, TMoreMoves).

/* PLAYER CAN PLAY ONE MORE TURN */
makeMoveAgain(P, Player, moreTurn, []) :- 
	!, 
	write('One more turn...'), 
	play(P, Player).

/* CHECK FOR MANUAL MOVE TO BE MADE AGAIN */
makeMoveAgain(_, Player, moreTurn, _) :- 
	settings(Player, manual), 
	!, 
	fail.

makeMoveAgain([Own, OwnKalaha, Opp, OppKalaha], Player, moreTurn, [H|T]) :- 
	!, 
	write('One more turn...'), 
	nl, 
	makeMove([NOwn, NOwnKalaha, NOpp, NOppKalaha], [Own, OwnKalaha, Opp, OppKalaha], MoreMoves, H), 
	write('My next move : '), 
	write(H), 
	write('.'), 
	nl, 
	display([NOpp, NOppKalaha, NOwn, NOwnKalaha], Player), 
	makeMoveAgain([NOwn, NOwnKalaha, NOpp, NOppKalaha], Player, MoreMoves, T).

/* NO MORE TURNS FOR THE PLAYER */
makeMoveAgain([Own, OwnKalaha, Opp, OppKalaha], Player, noMoreTurn, []) :- !, 
	nextPlayer(Player, Opponent), 
	write('--------------------------------------------------'), 
	nl, 
	play([Opp, OppKalaha, Own, OwnKalaha], Opponent). /* Rotate the board for opponent to play */

/*
GAME END CONDITION CHECK.
WHEN A PLAYER’S ALL HOLES ARE COMPLETELY EMPTY, THE GAME ENDS. THE PLAYER WHO
STILL HAS STONES LEFT IN HIS HOLES CAPTURES THOSE STONES AND PUTS THEM IN HIS
KALAHA. THE PLAYERS THEN COMPARE THEIR KALAHA. THE PLAYER WITH MOST STONES WINS
*/
finalCheck([NOwn, NOwnKalaha, NOpp,  NOppKalaha], [[0, 0, 0, 0, 0, 0], OwnKalaha, Opp, OppKalaha], noMoreTurn, _) :- 
	!, 
	Opp = [Opp1, Opp2, Opp3, Opp4, Opp5, Opp6], 
	NOwn = [0, 0, 0, 0, 0, 0], 
	NOpp = [0, 0, 0, 0, 0, 0], 
	/*NOwnKalaha is OwnKalaha + Opp1 + Opp2 + Opp3 + Opp4 + Opp5 + Opp6.*/
	NOwnKalaha is OwnKalaha, 
	NOppKalaha is OppKalaha + Opp1 + Opp2 + Opp3 + Opp4 + Opp5 + Opp6.

finalCheck([NOwn, NOwnKalaha, NOpp,  NOppKalaha], [Own, OwnKalaha, [0, 0, 0, 0, 0, 0], OppKalaha], noMoreTurn, _) :- 
	!, 
	Own = [Own1, Own2, Own3, Own4, Own5, Own6], 
	NOwn = [0, 0, 0, 0, 0, 0], 
	NOpp = [0, 0, 0, 0, 0, 0], 
	/*NOwnKalaha is OwnKalaha + Own1 + Own2 + Own3 + Own4 + Own5 + Own6.*/
	NOppKalaha is OppKalaha, 
	NOwnKalaha is OwnKalaha + Own1 + Own2 + Own3 + Own4 + Own5 + Own6.

finalCheck(P, P, MoreMoves, MoreMoves).



/* 
--------------------------------------------------------------------------------
GAME PLAYING RULES
--------------------------------------------------------------------------------
*/

/*
RULES AND GAME PLAYING MOVES
*/
/* PICKUP STONES AND START SEEDING */
pickStones(1, Picked, [0|L], [Picked|L]) :- !.
pickStones(N, Picked, [X|L2], [X|L1]) :-
	N > 1, 
	M is N - 1, 
	pickStones(M, Picked, L2, L1).

/*
BASIC RULE : STONES SHOULD BE SEEDED IN COUNTER-CLOCKWISE DIRECTION
*/
seedStones([NOwn, NOwnKalaha, NOpp, NOppKalaha], [Own, OwnKalaha, Opp, OppKalaha], MoreMoves, Picked, StartHole) :-
	convertListToBoard(P, [Own, OwnKalaha, Opp, OppKalaha]), 
	NextHole is StartHole + 1, 
	simpleSeedStones(NP, P, MoreMoves, Picked, StartHole, NextHole), 
	convertListToBoard(NP, [NOwn, NOwnKalaha, NOpp, NOppKalaha]).

/* CHECK ALL STONES SEEDED */
simpleSeedStones(P, P, _, 0, _, _) :- !.

/* ALL STONES NOT SEEDED, THERE ARE MORE STONES TO SEED */
simpleSeedStones(NP, P, MoreMoves, Picked, StartHole, NextHole) :-
	Picked > 0, 
	!, 
	jump(NextHole, P, P2, TmpP, TmpP2), 
	complexSeedStones(TmpP2, P2, MoreMoves, Remaining, Picked, StartHole, NextHole, _, _), 
	simpleSeedStones(NP, TmpP, MoreMoves, Remaining, StartHole, 1).

/* DO NOT SEED IN OPPONENTS KALAHA */
complexSeedStones([OppKalaha], [OppKalaha], _, X, X, _, _, 0, 0) :- !.

/* DO NOT SEED STONES IN THE SAME BOWL FROM WHICH THE STONES ARE PICKED UP */
complexSeedStones([0|NP], [0|P], MoreMoves, Remaining, Picked, StartHole, Hole, 0, 0) :-
	StartHole == Hole, 
	!, 
	NextHole is Hole + 1, 
	complexSeedStones(NP, P, MoreMoves, Remaining, Picked, StartHole, NextHole, _, _).

/* 
SEED LAST IN OWN BOWL WITH ZERO STONES => DO A CAPTURE.
IF LAST SEED LANDS IN MY OWN HOLE WITH ZERO STONES, 
THEN TAKE THIS STONE AND THE OPPOSITE HOLE'S STONES (OPPONENTS  SIDE)
AND PUT IT INTO MY KALAHA.
NOWNKALAHA IS NEW OWNKALAHA
*/
complexSeedStones([ 0, Own2, Own3, Own4, Own5, Own6, NOwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5,    0, OppKalaha], 
				  [ 0, Own2, Own3, Own4, Own5, Own6,  OwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  noMoreTurn, 0, 1, _, _, 0, 0 ):-
	!, 
	NOwnKalaha is OwnKalaha + Opp6 + 1.
complexSeedStones([ 0, Own3, Own4, Own5, Own6, NOwnKalaha, Opp1, Opp2, Opp3, Opp4,    0, Opp6, OppKalaha], 
				  [ 0, Own3, Own4, Own5, Own6,  OwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  noMoreTurn, 0, 1, _, _, 0, 0 ):-
	!, 
	NOwnKalaha is OwnKalaha + Opp5 + 1.
complexSeedStones([ 0, Own4, Own5, Own6, NOwnKalaha, Opp1, Opp2, Opp3,    0, Opp5, Opp6, OppKalaha], 
				  [ 0, Own4, Own5, Own6,  OwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
			      noMoreTurn, 0, 1, _, _, 0, 0 ):-
	!, 
	NOwnKalaha is OwnKalaha + Opp4 + 1.
complexSeedStones([ 0, Own5, Own6, NOwnKalaha, Opp1, Opp2,    0, Opp4, Opp5, Opp6, OppKalaha], 
				  [ 0, Own5, Own6,  OwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  noMoreTurn, 0, 1, _, _, 0, 0 ):-
	!, 
	NOwnKalaha is OwnKalaha + Opp3 + 1.
complexSeedStones([ 0, Own6, NOwnKalaha, Opp1,    0, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  [ 0, Own6,  OwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  noMoreTurn, 0, 1, _, _, 0, 0 ):-
	!, 
	NOwnKalaha is OwnKalaha + Opp2 + 1.
complexSeedStones([ 0, NOwnKalaha,    0, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  [ 0,  OwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  noMoreTurn, 0, 1, _, _, 0, 0 ):-
	!, 
	NOwnKalaha is OwnKalaha + Opp1 + 1.

/*
IF LAST SEED LANDS IN MY OWN KALAHA THEN I GET ANOTHER TURN
*/
complexSeedStones([NOwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  [ OwnKalaha, Opp1, Opp2, Opp3, Opp4, Opp5, Opp6, OppKalaha], 
				  moreTurn, 0, 1, _, _, 0, 0 ):-
	!, 
	NOwnKalaha is OwnKalaha + 1.

/*
NORMAL SEEDING OF THE LAST STONE
*/
complexSeedStones([NNX|P], [X|P], noMoreTurn, 0, 1, _, Hole, NTake, NTaken) :-
	!, 
	NX is X + 1, 
	performCapture(Hole, Hole, NTake, 0, NTaken, NX, NNX).

/*
NORMAL SEEDING OF STONES (BUT NOT LAST)
*/
complexSeedStones([NNX|NP], [X|P], MoreMoves, Remaining, InHand, StartHole, Hole, NTake, NTaken) :-
	InHand > 0, 
	!, 
	NX is X + 1, 
	NInHand is InHand - 1, 
	NextHole is Hole + 1, 
	complexSeedStones(NP, P, MoreMoves, Remaining, NInHand, StartHole, NextHole, Take, Taken), 
	performCapture(Take, Hole, NTake, Taken, NTaken, NX, NNX).

/*
IF LAST SEED ON OPPONENTS SIDE IN A BOWL WHERE THERE ARE 2 OR 3 STONES
THEN SHALL THOSE STONES BE MOVED TO MY KALAHA.  THIS SHALL BE REPEATED
CLOCKWISE UNTIL REACHING OWN KALAHA OR THERE THERE ARE NOT 2 OR 3
STONES IN THE BOWL.
*/
performCapture(_, 7, 0, Taken, 0, NX, NNX) :-
	!, 
	NNX is Taken + NX.
performCapture(0, _, 0, Taken, Taken, X, X) :-
	!.
performCapture(N, _, NN, Taken, NTaken, NX, 0) :-
	N > 7, N < 14, 	/* within the range of opponents holes */
	NX < 4, NX > 1, /* the holes have 2 or 3 stones */
	!, 
	NTaken is Taken + NX, 
	NN is N - 1.
performCapture(_, _, 0, Taken, Taken, NX, NX).

/*
SEARCH FOR START HOLE
*/
jump(1, P, P, NP, NP) :- !.
jump(N, [X|P], TmpP, [X|NP], TmpNP) :-
	N > 1, 
	!, 
	M is N - 1, 
	jump(M, P, TmpP, NP, TmpNP).

convertListToBoard( [Own1, Own2, Own3, Own4, Own5, Own6,  OwnKalaha,  Opp1, Opp2, Opp3, Opp4, Opp5, Opp6,  OppKalaha], 
					[[Own1, Own2, Own3, Own4, Own5, Own6], OwnKalaha, [Opp1, Opp2, Opp3, Opp4, Opp5, Opp6], OppKalaha] ).

/* 
--------------------------------------------------------------------------------
ALTERNATING BETWEEN PLAYER1 AND PLAYER2
--------------------------------------------------------------------------------
*/

nextPlayer(player1, player2).
nextPlayer(player2, player1).

/* 
--------------------------------------------------------------------------------
GAME INSTRUCTIONS HEADER 
--------------------------------------------------------------------------------
*/

:-
	protocol('gamelog.txt'), 
	nl, 
	write('----- Game Information -----'),
	nl,
	nl,
	write('This game is called Kalaha.'),
	nl,
	nl,
	write('--------------------------------------------------------------------------------'),
	nl,
	write('The rules for this game are as follows:'),
	nl,
	nl,
	write('1.	A player can start his/her move from any non-empty pit from his/her side of the board.'),
	nl,
	write('2.	The player cannot start his/her move using the pieces on the opponents side of the board.'),
	nl,
	write('3.	The players Kalaha, the players pits and the opponents pits are included in sowing. Opponents Kalaha is not included in sowing.'),
	nl,
	write('4.	Seeds are sowed in counter-clockwise (anti-clockwise) direction.'),
	nl,
	write('5.	The player cannot sow any of his/her seeds into the opponents Kalaha. i.e. we have to wrap around opponents Kalaha without placing any stone there.'),
	nl,
	write('6.	If the last seed land in the players Kalaha, the players score increases by 1 and he retain the right to continue playing.'),
	nl,
	write('7.	If the last seed does not end up in the players Kalaha, the player loses his/her turn.'),
	nl,
	write('8.	If last seed on opponents side in a bowl where there are 2 or 3 stones then those stones be will moved to players Kalaha. This shall be repeated clockwise until reaching own Kalaha or there are not 2 or 3 stones in the bowl.'),
	nl,
	write('9.	We cannot seed into the original hole from which the stones were picked.'),
	nl,
	write('10.	If the last counter is put into an empty hole on the players side of the board, a capture takes place: all stones in the opponents pit opposite and the last stone of the sowing are put into the players kalaha and the opponent moves next.'),
	nl,
	write('11.	If the last counter is put anywhere else, it is now the opponents turn.'),
	nl,
	write('12.	The seeds that are being captured or the seeds that has entered both players Kalaha do not re-enter the game. The game value of this game thus depends on the configuration of the active seeds or seeds that are not captured.'),
	nl,
	write('13.	When a players all holes are completely empty, the game ends. The player who still has stones left in his holes captures those stones and puts them in his Kalaha. The players then compare their Kalaha. The player with most stones wins.!!'),
	nl,
	write('--------------------------------------------------------------------------------'),
	nl,
	nl,
	write('A log file of the current game is created and all moves will be stored in this file at the end of the game...'), 
	nl, 
	write('The log file name is gamelog.txt'), 
	nl, 
	write('Check prolog current working directory using: working_directory(CWD, CWD).'), 
	nl, 
	write('The log file is stored at working_directory(CWD, CWD) folder...'), 
	nl, 
	nl,
	write('To change number of stones - run set(stones, Integer).'), 
	nl, 
	write('To change state-space search depth - run set(statespaceDepth, Integer).'), 
	nl,
	write('To change the pause duration between each move to have a look at the moves made - run set(pauseDuration, Float).'),
	nl,	
	write('To change player 1 alorithm - run set(player1, X).'), 
	nl, 
	write('To change player 2 alorithm - run set(player2, X).'), 
	nl, 
	write('  X can be either manual, minimax or alphabeta.'), 
	nl, nl, 
	write('The Default settings for the game are as follows: '), 
	nl, 
	write('stones = 6.'),
	nl, 
	write('statespaceDepth = 3.'),
	nl,
	write('pauseDuration = 0.25'),
	nl,
	write('Player1 algorithm = manual.'),
	nl,
	write('Player2 algorithm = minimax.'),
	nl,
	nl,
	write('The game is started with play(kalaha).'), 
	nl, nl.

