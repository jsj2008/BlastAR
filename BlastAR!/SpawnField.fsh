varying lowp vec2 vUV;

uniform lowp vec3 uForward;
uniform lowp vec3 uUp;
uniform lowp vec3 uLeft;
uniform lowp vec3 uSpawnDirection;
uniform lowp vec3 uEatPizza;
uniform mediump float uField;
uniform mediump float uTime;

void main(void){
    lowp vec3 color = vec3(0.5, 0.0, 0.0);
    
    highp vec2 uvCentered = (vUV - vec2(0.5)) * vec2(1.0, 0.75);
    highp vec3 dir = normalize(uForward + (uLeft * uvCentered.x - uUp * uvCentered.y));
    lowp float dif = uField - acos(dot(dir, uSpawnDirection));
    mediump float w = clamp(dif, 0.0, 1.0);
    mediump float conccentric = pow(clamp(sin(dif * 100.0 + uTime * 4.0), 0.0, 1.0), 16.0);
    
    w = pow(w, 128.0);
    color += vec3(conccentric, 0.0, 0.0);
    
    gl_FragColor = vec4(color * w, color.r * w);
}