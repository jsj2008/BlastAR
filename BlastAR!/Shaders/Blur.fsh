varying lowp vec2 vUV;

uniform sampler2D uTexture;

const highp float DELTA = 1.0 / 512.0;

void main(void){
    
    mediump vec4 avg = vec4(0.0);
    
    for(int i = 1; i >= -1; --i)
        for(int j = 1; j >= -1; --j){
            highp vec2 off = vec2(i, j) * DELTA;
            mediump vec4 color = texture2D(uTexture, vUV + off) * 1.125;
            avg += (color * color);
        }
    
    gl_FragColor = avg / 9.0;
    
    gl_FragColor += vec4(vUV, 0.0, 0.25);
}