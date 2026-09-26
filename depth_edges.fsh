#version 150

uniform sampler2D Main;
uniform sampler2D MainDepth;

in vec2 texCoord;
out vec4 fragColor;

const float EDGE_THRESHOLD = 0.002;
const float OUTLINE_ALPHA = 0.55;

float depthAt(vec2 uv) {
    return texture(MainDepth, uv).r;
}

void main() {
    vec2 texel = 1.0 / vec2(textureSize(Main, 0));
    float c = depthAt(texCoord);
    float l = depthAt(texCoord - vec2(texel.x, 0.0));
    float r = depthAt(texCoord + vec2(texel.x, 0.0));
    float u = depthAt(texCoord - vec2(0.0, texel.y));
    float d = depthAt(texCoord + vec2(0.0, texel.y));

    float edge = max(
        max(abs(c - l), abs(c - r)),
        max(abs(c - u), abs(c - d))
    );

    // Background depth is normally close to 1.0 in the depth buffer.
    float visible = 1.0 - step(0.99999, c);
    float mask = step(EDGE_THRESHOLD, edge) * visible;

    vec4 scene = texture(Main, texCoord);
    float alpha = mask * OUTLINE_ALPHA;
    fragColor = vec4(mix(scene.rgb, vec3(1.0), alpha), scene.a);
}
