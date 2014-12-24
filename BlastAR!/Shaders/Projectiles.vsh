attribute highp vec3 aPosition;

uniform mat4 uVP;

void main(void){
    highp vec4 screenPos = uVP * vec4(aPosition, 1.0);
    gl_PointSize = 1000.0 / screenPos.w;
    gl_Position = screenPos;
}