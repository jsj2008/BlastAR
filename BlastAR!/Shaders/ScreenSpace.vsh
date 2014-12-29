attribute vec3 aPosition;

uniform lowp float uAspect;
uniform lowp vec3  uOffset;

void main(){
    gl_Position = vec4((aPosition + uOffset) * vec3(1.0, uAspect, 1.0), 1.0);
    gl_PointSize = 10.0;
}