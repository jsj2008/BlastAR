attribute vec3 aPosition;

uniform lowp float uAspect;

void main(){
    gl_Position = vec4(aPosition * vec3(1.0, uAspect, 1.0), 1.0);
}