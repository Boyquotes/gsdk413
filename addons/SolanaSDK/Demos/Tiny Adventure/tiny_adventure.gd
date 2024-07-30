extends Node

@onready var start_screen = $StartingScreen
@onready var game_screen = $GameScreen
@onready var anchor_program:AnchorProgram = $AnchorProgram
@onready var anchor2_program:AnchorProgram = $AnchorProgram2
@onready var anchor3_program:AnchorProgram = $AnchorProgram3

@export var tiny_adventure_pid:String
@export var account_voter_pid:String
@export var account_voter_light_pid:String
@export var start_button:ButtonLock
@export var start_account_button:ButtonLock

@export var player:TextureRect
@export var chest:TextureRect
@export var chest_prize:float
@export var prize_label:Label
@export var step_blocks:Array[CenterContainer]
@export var left_button:TextureButton
@export var right_button:TextureButton

@export var in_game_balance:TokenVisualizer

var level_pda
var vault_pda

var account_voter_pda
var account_voter_light_pda
var account_voter_light_pda2
var account_voter_light_pda3

var curr_pos:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneLoader.emit_signal("scene_loaded")
	print(anchor3_program.to_string())
	print(anchor3_program["pid"])
	print(anchor3_program["json_file"])
#	file.open(d_file, file.READ)
#	print(anchor3_program["json_file"].get_as_text())
	print(anchor3_program["json_file"].get_data())
	anchor3_program.set_pid("HKUv1rTwUWxKTZp4FQ2cPfQsmQvfGxVAvPXRceE2nnkT")
	
	level_pda = Pubkey.new_pda(["Level1"],Pubkey.new_from_string(tiny_adventure_pid))
	vault_pda = Pubkey.new_pda(["Vault1"],Pubkey.new_from_string(tiny_adventure_pid))
	print("account_voter_pid "+account_voter_pid)
	print("account_voter_light_pid "+account_voter_light_pid)
	
	print("pubkey wallet "+SolanaService.wallet.get_pubkey().to_string())
	
	
	account_voter_light_pda = Pubkey.new_pda(["accountVoter",SolanaService.wallet.get_pubkey()],Pubkey.new_from_string(account_voter_light_pid))
	print("account_voter_light_pda "+account_voter_light_pda.to_string());
	account_voter_light_pda2 = Pubkey.new_pda(["accountVoter",Pubkey.new_from_string("3k43rhavF7Sso7Z6E1WwcLEV2jiCHkFeU1nJYtRk26ex")], Pubkey.new_from_string(account_voter_light_pid))
	print("account_voter_light_pda2 "+account_voter_light_pda2.to_string());
	
	account_voter_light_pda3 = Pubkey.new_pda(["accountVoter2"], Pubkey.new_from_string(account_voter_light_pid));
	print("account_voter_light_pda3 "+account_voter_light_pda3.to_string());

#	account_voter_pda = Pubkey.new_pda(["accountVoter"],Pubkey.new_from_string(account_voter_pid))
	account_voter_pda = Pubkey.new_pda(["accountVoter"],Pubkey.new_from_string(SolanaService.wallet.get_pubkey().to_string()));
	print("account_voter_pda "+account_voter_pda.to_string());
#	print(account_voter_light_pda.to_string());

	start_button.text = "Create acc (%s SOL)" % chest_prize
#	start_button.pressed.connect(init_game)
#	start_button.pressed.connect(init2_game)
	start_button.pressed.connect(init3_game)
	left_button.pressed.connect(move_left)
	right_button.pressed.connect(move_right)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func init3_game() -> void:
	print("begin3")
	print(account_voter_light_pid)
	print(SolanaService.wallet.get_kp())
#	print(Keypair.new_from_file(custom_wallet_path))
	var user_wallet:String = SolanaService.wallet.get_pubkey().to_string()
	print(user_wallet)
	print(SystemProgram.get_pid().to_string())
	print("Anchor program ", anchor3_program)
	print(anchor3_program["json_file"].get_data())
	print("begin3 IDL {}", anchor3_program.get_idl())
	var instructions:Array[Instruction]
	var init_ix:Instruction = anchor3_program.build_instruction("initialize",[
		account_voter_light_pda3,
		SolanaService.wallet.get_kp(), #signer
		SystemProgram.get_pid() #system program
	], {"pseudo" : "testPseudo"})
	print(instructions)
	print(init_ix)
	instructions.append(init_ix)
	print(instructions)
	var tx_id:String = await SolanaService.transaction_processor.sign_transaction(SolanaService.wallet.get_kp(),instructions,"finalized")

	if tx_id=="":
		push_error("Failed to start game")
		return

#	update_prize()
#	set_player_pos()
#	in_game_balance.load_token()

	start_screen.visible=false
	game_screen.visible=true


func init2_game() -> void:
	print("begin")
	print(account_voter_pid)
	print(SolanaService.wallet.get_kp())
#	print(Keypair.new_from_file(custom_wallet_path))
	var user_wallet:String = SolanaService.wallet.get_pubkey().to_string()
	print(user_wallet)
	var prize_in_lamports:int = int(chest_prize*pow(10,9))
	var instructions:Array[Instruction]
	var init_ix:Instruction = anchor2_program.build_instruction("initialize",[
		account_voter_pda,
		SolanaService.wallet.get_kp(), #signer
		SystemProgram.get_pid() #system program
	],
	AnchorProgram.u64(prize_in_lamports))

	instructions.append(init_ix)
	var tx_id:String = await SolanaService.transaction_processor.sign_transaction(SolanaService.wallet.get_kp(),instructions,"finalized")

	if tx_id=="":
		push_error("Failed to start game")
		return

	update_prize()
	set_player_pos()
	in_game_balance.load_token()

	start_screen.visible=false
	game_screen.visible=true

func init_game() -> void:
	var prize_in_lamports:int = int(chest_prize*pow(10,9))
	var instructions:Array[Instruction]
	var init_ix:Instruction = anchor_program.build_instruction("restartLevel",[
		level_pda, #gamedata
		vault_pda, #gamevault
		SolanaService.wallet.get_kp(), #signer
		SystemProgram.get_pid() #system program
	],
	AnchorProgram.u64(prize_in_lamports))
	
	instructions.append(init_ix)
	var tx_id:String = await SolanaService.transaction_processor.sign_transaction(SolanaService.wallet.get_kp(),instructions,"finalized")
	
	if tx_id=="":
		push_error("Failed to start game")
		return
		
	update_prize()
	set_player_pos()
	in_game_balance.load_token()
	
	start_screen.visible=false
	game_screen.visible=true
	
	
func move_left() -> void:
	move("moveLeft")
func move_right() -> void:
	move("moveRight")
	
func move(move_dir:String) -> void:
	var instructions:Array[Instruction]
	var move_ix:Instruction = anchor_program.build_instruction(move_dir,[
		level_pda, #gamedata
		vault_pda, #gamevault
		SolanaService.wallet.get_kp(), #signer
		SystemProgram.get_pid() #system program
	],null)
	
	instructions.append(move_ix)
	var tx_id:String = await SolanaService.transaction_processor.sign_transaction(SolanaService.wallet.get_kp(),instructions,"finalized")
	
	if tx_id=="":
		push_error("Failed to move")
		return
		
	set_player_pos()

	
func update_prize() -> void:
	var instance:AnchorProgram = spawn_anchor_program_instance()
	instance.fetch_account("GameVault",vault_pda)
	var data:Dictionary = await instance.account_fetched
	
	var prize_in_sol:float = float(data["chestPrize"])/pow(10,9)
	prize_label.text = "%s SOL" % str(prize_in_sol)
	
func set_player_pos() -> void:
	var instance:AnchorProgram = spawn_anchor_program_instance()
	instance.fetch_account("GameData",level_pda)
	var data:Dictionary = await instance.account_fetched
	
	var new_pos = data["characterPos"]
	player.get_parent().remove_child(player)
	step_blocks[new_pos].add_child(player)
	
	if new_pos == step_blocks.size()-1:
		in_game_balance.load_token()
		chest.visible=false
		

func spawn_anchor_program_instance()->AnchorProgram:
	var instance:AnchorProgram = AnchorProgram.new()
	add_child(instance)
	instance.set_pid(anchor_program.get_pid())
	instance.set_json_file(anchor_program.get_json_file())
	instance.set_idl(anchor_program.get_idl())
	return instance
