shader_type spatial;

// albedo 변수 (추천: 00526e)
uniform vec3 albedo : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

// 노멀맵 추가 (godot에서는 기본 지원하는 아이들이 있다)
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

// 노말맵 애니메이션을 위한 변수
uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;


void fragment() {
	// 노멀맵 계산 (웨이브 움직임)
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_direction2) * time_scale;
	
	// 노멀맵 블랜딩해서 하나로 합치기
	vec3 normal = texture(texture_normal, UV + time).rgb;
	vec3 normal2 = texture(texture_normal2, UV + time2).rgb;
	vec3 normal_blend = mix(normal, normal2, 0.5);
	
	
	// 기본 색상들
	ALBEDO = albedo;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}