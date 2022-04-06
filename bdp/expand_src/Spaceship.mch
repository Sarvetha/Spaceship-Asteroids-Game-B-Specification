/* Spaceship
 * Author: Sarvetha
 * Creation date: 23-Nov-21
 */
MACHINE
    Spaceship

SEES
    Space

SETS
    REPORT = { MOVEMENT_SUCCESSFUL , MOVEMENT_FAILED , MOVEMENT_FAILED_ASTEROID_COLLISION , MOVEMENT_FAILED_INSUFFICIENT_POWER , MOVEMENT_FAILED_OUT_OF_BOUND , WARP_DRIVE_SUCCESSFUL , WARP_DRIVE_FAILED , WARP_DRIVE_FAILED_ASTEROID_COLLISION , WARP_DRIVE_FAILED_INSUFFICIENT_POWER , WARP_DRIVE_FAILED_OUT_OF_BOUND , UNABLE_TO_DIRECTLY_WARP_TO_STARBASE , SPACESHIP_IS_DOCKED_AT_STARBASE , SPACESHIP_IS_NOT_AT_STARBASE , GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME , GAME_WON , GAME_NOT_OVER , GAME_LOST } ;

    MOVEMENTS = { MoveUp , MoveDown , MoveForward , MoveBackward , WarpDrive } ;

    DOCKED_STATUS = { Yes , No } ;

    GAME_STATUS = { GameWon , GameLost , GameNotOver }

DEFINITIONS
    isAsteroidCollision ( xx , yy ) == ( ( xx |-> yy ) : Asteroids ) ;
    isSpaceshipInRegion ( xx , yy ) == ( ( xx |-> yy ) : Region ) ;


    ANIMATION_FUNCTION == ( { row , col , icon | col : 1 .. 12 & row : 1 .. 7 & icon = 0 } ) ;
    ANIMATION_FUNCTION1 == ( { row , col , icon | col : 1 .. 12 & row : 1 .. 7 & icon = 1 & ( col , 8 - row ) : Asteroids } ) ;
    ANIMATION_FUNCTION2 == ( { row , col , icon | col : 1 .. 12 & row : 1 .. 7 & icon = 2 & col = spaceshipXRegion & row = ( 8 - spaceshipYRegion ) } ) ;
    ANIMATION_FUNCTION3 == ( { row , col , icon | col : 1 .. 12 & row : 1 .. 7 & icon = 3 & ( col , 8 - row ) : StarBase } ) ;


    ANIMATION_IMG0 == "/emptyspace.gif" ;
    ANIMATION_IMG1 == "/asteroids.gif" ;
    ANIMATION_IMG2 == "/rocketship.gif" ;
    ANIMATION_IMG3 == "/starbase.gif" ;

CONCRETE_CONSTANTS
    InitialPower ,
    NormalMovePower ,
    AsteroidCollisionPower ,
    WarpDrivePower

PROPERTIES
    InitialPower : NATURAL1 &
    InitialPower = 130 &
    NormalMovePower : NATURAL1  &
    NormalMovePower = 5 &
    AsteroidCollisionPower : NATURAL1  &
    AsteroidCollisionPower = 10 &
    WarpDrivePower : NATURAL1  &
    WarpDrivePower = 20

ABSTRACT_VARIABLES
    spaceshipPower ,
    spaceshipXRegion ,
    spaceshipYRegion ,
    spaceshipCurrentLocale ,
    spaceshipVisitedLocale ,
    noOfAsteroidCollisions ,
    gameStatus ,
    spaceshipMovements

INVARIANT
    spaceshipXRegion : NATURAL1 &
    spaceshipXRegion : SpaceXRegion &
    spaceshipYRegion : NATURAL1 &
    spaceshipYRegion : SpaceYRegion &
    spaceshipPower : INTEGER &
    spaceshipCurrentLocale : Region &
    spaceshipVisitedLocale : seq ( Region ) &
    noOfAsteroidCollisions : NATURAL &
    gameStatus <: GAME_STATUS &
    spaceshipMovements : seq ( MOVEMENTS )


INITIALISATION
    spaceshipXRegion := 1 ||
    spaceshipYRegion := 1 ||
    spaceshipPower := 130 ||
    spaceshipCurrentLocale := ( 1 |-> 1 ) ||
    spaceshipVisitedLocale := [ ( 1 |-> 1 ) ] ||
    noOfAsteroidCollisions := 0 ||
    gameStatus := { GameNotOver } ||
    spaceshipMovements := []

OPERATIONS
/* 
****************************************************************************************************************************************************
Move Up
****************************************************************************************************************************************************
*/
    report , movements <-- Move_Up =
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
        /* Checks if the game is over */
        IF
            ( GameNotOver : gameStatus )
        THEN
            /* Checks if the power is enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* Checks if the spaceship is inside the grid and has not hit an asteroid */
                IF
                    ( isSpaceshipInRegion ( spaceshipXRegion , succ ( spaceshipYRegion ) ) & not ( isAsteroidCollision ( spaceshipXRegion , succ ( spaceshipYRegion ) ) ) )
                THEN
                    /* Checks if the current move results in the game winning */
                    IF
                        ( ( spaceshipXRegion |-> succ ( spaceshipYRegion ) ) : StarBase )
                    THEN
                        spaceshipXRegion , spaceshipYRegion := spaceshipXRegion , succ ( spaceshipYRegion )
                        || spaceshipCurrentLocale := ( spaceshipXRegion |-> succ ( spaceshipYRegion ) )
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> succ ( spaceshipYRegion ) ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveUp
                        || movements := MoveUp
                    ELSE
                        /* Checks if power will be enough to continue with the game after the current move */
                        IF
                            ( ( spaceshipPower - NormalMovePower ) >= NormalMovePower )
                        THEN
                            spaceshipXRegion , spaceshipYRegion := spaceshipXRegion , succ ( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> succ ( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> succ ( spaceshipYRegion ) ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveUp
                            || movements := MoveUp

                        ELSE
                            spaceshipXRegion , spaceshipYRegion := spaceshipXRegion , succ ( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> succ ( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> succ ( spaceshipYRegion ) ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveUp
                            || movements := MoveUp

                        END
                    END
                    /* Checks if the spaceship has hit an asteroid */
                ELSIF
                    ( isAsteroidCollision ( spaceshipXRegion , succ ( spaceshipYRegion ) ) )
                THEN
                    /* Checks if the power will be enough to continue the game after the collision penalty */
                    IF
                        ( ( spaceshipPower - AsteroidCollisionPower ) >= NormalMovePower )
                    THEN
                        gameStatus := { GameNotOver }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := MOVEMENT_FAILED_ASTEROID_COLLISION
                        || spaceshipMovements := spaceshipMovements <- MoveUp
                        || movements := MoveUp

                    ELSE

                        gameStatus := { GameLost }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := GAME_LOST
                        || spaceshipMovements := spaceshipMovements <- MoveUp
                        || movements := MoveUp

                    END
                    /* Checks if the spaceship is not inside the grid */
                ELSIF
                    ( not ( isSpaceshipInRegion ( spaceshipXRegion , succ ( spaceshipYRegion ) ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- MoveUp
                    || movements := MoveUp

                ELSE
                    report := MOVEMENT_FAILED
                    || spaceshipMovements := spaceshipMovements <- MoveUp
                    || movements := MoveUp

                END
                /* If the power is not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveUp
                || movements := MoveUp

            END
            /* If the game is either already won or lost, a message will be displayed and the user will not be able to make any more moves */
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveUp
            || movements := MoveUp

        END
    END ;

/* 
***************************************************************************************************************************************
Move Down
***************************************************************************************************************************************
*/
    report , movements <-- Move_Down =
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
        /* Checks if the game is over */
        IF
            ( GameNotOver : gameStatus )
        THEN
            /* Checks if the power is enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* Checks if the spaceship is inside the grid and has not hit an asteroid */
                IF
                    ( isSpaceshipInRegion ( spaceshipXRegion , pred ( spaceshipYRegion ) ) & not ( isAsteroidCollision ( spaceshipXRegion , pred ( spaceshipYRegion ) ) ) )
                THEN
                    /* Checks if the current move results in the game winning */
                    IF
                        ( ( spaceshipXRegion |-> pred ( spaceshipYRegion ) ) : StarBase )
                    THEN
                        spaceshipXRegion , spaceshipYRegion := spaceshipXRegion , pred ( spaceshipYRegion )
                        || spaceshipCurrentLocale := ( spaceshipXRegion |-> pred ( spaceshipYRegion ) )
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> pred ( spaceshipYRegion ) ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveDown
                        || movements := MoveDown
                    ELSE
                        /* Checks if power will be enough to continue with the game after the current move */
                        IF
                            ( ( spaceshipPower - NormalMovePower ) >= NormalMovePower )
                        THEN
                            spaceshipXRegion , spaceshipYRegion := spaceshipXRegion , pred ( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> pred ( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> pred ( spaceshipYRegion ) ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveDown
                            || movements := MoveDown

                        ELSE

                            spaceshipXRegion , spaceshipYRegion := spaceshipXRegion , pred ( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> pred ( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> pred ( spaceshipYRegion ) ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveDown
                            || movements := MoveDown

                        END
                    END
                    /* Checks if the spaceship has hit an asteroid */
                ELSIF
                    ( isAsteroidCollision ( spaceshipXRegion , pred ( spaceshipYRegion ) ) )
                THEN
                    /* Checks if the power will be enough to continue the game after the collision penalty */
                    IF
                        ( ( spaceshipPower - AsteroidCollisionPower ) >= NormalMovePower )
                    THEN
                        gameStatus := { GameNotOver }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := MOVEMENT_FAILED_ASTEROID_COLLISION
                        || spaceshipMovements := spaceshipMovements <- MoveDown
                        || movements := MoveDown

                    ELSE
                        gameStatus := { GameLost }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := GAME_LOST
                        || spaceshipMovements := spaceshipMovements <- MoveDown
                        || movements := MoveDown

                    END
                    /* Checks if the spaceship is not inside the grid */
                ELSIF
                    ( not ( isSpaceshipInRegion ( spaceshipXRegion , pred ( spaceshipYRegion ) ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                ELSE
                    report := MOVEMENT_FAILED
                END
                /* If the power is not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveDown
                || movements := MoveDown

            END
            /* If the game is either already won or lost, a message will be displayed and the user will not be able to make any more moves */
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveDown
            || movements := MoveDown
        END
    END ;


/* 
***************************************************************************************************************************************
MoveForward
***************************************************************************************************************************************
*/
    report , movements <-- Move_Forward =
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
        /* Checks if the game is over */
        IF
            ( GameNotOver : gameStatus )
        THEN
            /* Checks if the power is enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* Checks if the spaceship is inside the grid and has not hit an asteroid */
                IF
                    ( isSpaceshipInRegion ( succ ( spaceshipXRegion ) , spaceshipYRegion ) & not ( isAsteroidCollision ( succ ( spaceshipXRegion ) , spaceshipYRegion ) ) )
                THEN
                    /* Checks if the current move results in the game winning */
                    IF
                        ( ( succ ( spaceshipXRegion ) |-> spaceshipYRegion ) : StarBase )
                    THEN
                        spaceshipXRegion , spaceshipYRegion := succ ( spaceshipXRegion ) , spaceshipYRegion
                        || spaceshipCurrentLocale := ( succ ( spaceshipXRegion ) |-> spaceshipYRegion )
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ succ ( spaceshipXRegion ) |-> spaceshipYRegion ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveForward
                        || movements := MoveForward
                    ELSE
                        /* Checks if power will be enough to continue with the game after the current move */
                        IF
                            ( ( spaceshipPower - NormalMovePower ) >= NormalMovePower )
                        THEN
                            spaceshipXRegion , spaceshipYRegion := succ ( spaceshipXRegion ) , spaceshipYRegion
                            || spaceshipCurrentLocale := ( succ ( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ succ ( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveForward
                            || movements := MoveForward
                        ELSE
                            spaceshipXRegion , spaceshipYRegion := succ ( spaceshipXRegion ) , spaceshipYRegion
                            || spaceshipCurrentLocale := ( succ ( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ succ ( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveForward
                            || movements := MoveForward
                        END
                    END
                    /* Checks if the spaceship has hit an asteroid */
                ELSIF
                    ( isAsteroidCollision ( succ ( spaceshipXRegion ) , spaceshipYRegion ) )
                THEN
                    /* Checks if the power will be enough to continue the game after the collision penalty */
                    IF
                        ( ( spaceshipPower - AsteroidCollisionPower ) >= NormalMovePower )
                    THEN
                        gameStatus := { GameNotOver }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := MOVEMENT_FAILED_ASTEROID_COLLISION
                        || spaceshipMovements := spaceshipMovements <- MoveForward
                        || movements := MoveForward
                    ELSE
                        gameStatus := { GameLost }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := GAME_LOST
                        || spaceshipMovements := spaceshipMovements <- MoveForward
                        || movements := MoveForward
                    END
                    /* Checks if the spaceship is not inside the grid */
                ELSIF
                    ( not ( isSpaceshipInRegion ( succ ( spaceshipXRegion ) , spaceshipYRegion ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- MoveForward
                    || movements := MoveForward
                ELSE
                    report := MOVEMENT_FAILED
                    || spaceshipMovements := spaceshipMovements <- MoveForward
                    || movements := MoveForward
                END
                /* If the power is not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveForward
                || movements := MoveForward
            END
            /* If the game is either already won or lost, a message will be displayed and the user will not be able to make any more moves */
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveForward
            || movements := MoveForward
        END
    END ;

/* 
***************************************************************************************************************************************
MoveBackward
***************************************************************************************************************************************
*/
    report , movements <-- Move_Backward =
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
        /* Checks if the game is over */
        IF
            ( GameNotOver : gameStatus )
        THEN
            /* Checks if the power is enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* Checks if the spaceship is inside the grid and has not hit an asteroid */
                IF
                    ( isSpaceshipInRegion ( pred ( spaceshipXRegion ) , spaceshipYRegion ) & not ( isAsteroidCollision ( pred ( spaceshipXRegion ) , spaceshipYRegion ) ) )
                THEN
                    /* Checks if the current move results in the game winning */
                    IF
                        ( ( pred ( spaceshipXRegion ) |-> spaceshipYRegion ) : StarBase )
                    THEN
                        spaceshipXRegion , spaceshipYRegion := pred ( spaceshipXRegion ) , spaceshipYRegion
                        || spaceshipCurrentLocale := ( pred ( spaceshipXRegion ) |-> spaceshipYRegion )
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ pred ( spaceshipXRegion ) |-> spaceshipYRegion ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveBackward
                        || movements := MoveBackward
                    ELSE
                        /* Checks if power will be enough to continue with the game after the current move */
                        IF
                            ( ( spaceshipPower - NormalMovePower ) >= NormalMovePower )
                        THEN
                            spaceshipXRegion , spaceshipYRegion := pred ( spaceshipXRegion ) , spaceshipYRegion
                            || spaceshipCurrentLocale := ( pred ( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ pred ( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveBackward
                            || movements := MoveBackward

                        ELSE

                            spaceshipXRegion , spaceshipYRegion := pred ( spaceshipXRegion ) , spaceshipYRegion
                            || spaceshipCurrentLocale := ( pred ( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ pred ( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveBackward
                            || movements := MoveBackward

                        END
                    END
                    /* Checks if the spaceship has hit an asteroid */
                ELSIF
                    ( isAsteroidCollision ( pred ( spaceshipXRegion ) , spaceshipYRegion ) )
                THEN
                    /* Checks if the power will be enough to continue the game after the collision penalty */
                    IF
                        ( ( spaceshipPower - AsteroidCollisionPower ) >= NormalMovePower )
                    THEN
                        gameStatus := { GameNotOver }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := MOVEMENT_FAILED_ASTEROID_COLLISION
                        || spaceshipMovements := spaceshipMovements <- MoveBackward
                        || movements := MoveBackward

                    ELSE

                        gameStatus := { GameLost }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || spaceshipPower  := spaceshipPower - AsteroidCollisionPower
                        || report := GAME_LOST
                        || spaceshipMovements := spaceshipMovements <- MoveBackward
                        || movements := MoveBackward

                    END
                    /* Checks if the spaceship is not inside the grid */
                ELSIF
                    ( not ( isSpaceshipInRegion ( pred ( spaceshipXRegion ) , spaceshipYRegion ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- MoveBackward
                    || movements := MoveBackward

                ELSE

                    report := MOVEMENT_FAILED
                    || spaceshipMovements := spaceshipMovements <- MoveBackward
                    || movements := MoveBackward
                END
                /* If the power is not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveBackward
                || movements := MoveBackward

            END
            /* If the game is either already won or lost, a message will be displayed and the user will not be able to make any more moves */
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveBackward
            || movements := MoveBackward
        END
    END ;


/* 
***************************************************************************************************************************************
WarpDrive
***************************************************************************************************************************************
*/
    report , movements <-- EngageWarpDrive ( xx , yy ) =
    PRE
        report : REPORT & movements : MOVEMENTS & xx : NATURAL1 & yy : NATURAL1
        THEN
        /* Checks if the game is over */
        IF
            ( GameNotOver : gameStatus )
        THEN
            /* Checks if the power is enough for a normal move */
            IF
                ( spaceshipPower >= WarpDrivePower )
            THEN
                /* Checks if the spaceship is inside the grid and has not hit an asteroid */
                IF
                    ( isSpaceshipInRegion ( xx , yy ) & not ( isAsteroidCollision ( xx , yy ) ) & not ( spaceshipCurrentLocale : HomeBase & ( xx |-> yy ) : StarBase ) )
                THEN
                    /* Checks if the current move results in the game winning */
                    IF
                        ( ( xx |-> yy ) : StarBase )
                    THEN
                        spaceshipXRegion , spaceshipYRegion := xx , yy
                        || spaceshipCurrentLocale := ( xx |-> yy )
                        || spaceshipPower := spaceshipPower - WarpDrivePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ xx |-> yy ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- WarpDrive
                        || movements := WarpDrive
                    ELSE
                        /* Checks if power will be enough to continue with the game after the current move */
                        IF
                            ( ( spaceshipPower - WarpDrivePower ) >= NormalMovePower )
                        THEN
                            spaceshipXRegion , spaceshipYRegion := xx , yy
                            || spaceshipCurrentLocale := ( xx |-> yy )
                            || spaceshipPower := spaceshipPower - WarpDrivePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ xx |-> yy ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- WarpDrive
                            || movements := WarpDrive

                        ELSE

                            spaceshipXRegion , spaceshipYRegion := xx , yy
                            || spaceshipCurrentLocale := ( xx |-> yy )
                            || spaceshipPower := spaceshipPower - WarpDrivePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ xx |-> yy ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- WarpDrive
                            || movements := WarpDrive

                        END
                    END
                /* Checks if the user tries to warp directly from home base to star base */
                ELSIF
                    ( spaceshipCurrentLocale : HomeBase & ( xx |-> yy ) : StarBase )
                THEN
                    report := UNABLE_TO_DIRECTLY_WARP_TO_STARBASE
                /* Checks if the spaceship has hit an asteroid */
                ELSIF
                    ( isAsteroidCollision ( xx , yy ) )
                THEN
                    /* Checks if the power will be enough to continue the game after the collision penalty */
                    IF
                        ( ( spaceshipPower - AsteroidCollisionPower ) >= NormalMovePower )
                    THEN
                        gameStatus := { GameNotOver }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || report := WARP_DRIVE_FAILED_ASTEROID_COLLISION
                        || spaceshipMovements := spaceshipMovements <- WarpDrive
                        || movements := WarpDrive

                    ELSE

                        gameStatus := { GameLost }
                        || noOfAsteroidCollisions := noOfAsteroidCollisions + 1
                        || report := GAME_LOST
                        || spaceshipMovements := spaceshipMovements <- WarpDrive
                        || movements := WarpDrive

                    END
                /* Checks if the spaceship is not inside the grid */
                ELSIF
                    ( not ( isSpaceshipInRegion ( xx , yy ) ) )
                THEN
                    report := WARP_DRIVE_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- WarpDrive
                    || movements := WarpDrive
                ELSE
                    report := WARP_DRIVE_FAILED
                    || spaceshipMovements := spaceshipMovements <- WarpDrive
                    || movements := WarpDrive
                END
            /* If the power is not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                report := WARP_DRIVE_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- WarpDrive
                || movements := WarpDrive
            END
         /* If the game is either already won or lost, a message will be displayed and the user will not be able to make any more moves */
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- WarpDrive
            || movements := WarpDrive
        END
    END ;
/* 
***************************************************************************************************************************************
Mission Status
***************************************************************************************************************************************
*/

    location , power , collisions <-- MissionStatus =
    BEGIN
        location := spaceshipCurrentLocale
        || power := spaceshipPower
        || collisions := noOfAsteroidCollisions
    END ;

/* 
***************************************************************************************************************************************
Mission Route
***************************************************************************************************************************************
*/
    report <-- MissionRoute =
    BEGIN
        report := spaceshipVisitedLocale
    END ;

/* 
***************************************************************************************************************************************
Docked at Starbase
***************************************************************************************************************************************
*/
    report <-- DockedAtStarbase =
    PRE
        report : REPORT
    THEN
        IF
            ( spaceshipCurrentLocale : StarBase )
        THEN
            report := SPACESHIP_IS_DOCKED_AT_STARBASE
        ELSE
            report := SPACESHIP_IS_NOT_AT_STARBASE
        END
    END ;

/* 
***************************************************************************************************************************************
Game Status
***************************************************************************************************************************************
*/

    report <-- GameStatus =
    PRE
        report : REPORT
    THEN
        IF
            ( GameWon : gameStatus )
        THEN
            report := GAME_WON
        ELSIF
            ( GameLost : gameStatus )
        THEN
            report := GAME_LOST
        ELSIF
            ( GameNotOver : gameStatus )
        THEN
            report := GAME_NOT_OVER
        END
    END ;

/* 
***************************************************************************************************************************************
Movements Taken
***************************************************************************************************************************************
*/

    allMovements <-- Movements_Taken =

    BEGIN
        allMovements := spaceshipMovements
    END ;

/* 
***************************************************************************************************************************************
Reset Game
***************************************************************************************************************************************
*/
    Reset_Game =

   BEGIN
        spaceshipXRegion := 1
        || spaceshipYRegion := 1
        || spaceshipVisitedLocale := []
        || spaceshipPower := 125
        || spaceshipMovements  := []


    END


END
