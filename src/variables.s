.data

// Ambrus started...

windowWidth:     .long 1000
windowHeight:    .long 1000


playerRadius:       .long 1112014848 # float 50
playerRadiusInt:    .long 50
halfPlayerSize:     .long 1108175838 # float playerRadius / sqrt(2)

renderer:           .quad # pointer of an SDL_Renderer

currentScoreTexture: .quad # pointer of an SDL_Texture
highestScoreTexture: .quad # pointer of an SDL_Texture

highestScoreBuffer: .skip 64 # string buffer for printing highest score
currentScoreBuffer: .skip 64 # string buffer for printing highest score

highestScore:       .long 0

score:              .long 0
font:               .quad # pointer of a TTF_Font

lifes:              .long 3 # number of lifes

waitingForKeyframe: .long 0 # the index of the keyframe we are currently waiting for
startTimeNs:        .long 0 # the time when we started the game


currentTimeNs:      .long 0 # the current time in nanoseconds
deltaTimeNs:        .long 0 # the time since the last frame in nanoseconds
vx_0:               .long 1140457472 # float 500.0f

vx:                 .long # float
vy:                 .long 0 # float
jumpSpeed:         .long 1148846080 # float 1000.0f

ay:                .long 1156415488 # float 1900.0f
ax:                .long 1145324611 # float 30.0f
isGameRunning:     .byte 1 # bool
obstacles:         .skip 480 # sizeof(struct Square) * 8
playerSquare:
    playerSquare_center:
        playerSquare_center_x:  .long 1120403456 # float 100.0f
        playerSquare_center_y:  .long 1134793348 # float 327.1446609406726f
    playerSquare_angle:         .long 0 # float
    playerSquare_radius:        .long 1112014848 # float 50.0f
    playerSquare_points:
        playerSquare_points_0:
            playerSquare_points_0_x: .long 0 # float 0.0f
            playerSquare_points_0_y: .long 0 # float 0.0f
        playerSquare_points_1:
            playerSquare_points_1_x: .long 0 # float 0.0f
            playerSquare_points_1_y: .long 0 # float 0.0f
        playerSquare_points_2:
            playerSquare_points_2_x: .long 0 # float 0.0f
            playerSquare_points_2_y: .long 0 # float 0.0f
        playerSquare_points_3:
            playerSquare_points_3_x: .long 0 # float 0.0f
            playerSquare_points_3_y: .long 0 # float 0.0f
    playerSquare_border:             .long 1084227584 # float 5.0f

    playerSquare_color:
        playerSquare_color_r:       .byte 26
        playerSquare_color_g:       .byte 18
        playerSquare_color_b:       .byte 57

    playerSquare_borderColor:
        playerSquare_borderColor_r: .byte 106
        playerSquare_borderColor_g: .byte 88
        playerSquare_borderColor_b: .byte 177


timeStruct:                         .skip 16 # a timespec

scoreFmtString:                     .asciz "Score: %ld"
highestFmtString:                   .asciz "Highest: %ld"

.text

.global maxHeight
.global sqHeight
.global sqHeightInt
.global sqRadius
.global sqRadiusInt

.global PI
.global keyFrames
.global lastAddedObstacle
.global sqDistance
.global topObstacleHeight
.global rotatingSpeed
.global center1
.global sqCenterX
.global baseHeight
.global baseHeightInt

.global windowWidth
.global windowHeight

.global renderer
.global currentScoreTexture
.global highestScoreTexture
.global currentScoreBuffer
.global highestScoreBuffer
.global highestScore
.global score
.global font
.global waitingForKeyframe
.global startTimeNs
.global currentTimeNs
.global deltaTimeNs
.global vx_0
.global vx
.global vy
.global jumpSpeed
.global ay
.global ax
.global isGameRunning
.global obstacles
.global playerSquare
.global timeStruct
.global asd
.global scoreFmtString
.global highestFmtString
.global PI_OVER_4
.global lifes