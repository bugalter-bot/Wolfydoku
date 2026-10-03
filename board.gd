extends Control
class_name Board
# Wolfy Doku - o'yin maydoni: chizish, tap'lar, animatsiya, ovoz.
# Signallar: wrong_placement (xato bo'ri), level_completed (level yechildi)

signal wrong_placement
signal level_completed
signal mark_placed   # X qo'yilganda (tebranish uchun)

const PALETTE := [
	Color("#fbdada"), Color("#d7e8fb"), Color("#dcf3d6"), Color("#fbf0c9"),
	Color("#e8dcf9"), Color("#fbe3cf"), Color("#d3f1ec"), Color("#f8dcec"), Color("#e6e6e6")
]
# Bo'ri tanasi uchun pastel ranglar (hudud rangidan mustaqil, aylanma tanlanadi)
var _wolf_tex: Texture2D = load("res://assets/wolf.png")

const CAT_COLORS := [
	Color("#f4a988"), Color("#c9b6e4"), Color("#a9c9e8"), Color("#f6cf7d"),
	Color("#9fd8c0"), Color("#f2a3b3"), Color("#c2c2c2"), Color("#e8b98f")
]
const DOUBLE_TAP_MS := 350
const LINE_DARK := Color("#3d3a4b")

var n := 0
var regions: Array = []   # regions[r][c] = hudud raqami
var solution: Array = []  # solution[r] = bo'ri ustuni
var state: Array = []     # 0 = bo'sh, 1 = X, 2 = bo'ri
var cats_placed := 0
var auto_x := true        # bo'ri qo'yilganda X'larni avtomatik qo'yish
var drag_mark := true     # barmoqni sirpantirganda X qo'yish (false = o'chirilgan)
var sound_on := true      # ovoz effektlari yoqilganmi
var locked := false

var _last_cell := Vector2i(-1, -1)
var _last_time := 0
var _pressing := false
var _drag_mode := -1   # 1 = faqat X chizish, 0 = faqat X o'chirish, -1 = hech narsa
var _last_drag := Vector2i(-1, -1)
var _pop := {}    # Vector2i -> 0..1 (bo'ri "bounce" animatsiyasi)
var _xpop := {}   # Vector2i -> 0..1 (X qo'yilganda "bounce")
var _sparks: Array = []  # bo'ri qo'yilganda uchadigan yulduzchalar
var _flash := {}  # Vector2i -> qolgan soniya (qizil chaqnash)
var _shake := 0.0 # ekran silkinishi (soniya)
var _time := 0.0  # umumiy vaqt (bo'rilarning yengil 'nafas olishi' uchun)

var _snd_mark: AudioStreamPlayer   # X qo'yish
var _snd_unmark: AudioStreamPlayer # X o'chirish
var _snd_pop: AudioStreamPlayer    # to'g'ri bo'ri
var _snd_wrong: AudioStreamPlayer  # xato bo'ri

const MAX_HISTORY := 30
var _history: Array = []  # undo uchun oldingi holatlar

# aqlli yordam (smart hint) uchun ko'rsatib turilgan taklif
var preview_cells: Array = []       # "exclude" turi uchun: X qo'yiladigan kataklar
var preview_target := Vector2i(-1, -1)  # "place" turi uchun: bo'ri qo'yiladigan katak
var preview_type := ""              # "exclude" | "place" | ""

# yumaloq katak chizish uchun (bitta stil qayta ishlatiladi)
var _cell_style := StyleBoxFlat.new()


func _ready() -> void:
	_snd_mark = _make_player("res://assets/sfx/mark.wav")
	_snd_unmark = _make_player("res://assets/sfx/unmark.wav")
	_snd_pop = _make_player("res://assets/sfx/pop.wav")
	_snd_wrong = _make_player("res://assets/sfx/wrong.wav")


func _make_player(path: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	add_child(p)
	return p


func _play(p: AudioStreamPlayer) -> void:
	if sound_on and p != null:
		p.play()


func load_level(level: Dictionary) -> void:
	n = int(level["size"])
	regions = []
	solution = []
	state = []
	for r in range(n):
		var reg_row := []
		var st_row := []
		for c in range(n):
			reg_row.append(int(level["regions"][r][c]))
			st_row.append(0)
		regions.append(reg_row)
		state.append(st_row)
		solution.append(int(level["solution"][r]))
	cats_placed = 0
	locked = false
	_last_cell = Vector2i(-1, -1)
	_pressing = false
	_drag_mode = -1
	_pop.clear()
	_xpop.clear()
	_sparks.clear()
	_flash.clear()
	_shake = 0.0
	_history.clear()
	queue_redraw()


# ---------------- UNDO / HINT ----------------
func _snapshot() -> Array:
	var copy := []
	for row in state:
		copy.append(row.duplicate())
	return copy


func _push_history() -> void:
	_history.append(_snapshot())
	if _history.size() > MAX_HISTORY:
		_history.pop_front()


func can_undo() -> bool:
	return not _history.is_empty()


func undo() -> bool:
	if _history.is_empty() or locked:
		return false
	state = _history.pop_back()
	cats_placed = 0
	for row in state:
		for v in row:
			if v == 2:
				cats_placed += 1
	queue_redraw()
	return true


func hint() -> bool:
	if locked:
		return false
	for r in range(n):
		var col: int = solution[r]
		if state[r][col] != 2:
			_push_history()
			state[r][col] = 2
			cats_placed += 1
			_pop[Vector2i(col, r)] = 0.0
			_burst(Vector2i(col, r))
			_play(_snd_pop)
			if auto_x:
				_auto_mark(r, col)
			queue_redraw()
			if cats_placed == n:
				locked = true
				level_completed.emit()
			return true
	return false


# ---------------- AQLLI YORDAM (smart hint: ko'rsatish + Apply) ----------------
func _related_cells(r: int, c: int) -> Array:
	var reg: int = regions[r][c]
	var out := []
	for rr in range(n):
		for cc in range(n):
			if rr == r and cc == c:
				continue
			var same_line := (rr == r or cc == c)
			var same_reg: bool = (int(regions[rr][cc]) == reg)
			var near := absi(rr - r) <= 1 and absi(cc - c) <= 1
			if (same_line or same_reg or near) and state[rr][cc] == 0:
				out.append(Vector2i(cc, rr))
	return out


func compute_smart_hint() -> Dictionary:
	if locked:
		return {"type": "none"}
	# 1) allaqachon qo'yilgan bo'ri atrofida hali X qo'yilmagan bo'sh katak bormi?
	for r in range(n):
		for c in range(n):
			if state[r][c] == 2:
				var cells := _related_cells(r, c)
				if cells.size() > 0:
					return {
						"type": "exclude", "cells": cells,
						"message": "Bu bo'rining qatori, ustuni, hududi va qo'shnilarida boshqa bo'ri bo'lmaydi — ularni chiqarib tashlang"
					}
	# 2) biror qator/ustun/hududda faqat bitta bo'sh (X qo'yilmagan) katak qoldimi?
	for r in range(n):
		if not state[r].has(2):
			var empties := []
			for c in range(n):
				if state[r][c] == 0:
					empties.append(Vector2i(c, r))
			if empties.size() == 1:
				return {"type": "place", "target": empties[0], "message": "Bu qatorda faqat bitta bo'sh katak qoldi — bo'ri shu yerga qo'yiladi"}
	for c in range(n):
		var has_cat := false
		var empties := []
		for r in range(n):
			if state[r][c] == 2:
				has_cat = true
				break
			if state[r][c] == 0:
				empties.append(Vector2i(c, r))
		if not has_cat and empties.size() == 1:
			return {"type": "place", "target": empties[0], "message": "Bu ustunda faqat bitta bo'sh katak qoldi — bo'ri shu yerga qo'yiladi"}
	for reg in range(n):
		var has_cat2 := false
		var empties2 := []
		for r in range(n):
			for c in range(n):
				if int(regions[r][c]) != reg:
					continue
				if state[r][c] == 2:
					has_cat2 = true
				elif state[r][c] == 0:
					empties2.append(Vector2i(c, r))
		if not has_cat2 and empties2.size() == 1:
			return {"type": "place", "target": empties2[0], "message": "Bu hududda faqat bitta bo'sh katak qoldi — bo'ri shu yerga qo'yiladi"}
	return {"type": "none"}


func show_preview(result: Dictionary) -> void:
	preview_type = String(result.get("type", ""))
	preview_cells = result.get("cells", [])
	preview_target = result.get("target", Vector2i(-1, -1))
	queue_redraw()


func cancel_preview() -> void:
	preview_type = ""
	preview_cells = []
	preview_target = Vector2i(-1, -1)
	queue_redraw()


func apply_preview() -> void:
	if preview_type == "exclude":
		_push_history()
		for cell in preview_cells:
			var cc: int = cell.x
			var rr: int = cell.y
			if state[rr][cc] == 0:
				state[rr][cc] = 1
		_play(_snd_mark)
	elif preview_type == "place":
		var cc2: int = preview_target.x
		var rr2: int = preview_target.y
		_push_history()
		state[rr2][cc2] = 2
		cats_placed += 1
		_pop[Vector2i(cc2, rr2)] = 0.0
		_burst(Vector2i(cc2, rr2))
		_play(_snd_pop)
		if auto_x:
			_auto_mark(rr2, cc2)
		if cats_placed == n:
			locked = true
			level_completed.emit()
	cancel_preview()


func _cell() -> float:
	if n <= 0:
		return 1.0
	return size.x / float(n)


func _process(delta: float) -> void:
	_time += delta
	var dirty := true  # bo'rilar doim ozgina 'nafas oladi', shuning uchun doim qayta chiziladi
	for k in _pop.keys():
		_pop[k] = minf(1.0, _pop[k] + delta / 0.35)
		if _pop[k] >= 1.0:
			_pop.erase(k)
		dirty = true
	for k in _xpop.keys():
		_xpop[k] = minf(1.0, _xpop[k] + delta / 0.28)
		if _xpop[k] >= 1.0:
			_xpop.erase(k)
	var i := _sparks.size() - 1
	while i >= 0:
		var sp: Dictionary = _sparks[i]
		sp["life"] = float(sp["life"]) - delta
		if float(sp["life"]) <= 0.0:
			_sparks.remove_at(i)
		else:
			var v: Vector2 = sp["v"]
			sp["p"] = Vector2(sp["p"]) + v * delta
			sp["v"] = v * 0.93 + Vector2(0, 260.0 * delta)
		i -= 1
	for k in _flash.keys():
		_flash[k] -= delta
		if _flash[k] <= 0.0:
			_flash.erase(k)
		dirty = true
	if _shake > 0.0:
		_shake = maxf(0.0, _shake - delta)
		dirty = true
	if dirty:
		queue_redraw()


# ---------------- KIRISH ----------------
func _gui_input(event: InputEvent) -> void:
	if locked or n == 0:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var cell := _cell_at(event.position)
			if cell.x < 0:
				return
			var before: int = state[cell.y][cell.x]
			_pressing = true
			_last_drag = cell
			_tap(cell.y, cell.x)
			# sirpantirish rejimi birinchi katakka qarab aniqlanadi:
			if before == 0:
				_drag_mode = 1      # bo'sh katakdan boshlandi -> faqat X chizadi
			elif before == 1 and _last_cell != Vector2i(-1, -1):
				_drag_mode = 0      # X li katakdan boshlandi -> faqat X o'chiradi
			else:
				_drag_mode = -1     # bo'ri / ikki tap -> sirpantirish ishlamaydi
		else:
			_pressing = false
			_drag_mode = -1
	elif event is InputEventMouseMotion and _pressing and drag_mark:
		var cell2 := _cell_at(event.position)
		if cell2.x < 0 or cell2 == _last_drag:
			return
		_last_drag = cell2
		var s: int = state[cell2.y][cell2.x]
		if _drag_mode == 1 and s == 0:
			state[cell2.y][cell2.x] = 1   # X chizish (X bor joy o'zgarmaydi)
			_xpop[cell2] = 0.0
			_play(_snd_mark)
			mark_placed.emit()
			queue_redraw()
		elif _drag_mode == 0 and s == 1:
			state[cell2.y][cell2.x] = 0   # X o'chirish (bo'sh joy o'zgarmaydi)
			_play(_snd_unmark)
			queue_redraw()


func _cell_at(pos: Vector2) -> Vector2i:
	var cs := _cell()
	if pos.x < 0.0 or pos.y < 0.0:
		return Vector2i(-1, -1)
	var col := int(pos.x / cs)
	var row := int(pos.y / cs)
	if row >= n or col >= n:
		return Vector2i(-1, -1)
	return Vector2i(col, row)


func _tap(row: int, col: int) -> void:
	var now := Time.get_ticks_msec()
	var key := Vector2i(col, row)
	var s: int = state[row][col]
	if s == 2:
		return  # to'g'ri qo'yilgan bo'rini o'zgartirib bo'lmaydi
	if s == 1 and key == _last_cell and now - _last_time <= DOUBLE_TAP_MS:
		_last_cell = Vector2i(-1, -1)
		_push_history()
		_try_cat(row, col)  # ikki tap = bo'ri
		return
	# bir tap: X qo'yish yoki olib tashlash
	_push_history()
	var placing_x := (s == 0)
	state[row][col] = 1 if placing_x else 0
	if placing_x:
		_xpop[key] = 0.0
		_play(_snd_mark)
		mark_placed.emit()
	else:
		_play(_snd_unmark)
	_last_cell = key
	_last_time = now
	queue_redraw()


func _try_cat(row: int, col: int) -> void:
	var key := Vector2i(col, row)
	if int(solution[row]) == col:
		state[row][col] = 2
		cats_placed += 1
		_pop[key] = 0.0
		_burst(key)
		_play(_snd_pop)
		if auto_x:
			_auto_mark(row, col)
		queue_redraw()
		if cats_placed == n:
			locked = true
			level_completed.emit()
	else:
		state[row][col] = 0
		_flash[key] = 0.5
		_shake = 0.3
		_play(_snd_wrong)
		queue_redraw()
		wrong_placement.emit()


func _auto_mark(row: int, col: int) -> void:
	var reg: int = regions[row][col]
	for r in range(n):
		for c in range(n):
			if state[r][c] != 0:
				continue
			var same_line := (r == row or c == col)
			var same_reg: bool = (int(regions[r][c]) == reg)
			var near := absi(r - row) <= 1 and absi(c - col) <= 1
			if same_line or same_reg or near:
				state[r][c] = 1


# ---------------- CHIZISH ----------------
func _draw_cell_box(rect: Rect2, color: Color, radius: float) -> void:
	_cell_style.bg_color = color
	_cell_style.set_corner_radius_all(int(radius))
	_cell_style.anti_aliasing = true
	draw_style_box(_cell_style, rect)


func _draw() -> void:
	if n == 0:
		return
	var cs := _cell()
	var gap := cs * 0.035
	var radius := cs * 0.17
	var off := Vector2.ZERO
	if _shake > 0.0:
		off.x = sin(_shake * 90.0) * 14.0 * (_shake / 0.3)
	draw_set_transform(off)

	for r in range(n):
		for c in range(n):
			var rect := Rect2(c * cs + gap, r * cs + gap, cs - gap * 2.0, cs - gap * 2.0)
			var base: Color = Palette.REGIONS[int(regions[r][c]) % Palette.REGIONS.size()]
			_draw_cell_box(rect, base, radius)
			var key := Vector2i(c, r)
			if _flash.has(key):
				_draw_cell_box(rect, Color(1, 0.1, 0.1, clampf(_flash[key] / 0.5, 0.0, 1.0) * 0.7), radius)
			if preview_type == "exclude" and preview_cells.has(key):
				var pulse := 0.35 + 0.25 * sin(_time * 6.0)
				_draw_cell_box(rect, Color(1.0, 1.0, 1.0, pulse), radius)
			if preview_type == "place" and preview_target == key:
				var pulse2 := 0.35 + 0.3 * sin(_time * 6.0)
				_draw_cell_box(rect, Color(1.0, 1.0, 1.0, pulse2), radius)

	# X va bo'rilar
	for r in range(n):
		for c in range(n):
			var center := Vector2((c + 0.5) * cs, (r + 0.5) * cs)
			var st: int = state[r][c]
			if st == 1:
				var xs := 1.0
				var xkey := Vector2i(c, r)
				if _xpop.has(xkey):
					xs = _ease_out_back(_xpop[xkey])
				_draw_x(center, cs * 0.17 * xs)
			elif st == 2:
				var s := 1.0
				var key2 := Vector2i(c, r)
				var bob := 0.0
				if _pop.has(key2):
					s = _ease_out_back(_pop[key2])
				else:
					# tinch turganda bo'ri yengil "nafas oladi" (yashash hissi)
					bob = sin(_time * 2.2 + r * 1.7 + c * 0.9) * cs * 0.015
				var cat_color: Color = CAT_COLORS[(r * 7 + c * 3) % CAT_COLORS.size()]
				_draw_cat(center + Vector2(0, bob), cs * 0.34 * s, cat_color)

	for sp in _sparks:
		var a: float = clampf(float(sp["life"]) / float(sp["max"]), 0.0, 1.0)
		var col: Color = sp["col"]
		col.a = a
		var sz: float = float(sp["size"]) * (0.4 + 0.6 * a)
		var pos: Vector2 = sp["p"]
		draw_circle(pos, sz, col)
		draw_line(pos - Vector2(sz * 1.8, 0), pos + Vector2(sz * 1.8, 0), col, maxf(1.5, sz * 0.35))
		draw_line(pos - Vector2(0, sz * 1.8), pos + Vector2(0, sz * 1.8), col, maxf(1.5, sz * 0.35))

	draw_set_transform(Vector2.ZERO)


func _burst(key: Vector2i) -> void:
	var cs := _cell()
	var center := Vector2((key.x + 0.5) * cs, (key.y + 0.5) * cs)
	var cols := [Color("#ffffff"), Color("#ffe27a"), Color("#ff9ec4"), Color("#9fe7d4")]
	for k in range(14):
		var ang := randf() * TAU
		var spd := randf_range(0.6, 1.5) * cs * 1.5
		var life := randf_range(0.5, 0.85)
		_sparks.append({
			"p": center,
			"v": Vector2(cos(ang), sin(ang)) * spd,
			"life": life,
			"max": life,
			"size": cs * randf_range(0.03, 0.06),
			"col": cols[k % cols.size()]})


func _ease_out_back(t: float) -> float:
	var u := t - 1.0
	return 1.0 + 2.70158 * u * u * u + 1.70158 * u * u


func _draw_x(c: Vector2, r: float) -> void:
	var w := maxf(5.0, r * 0.55)
	var layers := [[Color(0, 0, 0, 0.12), Vector2(0, w * 0.18)], [Color(1, 1, 1, 0.95), Vector2.ZERO]]
	for l in layers:
		var o: Vector2 = c + l[1]
		var col: Color = l[0]
		for d in [Vector2(r, r), Vector2(r, -r)]:
			draw_line(o - d, o + d, col, w, true)
			draw_circle(o - d, w * 0.5, col)
			draw_circle(o + d, w * 0.5, col)


func _draw_cat(c: Vector2, r: float, body: Color = Color("#f4a988")) -> void:
	# Bo'ri bolasi rasmi (assets/wolf.png). Rasm topilmasa, kod bilan chiziladi.
	if r <= 0.5:
		return
	if _wolf_tex != null:
		draw_circle(c + Vector2(0, r * 0.25), r * 0.95, Color(0, 0, 0, 0.10))
		var ws := r * 2.5
		draw_texture_rect(_wolf_tex, Rect2(c - Vector2(ws, ws) * 0.5, Vector2(ws, ws)), false)
		return
	_draw_cat_vector(c, r, body)


func _draw_cat_vector(c: Vector2, r: float, body: Color) -> void:
	var dark := body.darkened(0.22)
	var ear_in := body.darkened(0.12).lerp(Color("#ffd7dd"), 0.45)
	var cream := Color("#fff4e8")
	var ink := Color("#3d3a4b")
	# quloqlar: baland, uchli
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-r * 0.98, -r * 0.05), c + Vector2(-r * 0.78, -r * 1.42), c + Vector2(-r * 0.15, -r * 0.82)]), body)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(r * 0.98, -r * 0.05), c + Vector2(r * 0.15, -r * 0.82), c + Vector2(r * 0.78, -r * 1.42)]), body)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-r * 0.76, -r * 0.3), c + Vector2(-r * 0.7, -r * 1.05), c + Vector2(-r * 0.36, -r * 0.74)]), ear_in)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(r * 0.76, -r * 0.3), c + Vector2(r * 0.36, -r * 0.74), c + Vector2(r * 0.7, -r * 1.05)]), ear_in)
	# quloq uchlari (to'q)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-r * 0.83, -r * 1.06), c + Vector2(-r * 0.78, -r * 1.42), c + Vector2(-r * 0.56, -r * 1.12)]), dark)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(r * 0.83, -r * 1.06), c + Vector2(r * 0.56, -r * 1.12), c + Vector2(r * 0.78, -r * 1.42)]), dark)
	# yonoqdagi yung "tutam"lar
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-r * 0.98, r * 0.15), c + Vector2(-r * 1.2, r * 0.62), c + Vector2(-r * 0.6, r * 0.78)]), body)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(r * 0.98, r * 0.15), c + Vector2(r * 0.6, r * 0.78), c + Vector2(r * 1.2, r * 0.62)]), body)
	# bosh
	draw_circle(c, r, body)
	draw_circle(c + Vector2(-r * 0.2, -r * 0.4), r * 0.36, body.lightened(0.12))
	# peshona belgisi
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -r * 0.92), c + Vector2(-r * 0.12, -r * 0.6), c + Vector2(r * 0.12, -r * 0.6)]), dark)
	# tumshuq (och rangli)
	draw_circle(c + Vector2(-r * 0.2, r * 0.4), r * 0.3, cream)
	draw_circle(c + Vector2(r * 0.2, r * 0.4), r * 0.3, cream)
	draw_circle(c + Vector2(0, r * 0.3), r * 0.34, cream)
	# yonoq (blush)
	draw_circle(c + Vector2(-r * 0.66, r * 0.22), r * 0.14, Color(1, 0.7, 0.72, 0.45))
	draw_circle(c + Vector2(r * 0.66, r * 0.22), r * 0.14, Color(1, 0.7, 0.72, 0.45))
	# ko'zlar
	var eye_white := Color(1, 1, 1, 0.95)
	draw_circle(c + Vector2(-r * 0.4, -r * 0.1), r * 0.2, eye_white)
	draw_circle(c + Vector2(r * 0.4, -r * 0.1), r * 0.2, eye_white)
	draw_circle(c + Vector2(-r * 0.4, -r * 0.05), r * 0.12, ink)
	draw_circle(c + Vector2(r * 0.4, -r * 0.05), r * 0.12, ink)
	draw_circle(c + Vector2(-r * 0.36, -r * 0.1), r * 0.04, Color(1, 1, 1))
	draw_circle(c + Vector2(r * 0.44, -r * 0.1), r * 0.04, Color(1, 1, 1))
	# burun va og'iz
	draw_circle(c + Vector2(0, r * 0.2), r * 0.13, ink)
	var lw := maxf(1.5, r * 0.05)
	draw_line(c + Vector2(0, r * 0.3), c + Vector2(0, r * 0.4), ink, lw)
	draw_arc(c + Vector2(-r * 0.1, r * 0.4), r * 0.1, 0.0, PI * 0.8, 8, ink, lw, true)
	draw_arc(c + Vector2(r * 0.1, r * 0.4), r * 0.1, PI * 0.2, PI, 8, ink, lw, true)
