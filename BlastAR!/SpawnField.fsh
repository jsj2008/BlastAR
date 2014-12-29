varying lowp vec2 vUV;

uniform lowp vec3 uForward;
uniform lowp vec3 uUp;
uniform lowp vec3 uLeft;
uniform lowp vec3 uSpawnDirection;

void main(void){
    lowp vec2 uvCentered = vUV - vec2(0.5);
    lowp vec3 dir = normalize(uForward + (uLeft * uvCentered.x + uUp * uvCentered.y));
    
    mediump float w = dot(dir, uSpawnDirection);
    
    if(w < 0.9){
        w = 0.0;
    }
    
    gl_FragColor = vec4((dir * 0.5 + vec3(0.5)) * w, 1.0);
}