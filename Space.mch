/* Space
 * Author: Sarvetha - 2018427 - W1742121
 * Creation date: 23-Nov-21
 */
MACHINE
    Space

CONSTANTS
    SpaceXRegion,
    SpaceYRegion,
    Region,
    Asteroids,
    EmptySpace,
    HomeBase,
    StarBase   
    
PROPERTIES
    // SpaceXRegion: 1-12
    SpaceXRegion <: NATURAL1 &
    SpaceXRegion = 1..12 & 
    
    // SpaceYRegion: 1-7
    SpaceYRegion <: NATURAL1 & 
    SpaceYRegion = 1..7 &
    
    // The SpaceXRegion and the SpaceYRegion have a relationship, which is an element of Region
    Region : SpaceXRegion <-> SpaceYRegion &
    
    // Region = ({1..12} * {1..7})
    Region = SpaceXRegion * SpaceYRegion &
    
    // The regions of space which are populated by 11 asteroids 
    Asteroids : SpaceXRegion <-> SpaceYRegion &
    Asteroids = {(3 |-> 2), (3 |-> 5), (5 |-> 4), (6 |-> 7), (7 |-> 1), (7 |-> 5), (7 |-> 7), (8 |-> 3), (10 |-> 6), (11 |-> 2), (12 |-> 5)} &
    
    // The regions of empty space 
    EmptySpace <: Region &
    EmptySpace /\ Asteroids = {} &
    EmptySpace \/ Asteroids = Region &
    
    // Region of Home Base
    HomeBase : SpaceXRegion <-> SpaceYRegion &
    HomeBase = {(1 |-> 1)} &
    
    // Region of Star Base
    StarBase : SpaceXRegion <-> SpaceYRegion &
    StarBase = {(6 |-> 4)}
    
END
