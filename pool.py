#! /usr/bin/python3

# Python script to use turtle graphics to solve
# the brilliant.org Summer Challenge problem #0

import sys
import turtle



if (len(sys.argv) > 2):
    width  = int(sys.argv[1])
    height = int(sys.argv[2])
else:
    # brilliant.org problem has 100x67
    width = 100
    height = 67

if (len(sys.argv) > 3):
    scale = int(sys.argv[3])
else:
    scale = 5

width  *= scale
height *= scale

def round(x):
    return (int(x+0.5))



def isBottom():
    pos = turtle.position()
    return ( round(pos[1]) == 0)

def isLeft():
    pos = turtle.position()
    return (round(pos[0]) == 0)

def isTop():
    pos = turtle.position()
    return (round(pos[1]) == height)

def isRight():
    pos = turtle.position()
    return (round(pos[0]) == width)

def isCorner():
    return ( (isBottom() and isLeft()  ) or
             (isLeft()   and isTop()   ) or
             (isTop()    and isRight() ) or
             (isRight()  and isBottom()) )


def isNE():
    return (round(turtle.heading()) == 45)

def isNW():
    return (round(turtle.heading()) == 135)

def isSW():
    return (round(turtle.heading()) == 225)

def isSE():
    return (round(turtle.heading()) == 315)


def moveOneDiagonal():
    # Where are we?
    (x,y) = turtle.position()

    # where should we go?
    if (isNE()):
        x += scale
        y += scale
    elif (isSE()):
        x += scale
        y -= scale
    elif (isSW()):
        x -= scale
        y -= scale
    else: # isNW()
        x -= scale
        y += scale

    # go there!
    turtle.setposition(x,y)




# Now that all the functions are defined, we can run the table!
# Go to origin, draw pool table as rectangle
turtle.speed(10)
turtle.penup()
turtle.setpos(0,0)
turtle.setheading(0)  # point east
turtle.pendown()
turtle.forward(width)
turtle.left(90)
turtle.forward(height)
turtle.left(90)
turtle.forward(width)
turtle.left(90)
turtle.forward(height)

# point northeast
turtle.setheading(45)
moveOneDiagonal()  # take the first step

while ( not isCorner()):
    # situations where I bounce a right turn
    if ( (isTop()    and isNE() ) or
         (isRight()  and isSE() ) or
         (isBottom() and isSW() ) or
         (isLeft()   and isNW() ) ):
        turtle.right(90)
    elif (isTop() or isRight() or isBottom() or isLeft()):
        turtle.left(90)

    # now move one diagonal
    moveOneDiagonal()
    # and repeat....

# we dropped out of the loop because isCorner!
# Make a circle around the winning corner!
turtle.seth(0)
turtle.penup()
turtle.forward(4*scale)
turtle.seth(90)
turtle.color("red")
turtle.pendown()
turtle.circle(4*scale)

input("All done. Press enter to quit")

























