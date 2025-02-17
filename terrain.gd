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
## should an outline be drawn
@export var add_outline: bool = true
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


func draw() -> void:
	for i: int in terrain_parts.size():
		var part: Node = terrain_parts[i]
		part.queue_free()
		terrain_parts.remove_at(i)
	var baked_points: PackedVector2Array = curve.get_baked_points()
	print(baked_points)
	draw_terrain_polygon(baked_points)


func draw_terrain_polygon(points: PackedVector2Array) -> void:
	var polygon: Polygon2D = Polygon2D.new()
	terrain_parts.append(polygon)
	polygon.color = polygon_color
	if polygon_texture:
		polygon.texture = polygon_texture
	polygon.polygon = points
	add_child(polygon)
