## 
class_name HighlightFragment extends ParentFragment

signal add_highlight_mesh(MeshInstance3D)

var highlight_shader = load("res://inventory/highlightable_mesh_instance/highlight_shader.gdshader")
var mesh : MeshInstance3D
var highlight_mesh := MeshInstance3D.new()
var outline_material = ShaderMaterial.new()
var default_material

var is_highlighted : bool = false
	
func assimilate():
	fragment_tag = InventoryGridStatics.FragmentTags.HIGHLIGHT
	if mesh == null:
		return

	highlight_mesh = mesh.duplicate(true)
	highlight_mesh.mesh = mesh.mesh.duplicate(true)
	mesh.add_child(highlight_mesh)
	
	var highlight_material = mesh.get_active_material(0).duplicate(true)
	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = highlight_shader
	highlight_mesh.material_override = shader_mat

	highlight_mesh.visible = false
	highlight_mesh.scale = mesh.scale * 1.03
	
	emit_signal("add_highlight_mesh", highlight_mesh)
	
func highlight():
	
	if is_highlighted: return
	
	self.highlight_mesh.show()
	is_highlighted = true

func unhighlight():
	self.highlight_mesh.hide()
	is_highlighted = false
