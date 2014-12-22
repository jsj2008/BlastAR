varying lowp vec2 vUV;

uniform sampler2D uTexture;

const highp float DELTA = 1.0 / 512.0;

void main(void){
    
    mediump vec4 avg;
    
    for(int i = 2; i >= -2; --i)
        for(int j = 2; j >= -2; --j){
            highp vec2 off = vec2(i, j) * DELTA;
            mediump vec4 color = texture2D(uTexture, vUV + off) * 1.25;
            avg += (color * color);
        }
    
    gl_FragColor = avg / 25.0;
    
    gl_FragColor += vec4(vUV, 0.0, 0.25);
}