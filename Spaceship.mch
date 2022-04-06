/* Spaceship
 * Author: Sarvetha - 2018427 - W1742121
 * Creation date: 23-Nov-21
 */
MACHINE
    Spaceship

SEES
    Space
    
SETS
    REPORT = { MOVEMENT_SUCCESSFUL, MOVEMENT_FAILED, MOVEMENT_FAILED_ASTEROID_COLLISION, MOVEMENT_FAILED_INSUFFICIENT_POWER, MOVEMENT_FAILED_OUT_OF_BOUND,  WARP_DRIVE_SUCCESSFUL, WARP_DRIVE_FAILED, WARP_DRIVE_FAILED_ASTEROID_COLLISION, WARP_DRIVE_FAILED_INSUFFICIENT_POWER, WARP_DRIVE_FAILED_OUT_OF_BOUND, UNABLE_TO_DIRECTLY_WARP_TO_STARBASE, SPACESHIP_IS_DOCKED_AT_STARBASE, SPACESHIP_IS_NOT_AT_STARBASE, GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME, GAME_WON, GAME_NOT_OVER, GAME_LOST  } ;
    
    MOVEMENTS = {MoveUp, MoveDown, MoveForward, MoveBackward, WarpDrive};
    
    GAME_STATUS = { GameWon, GameLost, GameNotOver}
    
DEFINITIONS
    isAsteroidCollision( xx, yy ) == ( ( xx |-> yy ) : Asteroids );
    isSpaceshipInRegion( xx, yy ) == ( ( xx |-> yy ) : Region );
    
    // GUI animation function
    ANIMATION_FUNCTION == ({ row, col, icon | col:1..12 & row:1..7 & icon=0 });
    ANIMATION_FUNCTION1 == ({ row, col, icon | col:1..12 & row:1..7  & icon=1 & (col, 8-row) : Asteroids });
    ANIMATION_FUNCTION2 == ({ row, col, icon | col:1..12 & row:1..7 & icon=2 & col=spaceshipXRegion & row=(8-spaceshipYRegion) });
    ANIMATION_FUNCTION3 == ({ row, col, icon | col:1..12 & row:1..7 & icon=3 & (col, 8-row) : StarBase  });
    
    // Images for the GUI
    ANIMATION_IMG0 == "/Images/emptyspace.gif";
    ANIMATION_IMG1 == "/Images/asteroids.gif";
    ANIMATION_IMG2 == "/Images/rocketship.gif";
    ANIMATION_IMG3 == "/Images/starbase.gif";
    
CONSTANTS
    InitialPower,
    NormalMovePower,
    AsteroidCollisionPower,
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
    
VARIABLES
    spaceshipPower,
    spaceshipXRegion,
    spaceshipYRegion,
    spaceshipCurrentLocale,
    spaceshipVisitedLocale,
    noOfAsteroidCollisions,
    gameStatus,
    spaceshipMovements
    
INVARIANT
    spaceshipXRegion : NATURAL1 &
    spaceshipXRegion : SpaceXRegion &
    spaceshipYRegion : NATURAL1 &
    spaceshipYRegion : SpaceYRegion &
    spaceshipPower : INTEGER &
    spaceshipCurrentLocale : Region &
    spaceshipVisitedLocale : seq( Region ) &
    noOfAsteroidCollisions : NATURAL &
    gameStatus <: GAME_STATUS &
    spaceshipMovements : seq(MOVEMENTS)
    
    
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
    report, movements <-- Move_Up = 
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
        /* is game over */
        IF
            ( GameNotOver : gameStatus )
        THEN
            /* is power enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* is spaceship inside the region and has not hit an asteroid */ 
                IF
                    ( isSpaceshipInRegion( spaceshipXRegion, succ( spaceshipYRegion ) ) & not( isAsteroidCollision( spaceshipXRegion, succ( spaceshipYRegion ) ) ) )
                THEN
                    /* is current move results in the game winning */
                    IF
                        ( ( spaceshipXRegion |-> succ( spaceshipYRegion) ) : StarBase )
                    THEN
                        spaceshipXRegion, spaceshipYRegion := spaceshipXRegion, succ( spaceshipYRegion )
                        || spaceshipCurrentLocale := ( spaceshipXRegion |-> succ( spaceshipYRegion ) ) 
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> succ( spaceshipYRegion ) ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveUp
                        || movements := MoveUp
                    ELSE
                        /* is power enough to continue with the game after the current move */
                        IF
                            ( (spaceshipPower - NormalMovePower) >= NormalMovePower )
                        THEN
                            spaceshipXRegion, spaceshipYRegion := spaceshipXRegion, succ( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> succ( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> succ( spaceshipYRegion ) ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveUp
                            || movements := MoveUp

                        ELSE
                            spaceshipXRegion, spaceshipYRegion := spaceshipXRegion, succ( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> succ( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> succ( spaceshipYRegion ) ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveUp
                            || movements := MoveUp

                        END
                    END
                    /* is spaceship hits an asteroid */
                ELSIF
                    ( isAsteroidCollision( spaceshipXRegion, succ( spaceshipYRegion ) ) )
                THEN
                    /* is power enough to continue the game after the collision penalty */
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
                    /* is spaceship not inside the region */     
                ELSIF
                    ( not( isSpaceshipInRegion( spaceshipXRegion, succ( spaceshipYRegion ) ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- MoveUp
                    || movements := MoveUp

                ELSE
                    report := MOVEMENT_FAILED
                    || spaceshipMovements := spaceshipMovements <- MoveUp
                    || movements := MoveUp

                END
                /* if power not enough, sets the game status to lost and displays an insufficient power message */    
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveUp
                || movements := MoveUp

            END
            /* is game either won or lost, a message will be displayed and the user will not be able to make any more moves */    
        ELSIF 
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveUp
            || movements := MoveUp

        END
    END;
    
/* 
***************************************************************************************************************************************
Move Down
***************************************************************************************************************************************
*/
    report, movements <-- Move_Down = 
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
        /* is game over */
        IF
            ( GameNotOver : gameStatus )
        THEN
             /* is power enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* is spaceship inside the region and has not hit an asteroid */ 
                IF
                    ( isSpaceshipInRegion( spaceshipXRegion, pred( spaceshipYRegion ) ) & not( isAsteroidCollision( spaceshipXRegion, pred( spaceshipYRegion ) ) ) )
                THEN
                   /* is current move results in the game winning */
                    IF
                        ( ( spaceshipXRegion |-> pred( spaceshipYRegion) ) : StarBase )
                    THEN
                        spaceshipXRegion, spaceshipYRegion := spaceshipXRegion, pred( spaceshipYRegion )
                        || spaceshipCurrentLocale := ( spaceshipXRegion |-> pred( spaceshipYRegion ) ) 
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> pred( spaceshipYRegion ) ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveDown
                        || movements := MoveDown
                    ELSE
                        /* is power enough to continue with the game after the current move */
                        IF
                            ( (spaceshipPower - NormalMovePower) >= NormalMovePower )
                        THEN
                            spaceshipXRegion, spaceshipYRegion := spaceshipXRegion, pred( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> pred( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> pred( spaceshipYRegion ) ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveDown
                            || movements := MoveDown

                        ELSE

                            spaceshipXRegion, spaceshipYRegion := spaceshipXRegion, pred( spaceshipYRegion )
                            || spaceshipCurrentLocale := ( spaceshipXRegion |-> pred( spaceshipYRegion ) )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ spaceshipXRegion |-> pred( spaceshipYRegion ) ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveDown
                            || movements := MoveDown

                        END
                    END
                    /* is spaceship hits an asteroid */
                ELSIF
                    ( isAsteroidCollision( spaceshipXRegion, pred( spaceshipYRegion ) ) )
                THEN
                    /* is power enough to continue the game after the collision penalty */
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
                     /* is spaceship not inside the region */    
                ELSIF
                    ( not( isSpaceshipInRegion( spaceshipXRegion, pred( spaceshipYRegion ) ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- MoveDown
                    || movements := MoveDown
                ELSE
                    report := MOVEMENT_FAILED
                    || spaceshipMovements := spaceshipMovements <- MoveDown
                    || movements := MoveDown
                END
                /* if power not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveDown
                || movements := MoveDown

            END
            /* is game either won or lost, a message will be displayed and the user will not be able to make any more moves */        
        ELSIF 
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveDown
            || movements := MoveDown
        END
    END;
    
    
/* 
***************************************************************************************************************************************
MoveForward
***************************************************************************************************************************************
*/
    report, movements <-- Move_Forward = 
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
       /* is game over */
        IF
            ( GameNotOver : gameStatus ) 
        THEN
             /* is power enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* is spaceship inside the region and has not hit an asteroid */ 
                IF
                    ( isSpaceshipInRegion( succ( spaceshipXRegion ), spaceshipYRegion ) & not( isAsteroidCollision( succ( spaceshipXRegion ), spaceshipYRegion ) ) ) 
                THEN
                    /* is current move results in the game winning */
                    IF
                        ( ( succ( spaceshipXRegion ) |-> spaceshipYRegion ) : StarBase )
                    THEN
                        spaceshipXRegion, spaceshipYRegion := succ( spaceshipXRegion ), spaceshipYRegion
                        || spaceshipCurrentLocale := ( succ( spaceshipXRegion ) |-> spaceshipYRegion )
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ succ( spaceshipXRegion ) |-> spaceshipYRegion ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveForward
                        || movements := MoveForward
                    ELSE
                        /* is power enough to continue with the game after the current move */
                        IF
                            ( (spaceshipPower - NormalMovePower) >= NormalMovePower ) 
                        THEN
                            spaceshipXRegion, spaceshipYRegion := succ( spaceshipXRegion ), spaceshipYRegion
                            || spaceshipCurrentLocale := ( succ( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ succ( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveForward
                            || movements := MoveForward
                        ELSE
                            spaceshipXRegion, spaceshipYRegion := succ( spaceshipXRegion ), spaceshipYRegion
                            || spaceshipCurrentLocale := ( succ( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ succ( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveForward
                            || movements := MoveForward
                        END
                    END
                    /* is spaceship hits an asteroid */   
                ELSIF
                    ( isAsteroidCollision( succ( spaceshipXRegion ), spaceshipYRegion ) )
                THEN
                    /* is power enough to continue the game after the collision penalty */
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
                     /* is spaceship not inside the region */    
                ELSIF
                    ( not( isSpaceshipInRegion( succ( spaceshipXRegion ), spaceshipYRegion ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- MoveForward
                    || movements := MoveForward
                ELSE
                    report := MOVEMENT_FAILED
                    || spaceshipMovements := spaceshipMovements <- MoveForward
                    || movements := MoveForward
                END
                /* if power not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveForward
                || movements := MoveForward
            END
           /* is game either won or lost, a message will be displayed and the user will not be able to make any more moves */    
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveForward
            || movements := MoveForward
        END
    END;
    
/* 
***************************************************************************************************************************************
MoveBackward
***************************************************************************************************************************************
*/
    report, movements <-- Move_Backward = 
    PRE
        report : REPORT & movements : MOVEMENTS
    THEN
        /* is game over */
        IF
            ( GameNotOver : gameStatus ) 
        THEN
             /* is power enough for a normal move */
            IF
                ( spaceshipPower >= NormalMovePower )
            THEN
                /* is spaceship inside the region and has not hit an asteroid */ 
                IF
                    ( isSpaceshipInRegion( pred( spaceshipXRegion ), spaceshipYRegion ) & not( isAsteroidCollision( pred( spaceshipXRegion ), spaceshipYRegion ) ) ) 
                THEN
                    /* is current move results in the game winning */
                    IF
                        ( ( pred( spaceshipXRegion ) |-> spaceshipYRegion ) : StarBase )
                    THEN
                        spaceshipXRegion, spaceshipYRegion := pred( spaceshipXRegion ), spaceshipYRegion
                        || spaceshipCurrentLocale := ( pred( spaceshipXRegion ) |-> spaceshipYRegion )
                        || spaceshipPower := spaceshipPower - NormalMovePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ pred( spaceshipXRegion ) |-> spaceshipYRegion ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- MoveBackward
                        || movements := MoveBackward
                    ELSE
                        /* is power enough to continue with the game after the current move */
                        IF
                            ( (spaceshipPower - NormalMovePower) >= NormalMovePower ) 
                        THEN
                            spaceshipXRegion, spaceshipYRegion := pred( spaceshipXRegion ), spaceshipYRegion
                            || spaceshipCurrentLocale := ( pred( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ pred( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- MoveBackward
                            || movements := MoveBackward

                        ELSE

                            spaceshipXRegion, spaceshipYRegion := pred( spaceshipXRegion ), spaceshipYRegion
                            || spaceshipCurrentLocale := ( pred( spaceshipXRegion ) |-> spaceshipYRegion )
                            || spaceshipPower := spaceshipPower - NormalMovePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ pred( spaceshipXRegion ) |-> spaceshipYRegion ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- MoveBackward
                            || movements := MoveBackward

                        END
                    END
                    /* is spaceship hits an asteroid */
                ELSIF
                    ( isAsteroidCollision( pred( spaceshipXRegion ), spaceshipYRegion ) )
                THEN
                    /* is power enough to continue the game after the collision penalty */
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
                     /* is spaceship not inside the region */    
                ELSIF
                    ( not( isSpaceshipInRegion( pred( spaceshipXRegion ), spaceshipYRegion ) ) )
                THEN
                    report := MOVEMENT_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- MoveBackward
                    || movements := MoveBackward

                ELSE

                    report := MOVEMENT_FAILED
                    || spaceshipMovements := spaceshipMovements <- MoveBackward
                    || movements := MoveBackward
                END
                 /* if power not enough, sets the game status to lost and displays an insufficient power message */
            ELSE
                gameStatus := { GameLost }
                || report := MOVEMENT_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- MoveBackward
                || movements := MoveBackward

            END
           /* is game either won or lost, a message will be displayed and the user will not be able to make any more moves */    
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- MoveBackward
            || movements := MoveBackward
        END
    END;
    
    
/* 
***************************************************************************************************************************************
WarpDrive
***************************************************************************************************************************************
*/
    report, movements <-- EngageWarpDrive ( xx, yy ) = 
    PRE
        report : REPORT & movements : MOVEMENTS & xx : NATURAL1 & yy : NATURAL1
        THEN
       /* is game over */
        IF
            ( GameNotOver : gameStatus ) 
        THEN
            /* is power enough for a normal move */
            IF
                ( spaceshipPower >= WarpDrivePower )
            THEN
                /* is spaceship inside the region and has not hit an asteroid */ 
                IF
                    ( isSpaceshipInRegion( xx, yy ) & not( isAsteroidCollision( xx, yy ) ) & not( spaceshipCurrentLocale : HomeBase & ( xx |-> yy ) : StarBase ) ) 
                THEN
                    /* is current move results in the game winning */
                    IF
                        ( ( xx |-> yy ) : StarBase ) 
                    THEN
                        spaceshipXRegion, spaceshipYRegion := xx, yy
                        || spaceshipCurrentLocale := ( xx |-> yy )
                        || spaceshipPower := spaceshipPower - WarpDrivePower
                        || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ xx |-> yy ]
                        || gameStatus := { GameWon }
                        || report := GAME_WON
                        || spaceshipMovements := spaceshipMovements <- WarpDrive
                        || movements := WarpDrive
                    ELSE
                        /* is power enough to continue with the game after the current move */
                        IF
                            ( ( spaceshipPower - WarpDrivePower ) >= NormalMovePower ) 
                        THEN
                            spaceshipXRegion, spaceshipYRegion := xx, yy
                            || spaceshipCurrentLocale := ( xx |-> yy )
                            || spaceshipPower := spaceshipPower - WarpDrivePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ xx |-> yy ]
                            || gameStatus := { GameNotOver }
                            || report := MOVEMENT_SUCCESSFUL
                            || spaceshipMovements := spaceshipMovements <- WarpDrive
                            || movements := WarpDrive

                        ELSE

                            spaceshipXRegion, spaceshipYRegion := xx, yy
                            || spaceshipCurrentLocale := ( xx |-> yy )
                            || spaceshipPower := spaceshipPower - WarpDrivePower
                            || spaceshipVisitedLocale := spaceshipVisitedLocale ^ [ xx |-> yy ]
                            || gameStatus := { GameLost }
                            || report := GAME_LOST
                            || spaceshipMovements := spaceshipMovements <- WarpDrive
                            || movements := WarpDrive

                        END
                    END
                /* is user tries to warp directly from home base to star base */
                ELSIF
                    ( spaceshipCurrentLocale : HomeBase & ( xx |-> yy ) : StarBase ) 
                THEN
                    report := UNABLE_TO_DIRECTLY_WARP_TO_STARBASE
                /* is spaceship hits an asteroid */
                ELSIF
                    ( isAsteroidCollision( xx, yy ) )
                THEN
                    /* is power enough to continue the game after the collision penalty */
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
                 /* is spaceship not inside the region */
                ELSIF
                    ( not( isSpaceshipInRegion( xx, yy ) ) )
                THEN
                    report := WARP_DRIVE_FAILED_OUT_OF_BOUND
                    || spaceshipMovements := spaceshipMovements <- WarpDrive
                    || movements := WarpDrive
                ELSE
                    report := WARP_DRIVE_FAILED
                    || spaceshipMovements := spaceshipMovements <- WarpDrive
                    || movements := WarpDrive
                END
            /* if power not enough, sets the game status to lost and displays an insufficient power message */    
            ELSE
                report := WARP_DRIVE_FAILED_INSUFFICIENT_POWER
                || spaceshipMovements := spaceshipMovements <- WarpDrive
                || movements := WarpDrive
            END
         /* is game either won or lost, a message will be displayed and the user will not be able to make any more moves */    
        ELSIF
            ( GameWon : gameStatus or GameLost :  gameStatus )
        THEN
            report := GAME_ALREADY_ENDED_PLEASE_START_A_NEW_GAME
            || spaceshipMovements := spaceshipMovements <- WarpDrive
            || movements := WarpDrive
        END
    END;
/* 
***************************************************************************************************************************************
Mission Status
***************************************************************************************************************************************
*/
    
    location, power, collisions <-- MissionStatus =
    BEGIN
        location := spaceshipCurrentLocale
        || power := spaceshipPower
        || collisions := noOfAsteroidCollisions
    END;
    
/* 
***************************************************************************************************************************************
Mission Route
***************************************************************************************************************************************
*/
    report <-- MissionRoute =
    BEGIN
        report := spaceshipVisitedLocale
    END;
    
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
    END;
    
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
    END;

/* 
***************************************************************************************************************************************
Movements Taken
***************************************************************************************************************************************
*/
     
    allMovements <-- Movements_Taken =
    
    BEGIN
        allMovements := spaceshipMovements 
    END;
    
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