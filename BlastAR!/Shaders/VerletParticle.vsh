attribute vec3 aPosition;
attribute vec4 aColor;

uniform mat4 uVP;

varying lowp vec4 vColor;

void main(void){
    gl_Position = uVP * vec4(aPosition, 1.0);
    vColor = aColor;
}