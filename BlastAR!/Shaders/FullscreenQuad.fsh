uniform sampler2D uTexture;
uniform lowp vec3 uHue;

varying lowp vec2 vUV;

void main(){
    lowp vec4 color = texture2D(uTexture, vUV);
    gl_FragColor = vec4(color.rgb * uHue, color.a); //vec4(vUV, 0.0, 0.0) +
}