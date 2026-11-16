class_name PaintArea
extends Sprite2D

signal press_brush
signal release_brush

@export var circle_texture: CompressedTexture2D
var circle_image: Image
@export var brush_color : Color
@export var brush_size : int
var can_paint : bool = true

var _image : Image

func _ready() -> void:
	circle_image = circle_texture.get_image()
	# define brush size
	change_brush_size(brush_size)

func _input(event: InputEvent) -> void:
	_draw_input(event)

func _draw_input(event: InputEvent) -> void:
	if !can_paint || brush_color.a == 0:
		release_brush.emit()
		return
	
	if event is not InputEventMouseMotion || event.button_mask != MOUSE_BUTTON_LEFT:
		release_brush.emit()
		return
	
	if event.relative.length_squared() <= 0:
		release_brush.emit()
		return
	
	var lpos: Vector2 = to_local(event.position)
	var impos: Vector2 = lpos - offset + get_rect().size / 2.0 - Vector2(brush_size, brush_size)
	if !get_rect().has_point(lpos - offset):
		return
	
	var num := ceili(event.relative.length())
	var target_pos = impos - (event.relative)
	
	for i in num:
		impos = impos.move_toward(target_pos, 1.0)
		filled_circle(_image, impos)
	
	texture.update(_image)
	press_brush.emit()

func calcul_color_pourcentage(color_target: Color) -> float:
	var texture_size: Vector2 = texture.get_size()
	var score: int = 0
	
	for y in range(0, texture_size.y):
		for x in range(0, texture_size.x):
			if color_target == _image.get_pixel(x, y):
				score += 1
	
	return score / (texture_size.x * texture_size.y)

func define_texture_mask(maskTexture: Texture2D) -> void:
	_image = Image.create_empty(int(maskTexture.get_size().x), int(maskTexture.get_size().y), false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(_image)
	material.set("shader_parameter/mask_texture", maskTexture) 

func change_mask_color(new_color: MaskColorAssets.mask_color) -> void:
	brush_color = MaskColorAssets.get_mask_color(new_color)
	
	if brush_color == MaskColorAssets.NONE_COLOR:
		return

	var pixel_color: Color
	for x in range(circle_image.get_width()):
		for y in range(circle_image.get_height()):
			pixel_color = circle_image.get_pixel(x, y)
			if pixel_color.a == 1:
				pixel_color = pixel_color.a * brush_color
				pixel_color.a = 1 # in case a color change the alpha
				circle_image.set_pixel(x, y, pixel_color)

func change_brush_size(new_brush_size: int) -> void:
	brush_size = new_brush_size
	circle_image.resize(brush_size * 2, brush_size * 2, Image.INTERPOLATE_NEAREST)

func filled_circle(image_screen: Image, pos: Vector2i)->void:
	image_screen.blend_rect(circle_image, circle_image.get_used_rect(), pos)
