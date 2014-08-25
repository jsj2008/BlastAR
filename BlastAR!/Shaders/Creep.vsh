attribute vec3  aPosition;
attribute vec4  aColor;
attribute float aSize;

uniform mat4 uModel;
uniform mat4 uVP;
uniform float uScale;

varying lowp vec4 vColor;

void main(){
    vec4 worldPos = uModel * vec4(aPosition * uScale, 1.0);
    gl_Position = uVP * worldPos;
    gl_PointSize = aSize * 10.0 / gl_Position.w;
    
    mediump float dist = length(worldPos);
    vColor = aColor * clamp(1.0 - (dist / 15.0), 0.1, 1.0);
}