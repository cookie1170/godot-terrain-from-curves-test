@tool
class_name Terrain
extends Path2D

#region exports
@export_group("Bake Settings")
## maximum number of subdivisions, higher number - more accuracy, less performance
@export var max_segments: int = 5
## the amount of degrees the baked curve can deviate from the real curve until it has to be subdivided,
## lower number - more accuracy, less performance
@export var tolerange_degrees: float = 1.0
@export_group("Base Polygon")
## the tint of the polygon, should be white if it has a texture unless desired otherwise
@export var polygon_modulate: Color = Color.WHITE:
	set(value):
		draw()
		polygon_modulate = value
## texture used for the polygon (can be left blank)
@export var polygon_texture: Texture2D:
	set(value):
		draw()
		polygon_texture = value
		polygon_texture.changed.connect(draw)
## should the polygon's texture be repeated
@export var polygon_texture_repeat: CanvasItem.TextureRepeat = CanvasItem.TEXTURE_REPEAT_ENABLED:
	set(value):
		draw()
		polygon_texture_repeat = value
## offset of the texture
@export var texture_offset: Vector2 = Vector2.ZERO:
	set(value):
		draw()
		texture_offset = value
## scale of the texture
@export var texture_scale: Vector2 = Vector2(1, 1):
	set(value):
		draw()
		texture_scale = value
## rotation of the texture (in degrees)
@export_range(0, 360, 0.1, "radians_as_degrees") var texture_rotation: float:
	set(value):
		draw()
		texture_rotation = value
@export_group("Outline")
## should an outline be drawn
@export var add_outline: bool = true:
	set(value):
		draw()
		add_outline = value
## width of the ouline
@export_range(0, 64, 0.5) var outline_width: float = 16.0:
	set(value):
		draw()
		outline_width = value
## the tint of the outline, should be white if it has a texture unless desired otherwise
@export var outline_modulate: Color = Color.BLACK:
	set(value):
		draw()
		outline_modulate = value
## the gradient across the outline, outline modulate is unused if this is set
@export var outline_gradient: Gradient:
	set(value):
		draw()
		outline_gradient = value
		outline_gradient.changed.connect(draw)
## texture used for the outline (can be left blank)
@export var outline_texture: Texture2D:
	set(value):
		draw()
		outline_texture = value
		outline_texture.changed.connect(draw)
## texture mode of the outline
@export var outline_texture_mode: Line2D.LineTextureMode = Line2D.LINE_TEXTURE_TILE:
	set(value):
		draw()
		outline_texture_mode = value
## the joint mode of the outline
@export var outline_joint_mode: Line2D.LineJointMode:
	set(value):
		draw()
		outline_joint_mode = value
## the cap mode of the outline
@export var outline_cap_mode: Line2D.LineCapMode:
	set(value):
		draw()
		outline_cap_mode = value
@export_group("Collision")
## should a collision polygon be created SHOULD BE CHILD OF A StaticBody2D FOR THE COLLISION TO WORK
@export var add_collision: bool = true:
	set(value):
		draw()
		add_collision = value
#endregion

#region misc variables
var terrain_parts: Array[Node]


func _ready() -> void:
	draw()
	if Engine.is_editor_hint():
		curve.changed.connect(draw)


func draw() -> void:
	for part: Node in terrain_parts:
		terrain_parts.erase(part)
		part.free()
	var baked_points: PackedVector2Array = curve.tessellate(max_segments, tolerange_degrees)
	draw_terrain_polygon(baked_points)
	if add_collision:
		create_collision_polygon(curve.tessellate(3, 4))
	if add_outline:
		draw_outline(baked_points)


func draw_terrain_polygon(points: PackedVector2Array) -> void:
	var polygon: Polygon2D = Polygon2D.new()
	add_child(polygon)
	polygon.color = polygon_modulate
	if polygon_texture:
		polygon.texture = polygon_texture
	polygon.polygon = points
	polygon.texture_offset = texture_offset
	polygon.texture_scale = texture_scale
	polygon.texture_rotation = texture_rotation
	polygon.texture_repeat = polygon_texture_repeat
	terrain_parts.append(polygon)


func create_collision_polygon(points: PackedVector2Array) -> void:
	await ready
	var polygon: CollisionPolygon2D = CollisionPolygon2D.new()
	get_parent().call_deferred("add_child", polygon)
	polygon.position = position
	terrain_parts.append(polygon)
	polygon.polygon = points
	polygon.hide()


func draw_outline(points: PackedVector2Array) -> void:
	var outline: Line2D = Line2D.new()
	terrain_parts.append(outline)
	add_child(outline)
	outline.default_color = outline_modulate
	if outline_texture:
		outline.texture = outline_texture
	if outline_gradient:
		outline.gradient = outline_gradient
	outline.texture_mode = outline_texture_mode
	outline.joint_mode = outline_joint_mode
	outline.end_cap_mode = outline_cap_mode
	outline.width = outline_width
	outline.points = points
