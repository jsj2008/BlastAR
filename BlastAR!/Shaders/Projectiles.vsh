attribute vec3 aPosition;

uniform mat4 uVP;

void main(void){
    gl_Position = uVP * vec4(aPosition, 1.0);
    gl_PointSize = 10.0 / gl_Position.w;
}