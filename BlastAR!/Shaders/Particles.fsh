varying lowp vec4 vColor;
varying lowp float vP;

void main(){
    mediump float alpha = clamp(1.0 - length(gl_PointCoord - vec2(0.5, 0.5)) * 2.0, 0.0, 1.0) * (1.0 - vP);
    if(alpha <= 0.0) discard;
    
    lowp float aa = alpha * vColor.a;
    
    gl_FragColor = vec4(vColor.rgb * aa + vec3(alpha * alpha), aa);
}