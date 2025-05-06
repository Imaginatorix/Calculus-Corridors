extends Node2D

var currentLevel = 1
var gameDififculty = "EASY"

var player

# Band-aid solution
var frozen = false

var playerSpeed = 125
var enemySpeed = 120
var powerUpSpeed = 100

var timeLimit = 600
var timeLeft = "00:00"
var timeRem = timeLimit

var STATE_MENU = "MENU"
var STATE_PLAYING = "PLAYING"
var STATE_ASKING = "ASKING"
var STATE_GAME_OVER = "GAME_OVER"
var STATE_COMPLETED = "COMPLETED"

var state = STATE_MENU
var paused = false

var question = ""
var asker = "Mx. Slime"
var choices = [0, 1, 2, 3]
var correct_answer

var correct_sound
var wrong_sound

var ALGEBRA = {
	"easy": [0, 2, 0, 0, 1, 1, 0, 0, 0, 1, 0, 3, 1, 1, 1],
	"average": [1, 3, 1, 0, 0, 0, 3, 2, 2, 0, 1, 1, 0, 2, 0],
	"difficult": [2, 0, 0, 2, 0, 3, 0, 2, 0, 3, 1, 3, 1, 2, 0]
}
var PRECAL = {
	"easy": [1, 2, 0, 2, 0, 2, 1, 0, 1, 1, 0, 1, 0, 1, 0],
	"average": [2, 0, 2, 1, 0, 0, 2, 2, 0, 0, 0, 0, 1, 1, 0],
	"difficult": [1, 0, 0, 1, 1, 1, 2, 2, 1, 0, 2, 0, 0, 1, 1]
}
var CALC1 = {
	"easy": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"average": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"difficult": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
}
var CALC2 = {
	"easy": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"average": [0, 2, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
	"difficult": [0, 2, 3, 0, 0, 1, 2, 2, 0, 1, 2, 0, 2, 0, 0]
}
