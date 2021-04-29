using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "crt_post_process_profile_", menuName = "Post-Processing/CRT Profile")]
public class CRTProcessProfile : ScriptableObject
{
    public Shader shader;

    [Header("Colors Control")]
    [Range(-180, 180)]
    public float hue_shift;
    public float saturation;
    public float intensity;
    [Space]
    public float zoom = 2f;

    [Header("Lens Bend")]
    public float bend = 4f;
    public float middle_bend = 2.5f;
    [Space]
    [Header("Scan Line 1")]
    public float scanlineSize1 = 200;
    public float scanlineSpeed1 = -10;
    [Header("Scan Line 2")]
    public float scanlineSize2 = 20;
    public float scanlineSpeed2 = -3;
    [Space]
    public float scanlineAmount = 0.05f;
    [Space]
    [Header("Vignette")]
    public float vignetteSize = 1.9f;
    public float vignetteSmoothness = 0.6f;
    public float vignetteEdgeRound = 8f;
    [Space]
    [Header("Noise")]
    public float noiseSize = 75f;
    public float noiseAmount = 0.05f;

    [Space]
    [Header("Chromatic Abberation")]
    [Range(0f, 100f)]
    public float chromoIntensity = 15;
    public Vector2 redOffset;
    public Vector2 blueOffset;
    public Vector2 greenOffset;
}
