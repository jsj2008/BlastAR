uniform lowp vec4 uColor;

varying highp float d;

void main(){
    mediump float alpha = clamp(1.0 - length(gl_PointCoord - vec2(0.5, 0.5)) * 2.0, 0.0, 1.0);
//    if(alpha == 0.5) discard;
    
   	lowp float aa = alpha * uColor.a;
    
    gl_FragColor = vec4(uColor.rgb * aa + vec3(alpha * alpha), aa);
}