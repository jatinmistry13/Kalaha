# Kalaha

A 2 player board game in Prolog which explores the areas of Artificial Intelligence

### Requirements

The Game requires SWI-Prolog installed on the machine. The SWI-Prolg can be downloaded from the following location: http://www.swi-prolog.org/download/stable
Please refer to installation steps mentioned on SWI-Prolog site for installation on specific Operating System.
After the installation is done, double-click the KalahaGame.pl file It will start with the game playing rules and instructions. To play the game start the game with: play(kalaha).

### Game playing

Initially the game starts as soon as you input the above command in the prolog editor because both the player's algorithm are set to minimax. If the user himself wants to play the game then, he/she can change the algorithm for a player to manual. This can be done using following command: set(player1, X). OR set(player2, X).

The value of 'X' can be any of the following: manual, minimax, OR alphabeta.

A log file for the current game is created in the current working directory. This can be checked by entering following command in the Prolog: working_directory(CWD, CWD).

Note: The full-stop (dot) after the command is necessary for the command to execute properly. Also for each command or move during the game a full-stop (dot) at the end of the command or move is necessary for proper execution of the move or command.

### Game Rules

1. A player can start his/her move from any non-empty pit from his/her side of the board.
2. The player cannot start his/her move using the pieces on the opponents side of the board.
3. The players Kalaha, the players pits and the opponents pits are included in sowing. Opponents Kalaha is not included in sowing.
4. Seeds are sowed in counter-clockwise (anti-clockwise) direction.
5. The player cannot sow any of his/her seeds into the opponents Kalaha. i.e. we have to wrap around opponents Kalaha without placing any stone there.
6. If the last seed land in the players Kalaha, the players score increases by 1 and he retain the right to continue playing.
7. If the last seed does not end up in the players Kalaha, the player loses his/her turn.
8. If last seed on opponents side in a bowl where there are 2 or 3 stones then those stones be will moved to players Kalaha. This shall be repeated clockwise until in the bowl.
9. We cannot seed into the original hole from which the stones were picked.
10. If the last counter is put into an empty hole on the players side of the board, a capture takes place: all stones in the opponents pit opposite and the last sto the opponent moves next.
11. If the last counter is put anywhere else, it is now the opponents turn.
12. The seeds that are being captured or the seeds that has entered both players Kalaha do not re-enter the game. The game value of this game thus depends on the co t captured.
13. When a players all holes are completely empty, the game ends. The player who still has stones left in his holes captures those stones and puts them in his Kalaha. The players then compare their Kalaha. The player with most stones wins.!!

### Log file

A log file of the current game is created and all moves will be stored in this file at the end of the game... The log file name is gamelog.txt Check prolog current working directory using: working_directory(CWD, CWD). The log file is stored at working_directory(CWD, CWD) folder...

### Alter Settings

To change settings execute forllowing:
number of stones ==> set(stones, Integer). 

search depth ==> set(statespaceDepth, Integer). 

pause duration between each move to have a look at the moves made ==> set(pauseDuration, Float). 

player 1 alorithm ==> set(player1, X).

player 2 alorithm ==> set(player2, X). 

where `X` is one of [manual, minimax, alphabeta].

### Default Settings

stones = 6.

statespaceDepth = 3. 

pauseDuration = 0.25. 

Player1 algorithm = manual. 

Player2 algorthm = minimax. 


### Starting the Game

The game is started with play(kalaha).
