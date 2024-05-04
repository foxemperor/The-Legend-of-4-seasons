class_name PlayerKeybindResource
extends Resource


const MOVE_UP : String = "move_up"
const MOVE_DOWN : String = "move_down"
const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const INVENTORY : String = "inventory"
const RUN : String = "run"
const ATTACK : String = "attack"
const BLOCK : String = "block"
const ACTION : String = "action"


# Экспортируемые переменные для значений по-умолчанию
@export var DEFAULT_MOVE_UP_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_DOWN_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_INVENTORY_KEY = InputEventKey.new()
@export var DEFAULT_RUN_KEY = InputEventKey.new()
@export var DEFAULT_ATTACK_KEY = InputEventKey.new()
@export var DEFAULT_BLOCK_KEY = InputEventKey.new()
@export var DEFAULT_ACTION_KEY = InputEventKey.new()


# Хранение привязанных к действиям клавиш
var move_up_key = InputEventKey.new()
var move_down_key = InputEventKey.new()
var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var inventory_key = InputEventKey.new()
var run_key = InputEventKey.new()
var attack_key = InputEventKey.new()
var block_key = InputEventKey.new()
var action_key = InputEventKey.new()
