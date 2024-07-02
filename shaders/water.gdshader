shader_type spatial;

// albedo 변수 (추천: 00526e, 0079c3)
// albedo에 FRESNEL 효과를 주면, 물에 그래픽 효과 낼 수 있음
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform float alpha : hint_range(0.0, 1.0) = 0.95;

// 노멀맵 추가 (godot에서는 기본 지원하는 아이들이 있다)
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

// vertex 효과 내기 위한 변수들 (입체감)
uniform sampler2D wave;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

// World의 Scale에 영향받을 수 있도록 하는 가변 변수
varying float height;
varying vec3 world_pos;

// 노말맵 애니메이션을 위한 변수
uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;

// 수면 색과 물 아래 있는 메시의 거리에 따라 조정할 수 있는
// Depth Fade 관련 변수들
uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Depth 활용 Edge 감지
uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

// FRESNEL 효과 (albedo)
float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

// 가장자리 검출?
float edge(float depth) {
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}


void fragment() {
	// 노멀맵 계산 (웨이브 움직임)
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_direction2) * time_scale;
	
	// 노멀맵 블랜딩해서 하나로 합치기
	vec3 normal = texture(texture_normal, UV + time).rgb;
	vec3 normal2 = texture(texture_normal2, UV + time2).rgb;
	vec3 normal_blend = mix(normal, normal2, 0.5);
	
	// FRESNEL을 통한 albedo 값 계산
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);
	
	// 아래 로직으로 빛의 감쇠를 다루는 "비어의 법칙"을 적용할 수 있다.
    float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
    float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
    float depth_blend = exp((depth + VERTEX.z + depth_offset) * -beers_law);
    depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);    
    float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);

	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
	
	// edge depth 구하기
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	
	// depth 색상과 edge 색상을 혼합하여 mix 해주기
	vec3 depth_color_adj = mix(edge_color, color, step(edge_scale, z_dif));
	
	// 기본 색상들
	ALBEDO = clamp(surface_color + depth_color_adj, vec3(0.0), vec3(1.0));
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
	ALPHA = alpha;
}

void vertex() {
	// 메시의 각 버텍스에 대한 world_pos 설정
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// 노이즈 텍스처를 가져와서 각 버텍스의 위치에 r값 (0~1)을 가져온다.
	// 그 후, 높이 값에 height_scale을 곱하고 버텍스의 y값을 더해
	// 높이를 높이거나, 낮춘다.
	height = texture(wave, world_pos.xz / noise_scale + TIME * time_scale).r;
	VERTEX.y += height * height_scale;
}
