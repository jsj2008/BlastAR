attribute vec4 aPosition;
attribute vec2 aUV;

varying lowp vec2 vUV;

void main(){
    gl_Position = aPosition;
    vUV = aUV;
}