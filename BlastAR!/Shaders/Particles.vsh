attribute vec3  aPosition;
attribute vec3  aVelocity;
attribute vec4  aColor;
attribute float aSize;
attribute float aBirth;
attribute float aLife;

uniform mat4  uVP;
uniform float uTime;

varying lowp vec4 vColor;
varying lowp float vP;

void main(){
    highp float dt = uTime - aBirth;
    highp float p = dt / aLife;
    vec4 worldPosition = vec4(aPosition + aVelocity * dt, 1.0);
    
    gl_Position = uVP * worldPosition;
    gl_PointSize = (aSize + (aSize * p)) / gl_Position.w;
    
    vColor = aColor * vec4(1.0, 1.0, 1.0, max(1.0 - p, 0.0));
    vP = p;
}