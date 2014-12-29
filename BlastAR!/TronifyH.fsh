uniform sampler2D uTexture;
uniform lowp vec3 uHue;

varying lowp vec2 vUV;

const highp float DELTA = 1.0 / 512.0;

void main(){
    lowp vec4 color = texture2D(uTexture, vUV);
    mediump float delta = 0.0;
    
    color.rgb *= uHue;
    
    for(int i = 1; i >= -1; --i){
        if(i != 0) continue;
        highp vec2 off = vec2(i, 0) * DELTA;
        mediump vec3 dif = (color.rgb - (texture2D(uTexture, vUV + off)).rgb);
        delta += dot(dif, dif);
    }
    
    
    lowp vec3 orange = vec3(0.0, 0.0, 0.3);
    lowp vec3 green  = vec3(0.0, 1.0, 0.0);
    
    lowp vec3 interp = (1.0 - delta) * orange + delta * green;
    
    gl_FragColor = vec4(interp / 2.0, 1.0);
    
    //    gl_FragColor = vec4(highpass, color.a); //vec4(vUV, 0.0, 0.0) +
}