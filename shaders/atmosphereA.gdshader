// experimental shader with the goal of realizing athmospheric effect

shader_type spatial;
render_mode unshaded;

varying vec3 local_position;
varying vec3 world_position;

void vertex() {
	local_position = VERTEX;
	
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}



bool _solveQuadratic(float a, float b, float c, out float x0, out float x1) {
	// see https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html
	// (code there is buggy)
	
	float discr = b*b - 4.0*a*c;
	if (discr < 0.0) {
		return false;
	}
	else {
		x0 = (-b + sqrt(discr)) / (2.0*a);
		x1 = (-b - sqrt(discr)) / (2.0*a);
		return true;
	}
}


bool _calcRaySphereIntersection(vec3 rayOrigin, vec3 rayDir, vec3 center, float r,  out float x0, out float x1) {
	// see https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html
	
	vec3 diff = rayOrigin - center;
	float a = dot(rayDir, rayDir);
	float b = 2.0 * dot(rayDir, diff);
	float c = dot(diff, diff) - r*r;
	return _solveQuadratic(a, b, c, x0, x1);
}

void fragment() {
	// (doesnt work)
	// compute coordinates in world coordinates
	//vec4 vertexInWorld = VIEW_MATRIX * vec4(VERTEX, 1.0);
	
	// (doesnt work)
	// from camera space to world space
	//vec4 VERTEX_WORLD = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	// from world space to object space
	//vec4 VERTEX_LOCAL = inverse(MODEL_MATRIX) * VERTEX_WORLD;
	
	
	
	
	
	// NORMAL
	// VERTEX : view point based local coordinates
	
	//ALBEDO = vec3(0.1, 0.3, 0.5);
	
	//vec4 a = MODEL_MATRIX * vec4(VERTEX, 1.0);
	
	ALBEDO = local_position.xyz * 0.3;
	
	vec3 camera_worldSpace = INV_VIEW_MATRIX[3].xyz; // see https://docs.godotengine.org/en/3.5/tutorials/shaders/shader_reference/spatial_shader.html    Camera's world space position. This is the equivalent to camera.global_transform.origin in GDScript.
	
	
	// Get camera position in World space coordinates
	//vec3 rayOrigin = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz; // doesnt work
	//vec3 rayOrigin = camera_worldSpace;
	vec3 rayOrigin = -CAMERA_POSITION_WORLD; // HACKY
	
	vec3 rayDir = normalize(world_position-rayOrigin); // DOESNT WORK!!!
	//vec3 rayDir = normalize((INV_VIEW_MATRIX * vec4(VIEW, 1.0)).xyz); // view vector from View space to world space // doesnt work!!!
	float ax0, ax1;
	bool isHitSphereA = _calcRaySphereIntersection(rayOrigin, rayDir, vec3(0.0,0.0,0.0), 0.48, ax0, ax1);
	
	
	float bx0, bx1;
	bool isHitSphereB = _calcRaySphereIntersection(rayOrigin, rayDir, vec3(0.0,0.0,0.0), 0.43, bx0, bx1);
	
	vec3 athmosphereBaseColor = vec3(0.08, 0.08, 0.99);
	
	if (isHitSphereA && isHitSphereB) { // case when the ground sphere was hit
		float athmoDepth = ax0 - bx0;
		
		ALBEDO = athmosphereBaseColor*athmoDepth*0.5;
		
		ALPHA = athmoDepth*1.5;
	}
	else if (isHitSphereA && !isHitSphereB) { // case when the inner sphere was not hit
		float athmoDepth = ax0 - ax1;
		ALBEDO = athmosphereBaseColor*athmoDepth*0.5;
		
		ALPHA = athmoDepth*1.5;
	}
	else {
		ALPHA = 0.0;
	}
	
	
	//ALBEDO = -CAMERA_POSITION_WORLD * 0.1; // DBG
}


// ISSUE: sphere should stay the same size independent on position of camera!

// godot3                  godot4
// CAMERA_MATRIX           INV_VIEW_MATRIX