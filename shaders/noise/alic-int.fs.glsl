#ifdef GL_ES
precision highp float;
#endif

varying vec2 vTexCoord1;

uniform sampler2D sampler1;
uniform sampler2D sampler2;

uniform sampler2D sampler3;

uniform float width;
uniform float height;
uniform float vWidth;
uniform float vHeight;
uniform float vmax;
uniform float lmax;
uniform float cxFlag;
uniform float maxDim;
uniform float sgn;

// Packing a [0-1] float value into a 4D vector where each component will be a 8-bits integer
vec4 packFloatToVec4i(const float value) {
   const vec4 bitSh = vec4(256.0 * 256.0 * 256.0, 256.0 * 256.0, 256.0, 1.0);
   const vec4 bitMsk = vec4(0.0, 1.0 / 256.0, 1.0 / 256.0, 1.0 / 256.0);
   vec4 res = fract(value * bitSh);
   res -= res.xxyz * bitMsk;
   return res;
}

// Unpacking a [0-1] float value from a 4D vector where each component was a 8-bits integer
float unpackFloatFromVec4i(const vec4 value){
   const vec4 bitSh = vec4(1.0 / (256.0 * 256.0 * 256.0), 1.0 / (256.0 * 256.0), 1.0 / 256.0, 1.0);
   return(dot(value, bitSh));
}

//4.3 Coordinate Integration
void main(void) {
  float rwv = (vWidth - 1.) / width;
  float rhv = (vHeight - 1.) / height;

  vec4 cxPacked = texture2D(sampler1, vTexCoord1);
  vec4 cyPacked = texture2D(sampler2, vTexCoord1);
  float cx = unpackFloatFromVec4i(cxPacked) * maxDim;
  float cy = unpackFloatFromVec4i(cyPacked) * maxDim;

  float val;
  vec2 coord = vec2( rwv * cx, rhv * cy );
  vec4 vPacked = texture2D(sampler3, coord);
  float v = (unpackFloatFromVec4i(vPacked) - .5) * maxDim;
  if (cxFlag == 1.0) {
    val = mod(cx + sgn * v + width, width);
  } else {
    val = mod(cy + sgn * v + height, height);
  }
  gl_FragColor = packFloatToVec4i(val / maxDim);
}