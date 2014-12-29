#define M_E         2.71828182845904523536028747135266250   /* e              */
#define M_PI        3.14159265358979323846264338327950288   /* pi             */

varying lowp vec2 vUV;

uniform sampler2D uTexture;

const highp float DELTA = 1.0 / 512.0;
const highp float STD_DEV = 0.5;
const highp float STD_DEV_SQR = STD_DEV * STD_DEV;
const highp float GAUSS_COEFF = M_E / STD_DEV_SQR * sqrt(2.0 * M_PI);
const highp float TWO_STD_SQR = STD_DEV_SQR * 2.0;

void main(void){
    
    mediump vec4 avg = vec4(0.0);
    
    for(int j = 2; j >= -2; --j){
        highp float x = float(j) * DELTA;
        highp vec2 off = vec2(0, x);
        mediump vec4 color = texture2D(uTexture, vUV + off);
        
        avg += color * pow(GAUSS_COEFF, -(x * x / TWO_STD_SQR));
    }

    gl_FragColor = avg / 10.0;
}