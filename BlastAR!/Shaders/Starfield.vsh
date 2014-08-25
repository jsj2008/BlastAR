attribute vec3 aPosition;

uniform mat4 uVP;

varying lowp vec4 vColor;

void main(){
    gl_Position  = uVP * vec4(aPosition, 1.0);
    gl_PointSize = 15.0 / gl_Position.w;
    
    vColor = vec4(1.0);
}