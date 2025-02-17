@tool
class_name Terrain
extends Path2D

#region exports
## check to generate the polygon, can't use tool buttons because 4.3
@export var draw_terrain: bool = false:
	set(value):
		draw()
## should a collision polygon be created
@export var add_collision: bool = true
## should the collision polygon be visible (it looks ugly)
@export var visible_collision: bool = false
## should an outline be drawn
@export var add_outline: bool = true
## width of the ouline
@export_range(0, 64, 0.5) var outline_width: float
## color of the polygon
@export var polygon_color: Color = Color.WHITE
## color of the outline
@export var outline_color: Color = Color.BLACK
## texture used for the polygon (can be left blank)
@export var polygon_texture: Texture2D
## texture used for the outline (can be left blank)
@export var outline_texture: Texture2D
#endregion

#region misc variables
var terrain_parts: Array[Node]


func _ready() -> void:
	draw()


func draw() -> void:
	for part: Node in terrain_parts:
		print(part)
		part.queue_free()
		terrain_parts.erase(part)
	var baked_points: PackedVector2Array = curve.get_baked_points()
	draw_terrain_polygon(baked_points)
	if add_collision:
		create_collision_polygon(baked_points)
	if add_outline:
		draw_outline(baked_points)


func draw_terrain_polygon(points: PackedVector2Array) -> void:
	var polygon: Polygon2D = Polygon2D.new()
	add_child(polygon)
	polygon.color = polygon_color
	if polygon_texture:
		polygon.texture = polygon_texture
	polygon.polygon = points
	terrain_parts.append(polygon)
	print("Drawing terrain polygon")


func create_collision_polygon(points: PackedVector2Array) -> void:
	var polygon: CollisionPolygon2D = CollisionPolygon2D.new()
	add_child(polygon)
	terrain_parts.append(polygon)
	polygon.polygon = points
	polygon.visible = visible_collision
	print("Generating collision polygon")


func draw_outline(points: PackedVector2Array) -> void:
	var outline: Line2D = Line2D.new()
	terrain_parts.append(outline)
	add_child(outline)
	outline.default_color = outline_color
	if outline_texture:
		outline.texture = outline_texture
	outline.width = outline_width
	outline.points = points
	print("Drawing terrain outline")
