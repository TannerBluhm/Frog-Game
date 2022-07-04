shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_refraction;
uniform float refraction : hint_range(-16,16);
uniform vec4 refraction_texture_channel;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform float time_multiplier = 1;
uniform float water_flow_offset = 3;

uniform float frequency = 1;
uniform float xAmplitude = 1;
uniform float zAmplitude = 1;

uniform bool stop = false;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
	if (!stop)  {
		VERTEX.y += sin(VERTEX.x + xAmplitude * TIME) * frequency + sin(VERTEX.z + zAmplitude * TIME) * frequency;
	}
}



void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
	float time_modifier = 0.0;
	if (!stop) {
		time_modifier = TIME * time_multiplier;
	}
	
	NORMALMAP = texture(texture_normal, vec2(base_uv.x + time_modifier, base_uv.y + time_modifier * water_flow_offset)).rgb * texture(texture_normal, vec2(base_uv.x + -time_modifier, base_uv.y + -time_modifier)).rgb;
	
	NORMALMAP_DEPTH = normal_scale;
	vec3 unpacked_normal = NORMALMAP;
	unpacked_normal.xy = unpacked_normal.xy * 2.0 - 1.0;
	unpacked_normal.z = sqrt(max(0.0, 1.0 - dot(unpacked_normal.xy, unpacked_normal.xy)));
	vec3 ref_normal = normalize( mix(NORMAL,TANGENT * unpacked_normal.x + BINORMAL * unpacked_normal.y + NORMAL * unpacked_normal.z,NORMALMAP_DEPTH) );
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * dot(texture(texture_refraction,base_uv),refraction_texture_channel) * refraction;
	float ref_amount = 1.0 - albedo.a * albedo_tex.a;
	EMISSION += textureLod(SCREEN_TEXTURE,ref_ofs,ROUGHNESS * 8.0).rgb * ref_amount;
	ALBEDO *= 1.0 - ref_amount;
	ALPHA = 1.0;
}
