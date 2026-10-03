extends Control
# Wolfy Doku - asosiy sahna: menyu, levellar, yurak, taymer, undo/hint, progress saqlash.

const MAX_HEARTS := 3
const TEXT_COLOR := Color("#3d3a4b")
const SAVE_PATH := "user://save.json"
const MUSIC_TRACKS := [
	{"name": "Tinch", "path": "res://assets/music/calm.ogg"},
	{"name": "Quvnoq", "path": "res://assets/music/happy.ogg"},
]
# Havolalar (hozircha bo'sh: bo'sh bo'lsa "Tez kunda" ko'rsatiladi)
const FEEDBACK_URL := ""
const PRIVACY_URL := ""
const TERMS_URL := ""
# Faqat sinov uchun: true bo'lsa Sozlamalarda "Progressni tozalash" ko'rinadi
const DEBUG_RESET := false

var levels: Array = []
var level_index := 0
var hearts := MAX_HEARTS
var is_daily_mode := false
var _daily_level: Dictionary = {}

# progress
var unlocked := 1
var best_times := {}          # level id (String) -> soniya (float)
var daily_done_date := ""
var daily_best_date := ""
var daily_best_time := 0.0
var tutorial_seen := false
var drag_on := true

# valyuta (faqat kunlik reyting balli) va hintlar
var coins := 0          # bugungi reyting balli (baliqcha)
var streak := 0         # ketma-ket kunlar (hozircha faqat kuzatiladi)
var last_login_date := ""
var hints_left := 2       # kunlik bepul "aqlli yordam" (💡)
var cat_hints_left := 2   # kunlik bepul "bo'rini ko'rsat" (🐺)

# taymer
var _elapsed := 0.0
var _timer_running := false

var board: Board
var title_label: Label
var timer_label: Label
var back_btn: Button
var hint_btn: Button
var cat_btn: Button
var sound_btn: Button
var sound_on := true

var hint_banner: Panel
var hint_banner_label: Label
var apply_btn: Button
var _preview_active := false

var overlay: Control
var overlay_label: Label
var overlay_btn: Button
var _overlay_action: Callable = func(): pass

var menu_overlay: Control
var menu_grid: GridContainer
var menu_dim: ColorRect
var menu_root: Control
var menu_card: Panel
var menu_head: Panel
var menu_title: Label
var menu_close: Button
var menu_sub: Label
var menu_scroll: ScrollContainer
var _menu_tween: Tween
var _menu_tile := 200.0
var home_levels: Button
var home_levels_icon: GridIcon
var home_levels_pill: Panel

var leaderboard_overlay: Control
var leaderboard_list: VBoxContainer
var podium_hbox: HBoxContainer
var lb_score_label: Label
var lb_continue_btn: Button
var _lb_continue_action: Callable = func(): pass
var _anim_active := false
var _anim_current := 0
var _anim_to := 0
var _anim_step_timer := 0.0
const ANIM_STEP_DELAY := 0.45
var _anim_today := ""
var lb_title: Label
var lb_timer_bg: Panel
var lb_timer: Label
var lb_bubble: Panel
var lb_bubble_label: Label
var lb_podium: Control
var lb_scroll: ScrollContainer
var lb_close: Button
var lb_info_btn: Button
var lb_info: Control
var lb_ribbon: Ribbon
var lb_clock: ClockIcon
var lb_pinned: Control
var _avatar_cache := {}
const LB_ROW_H := 170
var _lb_tick := 0.0
var _lb_token := 0
var _lb_pulse: Tween

var settings_btn: Button
var settings_overlay: Control
var daily_dlg: Control
var daily_dlg_wolf: TextureRect
var daily_dlg_card: Panel
var daily_dlg_head: Panel
var daily_dlg_title: Label
var daily_dlg_best: HBoxContainer
var daily_dlg_time: Label
var daily_dlg_ask: Label
var daily_dlg_retry: Button
var daily_dlg_ad: AdBadge
var daily_dlg_close: Button
var sound_check: SetTile
var drag_check: SetTile
var tile_music: SetTile
var tile_vibe: SetTile
var set_root: Control
var set_card: Panel
var set_head: Panel
var set_title: Label
var set_close: Button
var set_music_row: Panel
var set_music_prev: Button
var set_music_next: Button
var set_music_name: Label
var set_lang: Button
var set_tutorial: Button
var set_feedback: Button
var set_privacy: Button
var set_terms: Button
var set_version: Label
var set_reset: Button
var _set_tween: Tween
var _reset_armed := false
var music_on := true
var vibrate_on := true
var music_idx := 0
var _music: AudioStreamPlayer
var _music_path := ""

var tutorial_overlay: Control

var confetti: CPUParticles2D
var board_bg: Panel
var title_bg: Panel
var coins_label: Label
var coins_bg: Panel
var celeb_bones: Control
var home_overlay: Control
var home_bg: Control
var home_logo: TextureRect
var _logo_tex: Texture2D = load("res://assets/logo.png")
var home_play: Button
var home_play_l1: Label
var home_daily: Button
var home_daily_l1: Label
var home_daily_icon: TextureRect
var home_clock: ClockIcon
var home_lb: Button
var home_lb_icon: PodiumIcon
var home_lb_pill: Panel
var home_lb_time: Label
var home_daily_chip: Panel
var home_daily_chip_l: Label
var _home_tick := 0.0
var home_coin_pill: Panel
var home_coins_label: Label
var home_settings: Button
var home_streak: Button
var home_streak_icon: StreakIcon
var home_streak_lbl: Label
var streak_dlg: Control
var streak_dlg_title: Label
var streak_dlg_icon: StreakIcon
var streak_dlg_num: Label
var streak_dlg_cur: Label
var streak_dlg_best_bg: Panel
var streak_dlg_best: Label
var streak_dlg_week: StreakWeek
var streak_dlg_btn: Button
var play_streak := 0          # o'ynalgan ketma-ket kunlar
var best_streak := 0
var last_play_date := ""
var streak_gift_pending := false
var _in_progress := false
var instr_card: Panel
var instr_items: Array = []   # [Panel, MiniGrid, Label]
var _found_regions: Array = []   # topilgan hududlar (topilish tartibida)
var _slot_pop := {}              # hudud -> 0..1 (paydo bo'lish animatsiyasi)
var _wolf_sil: Texture2D         # bo'ri boshining silueti (rangli chizish uchun)
var _celeb_gain := 0
var _lb_me_label: Label
var _pill_sb: StyleBoxFlat
var _hearts_y := 0.0   # yuraklar qatori y-koordinatasi (_layout hisoblaydi)
var _wolf_tex: Texture2D = load("res://assets/wolf.png")
var _lost_idx := -1
var _heart_t := 1.0
var _pending_daily_reward: Dictionary = {}

# g'alaba (celebration) oynasi
var celeb_overlay: Control
var celeb_dim: ColorRect
var celeb_rays: RayDraw
var celeb_wolf: TextureRect
var celeb_title: Label
var celeb_stats: Label
var celeb_btn: Button
var _celeb_tweens: Array = []
var _celeb_action: Callable = func(): pass
var _wolf_full_tex: Texture2D = load("res://assets/wolf_full.png")
@onready var _snd_click := AudioStreamPlayer.new()
@onready var _snd_win := AudioStreamPlayer.new()


func _ready() -> void:
	_apply_font()
	RenderingServer.set_default_clear_color(Palette.BG)
	add_child(_snd_click)
	add_child(_snd_win)
	_snd_click.stream = load("res://assets/sfx/tap.wav")
	_snd_win.stream = load("res://assets/sfx/win.wav")
	_load_levels()
	_load_progress()
	_build_ui()
	_setup_music()
	resized.connect(_layout)
	_layout()
	call_deferred("_layout")
	if levels.is_empty():
		title_label.text = "levels.json topilmadi!"
	else:
		_start_level(_first_unlocked_index())
		_in_progress = false
		_timer_running = false
		_process_day_rollover()
		_update_coins_label()
		_update_hint_label()
		_update_cat_label()
		if tutorial_seen and not _pending_daily_reward.is_empty():
			_show_daily_reward_popup()
	_open_home()


func _apply_font() -> void:
	# res://assets/fonts/ ichidagi eng qalin shriftni topib, hamma joyga default qiladi
	var dir := DirAccess.open("res://assets/fonts")
	if dir == null:
		return
	var best := ""
	var best_score := -1
	for f in dir.get_files():
		var name: String = f.trim_suffix(".import").trim_suffix(".remap")
		var lower := name.to_lower()
		if not (lower.ends_with(".ttf") or lower.ends_with(".otf")):
			continue
		if lower.contains("italic"):
			continue
		var score := 1
		if lower.contains("extrabold"):
			score = 3
		elif lower.contains("bold"):
			score = 2
		if score > best_score:
			best_score = score
			best = name
	if best == "":
		return
	var font = load("res://assets/fonts/" + best)
	if font == null:
		return
	var t := Theme.new()
	t.default_font = font
	theme = t


func _first_unlocked_index() -> int:
	for i in range(levels.size()):
		if int(levels[i]["id"]) == unlocked:
			return i
	return 0


func _load_levels() -> void:
	var f := FileAccess.open("res://levels.json", FileAccess.READ)
	if f == null:
		push_error("res://levels.json ochilmadi")
		return
	var data = JSON.parse_string(f.get_as_text())
	if data is Array:
		levels = data


# ---------------- PROGRESS SAQLASH ----------------
func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		unlocked = int(d.get("unlocked", 1))
		best_times = d.get("best_times", {})
		daily_done_date = str(d.get("daily_done_date", ""))
		daily_best_date = str(d.get("daily_best_date", ""))
		daily_best_time = float(d.get("daily_best_time", 0.0))
		tutorial_seen = bool(d.get("tutorial_seen", false))
		drag_on = bool(d.get("drag_on", true))
		sound_on = bool(d.get("sound_on", true))
		coins = int(d.get("coins", 0))
		streak = int(d.get("streak", 0))
		last_login_date = str(d.get("last_login_date", ""))
		hints_left = int(d.get("hints_left", 2))
		cat_hints_left = int(d.get("cat_hints_left", 2))
		play_streak = int(d.get("play_streak", 0))
		best_streak = int(d.get("best_streak", 0))
		last_play_date = str(d.get("last_play_date", ""))
		streak_gift_pending = bool(d.get("gift_pending", false))
		music_on = bool(d.get("music_on", true))
		vibrate_on = bool(d.get("vibrate_on", true))
		music_idx = int(d.get("music_idx", 0))


func _save_progress() -> void:
	var d := {"unlocked": unlocked, "best_times": best_times, "daily_done_date": daily_done_date,
		"daily_best_date": daily_best_date, "daily_best_time": daily_best_time,
		"tutorial_seen": tutorial_seen, "drag_on": drag_on, "sound_on": sound_on,
		"coins": coins, "streak": streak, "last_login_date": last_login_date,
		"hints_left": hints_left, "cat_hints_left": cat_hints_left,
		"play_streak": play_streak, "best_streak": best_streak,
		"last_play_date": last_play_date, "gift_pending": streak_gift_pending,
		"music_on": music_on, "vibrate_on": vibrate_on, "music_idx": music_idx}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d))


func _today_string() -> String:
	var dt := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [dt.year, dt.month, dt.day]


# ---------------- KUNLIK REYTING (soxta ishtirokchilar) ----------------
const BOT_NAMES := [
	"ELRL50", "JRS31Z", "TXHU3L", "BQQAED", "L4V9AV",
	"FQG0T5", "TQWDQC", "GF3CBF", "0A0S5U", "W1TEPW",
	"NN4J3M", "76P1DL", "5GEP8S", "C5H0FU", "PQ8BN2",
	"4HRQEX", "DDWDD6", "MEER1H", "HBTRQJ", "5AS8M8",
	"ZLZYPT", "DAFRL2", "RT7PJ6", "QJ87FD", "Q4TAL3",
	"GD1XGR", "ZNECQU", "T5RE4G", "6LS93P", "SPWRS1",
	"HZVRDR", "L9AW7B", "89LD8F", "XTKPXG", "QECXE8",
	"37KNUP", "RCF29W", "3Y325D", "GJSHGK", "NV1Z49",
	"FF7EJJ", "GV8NKZ", "059SAH", "P715KS", "F0GYYS",
	"TUPXPS", "R62NGG", "JV5WEA", "JYERZU", "HKL3E0"
]
const BOT_EMOJI := ["🐺", "🐶", "🐰", "🦊", "🐼", "🐹", "🦁", "🐨"]
# Rasm bo'lsa: res://assets/avatars/<nom>.png ishlatiladi (BOT_EMOJI bilan bir xil tartibda), bo'lmasa emoji
const AVATAR_NAMES := ["wolf", "dog", "rabbit", "fox", "panda", "hamster", "lion", "koala"]

func _bots_for_date(date_str: String) -> Array:
	var arr := []
	for nm in BOT_NAMES:
		var t: int = 4 + (absi(hash(date_str + nm)) % 15)   # 4..18 oralig'ida, kunga qarab sobit
		arr.append({"name": nm, "target": t})
	return arr


func _bot_current_score(target: int, date_str: String) -> int:
	if date_str != _today_string():
		return target   # o'tgan kun - to'liq son
	var t := Time.get_time_dict_from_system()
	var secs: int = t.hour * 3600 + t.minute * 60 + t.second
	var frac := clampf(secs / 86400.0, 0.0, 1.0)
	# 0 ga tushib qolmasligi uchun bot boshidanoq target'ning ~30% i bilan boshlaydi
	var eff_frac := 0.3 + 0.7 * frac
	return int(round(target * eff_frac))


func _leaderboard_entries(date_str: String, player_score: int, final: bool) -> Array:
	var entries := []
	for b in _bots_for_date(date_str):
		var sc: int = b.target if final else _bot_current_score(b.target, date_str)
		entries.append({"name": b.name, "score": sc})
	entries.append({"name": "Siz", "score": player_score, "is_player": true})
	entries.sort_custom(func(a, b2): return a.score > b2.score)
	return entries


func _finalize_leaderboard(date_str: String, player_score: int) -> Dictionary:
	var entries := _leaderboard_entries(date_str, player_score, true)
	var rank := entries.size()
	for i in range(entries.size()):
		if entries[i].get("is_player", false):
			rank = i + 1
			break
	var bonus := 0
	if rank == 1: bonus = 2
	elif rank == 2: bonus = 1
	elif rank == 3: bonus = 1
	return {"rank": rank, "bonus": bonus}


# ---------------- KUN ALMASHISHI (reyting yakunlash + hint yangilash) ----------------
func _process_day_rollover() -> void:
	var today := _today_string()
	if last_login_date == today:
		return  # bugun allaqachon qayta ishlangan
	if last_login_date == "":
		# birinchi marta o'rnatilgan
		streak = 1
		coins = 0
		hints_left = 2
		cat_hints_left = 2
		last_login_date = today
		_save_progress()
		return
	var prev_unix := Time.get_unix_time_from_datetime_string(last_login_date + "T00:00:00")
	var today_unix := Time.get_unix_time_from_datetime_string(today + "T00:00:00")
	var day_diff := int(round((today_unix - prev_unix) / 86400.0))
	var rank := 0
	var bonus := 0
	if day_diff == 1:
		streak += 1
		var result := _finalize_leaderboard(last_login_date, coins)
		rank = result.rank
		bonus = result.bonus
	else:
		streak = 1
	coins = 0
	hints_left = 2 + bonus
	cat_hints_left = 2 + bonus
	last_login_date = today
	_save_progress()
	if day_diff == 1:
		_pending_daily_reward = {"rank": rank, "bonus": bonus}


func _show_daily_reward_popup() -> void:
	var rank: int = _pending_daily_reward.get("rank", 0)
	var bonus: int = _pending_daily_reward.get("bonus", 0)
	_pending_daily_reward = {}
	_update_coins_label()
	_update_hint_label()
	_update_cat_label()
	var msg := "Kecha reytingda %d-o'rin!" % rank
	if bonus > 0:
		msg += "\n💡+%d, 🐺+%d bonus" % [bonus, bonus]
	msg += "\n\nBugungi: 💡%d  🐺%d" % [hints_left, cat_hints_left]
	_show_overlay(msg, "Rahmat!", func(): overlay.visible = false)


func _update_coins_label() -> void:
	if coins_label != null:
		coins_label.text = "%d" % coins
	if home_coins_label != null:
		home_coins_label.text = "%d" % coins


func _attach_icon(b: Button, kind: String) -> void:
	var ic := IconDraw.new()
	ic.name = "Icon"
	ic.kind = kind
	ic.tex = _wolf_tex
	ic.set_anchors_preset(Control.PRESET_FULL_RECT)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(ic)


func _set_badge(b: Button, txt: String) -> void:
	var ic = b.get_node_or_null("Icon")
	if ic != null:
		ic.badge = txt
		ic.queue_redraw()


func _update_hint_label() -> void:
	if hint_btn != null:
		_set_badge(hint_btn, str(hints_left) if hints_left > 0 else "v")


func _update_cat_label() -> void:
	if cat_btn != null:
		_set_badge(cat_btn, str(cat_hints_left) if cat_hints_left > 0 else "v")


func _use_hint() -> void:
	if hints_left <= 0:
		# HOZIRCHA TEST: haqiqiy reklama (AdMob) 6-bosqichda ulanadi.
		hints_left += 1
		_save_progress()
		_update_hint_label()
		_show_overlay("Reklama (test rejimi) ko'rildi!\n💡+1", "Ajoyib!", func(): overlay.visible = false)
		return
	var result := board.compute_smart_hint()
	if String(result.get("type", "none")) == "none":
		# hozircha aniq taklif topilmadi - to'g'ridan-to'g'ri bitta bo'rini ochamiz
		if board.hint():
			hints_left -= 1
			_save_progress()
			_update_hint_label()
		return
	board.show_preview(result)
	_show_hint_banner(String(result.get("message", "")))


func _use_cat_hint() -> void:
	if cat_hints_left <= 0:
		# HOZIRCHA TEST: haqiqiy reklama (AdMob) 6-bosqichda ulanadi.
		cat_hints_left += 1
		_save_progress()
		_update_cat_label()
		_show_overlay("Reklama (test rejimi) ko'rildi!\n🐺+1", "Ajoyib!", func(): overlay.visible = false)
		return
	if board.hint():
		cat_hints_left -= 1
		_save_progress()
		_update_cat_label()


func _show_hint_banner(message: String) -> void:
	_preview_active = true
	board.locked = true
	hint_banner_label.text = message
	hint_banner.visible = true
	apply_btn.visible = true
	hint_btn.visible = false
	cat_btn.visible = false


func _hide_hint_banner() -> void:
	_preview_active = false
	board.locked = false
	hint_banner.visible = false
	apply_btn.visible = false
	hint_btn.visible = true
	cat_btn.visible = true


func _apply_hint_preview() -> void:
	board.apply_preview()
	hints_left -= 1
	_save_progress()
	_update_hint_label()
	_hide_hint_banner()


func _cancel_hint_preview() -> void:
	board.cancel_preview()
	_hide_hint_banner()


# ---------------- UI QURISH ----------------
func _build_ui() -> void:
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 52)
	title_label.add_theme_color_override("font_color", TEXT_COLOR)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title_label)

	timer_label = Label.new()
	timer_label.add_theme_font_size_override("font_size", 40)
	timer_label.add_theme_color_override("font_color", TEXT_COLOR)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(timer_label)


	board_bg = _make_card(Color("#ffffff"), 34)
	title_bg = _make_card(Color("#ffffff"), 44)

	board = Board.new()
	add_child(board)
	board.sound_on = sound_on
	board.wrong_placement.connect(_on_wrong)
	board.mark_placed.connect(func(): _vibrate(20))
	board.level_completed.connect(_on_completed)
	_build_instructions()

	back_btn = _make_btn("⬅", 44, func():
		_click()
		_open_home())
	hint_btn = _make_btn("", 40, func():
		_click(); _use_hint())
	cat_btn = _make_btn("", 40, func():
		_click(); _use_cat_hint())
	_attach_icon(hint_btn, "bulb")
	_attach_icon(cat_btn, "cat")
	_update_hint_label()
	_update_cat_label()
	sound_btn = _make_btn("🔊" if sound_on else "🔇", 44, _toggle_sound)
	sound_btn.visible = false   # ovoz tugmasi endi faqat Sozlamalarda
	settings_btn = _make_btn("⚙", 44, func():
		_click(); _open_settings())

	hint_banner = Panel.new()
	var hb_sb := StyleBoxFlat.new()
	hb_sb.bg_color = Color("#fffdf8")
	hb_sb.corner_radius_top_left = 26
	hb_sb.corner_radius_top_right = 26
	hb_sb.corner_radius_bottom_left = 26
	hb_sb.corner_radius_bottom_right = 26
	hb_sb.shadow_color = Color(0, 0, 0, 0.25)
	hb_sb.shadow_size = 16
	hint_banner.add_theme_stylebox_override("panel", hb_sb)
	hint_banner.visible = false
	add_child(hint_banner)

	hint_banner_label = Label.new()
	hint_banner_label.add_theme_font_size_override("font_size", 30)
	hint_banner_label.add_theme_color_override("font_color", TEXT_COLOR)
	hint_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	hint_banner.add_child(hint_banner_label)

	apply_btn = _make_btn("Qo'llash ✓", 42, func():
		_click(); _apply_hint_preview())
	apply_btn.visible = false

	_build_home()

	# g'alaba / yutqazish oynasi
	overlay = Control.new()
	overlay.visible = false
	add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	overlay_label = Label.new()
	overlay_label.add_theme_font_size_override("font_size", 84)
	overlay_label.add_theme_color_override("font_color", Color.WHITE)
	overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.add_child(overlay_label)
	overlay_btn = Button.new()
	overlay_btn.add_theme_font_size_override("font_size", 52)
	overlay_btn.pressed.connect(func():
		_click(); _overlay_action.call())
	overlay.add_child(overlay_btn)

	_build_menu_overlay()
	_build_leaderboard_overlay()
	_build_settings_overlay()
	_build_daily_dialog()
	_build_streak_dialog()
	_build_tutorial_overlay()
	_build_celebration()
	_build_confetti()


func _make_btn(text: String, font_size: int, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", font_size)
	_style_round_btn(b)
	b.pressed.connect(action)
	add_child(b)
	return b


func _round_box(color: Color, shadow: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(80)
	sb.shadow_color = Color(0, 0, 0, 0.12)
	sb.shadow_size = int(shadow)
	sb.shadow_offset = Vector2(0, shadow * 0.4)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	return sb


func _style_round_btn(b: Button) -> void:
	b.add_theme_stylebox_override("normal", _round_box(Color("#ffffff"), 14))
	b.add_theme_stylebox_override("hover", _round_box(Color("#ffffff"), 14))
	b.add_theme_stylebox_override("pressed", _round_box(Color("#f1e6df"), 6))
	b.add_theme_stylebox_override("disabled", _round_box(Color("#ece5e0"), 6))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, Palette.TEXT)


func _make_card(color: Color, radius: int, parent: Node = null) -> Panel:
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.shadow_color = Color(0, 0, 0, 0.10)
	sb.shadow_size = 18
	sb.shadow_offset = Vector2(0, 8)
	p.add_theme_stylebox_override("panel", sb)
	var target: Node = parent if parent != null else self
	target.add_child(p)
	if parent == null:
		target.move_child(p, 0)   # asosiy ekranda karta orqa fonda tursin
	return p


func _build_menu_overlay() -> void:
	menu_overlay = Control.new()
	menu_overlay.visible = false
	add_child(menu_overlay)
	menu_dim = ColorRect.new()
	menu_dim.color = Color(0, 0, 0, 0.7)
	menu_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_overlay.add_child(menu_dim)
	menu_dim.gui_input.connect(func(ev: InputEvent):
		var me := ev as InputEventMouseButton
		if me != null and me.pressed and me.button_index == MOUSE_BUTTON_LEFT:
			_close_menu())

	menu_root = Control.new()
	menu_overlay.add_child(menu_root)
	menu_card = _make_card(Color("#FFFDF8"), 70, menu_root)
	menu_head = Panel.new()
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("#F7EDE3")
	hsb.corner_radius_top_left = 70
	hsb.corner_radius_top_right = 70
	menu_head.add_theme_stylebox_override("panel", hsb)
	menu_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_root.add_child(menu_head)
	menu_title = _lb_label("Darajalar", 64, Palette.TEXT)
	menu_root.add_child(menu_title)

	menu_close = Button.new()
	menu_close.flat = true
	for st in ["normal", "hover", "pressed", "focus"]:
		menu_close.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	menu_close.pressed.connect(func():
		_click(); _close_menu())
	menu_root.add_child(menu_close)
	var cx := CloseX.new()
	cx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cx.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_close.add_child(cx)
	_add_bounce(menu_close)

	menu_sub = _lb_label("", 36, Palette.TEXT)
	menu_root.add_child(menu_sub)

	menu_scroll = ScrollContainer.new()
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	menu_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	menu_root.add_child(menu_scroll)
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_left", 10)
	mc.add_theme_constant_override("margin_right", 10)
	mc.add_theme_constant_override("margin_top", 10)
	mc.add_theme_constant_override("margin_bottom", 24)
	menu_scroll.add_child(mc)
	menu_grid = GridContainer.new()
	menu_grid.columns = 4
	menu_grid.add_theme_constant_override("h_separation", 16)
	menu_grid.add_theme_constant_override("v_separation", 16)
	mc.add_child(menu_grid)


func _lb_panel(color: Color, radius: int, border_color: Color = Color(0, 0, 0, 0), border: int = 0) -> Panel:
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	if border > 0:
		sb.border_color = border_color
		sb.set_border_width_all(border)
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


func _lb_label(text: String, fs: int, color: Color, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align as HorizontalAlignment
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _build_leaderboard_overlay() -> void:
	leaderboard_overlay = Control.new()
	leaderboard_overlay.visible = false
	add_child(leaderboard_overlay)

	# iliq sariq-krem gradient fon
	var bg := TextureRect.new()
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.set_color(0, Color("#FCE7BC"))
	gr.set_color(1, Color("#FFF1DC"))
	gt.gradient = gr
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 4
	gt.height = 256
	bg.texture = gt
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	leaderboard_overlay.add_child(bg)

	# lenta (banner) + sarlavha
	lb_ribbon = Ribbon.new()
	lb_ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	leaderboard_overlay.add_child(lb_ribbon)
	lb_title = _lb_label("Reyting", 84, Color.WHITE)
	lb_title.add_theme_color_override("font_outline_color", Color("#D9822B"))
	lb_title.add_theme_constant_override("outline_size", 16)
	lb_ribbon.add_child(lb_title)

	# taymer: sekundomer + vaqt
	lb_timer_bg = _lb_panel(Color("#FFF6E6"), 38)
	leaderboard_overlay.add_child(lb_timer_bg)
	lb_clock = ClockIcon.new()
	lb_clock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_timer_bg.add_child(lb_clock)
	lb_timer = _lb_label("", 44, Color("#8B4F4A"))
	lb_timer_bg.add_child(lb_timer)

	lb_bubble = _lb_panel(Color("#FFF8EC"), 42, Color("#E8BF86"), 4)
	leaderboard_overlay.add_child(lb_bubble)
	lb_bubble_label = _lb_label("", 38, Color("#7A4B2A"))
	lb_bubble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lb_bubble_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16)
	lb_bubble.add_child(lb_bubble_label)

	lb_podium = Control.new()
	lb_podium.mouse_filter = Control.MOUSE_FILTER_IGNORE
	leaderboard_overlay.add_child(lb_podium)

	# ro'yxat kartasi (oq fon)
	lb_scroll = ScrollContainer.new()
	lb_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	leaderboard_overlay.add_child(lb_scroll)
	leaderboard_list = VBoxContainer.new()
	leaderboard_list.add_theme_constant_override("separation", 14)
	leaderboard_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lb_scroll.add_child(leaderboard_list)

	# pastga mahkamlangan "Siz" qatori
	lb_pinned = Control.new()
	lb_pinned.mouse_filter = Control.MOUSE_FILTER_IGNORE
	leaderboard_overlay.add_child(lb_pinned)

	# pastki katta tugma
	lb_continue_btn = Button.new()
	lb_continue_btn.add_theme_font_size_override("font_size", 80)
	lb_continue_btn.add_theme_stylebox_override("normal", _pill_box(Color("#F29521"), 90, Color(0.95, 0.58, 0.13, 0.35)))
	lb_continue_btn.add_theme_stylebox_override("hover", _pill_box(Color("#F7A33A"), 90, Color(0.95, 0.58, 0.13, 0.35)))
	lb_continue_btn.add_theme_stylebox_override("pressed", _pill_box(Color("#D9821A"), 90, Color(0.95, 0.58, 0.13, 0.2)))
	lb_continue_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		lb_continue_btn.add_theme_color_override(k, Color.WHITE)
	lb_continue_btn.pressed.connect(func():
		_click()
		leaderboard_overlay.visible = false
		_lb_continue_action.call())
	leaderboard_overlay.add_child(lb_continue_btn)

	# orqaga (chap) va "i" (o'ng) tugmalari
	lb_close = Button.new()
	lb_close.text = "⬅"
	lb_close.add_theme_font_size_override("font_size", 44)
	_style_round_btn(lb_close)
	lb_close.pressed.connect(func():
		_click()
		leaderboard_overlay.visible = false)
	leaderboard_overlay.add_child(lb_close)

	lb_info_btn = Button.new()
	lb_info_btn.text = "i"
	lb_info_btn.add_theme_font_size_override("font_size", 58)
	_style_round_btn(lb_info_btn)
	lb_info_btn.pressed.connect(func():
		_click()
		lb_info.visible = true)
	leaderboard_overlay.add_child(lb_info_btn)

	# ma'lumot oynasi ("i" bosilganda): qorong'i fon ustida rasmli tushuntirish
	lb_info = Control.new()
	lb_info.visible = false
	leaderboard_overlay.add_child(lb_info)
	var idim := ColorRect.new()
	idim.color = Color(0, 0, 0, 0.8)
	idim.set_anchors_preset(Control.PRESET_FULL_RECT)
	lb_info.add_child(idim)
	var art := LbInfoArt.new()
	art.wolf = _wolf_tex
	if ResourceLoader.exists("res://assets/bone.png"):
		art.bone_tex = load("res://assets/bone.png")
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	lb_info.add_child(art)
	var tap := Button.new()
	tap.flat = true
	tap.set_anchors_preset(Control.PRESET_FULL_RECT)
	for st in ["normal", "hover", "pressed", "focus"]:
		tap.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	tap.pressed.connect(func():
		_click()
		lb_info.visible = false)
	lb_info.add_child(tap)


func _layout_leaderboard() -> void:
	if leaderboard_overlay == null:
		return
	var w := size.x
	var h := size.y
	leaderboard_overlay.position = Vector2.ZERO
	leaderboard_overlay.size = size
	lb_close.size = Vector2(100, 100)
	lb_close.position = Vector2(30, 60)
	lb_info_btn.size = Vector2(100, 100)
	lb_info_btn.position = Vector2(w - 130, 60)
	var bw := minf(w - 320.0, 820.0)
	lb_ribbon.size = Vector2(bw, 130)
	lb_ribbon.position = Vector2((w - bw) / 2.0, 50)
	lb_title.position = Vector2(bw * 0.1, 0)
	lb_title.size = Vector2(bw * 0.8, 130)
	lb_timer_bg.size = Vector2(360, 76)
	lb_timer_bg.position = Vector2((w - 360.0) / 2.0, 196)
	lb_clock.size = Vector2(48, 48)
	lb_clock.position = Vector2(34, 16)
	lb_timer.position = Vector2(92, 0)
	lb_timer.size = Vector2(240, 76)
	lb_bubble.size = Vector2(w - 240.0, 84)
	lb_bubble.position = Vector2(120, 292)
	lb_podium.position = Vector2(0, 380)
	lb_podium.size = Vector2(w, 660)
	var list_y := 1050.0
	var scroll_h := maxf(260.0, h - list_y - 380.0)
	lb_scroll.position = Vector2(40, list_y)
	lb_scroll.size = Vector2(w - 80.0, scroll_h)
	lb_pinned.position = Vector2(40, list_y + scroll_h + 10.0)
	lb_pinned.size = Vector2(w - 80.0, LB_ROW_H)
	var cbw := minf(w * 0.70, 760.0)
	lb_continue_btn.size = Vector2(cbw, 140)
	lb_continue_btn.position = Vector2((w - cbw) / 2.0, h - 180.0)
	lb_continue_btn.pivot_offset = Vector2(cbw / 2.0, 70.0)
	lb_info.position = Vector2.ZERO
	lb_info.size = size


func _bot_avatar(name: String) -> String:
	var idx: int = int(absi(hash(name))) % BOT_EMOJI.size()
	return BOT_EMOJI[idx]


func _avatar_tex(nm: String) -> Texture2D:
	var idx: int = int(absi(hash(nm))) % AVATAR_NAMES.size()
	var key: String = AVATAR_NAMES[idx]
	if _avatar_cache.has(key):
		return _avatar_cache[key]
	var path := "res://assets/avatars/%s.png" % key
	var t: Texture2D = null
	if ResourceLoader.exists(path):
		t = load(path)
	_avatar_cache[key] = t
	return t


func _make_avatar_tile(entry: Dictionary, ts: float, frame: Color = Color(0, 0, 0, 0)) -> Panel:
	var is_me: bool = entry.get("is_player", false)
	var nm := String(entry.name)
	var col: Color = Palette.REGIONS[int(absi(hash(nm))) % Palette.REGIONS.size()]
	if is_me:
		col = Color("#F29A2B")
	if frame.a > 0.0:
		col = frame
	var fill: Color = Color("#FFE9B8") if is_me else col.lightened(0.55)
	var tile := _lb_panel(fill, int(ts * 0.24), col, int(ts * 0.06))
	tile.size = Vector2(ts, ts)
	var tex: Texture2D = _wolf_tex if is_me else _avatar_tex(nm)
	if tex != null:
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(ts * 0.08))
		tile.add_child(tr)
	else:
		var em := _lb_label(_bot_avatar(nm), int(ts * 0.58), Color.WHITE)
		em.set_anchors_preset(Control.PRESET_FULL_RECT)
		tile.add_child(em)
	return tile


# [matn, onlayn_mi]: botlar uchun kunga qarab sobit "N daq. oldin" yoki "Hozir o'ynayapti"
func _status_of(entry: Dictionary) -> Array:
	if entry.get("is_player", false):
		return ["Onlayn", true]
	var hv: int = absi(hash(String(entry.name) + _today_string()))
	if hv % 6 == 0:
		return ["Hozir o'ynayapti", true]
	return ["%d daq. oldin" % (1 + (hv / 7) % 29), false]


func _status_chip(txt: String, online: bool, fs: int) -> Panel:
	var font := title_label.get_theme_font("font")
	var tw: float = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var p := _lb_panel(Color("#4FBF6A") if online else Color("#CDB5A2"), int(fs * 0.85))
	p.size = Vector2(tw + fs * 1.4, fs * 1.7)
	var l := _lb_label(txt, fs, Color.WHITE)
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	p.add_child(l)
	return p


func _build_podium_slot(rank: int, entry: Dictionary, w: float, animate: bool, delay: float) -> void:
	var is_me: bool = entry.get("is_player", false)
	var heights := [400.0, 360.0, 340.0]
	var offs := [0.0, -330.0, 330.0]
	var body_cols := [Color("#FBC93D"), Color("#9AA8F2"), Color("#F79A5B")]
	var cap_cols := [Color("#FFD45E"), Color("#4F86E8"), Color("#FF8F4F")]
	var dark_cols := [Color("#B8730A"), Color("#4A5BB5"), Color("#C0541E")]
	var gift_cols := [Color("#E8453C"), Color("#4F86E8"), Color("#3DB36B")]
	var ph: float = heights[rank - 1]
	var base_y := 600.0
	var top := base_y - ph
	var cx: float = w / 2.0 + float(offs[rank - 1])

	var slot := Control.new()
	slot.position = Vector2(cx - 150.0, 0)
	slot.size = Vector2(300, 660)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_podium.add_child(slot)

	# ustun: pastga qarab so'nib ketadi
	var body := _lb_panel(body_cols[rank - 1], 36)
	body.position = Vector2(10, top)
	body.size = Vector2(280, ph + 10.0)
	slot.add_child(body)
	var fade := TextureRect.new()
	var fgt := GradientTexture2D.new()
	var fgr := Gradient.new()
	fgr.set_color(0, Color(0.992, 0.922, 0.796, 0.0))
	fgr.set_color(1, Color(0.992, 0.922, 0.796, 1.0))
	fgt.gradient = fgr
	fgt.fill_from = Vector2(0.5, 0.0)
	fgt.fill_to = Vector2(0.5, 1.0)
	fgt.width = 4
	fgt.height = 64
	fade.texture = fgt
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.position = Vector2(10, top + (ph + 10.0) * 0.5)
	fade.size = Vector2(280, (ph + 10.0) * 0.5)
	slot.add_child(fade)
	var cap := _lb_panel(cap_cols[rank - 1], 32, dark_cols[rank - 1], 4)
	cap.position = Vector2(0, top - 8)
	cap.size = Vector2(300, 64)
	slot.add_child(cap)

	var ts := 190.0 if rank == 1 else 170.0
	var tile := _make_avatar_tile(entry, ts, cap_cols[rank - 1])
	tile.position = Vector2(150.0 - ts / 2.0, top - ts + 34.0)
	slot.add_child(tile)

	var badge := RankBadge.new()
	badge.rank = rank
	badge.col = dark_cols[rank - 1]
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.size = Vector2(104, 104)
	badge.position = Vector2(98, top + 4)
	slot.add_child(badge)

	var name_lbl := _lb_label("Siz" if is_me else String(entry.name), 40, dark_cols[rank - 1])
	name_lbl.position = Vector2(0, top + 112)
	name_lbl.size = Vector2(300, 50)
	slot.add_child(name_lbl)

	var pill := _lb_panel(Color(1, 1, 1, 0.9), 36)
	pill.position = Vector2(45, top + 166)
	pill.size = Vector2(210, 62)
	slot.add_child(pill)
	var fl := _bone_row("%d" % int(entry.score), 38, Color("#8B4F4A"))
	fl.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill.add_child(fl)
	if is_me:
		_lb_me_label = fl.get_child(1)

	# sovg'a (bo'ri quloqli quti): top 3 ga bonus beriladi
	var gift := GiftIcon.new()
	gift.col = gift_cols[rank - 1]
	gift.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gift.size = Vector2(110, 110)
	gift.position = Vector2(95, top + 236)
	slot.add_child(gift)

	var st := _status_of(entry)
	var chip := _status_chip(String(st[0]), bool(st[1]), 30)
	chip.position = Vector2(150.0 - chip.size.x / 2.0, 616.0)
	slot.add_child(chip)

	if animate:
		slot.pivot_offset = Vector2(150, 600)
		slot.scale = Vector2(0.6, 0.6)
		slot.modulate.a = 0.0
		var tw := create_tween().set_parallel(true)
		tw.tween_property(slot, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
		tw.tween_property(slot, "modulate:a", 1.0, 0.3).set_delay(delay)


func _build_lb_row(rank: int, entry: Dictionary, row_w: float) -> Panel:
	var is_me: bool = entry.get("is_player", false)
	var row_col: Color = Color("#FFE2C2") if is_me else Color("#FBF3EC")
	var row := _lb_panel(row_col, 40, Color("#F2A55A"), 6 if is_me else 0)
	row.custom_minimum_size = Vector2(row_w, LB_ROW_H)
	row.set_meta("is_me", is_me)
	var rl := _lb_label(str(rank), 60, Color("#8B4F4A"))
	rl.position = Vector2(10, 0)
	rl.size = Vector2(130, LB_ROW_H)
	row.add_child(rl)
	var tile := _make_avatar_tile(entry, 124.0)
	tile.position = Vector2(150, (LB_ROW_H - 124.0) / 2.0)
	row.add_child(tile)
	var nl := _lb_label("Siz" if is_me else String(entry.name), 50, Color("#8B4F4A"), HORIZONTAL_ALIGNMENT_LEFT)
	nl.position = Vector2(300, 16)
	nl.size = Vector2(maxf(100.0, row_w - 300.0 - 270.0), 70)
	row.add_child(nl)
	var st := _status_of(entry)
	var chip := _status_chip(String(st[0]), bool(st[1]), 30)
	chip.position = Vector2(300, 98)
	row.add_child(chip)
	var pill := _lb_panel(Color.WHITE, 36)
	pill.position = Vector2(row_w - 250.0, (LB_ROW_H - 72.0) / 2.0)
	pill.size = Vector2(210, 72)
	row.add_child(pill)
	var fl := _bone_row("%d" % int(entry.score), 40, Color("#8B4F4A"))
	fl.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill.add_child(fl)
	if is_me:
		_lb_me_label = fl.get_child(1)
	return row


func _populate_leaderboard(entries: Array, animate: bool = false, rise_rows: int = 0) -> void:
	_lb_me_label = null
	for c in lb_podium.get_children():
		c.queue_free()
	for c in leaderboard_list.get_children():
		c.queue_free()
	var w := size.x
	if entries.size() >= 3:
		_build_podium_slot(1, entries[0], w, animate, 0.0)
		_build_podium_slot(2, entries[1], w, animate, 0.12)
		_build_podium_slot(3, entries[2], w, animate, 0.24)
	var row_w := w - 80.0
	for i in range(3, entries.size()):
		leaderboard_list.add_child(_build_lb_row(i + 1, entries[i], row_w))
	for c in lb_pinned.get_children():
		c.queue_free()
	var me_rank := 0
	for i in range(entries.size()):
		if entries[i].get("is_player", false):
			me_rank = i + 1
	lb_pinned.visible = me_rank > 3
	if me_rank > 3:
		var pr := _build_lb_row(me_rank, entries[me_rank - 1], row_w)
		pr.size = Vector2(row_w, LB_ROW_H)
		lb_pinned.add_child(pr)
	_scroll_lb_to_player()
	if rise_rows > 0:
		_rise_player_row(rise_rows)


func _scroll_lb_to_player() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for c in leaderboard_list.get_children():
		if not c.is_queued_for_deletion() and c.get_meta("is_me", false):
			lb_scroll.scroll_vertical = int(maxf(0.0, c.position.y - lb_scroll.size.y * 0.4))
			return
	lb_scroll.scroll_vertical = 0


func _rank_of(entries: Array) -> int:
	for i in range(entries.size()):
		if entries[i].get("is_player", false):
			return i + 1
	return entries.size()


func _update_lb_countdown() -> void:
	var t := Time.get_time_dict_from_system()
	var secs_left: int = 86400 - (t.hour * 3600 + t.minute * 60 + t.second)
	lb_timer.text = "%02d:%02d:%02d" % [secs_left / 3600, (secs_left / 60) % 60, secs_left % 60]


func _show_leaderboard(from_score: int, to_score: int, continue_text: String, continue_action: Callable, button_text: String = "") -> void:
	_lb_token += 1
	var token := _lb_token
	_lb_continue_action = continue_action
	var closing := continue_text == "Yopish"
	lb_continue_btn.text = button_text if button_text != "" else ("Yopish" if closing else "Davom etish")
	lb_close.visible = closing
	lb_info.visible = false
	var today := _today_string()
	_layout_leaderboard()
	_update_lb_countdown()
	var before_entries := _leaderboard_entries(today, from_score, false)
	var after_entries := _leaderboard_entries(today, to_score, false)
	var before := _rank_of(before_entries)
	var after := _rank_of(after_entries)
	lb_bubble_label.text = "Siz hozir %d-o'rindasiz." % before
	_populate_leaderboard(before_entries, true)
	leaderboard_overlay.visible = true

	if _lb_pulse != null and _lb_pulse.is_valid():
		_lb_pulse.kill()
	lb_continue_btn.scale = Vector2.ONE
	_lb_pulse = create_tween().set_loops()
	_lb_pulse.tween_property(lb_continue_btn, "scale", Vector2(1.04, 1.04), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_lb_pulse.tween_property(lb_continue_btn, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if from_score != to_score:
		await get_tree().create_timer(0.9).timeout
		if token != _lb_token or not leaderboard_overlay.visible:
			return
		await _lb_play_gain(from_score, to_score, token)
		if token != _lb_token or not leaderboard_overlay.visible:
			return
		await get_tree().create_timer(0.4).timeout
		if token != _lb_token or not leaderboard_overlay.visible:
			return
		_populate_leaderboard(after_entries, after < before, before - after)
		if after < before:
			lb_bubble_label.text = "Zo'r! Siz %d pog'onaga ko'tarildingiz." % (before - after)
		else:
			lb_bubble_label.text = "Siz hozir %d-o'rindasiz." % after
		_click()


# Ball 1, 2, 3 qilib qo'shiladi: har biri uchun "+1" suyak yuqoriga uchib chiqadi
func _lb_play_gain(from_score: int, to_score: int, token: int) -> void:
	for v in range(from_score + 1, to_score + 1):
		var lbl := _lb_me_label
		if lbl == null or not is_instance_valid(lbl):
			return
		lbl.text = str(v)
		var hb := lbl.get_parent() as Control
		hb.pivot_offset = hb.size / 2.0
		hb.scale = Vector2(1.4, 1.4)
		var tp := create_tween()
		tp.tween_property(hb, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var fl := _bone_row("+1", 60, Color("#FFD35C"))
		fl.custom_minimum_size = Vector2(220, 70)
		leaderboard_overlay.add_child(fl)
		var ctr := hb.get_global_rect().get_center() - leaderboard_overlay.global_position
		fl.position = ctr - Vector2(110, 35)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(fl, "position:y", fl.position.y - 190.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(fl, "modulate:a", 0.0, 0.5).set_delay(0.55)
		tw.finished.connect(fl.queue_free)
		_click()
		await get_tree().create_timer(0.5).timeout
		if token != _lb_token or not leaderboard_overlay.visible:
			return


# O'yinchi qatori pastdan yuqoriga sakrab chiqadi
func _rise_player_row(rows: int) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for c in leaderboard_list.get_children():
		if not c.is_queued_for_deletion() and c.get_meta("is_me", false):
			var target_y: float = c.position.y
			c.z_index = 5
			c.position.y = target_y + minf(float(rows), 4.0) * (float(LB_ROW_H) + 14.0)
			var tw := create_tween()
			tw.tween_property(c, "position:y", target_y, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			return


# Suyak + son (yumaloq pillalar uchun)
func _bone_row(txt: String, fs: int, color: Color) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", int(fs * 0.2))
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b := BoneIcon.new()
	b.custom_minimum_size = Vector2(fs * 1.15, fs * 1.15)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(b)
	hb.add_child(_lb_label(txt, fs, color))
	return hb


func _open_leaderboard() -> void:
	_show_leaderboard(coins, coins, "Yopish", func(): leaderboard_overlay.visible = false)


func _set_outline_btn(txt: String, fs: int) -> Button:
	var b := Button.new()
	b.text = txt
	b.add_theme_font_size_override("font_size", fs)
	for st in ["normal", "hover", "pressed"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#FFF1E3") if st == "pressed" else Color("#FFFDF8")
		sb.set_corner_radius_all(80)
		sb.border_color = Color("#C98A55")
		sb.set_border_width_all(4)
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, Color("#B8672F"))
	return b


func _set_link_btn(txt: String, fs: int) -> Button:
	var b := Button.new()
	b.text = txt
	b.flat = true
	b.add_theme_font_size_override("font_size", fs)
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, Color("#9B5B55"))
	return b


func _make_tile(kind: String, caption: String, on: bool) -> SetTile:
	var t := SetTile.new()
	t.kind = kind
	t.caption = caption
	t.on = on
	set_root.add_child(t)
	return t


func _build_settings_overlay() -> void:
	settings_overlay = Control.new()
	settings_overlay.visible = false
	add_child(settings_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_overlay.add_child(dim)
	dim.gui_input.connect(func(ev: InputEvent):
		var me := ev as InputEventMouseButton
		if me != null and me.pressed and me.button_index == MOUSE_BUTTON_LEFT:
			_close_settings())

	set_root = Control.new()
	settings_overlay.add_child(set_root)
	set_card = _make_card(Color("#FFFDF8"), 70, set_root)
	set_head = Panel.new()
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("#F7EDE3")
	hsb.corner_radius_top_left = 70
	hsb.corner_radius_top_right = 70
	set_head.add_theme_stylebox_override("panel", hsb)
	set_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_root.add_child(set_head)
	set_title = _lb_label("Sozlamalar", 64, Palette.TEXT)
	set_root.add_child(set_title)

	set_close = Button.new()
	set_close.flat = true
	for st in ["normal", "hover", "pressed", "focus"]:
		set_close.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	set_close.pressed.connect(func():
		_click(); _close_settings())
	set_root.add_child(set_close)
	var cx := CloseX.new()
	cx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cx.set_anchors_preset(Control.PRESET_FULL_RECT)
	set_close.add_child(cx)

	# 4 ta yoqish/o'chirish tugmasi
	sound_check = _make_tile("sound", "Ovoz", sound_on)
	sound_check.toggled.connect(func(v):
		sound_on = v; board.sound_on = v; sound_btn.text = "🔊" if v else "🔇"; _save_progress(); _click())
	tile_music = _make_tile("music", "Musiqa", music_on)
	tile_music.toggled.connect(func(v):
		music_on = v; _save_progress(); _apply_music(); _click())
	tile_vibe = _make_tile("vibe", "Tebranish", vibrate_on)
	tile_vibe.toggled.connect(func(v):
		vibrate_on = v; _save_progress(); _click()
		if v:
			Input.vibrate_handheld(60))
	drag_check = _make_tile("drag", "Sirpanish", drag_on)
	drag_check.toggled.connect(func(v):
		drag_on = v; board.drag_mark = v; _save_progress(); _click())

	# musiqa tanlash
	set_music_row = _lb_panel(Color("#F4ECE4"), 60)
	set_root.add_child(set_music_row)
	set_music_prev = Button.new()
	set_music_prev.text = "‹"
	set_music_prev.add_theme_font_size_override("font_size", 64)
	_style_round_btn(set_music_prev)
	set_music_prev.pressed.connect(func(): _music_step(-1))
	set_music_row.add_child(set_music_prev)
	set_music_name = _lb_label("Tinch", 58, Palette.TEXT)
	set_music_row.add_child(set_music_name)
	set_music_next = Button.new()
	set_music_next.text = "›"
	set_music_next.add_theme_font_size_override("font_size", 64)
	_style_round_btn(set_music_next)
	set_music_next.pressed.connect(func(): _music_step(1))
	set_music_row.add_child(set_music_next)

	set_lang = _set_outline_btn("Til: O'zbekcha  ›", 56)
	set_lang.pressed.connect(func():
		_click(); _flash_btn(set_lang, "Tez kunda"))
	set_root.add_child(set_lang)

	set_tutorial = _dlg_btn("O'rgatish", Color("#A9C6F5"), Color("#8FB3EE"), Palette.TEXT)
	set_tutorial.add_theme_font_size_override("font_size", 64)
	set_tutorial.pressed.connect(func():
		_click()
		settings_overlay.visible = false
		tutorial_overlay.visible = true)
	set_root.add_child(set_tutorial)

	set_feedback = _set_outline_btn("Fikr bildirish", 60)
	set_feedback.pressed.connect(func(): _open_url(FEEDBACK_URL, set_feedback))
	set_root.add_child(set_feedback)

	set_privacy = _set_link_btn("Maxfiylik siyosati", 40)
	set_privacy.pressed.connect(func(): _open_url(PRIVACY_URL, set_privacy))
	set_root.add_child(set_privacy)
	set_terms = _set_link_btn("Foydalanish shartlari", 40)
	set_terms.pressed.connect(func(): _open_url(TERMS_URL, set_terms))
	set_root.add_child(set_terms)

	var ver := str(ProjectSettings.get_setting("application/config/version", "0.1.0")).strip_edges()
	if ver == "":
		ver = "0.1.0"
	set_version = _lb_label("Versiya " + ver, 36, Color("#B5A39B"))
	set_root.add_child(set_version)

	set_reset = _set_link_btn("Progressni tozalash", 34)
	set_reset.add_theme_color_override("font_color", Color("#C0746B"))
	set_reset.add_theme_color_override("font_hover_color", Color("#C0746B"))
	set_reset.add_theme_color_override("font_pressed_color", Color("#C0746B"))
	set_reset.pressed.connect(_settings_reset_pressed)
	set_reset.visible = DEBUG_RESET
	set_root.add_child(set_reset)

	for b in [set_close, set_music_prev, set_music_next, set_lang, set_tutorial, set_feedback]:
		_add_bounce(b)


func _layout_settings() -> void:
	if settings_overlay == null or set_root == null:
		return
	settings_overlay.position = Vector2.ZERO
	settings_overlay.size = size
	var cw := minf(size.x - 160.0, 920.0)
	var ch := _settings_h()
	set_root.size = Vector2(cw, ch)
	set_root.pivot_offset = Vector2(cw / 2.0, ch / 2.0)
	var sc := _settings_base_scale()
	set_root.scale = Vector2(sc, sc)
	set_root.position = Vector2((size.x - cw) / 2.0, (size.y - ch) / 2.0)
	set_card.position = Vector2.ZERO
	set_card.size = Vector2(cw, ch)
	set_head.position = Vector2.ZERO
	set_head.size = Vector2(cw, 140)
	set_title.position = Vector2(0, 0)
	set_title.size = Vector2(cw, 140)
	set_close.position = Vector2(cw - 130.0, 25.0)
	set_close.size = Vector2(90, 90)
	var gap := 22.0
	var tw := (cw - 100.0 - gap * 3.0) / 4.0
	var tiles := [sound_check, tile_music, tile_vibe, drag_check]
	for i in range(4):
		var t: Control = tiles[i]
		t.position = Vector2(50.0 + i * (tw + gap), 190.0)
		t.size = Vector2(tw, 290.0)
	var fw := cw - 100.0
	set_music_row.position = Vector2(50, 510)
	set_music_row.size = Vector2(fw, 110)
	set_music_prev.position = Vector2(15, 15)
	set_music_prev.size = Vector2(80, 80)
	set_music_next.position = Vector2(fw - 95.0, 15)
	set_music_next.size = Vector2(80, 80)
	set_music_name.position = Vector2(100, 0)
	set_music_name.size = Vector2(fw - 200.0, 110)
	set_lang.position = Vector2(50, 645)
	set_lang.size = Vector2(fw, 110)
	set_tutorial.position = Vector2(50, 795)
	set_tutorial.size = Vector2(fw, 150)
	set_feedback.position = Vector2(50, 970)
	set_feedback.size = Vector2(fw, 150)
	set_privacy.position = Vector2(50, 1150)
	set_privacy.size = Vector2(fw / 2.0, 70)
	set_terms.position = Vector2(50.0 + fw / 2.0, 1150)
	set_terms.size = Vector2(fw / 2.0, 70)
	set_version.position = Vector2(0, 1235)
	set_version.size = Vector2(cw, 50)
	set_reset.position = Vector2(50, 1295)
	set_reset.size = Vector2(fw, 70)


func _flash_btn(b: Button, msg: String) -> void:
	var old := b.text
	b.text = msg
	await get_tree().create_timer(1.4).timeout
	b.text = old


func _open_url(url: String, b: Button) -> void:
	_click()
	if url == "":
		_flash_btn(b, "Tez kunda")
	else:
		OS.shell_open(url)


func _refresh_music_name() -> void:
	set_music_name.text = str(MUSIC_TRACKS[clampi(music_idx, 0, MUSIC_TRACKS.size() - 1)]["name"])


func _music_step(d: int) -> void:
	_click()
	music_idx = (music_idx + d + MUSIC_TRACKS.size()) % MUSIC_TRACKS.size()
	music_on = true
	tile_music.set_on(true)
	_refresh_music_name()
	_save_progress()
	_apply_music()


func _setup_music() -> void:
	_music = AudioStreamPlayer.new()
	_music.volume_db = -9.0
	add_child(_music)
	_music.finished.connect(func():
		if music_on:
			_music.play())
	_apply_music()


func _apply_music() -> void:
	if _music == null:
		return
	if not music_on:
		_music.stop()
		_music_path = ""
		return
	var path: String = MUSIC_TRACKS[clampi(music_idx, 0, MUSIC_TRACKS.size() - 1)]["path"]
	if _music_path == path and _music.playing:
		return
	if not ResourceLoader.exists(path):
		return
	_music_path = path
	_music.stream = load(path)
	_music.play()


func _vibrate(ms: int) -> void:
	if vibrate_on:
		Input.vibrate_handheld(ms)


func _settings_reset_pressed() -> void:
	_click()
	if not _reset_armed:
		_reset_armed = true
		set_reset.text = "Aniq tozalaymizmi? Yana bosing"
		await get_tree().create_timer(3.0).timeout
		_reset_armed = false
		set_reset.text = "Progressni tozalash"
		return
	_reset_armed = false
	set_reset.text = "Progressni tozalash"
	unlocked = 1
	best_times = {}
	daily_done_date = ""
	daily_best_date = ""
	daily_best_time = 0.0
	tutorial_seen = false
	coins = 0
	streak = 0
	play_streak = 0
	best_streak = 0
	last_play_date = ""
	streak_gift_pending = false
	last_login_date = ""
	hints_left = 2
	cat_hints_left = 2
	_update_streak_ui()
	_update_coins_label()
	_update_hint_label()
	_update_cat_label()
	_save_progress()
	settings_overlay.visible = false
	_start_level(0)
	_open_home()


# Sarlavha matni sig'ishi uchun shrift va oq pilla kengligini moslaydi
func _fit_title() -> void:
	if title_label == null or title_bg == null:
		return
	var w := size.x
	var max_w := maxf(440.0, w - 540.0)   # yon tugmalar bilan to'qnashmasin
	var fs := 52
	var font := title_label.get_theme_font("font")
	var tw := font.get_string_size(title_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	while tw > max_w - 60.0 and fs > 32:
		fs -= 2
		tw = font.get_string_size(title_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	title_label.add_theme_font_size_override("font_size", fs)
	var bw := clampf(tw + 80.0, 440.0, max_w)
	title_bg.size = Vector2(bw, title_bg.size.y)
	title_bg.position.x = w * 0.5 - bw / 2.0


# ---------------- KUNLIK JUMBOQ: QAYTA URINISH OYNASI ----------------
func _dlg_btn(txt: String, fill: Color, pressed: Color, font_col: Color) -> Button:
	var b := Button.new()
	b.text = txt
	b.add_theme_font_size_override("font_size", 80)
	b.add_theme_stylebox_override("normal", _pill_box(fill, 90, Color(0.95, 0.58, 0.13, 0.25)))
	b.add_theme_stylebox_override("hover", _pill_box(fill, 90, Color(0.95, 0.58, 0.13, 0.25)))
	b.add_theme_stylebox_override("pressed", _pill_box(pressed, 90, Color(0.95, 0.58, 0.13, 0.1)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, font_col)
	return b


func _build_daily_dialog() -> void:
	daily_dlg = Control.new()
	daily_dlg.visible = false
	add_child(daily_dlg)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	daily_dlg.add_child(dim)

	# bo'ri karta ortidan mo'ralaydi (karta ustida chizilgani uchun pastki qismi yashirinadi)
	daily_dlg_wolf = TextureRect.new()
	daily_dlg_wolf.texture = _wolf_tex
	daily_dlg_wolf.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	daily_dlg_wolf.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	daily_dlg_wolf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_dlg.add_child(daily_dlg_wolf)

	daily_dlg_card = _make_card(Color("#FFFDF8"), 70, daily_dlg)
	daily_dlg_head = Panel.new()
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("#F7EDE3")
	hsb.corner_radius_top_left = 70
	hsb.corner_radius_top_right = 70
	daily_dlg_head.add_theme_stylebox_override("panel", hsb)
	daily_dlg_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_dlg.add_child(daily_dlg_head)
	daily_dlg_title = _lb_label("Kunlik jumboq", 70, Palette.TEXT)
	daily_dlg.add_child(daily_dlg_title)

	daily_dlg_best = HBoxContainer.new()
	daily_dlg_best.alignment = BoxContainer.ALIGNMENT_CENTER
	daily_dlg_best.add_theme_constant_override("separation", 16)
	daily_dlg_best.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_dlg.add_child(daily_dlg_best)
	daily_dlg_best.add_child(_lb_label("Eng yaxshi vaqt:", 62, Palette.TEXT))
	var ck := ClockIcon.new()
	ck.custom_minimum_size = Vector2(70, 70)
	ck.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_dlg_best.add_child(ck)
	daily_dlg_time = _lb_label("0:00", 68, Color("#F29521"))
	daily_dlg_best.add_child(daily_dlg_time)
	daily_dlg_ask = _lb_label("Qayta urinamizmi?", 62, Palette.TEXT)
	daily_dlg.add_child(daily_dlg_ask)

	daily_dlg_retry = _dlg_btn("Qayta urinish", Color("#F29521"), Color("#D9821A"), Color.WHITE)
	daily_dlg_retry.pressed.connect(func():
		_click()
		_show_rewarded_ad(func():
			daily_dlg.visible = false
			home_overlay.visible = false
			_start_daily()))
	daily_dlg.add_child(daily_dlg_retry)
	daily_dlg_ad = AdBadge.new()
	daily_dlg_ad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_dlg.add_child(daily_dlg_ad)

	daily_dlg_close = _dlg_btn("Yopish", Color("#FFD29E"), Color("#F5BE82"), Color("#B0714A"))
	daily_dlg_close.pressed.connect(func():
		_click()
		daily_dlg.visible = false)
	daily_dlg.add_child(daily_dlg_close)


func _layout_daily_dialog() -> void:
	if daily_dlg == null:
		return
	var w := size.x
	var h := size.y
	daily_dlg.position = Vector2.ZERO
	daily_dlg.size = size
	var cw := minf(w - 180.0, 900.0)
	var ch := 930.0
	var cx := (w - cw) / 2.0
	var cy := (h - ch) / 2.0 + 20.0
	daily_dlg_card.position = Vector2(cx, cy)
	daily_dlg_card.size = Vector2(cw, ch)
	var ws := cw * 0.42
	daily_dlg_wolf.size = Vector2(ws, ws)
	daily_dlg_wolf.position = Vector2((w - ws) / 2.0, cy - ws * 0.78)
	daily_dlg_head.position = Vector2(cx, cy)
	daily_dlg_head.size = Vector2(cw, 130)
	daily_dlg_title.position = Vector2(cx, cy)
	daily_dlg_title.size = Vector2(cw, 130)
	daily_dlg_best.position = Vector2(cx, cy + 190)
	daily_dlg_best.size = Vector2(cw, 90)
	daily_dlg_ask.position = Vector2(cx, cy + 290)
	daily_dlg_ask.size = Vector2(cw, 90)
	var bw := cw - 150.0
	daily_dlg_retry.size = Vector2(bw, 160)
	daily_dlg_retry.position = Vector2(cx + 75.0, cy + 480.0)
	daily_dlg_ad.size = Vector2(130, 58)
	daily_dlg_ad.position = Vector2(cx + 75.0 + bw - 150.0, cy + 480.0 - 30.0)
	daily_dlg_close.size = Vector2(bw, 160)
	daily_dlg_close.position = Vector2(cx + 75.0, cy + 480.0 + 160.0 + 40.0)


func _show_daily_dialog() -> void:
	if daily_best_date == _today_string():
		daily_dlg_time.text = _fmt_time(daily_best_time)
	else:
		daily_dlg_time.text = "--:--"
	_layout_daily_dialog()
	daily_dlg.visible = true


# Mukofotli reklama. HOZIRCHA TEST: haqiqiy reklama (AdMob) 6-bosqichda ulanadi,
# shunda on_done faqat reklama oxirigacha ko'rilganda chaqiriladi.
func _show_rewarded_ad(on_done: Callable) -> void:
	on_done.call()


func _build_tutorial_overlay() -> void:
	tutorial_overlay = Control.new()
	tutorial_overlay.visible = false
	add_child(tutorial_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.add_child(dim)

	var card := _make_card(Color("#fffdf8"), 36, tutorial_overlay)

	var text := Label.new()
	text.text = "🐺 Qoidalar\n\nHar qator, ustun va hududda\nfaqat 1 ta bo'ri bo'ladi.\n\nBo'rilar qo'shni bo'lmaydi\n(diagonal ham).\n\nBir tap: ❌\nTez ikki tap: bo'ri\n\n3 xato — level qaytadan boshlanadi."
	text.add_theme_font_size_override("font_size", 32)
	text.add_theme_color_override("font_color", TEXT_COLOR)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.set_meta("is_tutorial_text", true)
	tutorial_overlay.add_child(text)

	var start_btn := Button.new()
	start_btn.text = "Boshladik! 🐾"
	start_btn.add_theme_font_size_override("font_size", 44)
	start_btn.set_meta("is_tutorial_btn", true)
	start_btn.pressed.connect(func():
		_click()
		tutorial_overlay.visible = false
		tutorial_seen = true
		_save_progress()
		if not _pending_daily_reward.is_empty():
			_show_daily_reward_popup())
	tutorial_overlay.add_child(start_btn)



func _build_confetti() -> void:
	confetti = CPUParticles2D.new()
	confetti.emitting = false
	confetti.one_shot = true
	confetti.amount = 90
	confetti.lifetime = 1.1
	confetti.explosiveness = 0.9
	confetti.spread = 180.0
	confetti.gravity = Vector2(0, 700)
	confetti.initial_velocity_min = 220.0
	confetti.initial_velocity_max = 520.0
	confetti.scale_amount_min = 4.0
	confetti.scale_amount_max = 8.0
	confetti.color = Color("#f4a988")
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color("#f4a988"), Color("#c9b6e4"), Color("#a9c9e8"),
		Color("#f6cf7d"), Color("#9fd8c0"), Color("#f2a3b3")
	])
	grad.offsets = PackedFloat32Array([0.0, 0.2, 0.4, 0.6, 0.8, 1.0])
	confetti.color_ramp = grad
	add_child(confetti)


func _tile_box(fill: Color, edge: Color, depth: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(38)
	sb.border_width_bottom = int(depth)
	sb.border_color = edge
	sb.shadow_color = Color(0, 0, 0, 0.08)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 4)
	return sb


func _rebuild_level_menu() -> void:
	for c in menu_grid.get_children():
		menu_grid.remove_child(c)
		c.queue_free()
	var done_n := 0
	var ts := _menu_tile
	for i in range(levels.size()):
		var lv: Dictionary = levels[i]
		var id := int(lv["id"])
		var done := best_times.has(str(id))
		var locked := id > unlocked
		var current := id == unlocked
		if done:
			done_n += 1
		var fill := Color("#EFE7E1")
		if done:
			fill = Palette.REGIONS[(id - 1) % Palette.REGIONS.size()]
		elif current:
			fill = Color("#F29521")
		var edge := fill.darkened(0.14)
		if locked:
			edge = Color("#DDD2CA")
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(ts, ts)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal", _tile_box(fill, edge, 8.0))
		btn.add_theme_stylebox_override("hover", _tile_box(fill, edge, 8.0))
		btn.add_theme_stylebox_override("pressed", _tile_box(fill.darkened(0.08), edge, 3.0))
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		if locked:
			var lk := LockIcon.new()
			lk.size = Vector2(ts * 0.42, ts * 0.42)
			lk.position = Vector2((ts - lk.size.x) / 2.0, (ts - lk.size.y) / 2.0)
			btn.add_child(lk)
		else:
			var num_h := ts * 0.72 if done else ts
			var num := _home_label(str(id), int(ts * 0.36), Color.WHITE)
			num.position = Vector2.ZERO
			num.size = Vector2(ts, num_h)
			num.add_theme_color_override("font_outline_color", edge)
			num.add_theme_constant_override("outline_size", int(ts * 0.05))
			btn.add_child(num)
			if done:
				var tl := _home_label("★ " + _fmt_time(float(best_times[str(id)])), int(ts * 0.14), Color.WHITE)
				tl.position = Vector2(0, ts * 0.58)
				tl.size = Vector2(ts, ts * 0.3)
				btn.add_child(tl)
		var idx := i
		btn.pressed.connect(func():
			if locked:
				_shake_tile(btn)
			else:
				_click()
				_pick_level(idx))
		menu_grid.add_child(btn)
		_add_bounce(btn)
		if current:
			var pt := btn.create_tween().set_loops()
			pt.tween_interval(0.9)
			pt.tween_property(btn, "scale", Vector2(1.06, 1.06), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			pt.tween_property(btn, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	menu_sub.text = "Yechilgan: %d / %d" % [done_n, levels.size()]


func _shake_tile(b: Control) -> void:
	_vibrate(15)
	var tw := b.create_tween()
	tw.tween_property(b, "rotation", 0.07, 0.05)
	tw.tween_property(b, "rotation", -0.07, 0.08)
	tw.tween_property(b, "rotation", 0.04, 0.06)
	tw.tween_property(b, "rotation", 0.0, 0.05)


func _pick_level(idx: int) -> void:
	_close_menu()
	home_overlay.visible = false
	_start_level(idx)
	if not tutorial_seen:
		tutorial_overlay.visible = true


func _layout_menu() -> void:
	if menu_overlay == null or menu_root == null:
		return
	menu_overlay.position = Vector2.ZERO
	menu_overlay.size = size
	var cw := minf(size.x - 100.0, 960.0)
	var ch := minf(size.y - 160.0, 1500.0)
	menu_root.size = Vector2(cw, ch)
	menu_root.pivot_offset = Vector2(cw / 2.0, ch / 2.0)
	menu_root.position = Vector2((size.x - cw) / 2.0, (size.y - ch) / 2.0)
	menu_card.position = Vector2.ZERO
	menu_card.size = Vector2(cw, ch)
	menu_head.position = Vector2.ZERO
	menu_head.size = Vector2(cw, 140)
	menu_title.position = Vector2.ZERO
	menu_title.size = Vector2(cw, 140)
	menu_close.position = Vector2(cw - 130.0, 25.0)
	menu_close.size = Vector2(90, 90)
	menu_sub.position = Vector2(0, 150)
	menu_sub.size = Vector2(cw, 60)
	menu_scroll.position = Vector2(24, 215)
	menu_scroll.size = Vector2(cw - 48.0, ch - 215.0 - 24.0)
	_menu_tile = floorf((cw - 48.0 - 20.0 - 3.0 * 16.0) / 4.0)


# ---------------- JOYLASHUV ----------------
func _layout() -> void:
	if board == null:
		return
	var w := size.x
	var h := size.y
	# telefon "chuqurcha"si / status bar uchun yuqori xavfsiz chekka
	var ti := 0.0
	var scr := DisplayServer.screen_get_size()
	if scr.y > 0:
		var sa := DisplayServer.get_display_safe_area()
		ti = clampf(float(sa.position.y) * h / float(scr.y), 0.0, h * 0.06)
	# yuqori qator (bo'rilar + yuraklar) -> ko'rsatma kartasi -> taxta -> tugmalar
	var row_y0 := h * 0.10 + ti + 128.0
	var instr_h := 150.0
	var head := 68.0 + instr_h + 50.0      # qatordan taxtagacha (karta bilan)
	var bs := minf(w - 80.0, h * 0.52)
	bs = maxf(300.0, minf(bs, h - (row_y0 + head) - 30.0 - 150.0 - 30.0))
	var used := row_y0 + head + bs + 30.0 + 150.0 + 30.0
	var shift := clampf((h - used) * 0.4, 0.0, 120.0)
	var row_y := row_y0 + shift * 0.25
	var instr_y := row_y + 68.0
	_hearts_y = row_y
	var board_top := instr_y + instr_h + 50.0 + shift * 0.5
	board.size = Vector2(bs, bs)
	board.position = Vector2((w - bs) / 2.0, board_top)
	board.queue_redraw()

	title_label.position = Vector2(0, h * 0.055 + ti)
	title_label.size = Vector2(w, 80)
	timer_label.position = Vector2(0, h * 0.10 + ti)
	timer_label.size = Vector2(w, 60)

	back_btn.size = Vector2(100, 100)
	back_btn.position = Vector2(30, h * 0.015 + ti)

	var pad := 24.0
	board_bg.position = board.position - Vector2(pad, pad)
	board_bg.size = board.size + Vector2(pad, pad) * 2

	title_bg.position = Vector2(w * 0.5 - 220, h * 0.045 + ti)
	title_bg.size = Vector2(440, 110)
	_fit_title()

	sound_btn.size = Vector2(100, 100)
	sound_btn.position = Vector2(w - 130, h * 0.015 + ti)
	settings_btn.size = Vector2(100, 100)
	settings_btn.position = Vector2(w - 130, h * 0.015 + ti)

	var by := board.position.y + bs + 30
	var bw := 200.0
	var gap := 30.0
	var total := bw * 2 + gap
	var sx := (w - total) / 2.0
	hint_btn.size = Vector2(150, 150)
	hint_btn.position = Vector2(w / 2.0 - 180.0, by)
	cat_btn.size = Vector2(150, 150)
	cat_btn.position = Vector2(w / 2.0 + 30.0, by)
	_layout_instructions(instr_y, instr_h)

	hint_banner.position = Vector2(board.position.x, 20)
	hint_banner.size = Vector2(bs, 160)
	hint_banner_label.position = Vector2(20, 12)
	hint_banner_label.size = Vector2(bs - 40, 136)

	apply_btn.size = Vector2(total, 100)
	apply_btn.position = Vector2(sx, by)

	overlay.position = Vector2.ZERO
	overlay.size = size
	overlay_label.position = Vector2(0, h * 0.36)
	overlay_label.size = Vector2(w, 120)
	overlay_btn.size = Vector2(640, 140)
	overlay_btn.position = Vector2((w - 640) / 2.0, h * 0.36 + 200)

	_layout_menu()

	_layout_home(w, h, ti)
	_layout_leaderboard()
	_layout_daily_dialog()
	_layout_streak_dialog()

	_layout_settings()

	tutorial_overlay.position = Vector2.ZERO
	tutorial_overlay.size = size
	var tcard_w := minf(w - 80.0, 600.0)
	var tcard_h := minf(h - 100.0, 820.0)
	var tcard_x := (w - tcard_w) / 2.0
	var tcard_y := (h - tcard_h) / 2.0
	for c in tutorial_overlay.get_children():
		if c.get_meta("is_tutorial_text", false):
			c.position = Vector2(tcard_x + 20, tcard_y + 30)
			c.size = Vector2(tcard_w - 40, tcard_h - 170)
		elif c.get_meta("is_tutorial_btn", false):
			c.size = Vector2(tcard_w - 80, 110)
			c.position = Vector2(tcard_x + 40, tcard_y + tcard_h - 130)
		elif c is Panel:
			c.position = Vector2(tcard_x, tcard_y)
			c.size = Vector2(tcard_w, tcard_h)

	queue_redraw()


# ---------------- LEVEL BOSHQARUVI ----------------
func _start_current() -> void:
	if is_daily_mode:
		_start_daily()
	else:
		_start_level(level_index)


func _start_level(i: int) -> void:
	is_daily_mode = false
	level_index = clampi(i, 0, levels.size() - 1)
	hearts = MAX_HEARTS
	_lost_idx = -1
	_elapsed = 0.0
	_timer_running = true
	_in_progress = true
	var lv: Dictionary = levels[level_index]
	board.load_level(lv)
	board.auto_x = int(lv["id"]) <= 2   # 1-2 levelda X avtomatik, keyin o'yinchi o'zi
	board.drag_mark = drag_on
	title_label.text = "Level %d" % int(lv["id"])
	_fit_title()
	overlay.visible = false
	if celeb_overlay != null:
		celeb_overlay.visible = false
	queue_redraw()


func _start_daily() -> void:
	if levels.is_empty():
		return
	is_daily_mode = true
	_in_progress = true
	var date_str := _today_string()
	var seed_val: int = absi(hash(date_str))
	var idx := seed_val % levels.size()
	_daily_level = levels[idx]
	hearts = MAX_HEARTS
	_lost_idx = -1
	_elapsed = 0.0
	_timer_running = true
	board.load_level(_daily_level)
	board.auto_x = false
	board.drag_mark = drag_on
	var mark := " ✓" if daily_done_date == date_str else ""
	var dd := Time.get_date_dict_from_system()
	title_label.text = "Kunlik jumboq (%02d/%02d)%s" % [dd.month, dd.day, mark]
	_fit_title()
	overlay.visible = false
	queue_redraw()


func _set_heart_t(v: float) -> void:
	_heart_t = v
	queue_redraw()


func _on_wrong() -> void:
	_vibrate(80)
	hearts -= 1
	_lost_idx = hearts
	_heart_t = 0.0
	create_tween().tween_method(_set_heart_t, 0.0, 1.0, 0.5)
	queue_redraw()
	if hearts <= 0:
		board.locked = true
		_timer_running = false
		_in_progress = false
		await get_tree().create_timer(0.5).timeout
		_show_overlay("Yutqazdingiz", "Qayta urinish", func(): _start_current())


func _on_completed() -> void:
	_timer_running = false
	_in_progress = false
	confetti.position = board.position + board.size / 2.0
	confetti.emitting = true
	if sound_on:
		_snd_win.play()

	_mark_played()
	_vibrate(150)
	var old_coins := coins
	var prev_best := -1.0
	var new_record := false
	if is_daily_mode:
		if daily_done_date != _today_string():
			coins += hearts
		daily_done_date = _today_string()
		if daily_best_date != _today_string() or _elapsed < daily_best_time:
			daily_best_date = _today_string()
			daily_best_time = _elapsed
		_save_progress()
	else:
		var lv: Dictionary = levels[level_index]
		var id := int(lv["id"])
		var first_clear := id >= unlocked
		if first_clear:
			unlocked = id + 1
			coins += hearts
		var key := str(id)
		if best_times.has(key):
			prev_best = float(best_times[key])
			new_record = _elapsed < prev_best
		if not best_times.has(key) or _elapsed < float(best_times[key]):
			best_times[key] = _elapsed
		_save_progress()
	_update_coins_label()

	await get_tree().create_timer(0.7).timeout
	if is_daily_mode:
		# X yo'q; "Davom etish" bosilsa to'g'ridan-to'g'ri keyingi levelga o'tamiz
		_show_leaderboard(old_coins, coins, "Davom etish", func(): _start_level(_first_unlocked_index()), "Davom etish")
		return
	var continue_text: String
	var continue_action: Callable
	if level_index >= levels.size() - 1:
		continue_text = "Boshidan boshlash"
		continue_action = func(): _start_level(0)
	else:
		var next_id := int(levels[level_index + 1]["id"])
		continue_text = "Level %d" % next_id
		continue_action = func(): _start_level(level_index + 1)
	var praises: Array = ["Zo'r!", "Aqlli!", "Ajoyib!", "Bo'rivoy!", "Mantiqchi!", "Super!"]
	if hearts == MAX_HEARTS:
		praises = ["Benuqson!", "Mukammal!", "Daho!"]
	var line1 := "Vaqt: " + _fmt_time(_elapsed)
	if new_record:
		line1 += "  \u2022  Yangi rekord!"
	elif prev_best >= 0.0:
		line1 += "  \u2022  Eng yaxshi: " + _fmt_time(prev_best)
	var gained := coins - old_coins
	var stats := line1
	_celeb_gain = gained
	var praise: String = praises[randi() % praises.size()]
	_show_leaderboard(old_coins, coins, "Davom etish", func(): _show_celebration(praise, stats, continue_text, continue_action))


func _build_celebration() -> void:
	celeb_overlay = Control.new()
	celeb_overlay.visible = false
	celeb_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(celeb_overlay)

	celeb_dim = ColorRect.new()
	celeb_dim.color = Color(0.08, 0.05, 0.1, 0.78)
	celeb_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	celeb_overlay.add_child(celeb_dim)

	celeb_rays = RayDraw.new()
	celeb_rays.set_anchors_preset(Control.PRESET_FULL_RECT)
	celeb_rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	celeb_overlay.add_child(celeb_rays)

	celeb_wolf = TextureRect.new()
	celeb_wolf.texture = _wolf_full_tex
	celeb_wolf.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	celeb_wolf.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	celeb_wolf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	celeb_overlay.add_child(celeb_wolf)

	celeb_title = Label.new()
	celeb_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	celeb_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	celeb_title.add_theme_font_size_override("font_size", 112)
	celeb_title.add_theme_color_override("font_color", Color("#FFF3C4"))
	celeb_title.add_theme_color_override("font_outline_color", Color("#E8761E"))
	celeb_title.add_theme_constant_override("outline_size", 24)
	celeb_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	celeb_title.add_theme_constant_override("shadow_offset_y", 8)
	celeb_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	celeb_overlay.add_child(celeb_title)

	celeb_stats = Label.new()
	celeb_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	celeb_stats.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	celeb_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	celeb_stats.add_theme_font_size_override("font_size", 48)
	celeb_stats.add_theme_color_override("font_color", Color.WHITE)
	celeb_stats.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	celeb_stats.add_theme_constant_override("shadow_offset_y", 4)
	celeb_stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	celeb_overlay.add_child(celeb_stats)

	celeb_bones = Control.new()
	celeb_bones.mouse_filter = Control.MOUSE_FILTER_IGNORE
	celeb_overlay.add_child(celeb_bones)

	celeb_btn = Button.new()
	celeb_btn.add_theme_font_size_override("font_size", 66)
	celeb_btn.add_theme_stylebox_override("normal", _round_box(Color("#F29A2B"), 18))
	celeb_btn.add_theme_stylebox_override("hover", _round_box(Color("#F7A83F"), 18))
	celeb_btn.add_theme_stylebox_override("pressed", _round_box(Color("#D9851A"), 6))
	celeb_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		celeb_btn.add_theme_color_override(k, Color.WHITE)
	celeb_btn.pressed.connect(func():
		_click()
		_kill_celeb_tweens()
		celeb_overlay.visible = false
		_celeb_action.call())
	celeb_overlay.add_child(celeb_btn)


func _kill_celeb_tweens() -> void:
	for t in _celeb_tweens:
		if t != null and t.is_valid():
			t.kill()
	_celeb_tweens.clear()


func _show_celebration(praise: String, stats: String, btn_text: String, action: Callable) -> void:
	_kill_celeb_tweens()
	_celeb_action = action
	var w := size.x
	var h := size.y
	var s := minf(w * 0.66, h * 0.34)
	var wolf_y := h * 0.42 - s * 0.5

	celeb_rays.center_y = h * 0.42
	celeb_rays.alpha = 0.0
	celeb_dim.modulate.a = 0.0

	celeb_wolf.size = Vector2(s, s)
	celeb_wolf.position = Vector2((w - s) / 2.0, wolf_y)
	celeb_wolf.pivot_offset = Vector2(s / 2.0, s * 0.95)
	celeb_wolf.scale = Vector2.ZERO
	celeb_wolf.rotation = 0.0

	celeb_title.text = praise
	celeb_title.size = Vector2(w, 160)
	celeb_title.position = Vector2(0, h * 0.15)
	celeb_title.pivot_offset = Vector2(w / 2.0, 80)
	celeb_title.scale = Vector2.ZERO
	celeb_title.rotation = -0.12

	celeb_stats.text = stats
	celeb_stats.size = Vector2(w - 120, 90)
	celeb_stats.position = Vector2(60, h * 0.63)
	celeb_stats.modulate.a = 0.0

	for c in celeb_bones.get_children():
		c.queue_free()
	var bs := 130.0
	var gap := 18.0
	var n := _celeb_gain
	var x0 := (w - (n * bs + maxf(0.0, n - 1.0) * gap)) / 2.0
	celeb_bones.position = Vector2(0, h * 0.63 + 100.0)
	for i in range(n):
		var b := BoneIcon.new()
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.size = Vector2(bs, bs)
		b.position = Vector2(x0 + i * (bs + gap), 0)
		b.pivot_offset = Vector2(bs, bs) / 2.0
		b.scale = Vector2.ZERO
		b.rotation = -0.5
		celeb_bones.add_child(b)
		var tb := create_tween().set_parallel(true)
		tb.tween_property(b, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.9 + i * 0.2)
		tb.tween_property(b, "rotation", 0.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.9 + i * 0.2)
		_celeb_tweens.append(tb)

	celeb_btn.text = btn_text
	celeb_btn.size = Vector2(w - 260, 150)
	celeb_btn.position = Vector2(130, h * 0.77)
	celeb_btn.pivot_offset = Vector2((w - 260) / 2.0, 75)
	celeb_btn.scale = Vector2.ZERO

	celeb_overlay.visible = true

	var tw := create_tween().set_parallel(true)
	tw.tween_property(celeb_dim, "modulate:a", 1.0, 0.35)
	tw.tween_property(celeb_rays, "alpha", 1.0, 0.7)
	tw.tween_property(celeb_wolf, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.1)
	tw.tween_property(celeb_title, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.3)
	tw.tween_property(celeb_title, "rotation", 0.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.3)
	tw.tween_property(celeb_stats, "modulate:a", 1.0, 0.4).set_delay(0.75)
	tw.tween_property(celeb_btn, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.95)
	_celeb_tweens.append(tw)

	# bo'ri yengil tebranib, "nafas olib" turadi
	var sway := create_tween().set_loops()
	sway.tween_property(celeb_wolf, "rotation", 0.045, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(celeb_wolf, "rotation", -0.045, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_celeb_tweens.append(sway)
	var bob := create_tween().set_loops()
	bob.tween_property(celeb_wolf, "position:y", wolf_y - 16.0, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(celeb_wolf, "position:y", wolf_y, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_celeb_tweens.append(bob)

	confetti.position = Vector2(w / 2.0, h * 0.16)
	confetti.restart()
	confetti.emitting = true


func _show_overlay(text: String, btn_text: String, action: Callable) -> void:
	overlay_label.text = text
	overlay_btn.text = btn_text
	_overlay_action = action
	overlay.visible = true


func _settings_h() -> float:
	return 1400.0 if DEBUG_RESET else 1320.0


func _settings_base_scale() -> float:
	return minf(1.0, (size.y - 60.0) / _settings_h())


func _open_settings() -> void:
	sound_check.set_on(sound_on)
	drag_check.set_on(drag_on)
	tile_music.set_on(music_on)
	tile_vibe.set_on(vibrate_on)
	_refresh_music_name()
	_layout_settings()
	if _set_tween != null and _set_tween.is_valid():
		_set_tween.kill()
	var base := Vector2.ONE * _settings_base_scale()
	settings_overlay.modulate.a = 0.0
	set_root.scale = base * 0.88
	settings_overlay.visible = true
	_set_tween = create_tween().set_parallel(true)
	_set_tween.tween_property(settings_overlay, "modulate:a", 1.0, 0.2)
	_set_tween.tween_property(set_root, "scale", base, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var tiles := [sound_check, tile_music, tile_vibe, drag_check]
	for i in range(tiles.size()):
		var t: Control = tiles[i]
		t.scale = Vector2(0.5, 0.5)
		t.modulate.a = 0.0
		var d := 0.10 + i * 0.06
		_set_tween.tween_property(t, "scale", Vector2.ONE, 0.35).set_delay(d).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_set_tween.tween_property(t, "modulate:a", 1.0, 0.2).set_delay(d)
	var rows := [set_music_row, set_lang, set_tutorial, set_feedback]
	for i in range(rows.size()):
		var r: Control = rows[i]
		var py := r.position.y
		r.position.y = py + 36.0
		r.modulate.a = 0.0
		var d2 := 0.22 + i * 0.05
		_set_tween.tween_property(r, "position:y", py, 0.3).set_delay(d2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_set_tween.tween_property(r, "modulate:a", 1.0, 0.2).set_delay(d2)


func _close_settings() -> void:
	if settings_overlay == null or not settings_overlay.visible:
		return
	if _set_tween != null and _set_tween.is_valid():
		_set_tween.kill()
	var base := Vector2.ONE * _settings_base_scale()
	_set_tween = create_tween().set_parallel(true)
	_set_tween.tween_property(settings_overlay, "modulate:a", 0.0, 0.16)
	_set_tween.tween_property(set_root, "scale", base * 0.92, 0.16).set_ease(Tween.EASE_IN)
	_set_tween.chain().tween_callback(func():
		settings_overlay.visible = false
		set_root.scale = base)


# Tugma bosilganda ozgina kichrayib, qo'yib yuborilganda "sakrab" qaytadi
func _add_bounce(b: Control) -> void:
	b.resized.connect(func(): b.pivot_offset = b.size / 2.0)
	if b is BaseButton:
		var bb := b as BaseButton
		bb.button_down.connect(func(): _bounce_to(b, 0.94, 0.06, false))
		bb.button_up.connect(func(): _bounce_to(b, 1.0, 0.28, true))


func _bounce_to(c: Control, s: float, t: float, spring: bool) -> void:
	var old = c.get_meta("bounce_tw", null)
	if old is Tween and old.is_valid():
		old.kill()
	var tw := create_tween()
	if spring:
		tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "scale", Vector2(s, s), t)
	c.set_meta("bounce_tw", tw)


func _open_menu() -> void:
	if levels.is_empty():
		return
	_layout_menu()
	_rebuild_level_menu()
	if _menu_tween != null and _menu_tween.is_valid():
		_menu_tween.kill()
	menu_overlay.modulate.a = 0.0
	menu_root.scale = Vector2(0.88, 0.88)
	menu_overlay.visible = true
	_menu_tween = create_tween().set_parallel(true)
	_menu_tween.tween_property(menu_overlay, "modulate:a", 1.0, 0.2)
	_menu_tween.tween_property(menu_root, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var kids := menu_grid.get_children()
	for i in range(mini(kids.size(), 28)):
		var t: Control = kids[i]
		t.scale = Vector2(0.5, 0.5)
		t.modulate.a = 0.0
		var d := 0.10 + ((i % 4) + (i / 4)) * 0.045
		_menu_tween.tween_property(t, "scale", Vector2.ONE, 0.35).set_delay(d).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_menu_tween.tween_property(t, "modulate:a", 1.0, 0.2).set_delay(d)
	# hozirgi (to'q sariq) darajaga o'tkazamiz
	await get_tree().process_frame
	var fi := levels.size() - 1
	for i in range(levels.size()):
		if int(levels[i]["id"]) == unlocked:
			fi = i
			break
	var row := fi / 4
	menu_scroll.scroll_vertical = int(maxf(0.0, row * (_menu_tile + 16.0) - _menu_tile))


func _close_menu() -> void:
	if menu_overlay == null or not menu_overlay.visible:
		return
	if _menu_tween != null and _menu_tween.is_valid():
		_menu_tween.kill()
	_menu_tween = create_tween().set_parallel(true)
	_menu_tween.tween_property(menu_overlay, "modulate:a", 0.0, 0.16)
	_menu_tween.tween_property(menu_root, "scale", Vector2(0.92, 0.92), 0.16).set_ease(Tween.EASE_IN)
	_menu_tween.chain().tween_callback(func():
		menu_overlay.visible = false
		menu_root.scale = Vector2.ONE)


func _fmt_time(t: float) -> String:
	var total := int(t)
	return "%d:%02d" % [total / 60, total % 60]


func _process(delta: float) -> void:
	queue_redraw()
	for k in _slot_pop.keys():
		_slot_pop[k] = minf(1.0, float(_slot_pop[k]) + delta / 0.45)
	if _timer_running:
		_elapsed += delta
		timer_label.text = _fmt_time(_elapsed)

	if home_overlay != null and home_overlay.visible:
		_home_tick += delta
		if _home_tick >= 1.0:
			_home_tick = 0.0
			_update_home_timers()

	if leaderboard_overlay != null and leaderboard_overlay.visible:
		_lb_tick += delta
		if _lb_tick >= 1.0:
			_lb_tick = 0.0
			_update_lb_countdown()


# yuraklar
const PROGRESS_COLORS := [
	Color("#f4a988"), Color("#c9b6e4"), Color("#a9c9e8"), Color("#f6cf7d"),
	Color("#9fd8c0"), Color("#f2a3b3"), Color("#c2c2c2"), Color("#e8b98f")
]


func _draw() -> void:
	var y := _hearts_y if _hearts_y > 0.0 else size.y * 0.16
	var n := board.n if board != null else 0
	var hs := 26.0
	var h_sp := 64.0
	var h_w := h_sp * (MAX_HEARTS - 1) + hs * 2.0 + 64.0
	var pill_h := 100.0
	var gap_g := 20.0
	if _pill_sb == null:
		_pill_sb = StyleBoxFlat.new()
		_pill_sb.bg_color = Color("#ffffff")
		_pill_sb.set_corner_radius_all(50)
		_pill_sb.shadow_color = Color(0, 0, 0, 0.10)
		_pill_sb.shadow_size = 12
		_pill_sb.shadow_offset = Vector2(0, 5)
	var slot := 0.0
	var wolf_w := 0.0
	if n > 0:
		slot = minf(84.0, (size.x - 60.0 - h_w - gap_g - 56.0) / float(n))
		wolf_w = slot * n + 56.0
	var group_w := h_w
	if n > 0:
		group_w += gap_g + wolf_w
	var gx := (size.x - group_w) / 2.0
	var hx := gx
	if n > 0:
		draw_style_box(_pill_sb, Rect2(gx, y - pill_h / 2.0, wolf_w, pill_h))
		_draw_wolf_slots(Vector2(gx + 28.0, y), slot)
		hx = gx + wolf_w + gap_g

	# yuraklar
	draw_style_box(_pill_sb, Rect2(hx, y - pill_h / 2.0, h_w, pill_h))
	var start_x := hx + 32.0 + hs
	for i in range(MAX_HEARTS):
		var hc := Vector2(start_x + i * h_sp, y - hs * 0.1)
		if i < hearts:
			_draw_heart(hc + Vector2(0, 3), hs, Color(0, 0, 0, 0.08))
			_draw_heart(hc, hs, Color("#ff5d73"))
			draw_circle(hc + Vector2(-hs * 0.63, -hs * 0.43), hs * 0.17, Color(1, 1, 1, 0.5))
		else:
			_draw_heart(hc, hs, Color("#E6DFD8"))
			if i == _lost_idx and _heart_t < 1.0:
				var t := _heart_t
				var a := 1.0 - t
				_draw_heart(hc, hs * (1.0 + 0.5 * t), Color(1.0, 0.36, 0.45, a))
				for k in range(8):
					var ang := TAU * k / 8.0
					draw_circle(hc + Vector2(cos(ang), sin(ang)) * (hs * 0.7 + 45.0 * t), 5.0 * a + 1.0, Color(1.0, 0.36, 0.45, a))


# Topilgan hududlarni kuzatadi: topilgan bo'ri o'z rangida birinchi bo'limlarga o'tadi
func _sync_found() -> void:
	if board == null or board.n <= 0 or board.state.size() != board.n:
		_found_regions.clear()
		return
	var placed: Array = []
	for r in range(board.n):
		var c: int = int(board.solution[r])
		if int(board.state[r][c]) == 2:
			placed.append(int(board.regions[r][c]))
	var keep: Array = []
	for rid in _found_regions:
		if placed.has(rid):
			keep.append(rid)
	for rid in placed:
		if not keep.has(rid):
			keep.append(rid)
			_slot_pop[rid] = 0.0
	_found_regions = keep


func _draw_wolf_slots(origin: Vector2, slot: float) -> void:
	_sync_found()
	var ids: Array = []
	for r in range(board.n):
		for c in range(board.n):
			var rid := int(board.regions[r][c])
			if not ids.has(rid):
				ids.append(rid)
	ids.sort()
	var order: Array = _found_regions.duplicate()
	for rid in ids:
		if not order.has(rid):
			order.append(rid)
	for i in range(order.size()):
		var rid: int = order[i]
		var col: Color = Palette.REGIONS[rid % Palette.REGIONS.size()]
		var c := origin + Vector2(slot * (i + 0.5), 0)
		var sz := slot * 0.94
		if i < _found_regions.size():
			var t: float = float(_slot_pop.get(rid, 1.0))
			var u := t - 1.0
			var eb := 1.0 + 2.70158 * u * u * u + 1.70158 * u * u
			var sc := lerpf(0.3, 1.0, eb)
			if _wolf_sil != null:
				var bsz := sz * 1.14 * sc
				draw_texture_rect(_wolf_sil, Rect2(c - Vector2(bsz, bsz) / 2.0, Vector2(bsz, bsz)), false, col)
			else:
				draw_circle(c, sz * 0.5 * sc, col)
			if _wolf_tex != null:
				var wsz := sz * sc
				draw_texture_rect(_wolf_tex, Rect2(c - Vector2(wsz, wsz) / 2.0, Vector2(wsz, wsz)), false)
		else:
			var pale := col.lerp(Color.WHITE, 0.45)
			if _wolf_sil != null:
				draw_texture_rect(_wolf_sil, Rect2(c - Vector2(sz, sz) / 2.0, Vector2(sz, sz)), false, pale)
			else:
				draw_circle(c, sz * 0.4, pale)


# Bo'ri boshining bir rangli silueti (alfa kanalidan)
func _make_silhouette() -> void:
	if _wolf_tex == null:
		return
	var img := _wolf_tex.get_image()
	if img == null:
		return
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	img.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	for yy in range(128):
		for xx in range(128):
			img.set_pixel(xx, yy, Color(1, 1, 1, img.get_pixel(xx, yy).a))
	_wolf_sil = ImageTexture.create_from_image(img)


# Pastdagi ko'rsatma kartasi
func _build_instructions() -> void:
	_make_silhouette()
	instr_card = _make_card(Color("#E9EEFB"), 40)
	var card_sb := instr_card.get_theme_stylebox("panel") as StyleBoxFlat
	card_sb.border_color = Color("#C5D1F2")
	card_sb.set_border_width_all(4)
	var texts := ["Har rangda 1 ta bo'ri", "Har qator va ustunda 1 ta bo'ri", "Bo'rilar bir-biriga tegmaydi"]
	var pats := [
		[1, 1, 1, 1, 2, 0, 1, 0, 0],
		[1, 2, 1, 0, 1, 0, 0, 1, 0],
		[1, 1, 1, 1, 2, 1, 1, 1, 1]]
	for i in range(3):
		var pn := _make_card(Color("#FFFFFF"), 26, instr_card)
		var pn_sb := pn.get_theme_stylebox("panel") as StyleBoxFlat
		pn_sb.shadow_size = 0
		var g := MiniGrid.new()
		g.pattern = pats[i]
		g.tex = _wolf_tex
		g.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pn.add_child(g)
		var lb := Label.new()
		lb.text = texts[i]
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lb.add_theme_color_override("font_color", Color("#4B5B93"))
		lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pn.add_child(lb)
		instr_items.append([pn, g, lb])


func _layout_instructions(y: float, hgt: float) -> void:
	if instr_card == null:
		return
	instr_card.position = Vector2(30, y)
	instr_card.size = Vector2(size.x - 60.0, hgt)
	var pad := 14.0
	var gp := 10.0
	var pw := (instr_card.size.x - pad * 2.0 - gp * 2.0) / 3.0
	var ph := hgt - pad * 2.0
	var cs := clampf((ph - 24.0) / 3.0, 18.0, 30.0)
	var gw := cs * 3.0 + 6.0
	for i in range(instr_items.size()):
		var pn: Panel = instr_items[i][0]
		var g: Control = instr_items[i][1]
		var lb: Label = instr_items[i][2]
		pn.position = Vector2(pad + i * (pw + gp), pad)
		pn.size = Vector2(pw, ph)
		g.size = Vector2(gw, gw)
		g.position = Vector2(12.0, (ph - gw) / 2.0)
		lb.position = Vector2(12.0 + gw + 8.0, 0)
		lb.size = Vector2(pw - gw - 12.0 - 8.0 - 6.0, ph)
		lb.add_theme_font_size_override("font_size", int(clampf(cs * 0.8, 18.0, 24.0)))


# ---------------- ASOSIY (BOSH) EKRAN ----------------
func _home_button_box(color: Color, shadow: float, radius: int) -> StyleBoxFlat:
	var sb := _round_box(color, shadow)
	sb.set_corner_radius_all(radius)
	return sb


# Yassi yumaloq tugma uslubi (rangli yengil porlash bilan)
func _pill_box(color: Color, radius: int, glow: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.shadow_color = glow
	sb.shadow_size = 26
	sb.shadow_offset = Vector2(0, 10)
	return sb


func _home_label(txt: String, fs: int, color: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _build_home() -> void:
	home_overlay = Control.new()
	home_overlay.visible = false
	add_child(home_overlay)

	home_bg = HomeBg.new()
	home_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_overlay.add_child(home_bg)

	# tepa: hisoblagich + sozlamalar
	home_coin_pill = _make_card(Color("#ffffff"), 44, home_overlay)
	var cr := _bone_row("0", 42, Palette.TEXT)
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_coin_pill.add_child(cr)
	home_coins_label = cr.get_child(1)
	home_coin_pill.visible = false   # vaqtincha yashirilgan (3-bandda qayta ko'ramiz)

	home_settings = Button.new()
	home_settings.text = "⚙"
	home_settings.add_theme_font_size_override("font_size", 44)
	_style_round_btn(home_settings)
	home_settings.pressed.connect(func():
		_click(); _open_settings())
	home_overlay.add_child(home_settings)

	# logotip (rasm) + yengil "nafas" va tebranish animatsiyasi
	home_logo = TextureRect.new()
	home_logo.texture = _logo_tex
	home_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	home_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	home_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_overlay.add_child(home_logo)
	var tw_l := create_tween().set_loops()
	tw_l.tween_property(home_logo, "scale", Vector2(1.025, 1.025), 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_l.tween_property(home_logo, "scale", Vector2(1.0, 1.0), 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var tw_r := create_tween().set_loops()
	tw_r.tween_property(home_logo, "rotation", 0.012, 2.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_r.tween_property(home_logo, "rotation", -0.012, 2.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# "Level N": yassi to'q sariq tabletka
	home_play = Button.new()
	home_play.add_theme_stylebox_override("normal", _pill_box(Color("#F29521"), 90, Color(0.95, 0.58, 0.13, 0.35)))
	home_play.add_theme_stylebox_override("hover", _pill_box(Color("#F7A33A"), 90, Color(0.95, 0.58, 0.13, 0.35)))
	home_play.add_theme_stylebox_override("pressed", _pill_box(Color("#D9821A"), 90, Color(0.95, 0.58, 0.13, 0.2)))
	home_play.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	home_play.pressed.connect(_home_play)
	home_overlay.add_child(home_play)
	home_play_l1 = _home_label("Level 1", 88, Color.WHITE)
	home_play.add_child(home_play_l1)
	var tw_p := create_tween().set_loops()
	tw_p.tween_property(home_play, "scale", Vector2(1.03, 1.03), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_p.tween_property(home_play, "scale", Vector2(1.0, 1.0), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# "Kunlik jumboq": ko'k-binafsha tabletka, taymer chipi ostiga yopishgan (tugma orqasida)
	home_daily_chip = Panel.new()
	var chip_sb := StyleBoxFlat.new()
	chip_sb.bg_color = Color("#7F95EC")
	chip_sb.corner_radius_bottom_left = 40
	chip_sb.corner_radius_bottom_right = 40
	home_daily_chip.add_theme_stylebox_override("panel", chip_sb)
	home_daily_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_overlay.add_child(home_daily_chip)
	home_clock = ClockIcon.new()
	home_clock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_daily_chip.add_child(home_clock)
	home_daily_chip_l = _home_label("", 44, Color.WHITE)
	home_daily_chip.add_child(home_daily_chip_l)

	home_daily = Button.new()
	home_daily.add_theme_stylebox_override("normal", _pill_box(Color("#8EA2F4"), 90, Color(0.5, 0.58, 0.95, 0.35)))
	home_daily.add_theme_stylebox_override("hover", _pill_box(Color("#9BADF6"), 90, Color(0.5, 0.58, 0.95, 0.35)))
	home_daily.add_theme_stylebox_override("pressed", _pill_box(Color("#7F95EC"), 90, Color(0.5, 0.58, 0.95, 0.2)))
	home_daily.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	home_daily.pressed.connect(_home_daily)
	home_overlay.add_child(home_daily)
	home_daily_icon = TextureRect.new()
	home_daily_icon.texture = _wolf_tex
	home_daily_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	home_daily_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	home_daily_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_daily.add_child(home_daily_icon)
	home_daily_l1 = _home_label("Kunlik jumboq", 60, Color.WHITE)
	home_daily.add_child(home_daily_l1)

	# Reyting tugmasi (chapda): podium ikonkasi + o'rin raqami + taymer
	home_lb = Button.new()
	home_lb.flat = true
	for st in ["normal", "hover", "pressed", "focus"]:
		home_lb.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	home_lb.pressed.connect(func():
		_click(); _open_leaderboard())
	home_overlay.add_child(home_lb)
	home_lb_icon = PodiumIcon.new()
	home_lb_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_lb.add_child(home_lb_icon)
	home_lb_pill = _lb_panel(Color(0.28, 0.24, 0.24, 0.9), 40)
	home_lb.add_child(home_lb_pill)
	home_lb_time = _home_label("", 40, Color.WHITE)
	home_lb_time.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_lb_pill.add_child(home_lb_time)

	# Darajalar tugmasi (o'ngda): rangli plitkalar ikonkasi + yozuv
	home_levels = Button.new()
	home_levels.flat = true
	for st in ["normal", "hover", "pressed", "focus"]:
		home_levels.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	home_levels.pressed.connect(func():
		_click(); _open_menu())
	home_overlay.add_child(home_levels)
	home_levels_icon = GridIcon.new()
	home_levels.add_child(home_levels_icon)
	home_levels_pill = _lb_panel(Color(0.28, 0.24, 0.24, 0.9), 40)
	home_levels.add_child(home_levels_pill)
	var hl_lbl := _home_label("Darajalar", 34, Color.WHITE)
	hl_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_levels_pill.add_child(hl_lbl)
	_add_bounce(home_levels)

	# Kunlar seriyasi pillasi (tepada o'rtada): oy + panja izi va raqam
	home_streak = Button.new()
	home_streak.add_theme_stylebox_override("normal", _pill_box(Color("#ffffff"), 55, Color(0, 0, 0, 0.10)))
	home_streak.add_theme_stylebox_override("hover", _pill_box(Color("#ffffff"), 55, Color(0, 0, 0, 0.10)))
	home_streak.add_theme_stylebox_override("pressed", _pill_box(Color("#f1e6df"), 55, Color(0, 0, 0, 0.05)))
	home_streak.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	home_streak.pressed.connect(func():
		_click(); _show_streak_dialog())
	home_overlay.add_child(home_streak)
	home_streak_icon = StreakIcon.new()
	home_streak_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_streak.add_child(home_streak_icon)
	home_streak_lbl = _home_label("0", 56, Color("#B8650F"))
	home_streak.add_child(home_streak_lbl)

func _layout_home(w: float, h: float, ti: float) -> void:
	if home_overlay == null:
		return
	home_overlay.position = Vector2.ZERO
	home_overlay.size = size
	# tepa
	home_coin_pill.position = Vector2(30, 30 + ti)
	home_coin_pill.size = Vector2(250, 90)
	home_settings.position = Vector2(w - 130, 30 + ti)
	home_settings.size = Vector2(100, 100)
	# logotip (rasm nisbati 1024:776)
	var lw := minf(w * 0.82, 900.0)
	var lh := lw * 776.0 / 1024.0
	home_logo.size = Vector2(lw, lh)
	home_logo.position = Vector2((w - lw) / 2.0, h * 0.075 + ti + 70.0)
	home_logo.pivot_offset = Vector2(lw / 2.0, lh / 2.0)
	# "Level N" tugmasi (yassi tabletka)
	var pw := minf(w * 0.70, 760.0)
	var ph := 160.0
	var pcy := h * 0.72
	home_play.size = Vector2(pw, ph)
	home_play.position = Vector2((w - pw) / 2.0, pcy - ph / 2.0)
	home_play.pivot_offset = Vector2(pw / 2.0, ph / 2.0)
	home_play_l1.position = Vector2(0, 0)
	home_play_l1.size = Vector2(pw, ph)
	# kunlik jumboq (shu kenglikda)
	var dh := 160.0
	var dy := pcy + ph / 2.0 + 50.0
	home_daily.size = Vector2(pw, dh)
	home_daily.position = Vector2((w - pw) / 2.0, dy)
	home_daily_icon.size = Vector2(112, 112)
	home_daily_icon.position = Vector2(34, (dh - 112.0) / 2.0)
	home_daily_l1.position = Vector2(150, 0)
	home_daily_l1.size = Vector2(pw - 150.0 - 30.0, dh)
	# taymer chipi: tugma ostiga yopishib turadi
	var cw := 310.0
	var ch := 76.0
	home_daily_chip.size = Vector2(cw, ch)
	home_daily_chip.position = Vector2((w - cw) / 2.0, dy + dh - 12.0)
	home_clock.size = Vector2(46, 46)
	home_clock.position = Vector2(34, 18.0)
	home_daily_chip_l.position = Vector2(86, 12.0)
	home_daily_chip_l.size = Vector2(cw - 86.0 - 12.0, ch - 16.0)
	# reyting tugmasi (chapda, logotip va "Level" orasida)
	var logo_bot := home_logo.position.y + lh
	var play_top := pcy - ph / 2.0
	var lb_h := 262.0
	home_lb.size = Vector2(230, lb_h)
	home_lb.position = Vector2(24, logo_bot + maxf(20.0, (play_top - logo_bot - lb_h) * 0.4))
	home_lb_icon.size = Vector2(230, 180)
	home_lb_icon.position = Vector2.ZERO
	home_lb_pill.size = Vector2(222, 70)
	home_lb_pill.position = Vector2(4, 190)
	home_levels.size = Vector2(230, lb_h)
	home_levels.position = Vector2(w - 24.0 - 230.0, home_lb.position.y)
	home_levels_icon.size = Vector2(230, 180)
	home_levels_icon.position = Vector2.ZERO
	home_levels_pill.size = Vector2(222, 70)
	home_levels_pill.position = Vector2(4, 190)
	# kunlar seriyasi pillasi (tepada o'rtada)
	var sw := 290.0
	var sh := 100.0
	home_streak.size = Vector2(sw, sh)
	home_streak.position = Vector2((w - sw) / 2.0, 30.0 + ti)
	home_streak_icon.size = Vector2(88, 88)
	home_streak_icon.position = Vector2(26, 6)
	home_streak_lbl.position = Vector2(120, 0)
	home_streak_lbl.size = Vector2(sw - 120.0 - 24.0, sh)


func _update_home_timers() -> void:
	if home_daily_chip_l == null:
		return
	var t := Time.get_time_dict_from_system()
	var secs_left: int = 86400 - (t.hour * 3600 + t.minute * 60 + t.second)
	var clock := "%02d:%02d:%02d" % [secs_left / 3600, (secs_left / 60) % 60, secs_left % 60]
	home_daily_chip_l.text = clock
	home_lb_time.text = clock
	home_daily_l1.text = "Kunlik jumboq" + (" \u2713" if daily_done_date == _today_string() else "")
	home_lb_icon.rank = _rank_of(_leaderboard_entries(_today_string(), coins, false))
	home_lb_icon.queue_redraw()
	_update_streak_ui()


func _refresh_home() -> void:
	var id := 1
	if not levels.is_empty():
		if _in_progress and not is_daily_mode:
			id = int(levels[level_index]["id"])
		else:
			id = int(levels[_first_unlocked_index()]["id"])
	home_play_l1.text = "Level %d" % id
	_update_home_timers()
	_update_coins_label()


# ---------------- KUNLAR SERIYASI ----------------
func _day_diff(from_date: String, to_date: String) -> int:
	var a := Time.get_unix_time_from_datetime_string(from_date + "T00:00:00")
	var b := Time.get_unix_time_from_datetime_string(to_date + "T00:00:00")
	return int(round((b - a) / 86400.0))


# Faol seriya: kecha yoki bugun o'ynalgan bo'lsa saqlanadi, aks holda 0
func _streak_now() -> int:
	if last_play_date == "":
		return 0
	if _day_diff(last_play_date, _today_string()) <= 1:
		return play_streak
	return 0


# Level yoki kunlik jumboq tugatilganda chaqiriladi (kuniga bir marta hisoblanadi)
func _mark_played() -> void:
	var today := _today_string()
	if last_play_date == today:
		return
	var diff := 999
	if last_play_date != "":
		diff = _day_diff(last_play_date, today)
	if diff == 1:
		play_streak += 1
	elif diff > 1:
		play_streak = 1
	elif play_streak == 0:
		play_streak = 1
	last_play_date = today
	best_streak = maxi(best_streak, play_streak)
	if play_streak % 7 == 0:
		streak_gift_pending = true
	_save_progress()
	_update_streak_ui()


# 7 kunlik qatordagi joy: nechta katak to'lgan (0..7)
func _week_pos() -> int:
	if streak_gift_pending:
		return 7
	var n := _streak_now()
	if n <= 0:
		return 0
	return (n - 1) % 7 + 1


func _update_streak_ui() -> void:
	if home_streak_lbl == null:
		return
	home_streak_lbl.text = str(_streak_now())
	home_streak_icon.gift = streak_gift_pending
	home_streak_icon.queue_redraw()


func _build_streak_dialog() -> void:
	streak_dlg = Control.new()
	streak_dlg.visible = false
	add_child(streak_dlg)
	var bg := ColorRect.new()
	bg.color = Color("#F8EFE0")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	streak_dlg.add_child(bg)
	streak_dlg_title = _lb_label("Kunlar seriyasi", 64, Color("#9B5B55"))
	streak_dlg.add_child(streak_dlg_title)
	streak_dlg_icon = StreakIcon.new()
	streak_dlg_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	streak_dlg.add_child(streak_dlg_icon)
	streak_dlg_num = _lb_label("0", 230, Color("#F29521"))
	streak_dlg.add_child(streak_dlg_num)
	streak_dlg_cur = _lb_label("Joriy seriya", 80, Color("#F29521"))
	streak_dlg.add_child(streak_dlg_cur)
	streak_dlg_best_bg = _lb_panel(Color.WHITE, 60)
	streak_dlg.add_child(streak_dlg_best_bg)
	streak_dlg_best = _lb_label("Eng yaxshi seriya: 0", 54, Color("#9B5B55"))
	streak_dlg_best.set_anchors_preset(Control.PRESET_FULL_RECT)
	streak_dlg_best_bg.add_child(streak_dlg_best)
	streak_dlg_week = StreakWeek.new()
	streak_dlg_week.mouse_filter = Control.MOUSE_FILTER_IGNORE
	streak_dlg.add_child(streak_dlg_week)
	streak_dlg_btn = _dlg_btn("Davom etish", Color("#F7971F"), Color("#D9821A"), Color.WHITE)
	streak_dlg_btn.pressed.connect(_streak_dlg_continue)
	streak_dlg.add_child(streak_dlg_btn)


func _layout_streak_dialog() -> void:
	if streak_dlg == null:
		return
	var w := size.x
	var h := size.y
	streak_dlg.position = Vector2.ZERO
	streak_dlg.size = size
	streak_dlg_title.position = Vector2(0, h * 0.05)
	streak_dlg_title.size = Vector2(w, 120)
	var isz := minf(w * 0.5, 460.0)
	var y := h * 0.15
	streak_dlg_icon.size = Vector2(isz, isz)
	streak_dlg_icon.position = Vector2((w - isz) / 2.0, y)
	y += isz + 20.0
	streak_dlg_num.position = Vector2(0, y)
	streak_dlg_num.size = Vector2(w, 250)
	streak_dlg_cur.position = Vector2(0, y + 240.0)
	streak_dlg_cur.size = Vector2(w, 110)
	streak_dlg_best_bg.size = Vector2(700, 100)
	streak_dlg_best_bg.position = Vector2((w - 700.0) / 2.0, y + 370.0)
	streak_dlg_week.size = Vector2(w - 100.0, 260)
	streak_dlg_week.position = Vector2(50, y + 520.0)
	var bw := minf(w * 0.7, 760.0)
	streak_dlg_btn.size = Vector2(bw, 160)
	streak_dlg_btn.position = Vector2((w - bw) / 2.0, minf(y + 830.0, h - 260.0))


func _refresh_streak_dialog() -> void:
	var n := _streak_now()
	streak_dlg_num.text = str(n)
	streak_dlg_cur.text = "Joriy seriya"
	streak_dlg_cur.add_theme_font_size_override("font_size", 80)
	streak_dlg_best.text = "Eng yaxshi seriya: %d" % maxi(best_streak, n)
	streak_dlg_week.pos = _week_pos()
	streak_dlg_week.gift = streak_gift_pending
	streak_dlg_week.queue_redraw()
	streak_dlg_btn.text = "Sovg'ani olish" if streak_gift_pending else "Davom etish"


func _show_streak_dialog() -> void:
	_refresh_streak_dialog()
	_layout_streak_dialog()
	streak_dlg.visible = true


func _streak_dlg_continue() -> void:
	_click()
	if streak_gift_pending:
		streak_gift_pending = false
		hints_left += 3
		cat_hints_left += 3
		_save_progress()
		_update_hint_label()
		_update_cat_label()
		_update_streak_ui()
		_refresh_streak_dialog()
		streak_dlg_cur.text = "Sovg'a: +3 💡  +3 🐺"
		streak_dlg_cur.add_theme_font_size_override("font_size", 60)
		streak_dlg_btn.text = "Davom etish"
		return
	streak_dlg.visible = false


func _open_home() -> void:
	_timer_running = false
	if _preview_active:
		_cancel_hint_preview()
	_refresh_home()
	home_overlay.visible = true
	home_overlay.modulate.a = 0.0
	create_tween().tween_property(home_overlay, "modulate:a", 1.0, 0.3)


func _home_play() -> void:
	if levels.is_empty():
		return
	_click()
	home_overlay.visible = false
	if _in_progress and not is_daily_mode:
		_timer_running = true
	else:
		_start_level(_first_unlocked_index())
	if not tutorial_seen:
		tutorial_overlay.visible = true


func _home_daily() -> void:
	if levels.is_empty():
		return
	_click()
	if daily_done_date == _today_string():
		_show_daily_dialog()   # bugun bajarilgan: qayta urinish uchun reklama so'raymiz
		return
	home_overlay.visible = false
	_start_daily()
	if not tutorial_seen:
		tutorial_overlay.visible = true


func _draw_progress_cat(c: Vector2, r: float, col: Color) -> void:
	draw_circle(c, r * 1.12, col)
	if _wolf_tex != null:
		var ws := r * 2.0
		draw_texture_rect(_wolf_tex, Rect2(c - Vector2(ws, ws) * 0.5, Vector2(ws, ws)), false)


func _draw_heart(c: Vector2, s: float, col: Color) -> void:
	draw_circle(c + Vector2(-s * 0.5, -s * 0.25), s * 0.5, col)
	draw_circle(c + Vector2(s * 0.5, -s * 0.25), s * 0.5, col)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-s * 0.92, -s * 0.02), c + Vector2(s * 0.92, -s * 0.02), c + Vector2(0, s * 1.0)]), col)


# kompyuterda test uchun: N = keyingi level, P = oldingi level
func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and not levels.is_empty():
		if event.keycode == KEY_N:
			_start_level(level_index + 1)
		elif event.keycode == KEY_P:
			_start_level(level_index - 1)


func _click() -> void:
	if sound_on:
		_snd_click.play()


func _toggle_sound() -> void:
	sound_on = not sound_on
	board.sound_on = sound_on
	sound_btn.text = "🔊" if sound_on else "🔇"
	if sound_check != null:
		sound_check.set_on(sound_on)
	_save_progress()
	_click()


# Tugmalardagi ikonlar (lampochka, bo'ri) kod bilan chiziladi
class IconDraw extends Control:
	var kind := "bulb"
	var badge := ""
	var tex: Texture2D

	func _draw() -> void:
		var u := minf(size.x, size.y)
		if kind == "bulb":
			_draw_bulb(u)
		else:
			_draw_cat_icon(u)
		_draw_badge(u)

	func _draw_bulb(u: float) -> void:
		var c := Vector2(size.x * 0.5, size.y * 0.44)
		var r := u * 0.25
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-r * 0.5, r * 0.86), c + Vector2(r * 0.5, r * 0.86),
			c + Vector2(r * 0.42, r * 1.32), c + Vector2(-r * 0.42, r * 1.32)]), Color("#FFB020"))
		draw_circle(c, r, Color("#FFC93C"))
		draw_circle(c + Vector2(-r * 0.35, -r * 0.35), r * 0.26, Color(1, 1, 1, 0.6))
		draw_rect(Rect2(c.x - r * 0.46, c.y + r * 1.32, r * 0.92, r * 0.26), Color("#8B7A6B"))
		draw_rect(Rect2(c.x - r * 0.3, c.y + r * 1.58, r * 0.6, r * 0.2), Color("#6E5F53"))

	func _draw_cat_icon(u: float) -> void:
		# bo'ri bolasi ikoni
		if tex != null:
			var ts := u * 0.68
			draw_texture_rect(tex, Rect2(Vector2(size.x - ts, size.y - ts) * 0.5 + Vector2(0, u * 0.03), Vector2(ts, ts)), false)
			return
		var c := Vector2(size.x * 0.5, size.y * 0.56)
		var r := u * 0.26
		var body := Color("#9FB3C8")
		var dark := body.darkened(0.22)
		var cream := Color("#fff4e8")
		var ink := Color("#3d3a4b")
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-r * 0.98, -r * 0.05), c + Vector2(-r * 0.78, -r * 1.42), c + Vector2(-r * 0.15, -r * 0.82)]), body)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(r * 0.98, -r * 0.05), c + Vector2(r * 0.15, -r * 0.82), c + Vector2(r * 0.78, -r * 1.42)]), body)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-r * 0.83, -r * 1.06), c + Vector2(-r * 0.78, -r * 1.42), c + Vector2(-r * 0.56, -r * 1.12)]), dark)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(r * 0.83, -r * 1.06), c + Vector2(r * 0.56, -r * 1.12), c + Vector2(r * 0.78, -r * 1.42)]), dark)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-r * 0.98, r * 0.15), c + Vector2(-r * 1.2, r * 0.62), c + Vector2(-r * 0.6, r * 0.78)]), body)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(r * 0.98, r * 0.15), c + Vector2(r * 0.6, r * 0.78), c + Vector2(r * 1.2, r * 0.62)]), body)
		draw_circle(c, r, body)
		draw_circle(c + Vector2(-r * 0.2, r * 0.4), r * 0.3, cream)
		draw_circle(c + Vector2(r * 0.2, r * 0.4), r * 0.3, cream)
		draw_circle(c + Vector2(0, r * 0.3), r * 0.34, cream)
		draw_circle(c + Vector2(-r * 0.4, -r * 0.1), r * 0.2, Color.WHITE)
		draw_circle(c + Vector2(r * 0.4, -r * 0.1), r * 0.2, Color.WHITE)
		draw_circle(c + Vector2(-r * 0.4, -r * 0.05), r * 0.12, ink)
		draw_circle(c + Vector2(r * 0.4, -r * 0.05), r * 0.12, ink)
		draw_circle(c + Vector2(0, r * 0.2), r * 0.13, ink)

	func _draw_badge(u: float) -> void:
		if badge == "":
			return
		var bc := Vector2(size.x * 0.84, size.y * 0.16)
		var br := u * 0.14
		draw_circle(bc, br, Color("#FF6B81"))
		if badge == "v":
			draw_colored_polygon(PackedVector2Array([
				bc + Vector2(-br * 0.3, -br * 0.45), bc + Vector2(-br * 0.3, br * 0.45), bc + Vector2(br * 0.5, 0)]), Color.WHITE)
		else:
			var font := get_theme_default_font()
			var fs := int(br * 1.3)
			draw_string(font, Vector2(bc.x - br, bc.y + fs * 0.36), badge, HORIZONTAL_ALIGNMENT_CENTER, br * 2.0, fs, Color.WHITE)


# G'alaba oynasidagi aylanuvchi oltin nurlar va yulduzchalar
class RayDraw extends Control:
	var t := 0.0
	var alpha := 0.0
	var center_y := 0.0

	func _process(delta: float) -> void:
		if is_visible_in_tree():
			t += delta
			queue_redraw()

	func _draw() -> void:
		if alpha <= 0.01:
			return
		var c := Vector2(size.x * 0.5, center_y)
		var reach := maxf(size.x, size.y) * 1.3
		var n := 14
		for i in range(n):
			var a0 := t * 0.22 + i * TAU / n
			var a1 := a0 + TAU / n * 0.5
			draw_colored_polygon(PackedVector2Array([
				c, c + Vector2(cos(a0), sin(a0)) * reach, c + Vector2(cos(a1), sin(a1)) * reach]),
				Color(1.0, 0.82, 0.25, 0.2 * alpha))
		for k in range(5):
			draw_circle(c, 150.0 + k * 55.0, Color(1.0, 0.85, 0.35, 0.07 * alpha))
		for k in range(10):
			var ang := k * 2.399 + t * 0.25
			var dist := 300.0 + (k % 3) * 80.0
			var p := c + Vector2(cos(ang), sin(ang)) * dist
			var tw := absf(sin(t * 2.4 + k * 1.7))
			_star(p, 10.0 + 22.0 * tw, Color(1, 0.95, 0.6, alpha * (0.35 + 0.65 * tw)))

	func _star(p: Vector2, r: float, col: Color) -> void:
		var pts := PackedVector2Array()
		for i in range(8):
			var a := i * PI / 4.0 - PI / 2.0
			var rad := r if i % 2 == 0 else r * 0.28
			pts.append(p + Vector2(cos(a), sin(a)) * rad)
		draw_colored_polygon(pts, col)


# Suyak ikoni (valyuta) - kod bilan chiziladi
class BoneIcon extends Control:
	static var tex: Texture2D = null
	static var tried := false

	func _draw() -> void:
		if not tried:
			tried = true
			if ResourceLoader.exists("res://assets/bone.png"):
				tex = load("res://assets/bone.png")
		if tex != null:
			draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)
			return
		var u := minf(size.x, size.y)
		var c := size * 0.5
		var d := Vector2(1, -1).normalized()
		var n := Vector2(1, 1).normalized()
		var a := c - d * u * 0.29
		var b := c + d * u * 0.29
		_shape(a, b, n, u, Color("#C9A27A"), u * 0.05)
		_shape(a, b, n, u, Color("#FFF3DF"), 0.0)
		draw_line(c - d * u * 0.2 - n * u * 0.05, c + d * u * 0.05 - n * u * 0.05, Color(1, 1, 1, 0.8), u * 0.06, true)

	func _shape(a: Vector2, b: Vector2, n: Vector2, u: float, col: Color, g: float) -> void:
		draw_line(a, b, col, u * 0.24 + g * 2.0, true)
		for e in [a, b]:
			for sg in [-1.0, 1.0]:
				draw_circle(e + n * sg * u * 0.115, u * 0.145 + g, col)


# Ko'rsatma kartasidagi kichik 3x3 to'r
class MiniGrid extends Control:
	var pattern: Array = []
	var tex: Texture2D
	var sb_x := StyleBoxFlat.new()
	var sb_e := StyleBoxFlat.new()

	func _init() -> void:
		sb_x.bg_color = Color("#7A8CE0")
		sb_x.set_corner_radius_all(7)
		sb_e.bg_color = Color("#DCE5F8")
		sb_e.set_corner_radius_all(7)

	func _draw() -> void:
		var gap := 3.0
		var cs := (size.x - gap * 2.0) / 3.0
		for r in range(3):
			for c in range(3):
				var v: int = pattern[r * 3 + c]
				var rect := Rect2(c * (cs + gap), r * (cs + gap), cs, cs)
				draw_style_box(sb_x if v == 1 else sb_e, rect)
				var ctr := rect.get_center()
				if v == 1:
					var d := cs * 0.22
					var wd := cs * 0.14
					draw_line(ctr + Vector2(-d, -d), ctr + Vector2(d, d), Color.WHITE, wd, true)
					draw_line(ctr + Vector2(-d, d), ctr + Vector2(d, -d), Color.WHITE, wd, true)
					for e in [Vector2(-d, -d), Vector2(d, d), Vector2(-d, d), Vector2(d, -d)]:
						draw_circle(ctr + e, wd * 0.5, Color.WHITE)
				elif v == 2 and tex != null:
					draw_texture_rect(tex, rect.grow(-1.0), false)


# "AD" belgisi: yashil tabletka, ichida oq uchburchak va "AD"
class AdBadge extends Control:
	func _draw() -> void:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#1FBF5B")
		sb.set_corner_radius_all(int(size.y * 0.5))
		draw_style_box(sb, Rect2(Vector2.ZERO, size))
		var h := size.y
		var tc := Vector2(h * 0.62, h * 0.5)
		draw_colored_polygon(PackedVector2Array([
			tc + Vector2(-h * 0.2, -h * 0.26), tc + Vector2(-h * 0.2, h * 0.26), tc + Vector2(h * 0.26, 0)]), Color.WHITE)
		var fs := int(h * 0.58)
		draw_string(get_theme_default_font(), Vector2(h * 0.95, h * 0.5 + fs * 0.36), "AD", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)


# Sarlavha lentasi (ikki yonida qayrilgan "qanotlar")
class Ribbon extends Control:
	func _draw() -> void:
		var w := size.x
		var h := size.y
		var wing := Color("#F2A92E")
		draw_colored_polygon(PackedVector2Array([Vector2(0, h * 0.22), Vector2(w * 0.26, h * 0.22), Vector2(w * 0.26, h * 1.02), Vector2(0, h * 1.02), Vector2(w * 0.05, h * 0.62)]), wing)
		draw_colored_polygon(PackedVector2Array([Vector2(w, h * 0.22), Vector2(w * 0.74, h * 0.22), Vector2(w * 0.74, h * 1.02), Vector2(w, h * 1.02), Vector2(w * 0.95, h * 0.62)]), wing)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#F9BE3C")
		sb.set_corner_radius_all(int(h * 0.3))
		sb.shadow_color = Color(0.6, 0.35, 0.05, 0.25)
		sb.shadow_size = 14
		sb.shadow_offset = Vector2(0, 8)
		draw_style_box(sb, Rect2(w * 0.1, 0, w * 0.8, h))
		draw_line(Vector2(w * 0.17, h * 0.14), Vector2(w * 0.83, h * 0.14), Color(1, 1, 1, 0.35), 6.0, true)


# Umumiy rasmlar: bo'ri quloqli sovg'a qutisi va o'rin nishoni (CanvasItem o'z _draw() ida chaqiradi)
class LbArt:
	static func gift(ci: CanvasItem, r: Rect2, col: Color) -> void:
		var u := minf(r.size.x, r.size.y)
		var c := r.get_center()
		var gold := Color("#FFC93C")
		for sg in [-1.0, 1.0]:
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(sg * u * 0.34, -u * 0.18), c + Vector2(sg * u * 0.40, -u * 0.48), c + Vector2(sg * u * 0.10, -u * 0.26)]), col.darkened(0.25))
		var body := StyleBoxFlat.new()
		body.bg_color = col
		body.set_corner_radius_all(int(u * 0.12))
		ci.draw_style_box(body, Rect2(c + Vector2(-u * 0.38, -u * 0.08), Vector2(u * 0.76, u * 0.52)))
		var lid := StyleBoxFlat.new()
		lid.bg_color = col.lightened(0.25)
		lid.set_corner_radius_all(int(u * 0.1))
		ci.draw_style_box(lid, Rect2(c + Vector2(-u * 0.44, -u * 0.27), Vector2(u * 0.88, u * 0.24)))
		ci.draw_rect(Rect2(c + Vector2(-u * 0.07, -u * 0.27), Vector2(u * 0.14, u * 0.71)), gold)
		ci.draw_circle(c + Vector2(-u * 0.12, -u * 0.34), u * 0.11, gold)
		ci.draw_circle(c + Vector2(u * 0.12, -u * 0.34), u * 0.11, gold)
		ci.draw_circle(c + Vector2(0, -u * 0.30), u * 0.065, gold.darkened(0.18))
		var pc := c + Vector2(u * 0.23, u * 0.27)
		var wcol := Color(1, 1, 1, 0.9)
		ci.draw_circle(pc + Vector2(0, u * 0.03), u * 0.055, wcol)
		for ox in [-0.07, 0.0, 0.07]:
			ci.draw_circle(pc + Vector2(ox * u, -u * 0.04 - (0.02 * u if ox == 0.0 else 0.0)), u * 0.026, wcol)

	static func badge(ci: CanvasItem, c: Vector2, r: float, col: Color, rank: int, font: Font) -> void:
		for sg in [-1.0, 1.0]:
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(sg * r * 0.95, -r * 0.35), c + Vector2(sg * r * 0.85, -r * 1.3), c + Vector2(sg * r * 0.2, -r * 0.85)]), col)
		ci.draw_circle(c, r + 4.0, Color(1, 1, 1, 0.85))
		ci.draw_circle(c, r, col)
		var fs := int(r * 1.15)
		ci.draw_string_outline(font, Vector2(c.x - r, c.y + fs * 0.36), str(rank), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, 6, col.darkened(0.3))
		ci.draw_string(font, Vector2(c.x - r, c.y + fs * 0.36), str(rank), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, Color.WHITE)


class GiftIcon extends Control:
	var col := Color("#E8453C")

	func _draw() -> void:
		LbArt.gift(self, Rect2(Vector2.ZERO, size), col)


class RankBadge extends Control:
	var rank := 1
	var col := Color("#B8730A")

	func _draw() -> void:
		LbArt.badge(self, size * 0.5 + Vector2(0, size.y * 0.1), size.x * 0.36, col, rank, get_theme_default_font())


# "i" bosilganda chiqadigan tushuntirish rasmi (hammasi kod bilan chiziladi)
class LbInfoArt extends Control:
	var wolf: Texture2D
	var bone_tex: Texture2D

	func _txt(font: Font, p: Vector2, t: String, fs: int, col: Color, wd: float, outline: int = 0, ocol: Color = Color.WHITE) -> void:
		var lines := t.split("\n")
		for i in range(lines.size()):
			var q := p + Vector2(0, i * fs * 1.15)
			if outline > 0:
				draw_string_outline(font, q, lines[i], HORIZONTAL_ALIGNMENT_CENTER, wd, fs, outline, ocol)
			draw_string(font, q, lines[i], HORIZONTAL_ALIGNMENT_CENTER, wd, fs, col)

	func _arrow(a: Vector2, c: Vector2, b: Vector2) -> void:
		var pts := PackedVector2Array()
		for i in range(21):
			var t := float(i) / 20.0
			pts.append(a * (1.0 - t) * (1.0 - t) + c * 2.0 * (1.0 - t) * t + b * t * t)
		var col := Color("#F29521")
		draw_polyline(pts, col, 16.0, true)
		var dir := (b - pts[19]).normalized()
		var n := Vector2(-dir.y, dir.x)
		draw_colored_polygon(PackedVector2Array([b + dir * 34.0, b - dir * 20.0 + n * 34.0, b - dir * 20.0 - n * 34.0]), col)

	func _glow(c: Vector2, r: float, col: Color) -> void:
		for i in range(8):
			draw_circle(c, r * (1.0 - float(i) / 8.0 * 0.8), Color(col.r, col.g, col.b, 0.07))

	func _bone(c: Vector2, len: float, ang: float) -> void:
		if bone_tex != null:
			draw_set_transform(c, ang, Vector2.ONE)
			draw_texture_rect(bone_tex, Rect2(Vector2(-len * 0.5, -len * 0.5), Vector2(len, len)), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			return
		var d := Vector2.from_angle(ang)
		var n := Vector2(-d.y, d.x)
		var a := c - d * len * 0.36
		var b := c + d * len * 0.36
		for k in range(2):
			var cc := Color("#C9831A") if k == 0 else Color("#FFC93C")
			var g := len * 0.05 if k == 0 else 0.0
			draw_line(a, b, cc, len * 0.22 + g * 2.0, true)
			for e in [a, b]:
				for sg in [-1.0, 1.0]:
					draw_circle(e + n * sg * len * 0.1, len * 0.13 + g, cc)

	func _card(r: Rect2) -> void:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color.WHITE
		sb.set_corner_radius_all(22)
		draw_style_box(sb, r)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var u := minf(w / 1080.0, h / 2316.0)
		var font := get_theme_default_font()
		var cream := Color("#FFF1CC")
		_txt(font, Vector2(0, h * 0.135), "Reyting", int(150 * u), Color.WHITE, w, int(18 * u), Color("#E8761E"))

		# 1) asosiy levellarni yeching
		var g := Rect2(w * 0.14, h * 0.192, w * 0.28, w * 0.28)
		_card(g)
		var tcols := [Color("#D55A98"), Color("#E3B83E"), Color("#D55A98"), Color("#52B6E6"), Color("#52B6E6"), Color("#E3B83E"), Color("#D55A98"), Color("#E3B83E"), Color("#D55A98")]
		var pad := g.size.x * 0.03
		var cs := (g.size.x - pad * 4.0) / 3.0
		for i in range(9):
			var tr := Rect2(g.position + Vector2(pad + (i % 3) * (cs + pad), pad + (i / 3) * (cs + pad)), Vector2(cs, cs))
			var tsb := StyleBoxFlat.new()
			tsb.bg_color = tcols[i]
			tsb.set_corner_radius_all(int(cs * 0.14))
			draw_style_box(tsb, tr)
			if (i == 0 or i == 5) and wolf != null:
				draw_texture_rect(wolf, tr.grow(-cs * 0.06), false)
			else:
				var tc := tr.get_center()
				var k := cs * 0.22
				draw_line(tc + Vector2(-k, -k), tc + Vector2(k, k), Color.WHITE, cs * 0.1, true)
				draw_line(tc + Vector2(-k, k), tc + Vector2(k, -k), Color.WHITE, cs * 0.1, true)
		_txt(font, Vector2(w * 0.08, h * 0.352), "Asosiy levellarni\nyeching", int(56 * u), cream, w * 0.44)
		_arrow(Vector2(w * 0.52, h * 0.262), Vector2(w * 0.65, h * 0.252), Vector2(w * 0.662, h * 0.296))

		# 2) suyaklar
		var bc := Vector2(w * 0.75, h * 0.385)
		_glow(bc, 330.0 * u, Color("#FFD35C"))
		_bone(bc + Vector2(-60, 20) * u, 300.0 * u, -0.5)
		_bone(bc + Vector2(80, -90) * u, 260.0 * u, 0.6)
		_bone(bc + Vector2(0, 110) * u, 190.0 * u, 0.2)
		_arrow(Vector2(w * 0.49, h * 0.418), Vector2(w * 0.40, h * 0.404), Vector2(w * 0.34, h * 0.447))

		# 3) reyting ro'yxati
		var lr := Rect2(w * 0.136, h * 0.497, w * 0.31, h * 0.131)
		_card(lr)
		var tints := [Color("#FFE9A8"), Color("#E3EAFB"), Color("#FDE0CC")]
		var bcols := [Color("#C98A12"), Color("#4A5BB5"), Color("#C0541E")]
		var rh := (lr.size.y - lr.size.y * 0.1) / 3.0
		for i in range(3):
			var rr := Rect2(lr.position + Vector2(lr.size.x * 0.03, lr.size.y * 0.05 + i * rh), Vector2(lr.size.x * 0.94, rh * 0.94))
			var rsb := StyleBoxFlat.new()
			rsb.bg_color = tints[i]
			rsb.set_corner_radius_all(14)
			draw_style_box(rsb, rr)
			LbArt.badge(self, Vector2(rr.position.x + rh * 0.45, rr.get_center().y + rh * 0.04), rh * 0.27, bcols[i], i + 1, font)
			var av := Rect2(rr.position.x + rh * 0.95, rr.position.y + rh * 0.1, rh * 0.74, rh * 0.74)
			var asb := StyleBoxFlat.new()
			asb.bg_color = Color("#FFE9B8")
			asb.border_color = bcols[i]
			asb.set_border_width_all(4)
			asb.set_corner_radius_all(10)
			draw_style_box(asb, av)
			if wolf != null:
				draw_texture_rect(wolf, av.grow(-4.0), false)
			draw_string(font, Vector2(rr.position.x + rh * 1.85, rr.get_center().y + rh * 0.12), "ID123456…", HORIZONTAL_ALIGNMENT_LEFT, -1, int(rh * 0.3), Color("#8B4F4A"))
		_txt(font, Vector2(w * 0.08, h * 0.655), "Reyting tepasiga\nchiqing", int(56 * u), cream, w * 0.4)
		_arrow(Vector2(w * 0.52, h * 0.563), Vector2(w * 0.65, h * 0.555), Vector2(w * 0.662, h * 0.598))

		# 4) sovg'a va ramka
		var gc := Vector2(w * 0.70, h * 0.69)
		_glow(gc, 340.0 * u, Color("#FFD35C"))
		LbArt.gift(self, Rect2(gc - Vector2(170, 170) * u, Vector2(340, 340) * u), Color("#E8453C"))
		var fr := Rect2(gc + Vector2(70, 40) * u, Vector2(190, 190) * u)
		var fsb := StyleBoxFlat.new()
		fsb.bg_color = Color("#CFE9F2")
		fsb.border_color = Color("#F2B01E")
		fsb.set_border_width_all(int(12 * u))
		fsb.set_corner_radius_all(int(34 * u))
		draw_style_box(fsb, fr)
		if wolf != null:
			draw_texture_rect(wolf, fr.grow(-14.0 * u), false)
		_txt(font, Vector2(w * 0.5, h * 0.772), "Maxsus ramkalar va\nsovg'alar yuting", int(56 * u), cream, w * 0.48)

		# pastki tugma
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = Color(0.45, 0.28, 0.05, 0.85)
		bsb.set_corner_radius_all(int(90 * u))
		draw_style_box(bsb, Rect2(w * 0.155, h * 0.862, w * 0.69, 150.0 * u))
		_txt(font, Vector2(w * 0.155, h * 0.862 + 98.0 * u), "Davom etish uchun bosing", int(66 * u), Color.WHITE, w * 0.69)


# Taymer chipidagi kichik sekundomer ikonkasi
# Kunlar seriyasi ikonkasi: oy (yarim oy) + bo'ri panja izi
class StreakIcon extends Control:
	var gift := false
	var tex: Texture2D = null

	func _init() -> void:
		if ResourceLoader.exists("res://assets/streak.png"):
			tex = load("res://assets/streak.png")

	func _draw() -> void:
		var u := minf(size.x, size.y)
		if tex != null:
			draw_texture_rect(tex, Rect2((size.x - u) / 2.0, (size.y - u) / 2.0, u, u), false)
			if gift:
				_draw_gift(u)
			return
		_draw_fallback(u)
		if gift:
			_draw_gift(u)

	func _draw_gift(u: float) -> void:
		var g := Vector2(u * 0.82, u * 0.18)
		var gs := u * 0.13
		draw_rect(Rect2(g.x - gs, g.y - gs * 0.8, gs * 2.0, gs * 1.6), Color("#E8483A"))
		draw_rect(Rect2(g.x - gs * 0.2, g.y - gs * 0.8, gs * 0.4, gs * 1.6), Color("#FFD23F"))
		draw_rect(Rect2(g.x - gs, g.y - gs * 0.15, gs * 2.0, gs * 0.3), Color("#FFD23F"))

	func _draw_fallback(u: float) -> void:
		var o := Vector2(u * 0.50, u * 0.50)
		var big_r := u * 0.40
		var d := u * 0.26
		var cut_r := u * 0.34
		var ix := (d * d + big_r * big_r - cut_r * cut_r) / (2.0 * d)
		var iy := sqrt(maxf(big_r * big_r - ix * ix, 0.0))
		var th := atan2(iy, ix)
		var n := 28
		var pts := PackedVector2Array()
		for i in range(n + 1):
			var a := th + (TAU - 2.0 * th) * float(i) / float(n)
			pts.append(o + Vector2(cos(a), sin(a)) * big_r)
		var cc := o + Vector2(d, 0.0)
		var pa := atan2(-iy, ix - d)
		if pa < 0.0:
			pa += TAU
		var pb := atan2(iy, ix - d)
		for i in range(n + 1):
			var a2 := pa + (pb - pa) * float(i) / float(n)
			pts.append(cc + Vector2(cos(a2), sin(a2)) * cut_r)
		draw_colored_polygon(pts, Color("#FFC93C"))
		# panja izi
		var pc := cc + Vector2(u * 0.02, u * 0.06)
		var pr := u * 0.085
		var pcol := Color("#F29521")
		draw_circle(pc + Vector2(0.0, pr * 0.35), pr, pcol)
		var tr := pr * 0.5
		draw_circle(pc + Vector2(-pr * 1.15, -pr * 0.55), tr, pcol)
		draw_circle(pc + Vector2(-pr * 0.42, -pr * 1.25), tr, pcol)
		draw_circle(pc + Vector2(pr * 0.42, -pr * 1.25), tr, pcol)
		draw_circle(pc + Vector2(pr * 1.15, -pr * 0.55), tr, pcol)


# 7 kunlik qator: 6 ta doira + oxirida sovg'a
class StreakWeek extends Control:
	var pos := 0
	var gift := false

	func _draw() -> void:
		var font := get_theme_default_font()
		var cw := size.x / 7.0
		var r := minf(cw * 0.42, 62.0)
		for i in range(7):
			var cx := cw * (float(i) + 0.5)
			var done := i < pos
			var lab_col := Color("#F29521") if done else Color("#B0877A")
			draw_string(font, Vector2(cx - cw * 0.5, 50.0), "%d-kun" % (i + 1), HORIZONTAL_ALIGNMENT_CENTER, cw, 38, lab_col)
			var c := Vector2(cx, 100.0 + r)
			if i == 6 and (pos < 7 or gift):
				var gs := r * 0.95
				draw_rect(Rect2(c.x - gs, c.y - gs * 0.55, gs * 2.0, gs * 1.5), Color("#FFC93C"))
				draw_rect(Rect2(c.x - gs * 1.1, c.y - gs * 0.9, gs * 2.2, gs * 0.5), Color("#FFB820"))
				draw_rect(Rect2(c.x - gs * 0.18, c.y - gs * 0.9, gs * 0.36, gs * 1.85), Color("#E8483A"))
				draw_circle(c + Vector2(-gs * 0.3, -gs * 1.05), gs * 0.28, Color("#E8483A"))
				draw_circle(c + Vector2(gs * 0.3, -gs * 1.05), gs * 0.28, Color("#E8483A"))
			elif done:
				draw_circle(c, r, Color("#F7971F"))
				draw_polyline(PackedVector2Array([c + Vector2(-r * 0.42, 0.0), c + Vector2(-r * 0.1, r * 0.3), c + Vector2(r * 0.45, -r * 0.28)]), Color.WHITE, r * 0.18, true)
			else:
				draw_circle(c, r, Color("#E3D8CB"))


# Sozlamalar: ikonkali yoqish/o'chirish plitkasi
class SetTile extends Control:
	signal toggled(v: bool)
	var kind := "sound"
	var caption := ""
	var on := true
	var knob := 1.0:
		set(v):
			knob = v
			queue_redraw()
	var _tw: Tween

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			pivot_offset = size / 2.0

	func set_on(v: bool) -> void:
		var changed := v != on
		on = v
		_slide(is_visible_in_tree() and changed)

	func _slide(animate: bool) -> void:
		if _tw != null and _tw.is_valid():
			_tw.kill()
		var target := 1.0 if on else 0.0
		if not animate:
			knob = target
			return
		_tw = create_tween()
		_tw.tween_property(self, "knob", target, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	func _pop() -> void:
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(0.92, 0.92), 0.06)
		tw.tween_property(self, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	func _gui_input(event: InputEvent) -> void:
		var e := event as InputEventMouseButton
		if e != null and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			on = not on
			_slide(true)
			_pop()
			toggled.emit(on)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#FFFDF8")
		sb.set_corner_radius_all(int(w * 0.18))
		sb.border_color = Color("#EBDCCF").lerp(Color("#A5DDB9"), knob)
		sb.set_border_width_all(3)
		sb.shadow_color = Color(0.18, 0.75, 0.39, 0.14 * knob)
		sb.shadow_size = 8
		draw_style_box(sb, Rect2(Vector2.ZERO, size))
		_draw_icon(Vector2(w * 0.5, h * 0.27), w * 0.55)
		var font := get_theme_default_font()
		draw_string(font, Vector2(0.0, h * 0.58), caption, HORIZONTAL_ALIGNMENT_CENTER, w, 30, Color("#8B6F66"))
		var pw := w * 0.80
		var ph := h * 0.22
		var pr := Rect2((w - pw) / 2.0, h * 0.68, pw, ph)
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color("#C9BEB6").lerp(Color("#2FBF63"), knob)
		psb.set_corner_radius_all(int(ph / 2.0))
		draw_style_box(psb, pr)
		var kr := ph * 0.40
		var kx := lerpf(pr.position.x + ph / 2.0, pr.position.x + pr.size.x - ph / 2.0, knob)
		var ky := pr.position.y + ph / 2.0
		draw_circle(Vector2(kx, ky + 2.0), kr, Color(0, 0, 0, 0.12))
		draw_circle(Vector2(kx, ky), kr, Color.WHITE)
		var fs := int(ph * 0.46)
		var ty := ky + fs * 0.35
		var txw := pw - ph * 1.0
		draw_string(font, Vector2(pr.position.x + ph * 0.1, ty), "ON", HORIZONTAL_ALIGNMENT_CENTER, txw, fs, Color(1, 1, 1, knob))
		draw_string(font, Vector2(pr.position.x + ph * 0.9, ty), "OFF", HORIZONTAL_ALIGNMENT_CENTER, txw, fs, Color(1, 1, 1, 1.0 - knob))

	func _draw_icon(c: Vector2, u: float) -> void:
		var col := Color("#A8605A").lerp(Color("#C2AFA9"), (1.0 - knob) * 0.7)
		if kind == "sound":
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-0.34, -0.14) * u, c + Vector2(-0.14, -0.14) * u, c + Vector2(0.10, -0.34) * u,
				c + Vector2(0.10, 0.34) * u, c + Vector2(-0.14, 0.14) * u, c + Vector2(-0.34, 0.14) * u]), col)
			draw_arc(c + Vector2(0.10, 0.0) * u, 0.24 * u, -0.9, 0.9, 16, col, u * 0.07, true)
			draw_arc(c + Vector2(0.10, 0.0) * u, 0.40 * u, -0.8, 0.8, 16, col, u * 0.07, true)
		elif kind == "music":
			draw_circle(c + Vector2(-0.22, 0.22) * u, 0.12 * u, col)
			draw_circle(c + Vector2(0.18, 0.12) * u, 0.12 * u, col)
			draw_line(c + Vector2(-0.12, 0.22) * u, c + Vector2(-0.12, -0.26) * u, col, u * 0.07)
			draw_line(c + Vector2(0.28, 0.12) * u, c + Vector2(0.28, -0.36) * u, col, u * 0.07)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-0.12, -0.26) * u, c + Vector2(0.28, -0.36) * u,
				c + Vector2(0.28, -0.20) * u, c + Vector2(-0.12, -0.10) * u]), col)
		elif kind == "vibe":
			var vsb := StyleBoxFlat.new()
			vsb.draw_center = false
			vsb.border_color = col
			vsb.set_border_width_all(int(u * 0.07))
			vsb.set_corner_radius_all(int(u * 0.1))
			draw_style_box(vsb, Rect2(c + Vector2(-0.16, -0.36) * u, Vector2(0.32, 0.72) * u))
			draw_circle(c + Vector2(0.0, 0.24) * u, u * 0.04, col)
			draw_arc(c, 0.32 * u, PI - 0.5, PI + 0.5, 12, col, u * 0.06, true)
			draw_arc(c, 0.46 * u, PI - 0.5, PI + 0.5, 12, col, u * 0.06, true)
			draw_arc(c, 0.32 * u, -0.5, 0.5, 12, col, u * 0.06, true)
			draw_arc(c, 0.46 * u, -0.5, 0.5, 12, col, u * 0.06, true)
		else:
			var xc := c + Vector2(-0.22, 0.0) * u
			var k := 0.14 * u
			draw_line(xc + Vector2(-k, -k), xc + Vector2(k, k), col, u * 0.08, true)
			draw_line(xc + Vector2(-k, k), xc + Vector2(k, -k), col, u * 0.08, true)
			draw_line(c, c + Vector2(0.30, 0.0) * u, col, u * 0.07, true)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(0.44, 0.0) * u, c + Vector2(0.28, -0.13) * u, c + Vector2(0.28, 0.13) * u]), col)


# Yopish (X) belgisi
class CloseX extends Control:
	func _draw() -> void:
		var u := minf(size.x, size.y)
		var c := size * 0.5
		var k := u * 0.24
		var col := Color("#9B5B55")
		draw_line(c + Vector2(-k, -k), c + Vector2(k, k), col, u * 0.10, true)
		draw_line(c + Vector2(-k, k), c + Vector2(k, -k), col, u * 0.10, true)


class ClockIcon extends Control:
	func _draw() -> void:
		var u := minf(size.x, size.y)
		var c := size * 0.5 + Vector2(0, u * 0.05)
		var r := u * 0.38
		draw_rect(Rect2(c.x - u * 0.1, c.y - r - u * 0.17, u * 0.2, u * 0.12), Color("#C98A2B"))
		draw_circle(c, r + u * 0.06, Color("#F2A04A"))
		draw_circle(c, r * 0.82, Color("#FFF3DC"))
		draw_line(c, c + Vector2(0, -r * 0.55), Color("#8B4F4A"), u * 0.08, true)
		draw_line(c, c + Vector2(r * 0.42, r * 0.14), Color("#8B4F4A"), u * 0.08, true)


# Reyting tugmasi ikonkasi: halqa ichida 2-1-3 podium, burchakda o'rin raqami
class PodiumIcon extends Control:
	var rank := 0

	func _blk(cx: float, base_y: float, bw: float, hh: float, col: Color, txt: String) -> void:
		var sb := StyleBoxFlat.new()
		sb.bg_color = col
		sb.set_corner_radius_all(int(bw * 0.22))
		draw_style_box(sb, Rect2(cx - bw * 0.5, base_y - hh, bw, hh))
		var font := get_theme_default_font()
		var fs := int(bw * 0.62)
		draw_string(font, Vector2(cx - bw * 0.5, base_y - hh + hh * 0.2 + fs * 0.8), txt, HORIZONTAL_ALIGNMENT_CENTER, bw, fs, Color.WHITE)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var c := Vector2(w * 0.5, h * 0.52)
		var r := minf(w, h) * 0.46
		draw_circle(c, r, Color(1.0, 0.9, 0.75, 0.35))
		draw_arc(c, r, 0.0, TAU, 64, Color("#F5B060"), 10.0, true)
		var bw := w * 0.24
		var base_y := h * 0.78
		_blk(w * 0.30, base_y, bw, h * 0.30, Color("#B7A3EA"), "2")
		_blk(w * 0.70, base_y, bw, h * 0.24, Color("#F2A04A"), "3")
		_blk(w * 0.50, base_y, bw, h * 0.46, Color("#FFC93C"), "1")
		if rank > 0:
			var bc := Vector2(w * 0.84, h * 0.15)
			var br := h * 0.15
			draw_circle(bc, br, Color("#FFD23F"))
			draw_arc(bc, br, 0.0, TAU, 32, Color("#F0A91E"), 4.0, true)
			var fs := int(br * (1.2 if rank < 100 else 0.95))
			draw_string(get_theme_default_font(), Vector2(bc.x - br, bc.y + fs * 0.36), str(rank), HORIZONTAL_ALIGNMENT_CENTER, br * 2.0, fs, Color("#8B4F4A"))


# Asosiy ekran foni: krem fon ustida yumshoq rangli kataklar naqshi
class HomeBg extends Control:
	var sb := StyleBoxFlat.new()

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		sb.set_corner_radius_all(34)
		sb.bg_color = Color(1.0, 1.0, 1.0, 0.30)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Palette.BG)
		var cs := 170.0
		var gap := 18.0
		var step := cs + gap
		var cols := int(size.x / step) + 2
		var rows := int(size.y / step) + 2
		var ox := (size.x - (cols - 1) * step) / 2.0
		for r in range(rows):
			for c in range(cols):
				var cx := ox + c * step
				var cy := r * step - 30.0
				# tepa va past aniq, o'rtasi xira
				var t := clampf((absf(cy - size.y * 0.5) / (size.y * 0.5) - 0.30) / 0.50, 0.0, 1.0)
				t = t * t * (3.0 - 2.0 * t)
				sb.bg_color = Color(1.0, 1.0, 1.0, lerpf(0.03, 0.30, t))
				draw_style_box(sb, Rect2(cx - cs / 2.0, cy - cs / 2.0, cs, cs))


class GridIcon extends Control:
	var _sb := StyleBoxFlat.new()

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_sb.set_corner_radius_all(26)
		_sb.border_width_bottom = 8
		_sb.shadow_color = Color(0, 0, 0, 0.15)
		_sb.shadow_size = 10
		_sb.shadow_offset = Vector2(0, 6)

	func _draw() -> void:
		var s := minf(size.x * 0.36, size.y * 0.44)
		var gap := s * 0.14
		var total := s * 2.0 + gap
		var o := Vector2((size.x - total) / 2.0, (size.y - total) / 2.0 - 4.0)
		for k in range(4):
			var col: Color = Palette.REGIONS[k]
			_sb.bg_color = col
			_sb.border_color = col.darkened(0.14)
			var p := o + Vector2((k % 2) * (s + gap), (k / 2) * (s + gap))
			draw_style_box(_sb, Rect2(p, Vector2(s, s)))


class LockIcon extends Control:
	var col := Color("#B9ABA2")

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var u := minf(size.x, size.y)
		var c := size / 2.0
		var bw := u * 0.62
		var bh := u * 0.48
		var body := Rect2(c.x - bw / 2.0, c.y - bh / 2.0 + u * 0.12, bw, bh)
		var r := bw * 0.30
		draw_arc(Vector2(c.x, body.position.y), r, PI, TAU, 24, col, u * 0.11, true)
		draw_line(Vector2(c.x - r, body.position.y), Vector2(c.x - r, body.position.y + u * 0.06), col, u * 0.11)
		draw_line(Vector2(c.x + r, body.position.y), Vector2(c.x + r, body.position.y + u * 0.06), col, u * 0.11)
		var sb := StyleBoxFlat.new()
		sb.bg_color = col
		sb.set_corner_radius_all(int(u * 0.12))
		draw_style_box(sb, body)
		draw_circle(Vector2(c.x, body.position.y + bh * 0.5), u * 0.06, Color("#EFE7E1"))

