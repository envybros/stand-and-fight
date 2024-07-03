shader_type spatial;

uniform vec2 rooms = vec2(1, 1);
uniform float room_seed : hint_range(0.0, 999.0, 1.0) = 0.0;
uniform vec2 atlas_rooms = vec2(1, 1);
uniform float depth : hint_range(0.0, 1.0) = 0.5;
uniform float emission_cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float emission_strength : hint_range(0.0, 10.0) = 1.0;